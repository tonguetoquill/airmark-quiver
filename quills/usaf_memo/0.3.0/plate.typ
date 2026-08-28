#import "@local/quillmark-helper:0.1.0": (
  data, display, field-region, form-field, signature-field,
)
#import "@local/tonguetoquill-usaf-memo:4.0.0": (
  backmatter, date-pattern, frontmatter, indorsement, mainmatter,
)

// A memo has no "no style" state, so the blank takes the package's default.
// Resolved once here: `frontmatter` and the date's pattern must agree.
#let memo_style = if data.memo_style != "" { data.memo_style } else { "usaf" }

// The letterhead arrives as one ordered array of lines. Element 0 is the title,
// set larger; the rest are caption lines beneath it. A single element renders
// the title alone — the package skips a falsey caption. An empty array renders
// no letterhead text at all, silently: the block is `place`d, so an empty title
// leaves no glyphs and takes no space from the flow, and the seal stands alone.
#let letterhead_lines = data.letterhead_title

// Body text size, in points. Also the height of one line of the indorsement
// header, which is what an omitted indorsement date reserves for its fill-in
// widget (`date-placeholder-slot`, whose slot is `1em` tall and 1in wide).
#let body_font_size = data.font_size * 1pt

// Frontmatter configuration
#show: frontmatter.with(
  // Letterhead configuration
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

  // Date. `data.date` is the native `datetime` and would render identically,
  // but its ink would be born inside the package and carry no schema address.
  // `display` places the field's *content* projection instead: the glyphs are
  // born in the generated helper, so the memo date stays click-to-edit however
  // deep the package formats it.
  //
  // A blank date means today's, and the plate stamps it rather than falling
  // through to `frontmatter`'s own `datetime.today()`: package-born ink carries
  // no address, so the one date a memo never types would be the one date a
  // preview cannot click. `field-region` claims that ink for the field instead.
  //
  // The stamp is markup, not the bare `str` `.display()` returns: a `str` off a
  // function call carries no source position, and ink with none is unclaimable.
  date: {
    let pattern = date-pattern(memo-style: memo_style)
    let authored = display("date", pattern)
    if authored != none {
      authored
    } else {
      field-region("date", [#datetime.today().display(pattern)])
    }
  },

  // Receiver information
  memo_for: data.memo_for,

  // Sender information (omitted for Memorandum for Record)
  ..if data.memo_from.len() > 0 { (memo_from: data.memo_from) },

  // Subject line
  subject: data.subject,

  // Optional references
  ..if data.references.len() > 0 { (references: data.references) },

  // Optional footer tag line
  footer_tag_line: data.tag_line,

  // The blank reads as no banner, which is what the package's own
  // `classification_level: none` default means.
  classification_level: data.classification.value,

  dissemination: data.dissemination,

  // CUI designation indicator block fields (DoDM 5200.48). `classification`
  // declares a `CUI` variant, so these four exist only where the discriminant
  // reads CUI, and the branch is what makes reading them total: inside it every
  // declared field of that world is present, outside it none is. The package's
  // own `cui_*: none` defaults cover the worlds that omit them.
  ..if data.classification.value == "CUI" {
    (
      cui_controlled_by: data.classification.controlled_by,
      cui_category: data.classification.category,
      cui_limited_dissemination: data.classification.limited_dissemination,
      cui_poc: data.classification.poc,
    )
  },

  // USAF vs DAF memorandum style (date format, body indentation).
  memo_style: memo_style,

  // Font size
  font_size: body_font_size,

  // List recipients in vertical list
  memo_for_cols: 1,
)

// Mainmatter. The body's region needs no recovery step here: the package's
// render-body rebuilds paragraphs through a state buffer (AFH 33-337
// auto-numbering), but the rebuilt glyphs keep their spans, which is what
// the backend reads regions from.
// Appointment letters ride the same block: the appointing sentence becomes
// paragraph 1 with the appointee table under it (or after the body, by
// choice), and a supersession sentence closes the numbering. Each piece is
// emitted only when set, so a memo with no member cards, no statement, and
// no supersession hands the renderer exactly its body, as before.
//
// Nothing here may emit a PDF form widget: the renderer lays the block out
// once hidden and once for real, and a widget inside it would be born twice.
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

// An unset content field reaches the plate as the empty string; a set-but-
// whitespace one trims to empty content. Both read as blank.
#let blank(v) = v == "" or v == none or trim-inline(v) == []

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
#let members-table() = if member_cards.len() > 0 and columns.len() > 0 {
  table(
    columns: columns.map(col => col.at(2)),
    table.header(..columns.map(col => cell(col.at(1)))),
    ..member_cards
      .map(card => columns.map(col => cell(card.at(col.at(0), default: ""))))
      .flatten(),
  )
}

#let statement = if not blank(data.appointment_statement) {
  [#trim-inline(data.appointment_statement)#parbreak()]
}
#let supersession = if data.supersedes_previous {
  let wording = if blank(data.supersession_text) {
    [This letter supersedes all previous letters, same subject.]
  } else {
    trim-inline(data.supersession_text)
  }
  [#wording#parbreak()]
}
#let table_at_end = data.members_position == "end_of_body"

