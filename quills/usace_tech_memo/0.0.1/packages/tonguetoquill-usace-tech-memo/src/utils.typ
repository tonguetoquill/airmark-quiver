#import "config.typ": *

#let falsey(v) = (
  v == none
    or v == false
    or (type(v) == array and v.len() == 0)
    or (type(v) == str and v.trim() == "")
    or v == []
)

#let trim-inline(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak or c == linebreak()
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

#let plain-text(it) = {
  if type(it) == str { return it }
  if type(it) != content { return "" }
  if it.func() in ([ ].func(), linebreak, parbreak) { return " " }
  if it.has("text") { return plain-text(it.text) }
  if it.has("children") { return it.children.map(plain-text).join(default: "") }
  if it.has("body") { return plain-text(it.body) }
  if it.has("child") { return plain-text(it.child) }
  ""
}

#let blank(v) = falsey(v) or plain-text(v).trim() == ""

#let ensure-array(v) = {
  if v == none { () } else if type(v) == array { v } else { (v,) }
}

#let join-inline(value, sep: ", ") = {
  if value == none { return [] }
  let items = ensure-array(value).map(trim-inline).filter(item => not blank(item))
  let joined = items.map(item => [#item]).join(sep)
  if joined == none { [] } else { joined }
}

#let date-pattern = "[day padding:none] [month repr:long] [year]"
#let table-date-pattern = "[month repr:numerical padding:zero]/[day padding:zero]/[year]"

#let format-date(d, pattern: date-pattern) = {
  if d == none or d == [] or d == "" {
    none
  } else if type(d) == datetime {
    d.display(pattern)
  } else {
    d
  }
}

#let distribution-text(value) = {
  if blank(value) { return [] }
  let key = if type(value) == str { value } else { plain-text(value).trim() }
  let full = DISTRIBUTION_STATEMENTS.at(key, default: none)
  if full != none { full } else { value }
}

#let heading-name(it) = lower(plain-text(it.body).trim())
