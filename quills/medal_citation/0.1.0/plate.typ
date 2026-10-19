#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-medal-citation:0.1.0": afam, afcm, msm, ordinal-suffix

#let trim(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

#let ink-value(v) = {
  let trimmed = trim(v)
  if trimmed == none or trimmed == "" or trimmed == [] { [] } else { trimmed }
}

#let ink(key) = ink-value(qm.data.at(key))

#let period-pattern = "[day padding:none] [month repr:long] [year]"
#let shown-date(key) = {
  let shown = qm.ink(qm.data, key, period-pattern)
  if shown == none { [] } else { upper(shown) }
}

#let choice(key) = {
  let field = qm.data.at(key)
  let value = if type(field) == str { field } else { field.value }
  if value == none { "" } else { value }
}

#let medal-field = qm.data.medal
#let medal = if type(medal-field) == str { medal-field } else { medal-field.value }

#let signing-field(width, height) = qm.signature-field(
  "Signature",
  field: "commander_title",
  width: width,
  height: height,
)

#let common = (
  oak_leaf_cluster: choice("oak_leaf_cluster"),
  rank: ink("rank"),
  service: ink("service"),
  period_from: shown-date("period_from"),
  period_to: shown-date("period_to"),
  accomplishments: ink("accomplishments"),
  commander_title: ink("commander_title"),
  signing_field: signing-field,
)

#let afam-given() = {
  let key = "medal.afam_signed_on"
  let day = qm.ink(qm.data, key, "[day padding:none]")
  [GIVEN UNDER MY HAND THIS #h(12pt)]
  if day != none {
    let signed = medal-field.afam_signed_on
    [#day#ordinal-suffix(signed.day()) #h(12pt) DAY OF #h(12pt)]
    upper(qm.ink(qm.data, key, "[month repr:long] [year]"))
  }
}

#if medal == "Air and Space Achievement Medal" {
  afam((
    ..common,
    given: afam-given(),
    commander_name: ink-value(medal-field.commander_name),
  ))
} else if medal == "Meritorious Service Medal" {
  msm((
    ..common,
    signed_on: shown-date("medal.signed_on"),
    commander_name: ink-value(medal-field.msm_commander_name),
    commander_grade: ink-value(medal-field.commander_grade),
  ))
} else if medal == "Air and Space Commendation Medal" {
  afcm((
    ..common,
    signed_on: shown-date("medal.signed_on"),
    commander_name: ink-value(medal-field.commander_name),
  ))
}
