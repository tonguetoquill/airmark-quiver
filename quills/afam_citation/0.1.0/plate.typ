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

#let period-pattern = "[day padding:none] [month repr:long] [year]"
#let shown-date(key) = {
  let shown = display(key, period-pattern)
  if shown == none { [] } else { upper(shown) }
}

#citation((
  rank: ink("rank"),
  service: ink("service"),
  period_from: shown-date("period_from"),
  period_to: shown-date("period_to"),
  accomplishments: ink("accomplishments"),
  signed_on: data.at("signed_on"),
  commander_name: ink("commander_name"),
  commander_title: ink("commander_title"),
))
