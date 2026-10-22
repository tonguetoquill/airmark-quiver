#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-army-memo:0.1.0": backmatter, date-pattern, frontmatter, mainmatter, render-task

#let addressing = qm.data.addressing
#let letterhead = qm.data.letterhead
#let additional = qm.data.additional

#let body_font_size = additional.font_size * 1pt

// Each seal's disc in its image's pixels: where it starts and its diameter.
// The letterhead sets the disc at 1in.
#let seal = if letterhead.letterhead_seal == "dod" {
  (file: "assets/dod_seal.png", pixels: 296, start: 0, disc: 296)
} else {
  (file: "assets/dow_seal.png", pixels: 308, start: 1, disc: 300)
}
#let seal_scale = 1in / seal.disc

// A blank date's fill-in slot: an AcroForm text box the signer types the date
// into, flush right where a printed date would sit. It claims a cap height,
// the extent of a printed date, and the widget overhangs the line. At one and
// a half times the font size tall, a viewer's border inset leaves a typed
// date's descenders whole. Its bottom sits 0.44 of the font size below the
// baseline, where PDFium and MuPDF center a typed date within 0.12pt of the
// office symbol's baseline.
#let date_slot_width = body_font_size * 8.5
#let date_slot(name, field) = context box(
  width: date_slot_width,
  height: measure[0].height,
  place(bottom + left, dy: body_font_size * 0.44, qm.form-field(
    name,
    type: "text",
    width: date_slot_width,
    height: body_font_size * 1.5,
    field: field,
    font: "times",
    size: body_font_size,
    align: "right",
  )),
)

#qm.tasks.update(_ => render-task)

#let thru_path(i) = addressing.at("$path") + "memo_thru." + str(i)

#show: frontmatter.with(
  letterhead-title: letterhead.letterhead_title,
  letterhead-seal: move(
    dx: -seal.start * seal_scale,
    dy: -seal.start * seal_scale,
    image(seal.file, width: seal.pixels * seal_scale),
  ),
  office-symbol: addressing.office_symbol,
  record-number: addressing.record_number,
  office-symbol-info: addressing.office_symbol_info,
  // `qm.ink` keeps a printed date click-to-edit. A blank date is left for the
  // signer to fill in.
  date: qm.ink(addressing, "date", date-pattern()),
  date-field: date_slot("Date", addressing.at("$path") + "date"),
  suspense: qm.ink(addressing, "suspense", date-pattern()),
  memo-for: addressing.memo_for,
  memo-thru: addressing.memo_thru,
  thru-fields: range(addressing.memo_thru.len()).map(i => (
    comment: height => qm.form-field(
      "Thru_" + str(i + 1) + "_Comment",
      type: "text",
      field: thru_path(i),
      width: 90pt,
      height: height,
      font: "times",
      size: 8pt,
      align: "left",
      multiline: true,
    ),
    signature: height => qm.signature-field(
      "Thru_" + str(i + 1) + "_Signature",
      field: thru_path(i),
      width: 90pt,
      height: height,
    ),
  )),
  subject: addressing.subject,
  classification-level: qm.data.classification.value,
  dissemination: qm.data.dissemination,
  // The CUI cells exist only where the classification reads CUI.
  ..if qm.data.classification.value == "CUI" {
    (
      cui-controlled-by: qm.data.classification.controlled_by,
      cui-category: qm.data.classification.category,
      cui-limited-dissemination: qm.data.classification.limited_dissemination,
      cui-poc: qm.data.classification.poc,
    )
  },
  font-size: body_font_size,
)

#mainmatter(references: additional.references)[
  #qm.data.at("$body")
]

#backmatter(
  authority-line: addressing.authority_line,
  signature-block: addressing.signature_block,
  // 200pt by two and a half times the font size, ending 3pt above the name.
  signing-field: qm.signature-field(
    "Signature",
    field: addressing.at("$path") + "signature_block",
    height: body_font_size * 2.5,
  ),
  enclosures: additional.enclosures,
  distribution: additional.distribution,
  cf: additional.cf,
  cf-without-enclosures: additional.cf_without_enclosures,
)
