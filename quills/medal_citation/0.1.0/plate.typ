#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-medal-citation:0.1.0": afam, afcm, msm

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

#let date-pattern = "[day padding:none] [month repr:long] [year]"
#let shown-date(key) = {
  let shown = qm.ink(qm.data, key, date-pattern)
  if shown == none { [] } else { upper(shown) }
}

#let short-date(key) = {
  let shown = qm.ink(qm.data, key, "[day padding:none] [month repr:short] [year]")
  if shown == none { [] } else { upper(shown) }
}

#let choice(key) = {
  let field = qm.data.at(key)
  let value = if type(field) == str { field } else { field.value }
  if value == none { "" } else { value }
}

#let medal = choice("medal")

#let cluster-line(n) = {
  if n == none or n <= 0 { return "" }
  let words = ("FIRST", "SECOND", "THIRD", "FOURTH", "FIFTH", "SIXTH", "SEVENTH", "EIGHTH", "NINTH", "TENTH")
  let suffix = if calc.rem(n, 100) in (11, 12, 13) { "TH" } else {
    ("TH", "ST", "ND", "RD", "TH", "TH", "TH", "TH", "TH", "TH").at(calc.rem(n, 10))
  }
  words.at(n - 1, default: str(n) + suffix) + " OAK LEAF CLUSTER"
}

#let signing-field(width, height) = qm.signature-field(
  "Signature",
  field: "signer_title",
  width: width,
  height: height,
)

#let common = (
  oak_leaf_cluster: cluster-line(qm.data.oak_leaf_cluster),
  recipient: ink("recipient"),
  reason: ink("reason"),
  period_from: shown-date("period_from"),
  period_to: shown-date("period_to"),
  accomplishments: ink("accomplishments"),
  signed_on: shown-date("signed_on"),
  signer_name: ink("signer_name"),
  signer_grade: ink("signer_grade"),
  signer_title: ink("signer_title"),
  signing_field: signing-field,
  footer: (
    ("Special Order", ink("special_order")),
    ("Condition", ink("condition")),
    ("PAS", ink("pas")),
    ("RDP", short-date("rdp")),
  ),
)

#if medal == "Air and Space Achievement Medal" {
  afam(common)
} else if medal == "Meritorious Service Medal" {
  msm(common)
} else if medal == "Air and Space Commendation Medal" {
  afcm(common)
}
