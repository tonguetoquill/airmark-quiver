#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usaf-letter:0.1.0": (
  backmatter, date-pattern, frontmatter, mainmatter,
)

// The letterhead arrives as one ordered array of lines. Element 0 is the title,
// set larger; the rest are caption lines beneath it. A single element renders
// the title alone — the package skips a falsey caption. An empty array renders
// no letterhead text at all, silently: the block is `place`d, so an empty title
// leaves no glyphs and takes no space from the flow, and the seal stands alone.
#let letterhead_lines = qm.data.letterhead_title

// Body text size, in points. Also the height of a blank date's fill-in widget.
#let body_font_size = qm.data.font_size * 1pt

// A blank date's fill-in slot: an empty AcroForm text box the signer types the
// date into, set in the body face and flush right, as the printed date would
// be. Wide enough for the longest date, "30 September 2026", which runs 8em in
// the body face.
//
// The slot claims a cap-height, the extent of a printed date, and the widget
// overhangs it about the line's middle, so a blank date takes no more room from
// the flow than a printed one and the page lays out the same either way.
#let date_slot_width = body_font_size * 8.5
#let date_slot(name, field) = context box(
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
    align: "right",
  )),
)

#show: frontmatter.with(
  letterhead-title: letterhead_lines.at(0, default: ""),
  letterhead-caption: if letterhead_lines.len() > 1 { letterhead_lines.slice(1) } else { () },
  letterhead-seal-subtitle: qm.data.letterhead_seal_subtitle,
  // A letter has no seal-less state, so the blank takes the default, DoW.
  letterhead-seal: image(
    if qm.data.letterhead_seal == "dod" {
      "assets/dod_seal.png"
    } else {
      "assets/dow_seal.png"
    }
  ),

  // Date. `data.date` is the native `datetime` and would render identically,
  // but its ink would be born inside the package and carry no schema address.
  // `qm.ink` places the field's *content* projection instead: the glyphs are
  // born in the generated helper, so the letter's date stays click-to-edit
  // however deep the package formats it.
  //
  // A blank date is left for the signer: a letter is dated when it is signed,
  // which is generally not when it is rendered, so the slot is fillable rather
  // than stamped with the compile date. Passing it as the date also keeps it
  // from `frontmatter`'s own `datetime.today()` fallback.
  date: {
    let authored = qm.ink(qm.data, "date", date-pattern())
    if authored != none { authored } else { date_slot("Date", "date") }
  },

  letter-from: qm.data.letter_from,
  letter-for: qm.data.letter_for,
  salutation: qm.data.salutation,

  footer-tag-line: qm.data.tag_line,

  // The blank reads as no banner, which is what the package's own
  // `classification-level: none` default means.
  classification-level: qm.data.classification.value,

  dissemination: qm.data.dissemination,

  // CUI designation indicator block fields (DoDM 5200.48). `classification`
  // declares a `CUI` variant, so these four exist only where the discriminant
  // reads CUI, and the branch is what makes reading them total: inside it every
  // declared field of that world is present, outside it none is. The package's
  // own `cui_*: none` defaults cover the worlds that omit them.
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

// An empty body reaches the plate as `""`, and `mainmatter` would still set a
// blank paragraph for it, dropping the close two lines too far.
#if qm.data.at("$body") != "" {
  mainmatter[#qm.data.at("$body")]
}

#backmatter(
  complimentary-close: qm.data.complimentary_close,
  signature-block: qm.data.signature_block,
  // The widget sits at the bottom of AFH 33-337's four blank lines and is
  // sized to two and a half of them, so the line and a half above it stays
  // clear of the complimentary close without moving the block off the fifth
  // line.
  signing-field: qm.signature-field(
    "Signature",
    field: "signature_block",
    height: body_font_size * 2.5,
  ),

  ..if qm.data.attachments.len() > 0 { (attachments: qm.data.attachments) },

  ..if qm.data.cc.len() > 0 { (cc: qm.data.cc) },
)
