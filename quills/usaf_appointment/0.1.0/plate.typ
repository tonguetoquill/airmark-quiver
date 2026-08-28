#import "@local/quillmark-helper:0.1.0": (
  data, display, field-region, signature-field,
)
#import "@local/tonguetoquill-usaf-memo:4.0.0": (
  backmatter, date-pattern, frontmatter, mainmatter,
)

// An appointment letter is a unit-level USAF memorandum: AFH 33-337 numbered
// paragraphs, with the appointee table hanging under paragraph 1. The DAF
// headquarters style (unnumbered, first-line-indented paragraphs) has no
// "paragraph 1" to hang a table under, so the style is fixed here rather
// than offered as a field.
#let memo_style = "usaf"

// Every text field is `plaintext`/`richtext`, so it arrives as content carrying
// a space element on each side (and, as an array item, a trailing parbreak).
// `trim-inline` strips that padding so a field can sit in a table cell or run
// straight into prose without a stray leading space.
#let trim-inline(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

// An unset content field reaches the plate as the empty string; a set-but-
// whitespace one trims to empty content. Both read as blank.
#let blank(v) = v == "" or v == none or trim-inline(v) == []

// The letterhead arrives as one ordered array of lines. Element 0 is the title,
// set larger; the rest are caption lines beneath it.
#let letterhead_lines = data.letterhead_title

// Body text size, in points. Table cells are set below it (see `cell`).
#let body_font_size = data.font_size * 1pt

// Frontmatter configuration — identical to usaf_memo@0.3.0 apart from the
// fixed memo style.
#show: frontmatter.with(
  letterhead_title: letterhead_lines.at(0, default: ""),
  letterhead_caption: if letterhead_lines.len() > 1 { letterhead_lines.slice(1) } else { () },
  letterhead_seal_subtitle: data.letterhead_seal_subtitle,
  // Enum blank is `""`, not a seal. Omit so the package renders none rather
  // than treating the blank as DoW.
  ..if data.letterhead_seal != "" {
    (letterhead_seal: image(
      if data.letterhead_seal == "dod" {
        "assets/dod_seal.png"
      } else {
        "assets/dow_seal.png"
      }
    ))
  },

  // Date. `display` places the field's content projection so the printed date
  // stays click-to-edit; a blank date means today's, stamped here and claimed
  // for the field with `field-region` so it too carries a schema address.
  date: {
    let pattern = date-pattern(memo-style: memo_style)
    let authored = display("date", pattern)
    if authored != none {
      authored
    } else {
      field-region("date", [#datetime.today().display(pattern)])
    }
  },

  memo_for: data.memo_for,

  // Sender information (omitted for a Memorandum for Record)
  ..if data.memo_from.len() > 0 { (memo_from: data.memo_from) },

  subject: data.subject,

  ..if data.references.len() > 0 { (references: data.references) },

  footer_tag_line: data.tag_line,

  // The blank reads as no banner, which is what the package's own
  // `classification_level: none` default means.
  classification_level: data.classification.value,

  dissemination: data.dissemination,

  // CUI designation indicator block fields (DoDM 5200.48). `classification`
  // declares a `CUI` variant, so these four exist only where the discriminant
  // reads CUI.
  ..if data.classification.value == "CUI" {
    (
      cui_controlled_by: data.classification.controlled_by,
      cui_category: data.classification.category,
      cui_limited_dissemination: data.classification.limited_dissemination,
      cui_poc: data.classification.poc,
    )
  },

  memo_style: memo_style,
  font_size: body_font_size,
  memo_for_cols: 1,
)

// ── Appointee table ─────────────────────────────────────────────────────────
// One `member` card per row, in document order. Filter to the kind before
// enumerating so ordinals are per-kind.
#let member_cards = (
  data
    .at("$cards", default: ())
    .filter(card => card.at("$kind", default: none) == "member")
)

// Column spec: (field key, header, width). A column renders only when some
// appointee fills it, so a letter that lists no e-mail addresses prints no
// e-mail column; the extra column renders only when the letter names it.
// Widths are `auto` except e-mail, which takes whatever is left and is the
// one value long enough to need it.
#let any-filled(key) = member_cards.any(card => not blank(card.at(key, default: "")))
#let columns = (
  ("role", "Role", auto),
  ("rank", "Rank", auto),
  ("name", "Name", auto),
  ("office_symbol", "Office Symbol", auto),
  ("duty_phone", "Duty Phone", auto),
  ("email", "Email", 1fr),
  ("deros", "DEROS", auto),
).filter(col => any-filled(col.at(0)))
#let columns = if not blank(data.members_extra_column) {
  columns + (("extra", trim-inline(data.members_extra_column), auto),)
} else {
  columns
}

// Cells step down from the body size (two points, then one more per column
// past six) so a full seven- or eight-column roster fits the 6.5in text block
// at 12pt body text. The size is set inside each
// cell rather than around the table: the memo package's body renderer keeps
// only the bare `table` element it captures, so anything wrapped around the
// table is dropped, and its own `set table(stroke, inset)` rule supplies the
// borders — pass neither here.
#let cell-size = body_font_size - 2pt - calc.max(0, columns.len() - 6) * 1pt
#let cell(v) = text(size: cell-size, trim-inline(v))
#let members-table() = if member_cards.len() > 0 {
  table(
    columns: columns.map(col => col.at(2)),
    table.header(..columns.map(col => cell(col.at(1)))),
    ..member_cards
      .map(card => columns.map(col => cell(card.at(col.at(0), default: ""))))
      .flatten(),
  )
}

// ── Mainmatter ──────────────────────────────────────────────────────────────
// The appointing sentence is paragraph 1, the table hangs under it (or after
// the body, by choice), the body continues the numbering, and the supersession
// sentence closes it. The package's body renderer captures each paragraph and
// table from this one block and numbers the paragraphs per AFH 33-337.
//
// Nothing here may emit a PDF form widget: the renderer lays the block out
// once hidden and once for real, and a widget inside it would be born twice.
#let statement = [#trim-inline(data.appointment_statement)#parbreak()]
#let supersession = if data.supersedes_previous {
  let wording = if blank(data.supersession_text) {
    [This letter supersedes all previous letters, same subject.]
  } else {
    trim-inline(data.supersession_text)
  }
  [#wording#parbreak()]
}
#let table_at_end = data.members_position == "end_of_body"

#mainmatter[
  #statement
  #if not table_at_end { members-table() }
  #data.at("$body")
  #if table_at_end { members-table() }
  #supersession
]

// ── Backmatter ──────────────────────────────────────────────────────────────
// AFH 33-337: the signature block starts on the fifth line below the text,
// four blank lines between. The signing widget sits at the bottom of those
// four lines and is sized to two and a half of them, so the line and a half
// above it stays clear of the body text without moving the block.
#backmatter(
  signature_block: data.signature_block,
  signing_field: signature-field(
    "Signature",
    field: "signature_block",
    height: body_font_size * 2.5,
  ),
  ..if data.cc.len() > 0 { (cc: data.cc) },
  ..if data.distribution.len() > 0 { (distribution: data.distribution) },
  ..if data.attachments.len() > 0 { (attachments: data.attachments) },
)
