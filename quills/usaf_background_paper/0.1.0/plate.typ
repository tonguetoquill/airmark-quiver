#import "@local/quillmark-helper:0.1.0": data, display, form-field
#import "@local/tonguetoquill-usaf-background-paper:0.1.0": date-pattern, paper

#let body-font-size = data.font_size * 1pt

// A blank date is filled in on the PDF. The slot is about as wide as
// "30 Sep 26" and sits on the line, so the identification line does not grow
// taller than a printed date.
#let date-slot-width = body-font-size * 6.5
#let date-slot = context box(
  width: date-slot-width,
  height: measure[0].height,
  place(horizon + left, form-field(
    "Date",
    type: "text",
    width: date-slot-width,
    height: body-font-size,
    field: "date",
    font: "times",
    size: body-font-size,
    align: "left",
  )),
)

#let filled(v) = v != none and v != "" and v != []

#let authored-date = display("date", date-pattern)
#let any-id = (
  data.originator, data.organization, data.office_symbol, data.phone, data.typist,
).any(filled)
#let date-ink = if authored-date != none {
  authored-date
} else if any-id {
  date-slot
} else {
  none
}

#show: paper.with(
  document-title: [BACKGROUND PAPER],
  narrative: true,
  subject: data.subject,
  originator: data.originator,
  organization: data.organization,
  office-symbol: data.office_symbol,
  phone: data.phone,
  typist: data.typist,
  date: date-ink,
  font-size: body-font-size,

  classification-level: data.classification.value,
  dissemination: data.dissemination,

  ..if data.classification.value == "CUI" {
    (
      cui-controlled-by: data.classification.controlled_by,
      cui-category: data.classification.category,
      cui-limited-dissemination: data.classification.limited_dissemination,
      cui-poc: data.classification.poc,
    )
  },
)

#if data.at("$body") != "" {
  data.at("$body")
}