// `after_statement` puts the table under paragraph 1, and paragraph 1 is the
// statement when one is set, else the body's own first paragraph. The body
// arrives as one content sequence, so its first paragraph is the run of
// children up to the first paragraph break (a leading list or heading ends
// at that break too); the table goes between that run and the rest.
#let split-first-par(body) = {
  let kids = if type(body) == content { body.at("children", default: none) } else { none }
  if kids == none { return (body, []) }
  let padding(c) = c == [ ] or c.func() == parbreak
  let i = 0
  while i < kids.len() and padding(kids.at(i)) { i += 1 }
  while i < kids.len() and kids.at(i).func() != parbreak { i += 1 }
  (kids.slice(0, i).sum(default: []), kids.slice(i).sum(default: []))
}
#let members_table = members-table()
#let (par1, rest) = if statement != none or members_table == none or table_at_end {
  (statement, data.at("$body"))
} else {
  split-first-par(data.at("$body"))
}

#mainmatter[
  #par1
  #if not table_at_end { members_table }
  #rest
  #if table_at_end { members_table }
  #supersession
]

// Backmatter
#backmatter(
  // Signature block
  signature_block: data.signature_block,
  // The widget sits at the bottom of AFH 33-337's four blank lines and is
  // sized to two and a half of them, so the line and a half above it stays
  // clear of the body text without moving the block off the fifth line.
  signing_field: signature-field(
    "Signature",
    field: "signature_block",
    height: body_font_size * 2.5,
  ),

  // Optional cc
  ..if data.cc.len() > 0 { (cc: data.cc) },

  // Optional distribution
  ..if data.distribution.len() > 0 { (distribution: data.distribution) },

  // Optional attachments
  ..if data.attachments.len() > 0 { (attachments: data.attachments) },
)

// The action line's wording follows the indorsement's place in the chain, not
// an endorser's choice: the last indorsement is the approval authority and
// reads Approve / Disapprove, every one before it is a coordinating official
// and reads Concur / Nonconcur. Only this loop can see whether an indorsement
// is the last one, so the position is resolved here and passed down. Cards of
// other kinds may interleave, so the last indorsement is the last card *of
// this kind*, not the last card. `-1` never matches a real index, which is the
// wanted result when there are no indorsements at all.
// Parenthesized so the method chain can span lines: in markup, a `#let` whose
// expression ends at a line break stops there, and the next line's leading
// `.at(…)` would be read as text.
#let last_indorsement_index = (
  data
    .at("$cards")
    .enumerate()
    .filter(entry => entry.at(1).at("$kind", default: none) == "indorsement")
    .map(entry => entry.at(0))
    .at(-1, default: -1)
)

// Indorsements - iterate through CARDS array and filter by CARD tag
#for (i, card) in data.at("$cards").enumerate() {
  if card.at("$kind", default: none) == "indorsement" {
    // The quillmark helper leaves an unset/whitespace-only markdown body as
    // the empty string `""`; only non-empty bodies are eval'd into content.
    // Pass truly empty content (`[]`) in the empty case so indorsement can
    // collapse the body's surrounding spacing.
    let body = card.at("$body", default: "")
    let body_content = if type(body) == str { [] } else { body }
    // Per AFH 33-337 Ch. 14, an indorsement is dated when the endorser signs
    // it (distinct from the originating memo's date). The signing date is
    // generally unknown at compile time, so a blank or omitted date leaves the
    // date slot fillable rather than stamping the compile date into it.
    // `display` takes an address, so a per-card call yields a per-card region
    // even though every iteration shares one `card` loop variable, and it
    // returns `none` for a blank date — the fill-in case below.
    let resolved_date = display(
      card.at("$path") + "date",
      date-pattern(memo-style: memo_style),
    )
    // The card's `$path` prefix composes its canonical schema addresses
    // (`$cards.indorsement.<n>.…`, per-kind ordinal) — the absolute loop
    // index `i` is NOT that ordinal once kinds interleave, so it stays a
    // widget-name suffix only. The card body's region rides its own glyph
    // spans through the package rebuild, per-card because each card's body
    // has its own backend-generated eval site.
    indorsement(
      from: card.at("from", default: ""),
      to: card.at("for", default: ""),
      signature_block: card.signature_block,
      signing_field: signature-field(
        "Ind_" + str(i) + "_Signature",
        field: card.at("$path") + "signature_block",
        height: body_font_size * 2.5,
      ),
      ..if card.format != "" { (format: card.format) },
      date: resolved_date,
      // An omitted date becomes an empty AcroForm text box the endorser types
      // the signing date into, sized to the slot the package reserves for it.
      // Built only when there is no date to print: a widget over a printed date
      // would offer an edit that the rendered document does not carry back.
      ..if resolved_date == none {
        (date_field: form-field(
          "Ind_" + str(i) + "_Date",
          type: "text",
          width: 1in,
          height: body_font_size,
          field: card.at("$path") + "date",
        ))
      },
      ..if card.action != "" { (action: card.action) },
      approval_authority: i == last_indorsement_index,
      body_content,
    )
  }
}
