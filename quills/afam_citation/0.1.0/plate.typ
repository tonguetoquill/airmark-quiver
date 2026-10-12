#import "@local/quillmark-helper:0.1.0": data, display
#import "@local/tonguetoquill-afam-citation:0.1.0": citation

#let trim(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

#let ink(key) = {
  let v = trim(data.at(key))
  if v == none or v == "" or v == [] { [] } else { v }
}

// The accomplishments paragraph is 1350 characters. A space counts.
#let counted(c) = {
  c == [ ] or c.func() == linebreak or c.func() == parbreak or c.func() == smartquote
}

#let char-count(c) = {
  if type(c) == str { return c.clusters().len() }
  if type(c) != content { return 0 }
  if counted(c) { return 1 }
  if c.has("text") and type(c.at("text")) == str { return c.text.clusters().len() }
  if c.has("children") { return c.children.map(char-count).sum(default: 0) }
  if c.has("body") { return char-count(c.body) }
  if c.has("child") { return char-count(c.child) }
  0
}

// Returns (kept content or none, characters still available).
#let take-chars(c, left) = {
  if left <= 0 { return (none, 0) }
  if type(c) == str {
    let clusters = c.clusters()
    if clusters.len() <= left { return (c, left - clusters.len()) }
    return (clusters.slice(0, left).join(), 0)
  }
  if type(c) != content { return (c, left) }
  if counted(c) { return (c, left - 1) }
  if c.has("text") and type(c.at("text")) == str {
    let clusters = c.text.clusters()
    if clusters.len() <= left { return (c, left - clusters.len()) }
    let kept = clusters.slice(0, left).join()
    let fields = c.fields()
    fields.remove("text")
    let out = if fields.len() == 0 { text(kept) } else { text(..fields, kept) }
    return (out, 0)
  }
  if c.has("children") {
    let kept = ()
    let rest = left
    for k in c.children {
      if rest <= 0 { break }
      let (piece, next) = take-chars(k, rest)
      rest = next
      if piece != none { kept.push(piece) }
    }
    if kept.len() == 0 { return (none, rest) }
    let out = if c.fields().keys() == ("children",) {
      kept.sum(default: [])
    } else {
      let fields = c.fields()
      fields.remove("children")
      c.func()(..fields, children: kept)
    }
    return (out, rest)
  }
  if c.has("body") {
    let (piece, rest) = take-chars(c.body, left)
    if piece == none { return (none, rest) }
    let fields = c.fields()
    fields.remove("body")
    let out = if fields.len() == 0 { c.func()(piece) } else { c.func()(..fields, piece) }
    return (out, rest)
  }
  if c.has("child") {
    let (piece, rest) = take-chars(c.child, left)
    if piece == none { return (none, rest) }
    let fields = c.fields()
    fields.remove("child")
    let out = if fields.len() == 0 { c.func()(piece) } else { c.func()(..fields, piece) }
    return (out, rest)
  }
  (c, left)
}

#let capped(body, limit) = {
  if type(body) != content { return body }
  if char-count(body) <= limit { return body }
  let (out, _) = take-chars(body, limit)
  if out == none { [] } else { out }
}

#let period-pattern = "[day padding:none] [month repr:long] [year]"
#let shown-date(key) = {
  let shown = display(key, period-pattern)
  if shown == none { [] } else { upper(shown) }
}

#let choice(key) = {
  let field = data.at(key)
  let value = if type(field) == str { field } else { field.value }
  if value == none { "" } else { value }
}

#citation((
  oak_leaf_cluster: choice("oak_leaf_cluster"),
  rank: ink("rank"),
  service: ink("service"),
  period_from: shown-date("period_from"),
  period_to: shown-date("period_to"),
  accomplishments: capped(ink("accomplishments"), 1350),
  signed_on: data.at("signed_on"),
  commander_name: ink("commander_name"),
  commander_title: ink("commander_title"),
))
