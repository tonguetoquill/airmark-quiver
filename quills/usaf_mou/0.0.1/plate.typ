#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usaf-mou:0.0.1": (
  agreement-backmatter, date-pattern, frontmatter, mainmatter,
)

#let addressing = qm.data.addressing
#let signatures = qm.data.signatures
#let letterhead = qm.data.letterhead
#let classification = qm.data.classification
#let additional = qm.data.additional
#let level = classification.level

// A memo has no "no style" state, so the blank takes the package's default.
// Resolved once here: `frontmatter` and the dates' pattern must agree.
#let memo_style = if additional.memo_style != "" { additional.memo_style } else { "usaf" }

#let letterhead_lines = letterhead.letterhead_title

// Body text size, in points. Also the height of a blank date's fill-in widget.
#let body_font_size = additional.font_size * 1pt

// A blank date's fill-in slot: an AcroForm text box claiming a cap height, the
// extent of a printed date, with the widget overhanging the line about its
// middle so it takes no room from the flow. Wide enough for the longest date
// either style prints, "September 30, 2026".
#let date_slot_width = body_font_size * 8.5
#let date_slot(name, field, align: "right") = context box(
  width: date_slot_width,
  height: measure[0].height,
  place(horizon + left, qm.form-field(
    name,
    type: "text",
    width: date_slot_width,
    height: body_font_size,
    field: field,
    font: "times",
    size: body_font_size,
    align: align,
  )),
)

// "MEMORANDUM OF UNDERSTANDING BETWEEN A AND B", or "A, B, AND C" for three
// or more parties. The heading takes MEMORANDUM FOR's place and prints alone.
// A blank line left in the list is not a party.
#let parties = addressing.parties.filter(p => (
  p != none and p != false and p != "" and p != []
))
#let party_list = if parties.len() == 2 {
  parties.join([ AND ])
} else {
  parties.join([, ], last: [, AND ])
}
#let heading = if parties.len() > 0 {
  [MEMORANDUM OF UNDERSTANDING BETWEEN #party_list]
} else {
  [MEMORANDUM OF UNDERSTANDING]
}

#show: frontmatter.with(
  letterhead-title: letterhead_lines.at(0, default: ""),
  letterhead-caption: if letterhead_lines.len() > 1 { letterhead_lines.slice(1) } else { () },
  letterhead-seal-subtitle: letterhead.letterhead_seal_subtitle,
  letterhead-seal: image(
    if letterhead.letterhead_seal == "dod" {
      "assets/dod_seal.png"
    } else {
      "assets/dow_seal.png"
    }
  ),

  // `qm.ink` keeps a printed date click-to-edit. A blank date is left for the
  // signer to fill in.
  date: qm.ink(addressing, "date", date-pattern(memo-style: memo_style)),
  date-field: date_slot("Date", addressing.at("$path") + "date"),

  memo-for: (),
  memo-heading: heading,

  ..if addressing.memo_from.len() > 0 { (memo-from: addressing.memo_from) },

  subject: addressing.subject,

  ..if additional.references.len() > 0 { (references: additional.references) },

  footer-tag-line: letterhead.tag_line,

  classification-level: level.value,

  dissemination: classification.dissemination,

  // The CUI cells exist only where the classification reads CUI.
  ..if level.value == "CUI" {
    (
      cui-controlled-by: level.controlled_by,
      cui-category: level.category,
      cui-limited-dissemination: level.limited_dissemination,
      cui-poc: level.poc,
    )
  },

  memo-style: memo_style,

  font-size: body_font_size,
)

#mainmatter[
  #qm.data.at("$body")
]

// Widget names carry the signer's place in the list; schema addresses come
// from each signer's own `$path`.
#let signers = signatures.signers.enumerate().map(((i, signer)) => {
  let path = signer.at("$path", default: signatures.at("$path") + "signers." + str(i) + ".")
  let printed_date = qm.ink(signer, "date", date-pattern(memo-style: memo_style))
  (
    lines: signer.at("signature_block", default: ()),
    signing-field: qm.signature-field(
      "Signer_" + str(i + 1) + "_Signature",
      field: path + "signature_block",
      height: body_font_size * 2.5,
    ),
    date: if not signatures.date_lines {
      none
    } else if printed_date != none {
      printed_date
    } else {
      date_slot("Signer_" + str(i + 1) + "_Date", path + "date", align: "left")
    },
  )
})

#agreement-backmatter(
  signers: signers,
  ..if additional.attachments.len() > 0 { (attachments: additional.attachments) },
  ..if additional.cc.len() > 0 { (cc: additional.cc) },
  ..if additional.distribution.len() > 0 { (distribution: additional.distribution) },
)
