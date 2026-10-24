#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usaf-paper:0.1.0": date-pattern as paper-date-pattern, paper

#let body-font-size = qm.data.font_size * 1pt

// A blank date is filled in on the PDF. The slot is about as wide as
// "30 Sep 26" and sits on the line, so the identification line does not grow
// taller than a printed date.
#let paper-date-slot-width = body-font-size * 6.5
#let paper-date-slot = context box(
  width: paper-date-slot-width,
  height: measure[0].height,
  place(horizon + left, qm.form-field(
    "Date",
    type: "text",
    width: paper-date-slot-width,
    height: body-font-size,
    field: "date",
    font: "times",
    size: body-font-size,
    align: "left",
  )),
)

#let filled(v) = v != none and v != "" and v != []

#let authored-date = qm.ink(qm.data, "date", paper-date-pattern)
#let any-id = (
  qm.data.originator,
  qm.data.organization,
  qm.data.office_symbol,
  qm.data.phone,
  qm.data.typist,
).any(filled)
#let date-ink = if authored-date != none {
  authored-date
} else if any-id {
  paper-date-slot
} else {
  none
}

#show: paper.with(
  document-title: upper(qm.data.title),
  subject: qm.data.subject,
  originator: qm.data.originator,
  organization: qm.data.organization,
  office-symbol: qm.data.office_symbol,
  phone: qm.data.phone,
  typist: qm.data.typist,
  date: date-ink,
  font-size: body-font-size,
  classification-level: qm.data.classification.value,
  dissemination: qm.data.dissemination,
  ..if qm.data.classification.value == "CUI" {
    (
      cui-controlled-by: qm.data.classification.controlled_by,
      cui-category: qm.data.classification.category,
      cui-limited-dissemination: qm.data.classification.limited_dissemination,
      cui-poc: qm.data.classification.poc,
    )
  },
)

#qm.data.at("$body")
