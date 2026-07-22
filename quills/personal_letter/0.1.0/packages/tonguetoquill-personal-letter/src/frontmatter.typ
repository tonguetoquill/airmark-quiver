// frontmatter.typ — heading section for AFH 33-337 Ch. 15 personal letter
//
// Layout (all measurements from top of page):
//   1.75 in  — date, right-aligned at 1 inch from the right edge
//   [1 blank line]
//   Return address (flush left, single-spaced)
//   [2 blank lines]
//   Receiver's address (flush left, single-spaced)
//   [1 blank line]
//   Salutation ("Dear …" — no punctuation after)
//   [1 blank line]
//   ← body text begins here

#import "config.typ": DEFAULT_BODY_FONTS, DEFAULT_LETTERHEAD_FONTS, spacing
#import "utils.typ": *

#let frontmatter(
  // Required heading fields
  return_address:   none,
  receiver_address: none,
  salutation:       none,
  // Date
  date:             none,
  addressee_type:   "military",
  // Letterhead
  letterhead_title:    "DEPARTMENT OF THE AIR FORCE",
  letterhead_caption:  none,
  letterhead_seal:     none,
  letterhead_font:     DEFAULT_LETTERHEAD_FONTS,
  // Typography
  body_font:        DEFAULT_BODY_FONTS,
  font_size:        12pt,
  // Optional classification banner
  classification_level: none,
  dissemination:        none,
  // body (passed by show rule)
  it,
) = {
  assert(return_address   != none, message: "return_address is required")
  assert(receiver_address != none, message: "receiver_address is required")
  assert(salutation       != none, message: "salutation is required")

  let actual_date = if date == none { datetime.today() } else { date }
  let marking = classification-marking(classification_level, dissemination)
  let mark-color = classification-color(classification_level)

  // ── Document-wide typography ─────────────────────────────────────────────
  set par(leading: spacing.line, spacing: spacing.line, justify: false)
  set block(above: spacing.line, below: 0em, spacing: 0em)
  set text(font: body_font, size: font_size, fallback: true)

  // ── Page geometry ────────────────────────────────────────────────────────
  set page(
    paper: "us-letter",
    margin: (top: spacing.margin, bottom: spacing.margin,
             left: spacing.margin, right: spacing.margin),
    header: {
      // Ch. 15 inherits memo page-numbering rules: first page not numbered;
      // subsequent pages numbered 0.5 in from top, flush with right margin.
      context if counter(page).get().first() > 1 {
        place(dy: +.5in,
          block(width: 100%, align(right, text(12pt)[#counter(page).display()])))
      }
      if marking != none {
        place(top + center, dy: 0.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: mark-color)[#strong(marking)])
      }
    },
    footer: {
      if marking != none {
        place(bottom + center, dy: -.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: mark-color)[#strong(marking)])
      }
    },
  )

  // ── Cache line stride ────────────────────────────────────────────────────
  context {
    let h1 = measure(par(spacing: 0pt)[x]).height
    LINE_STRIDE.update(measure(par(spacing: 0pt)[x#linebreak()x]).height - h1)
  }

  // ── Letterhead ───────────────────────────────────────────────────────────
  if letterhead_caption != none {
    render-letterhead(
      letterhead_title,
      letterhead_caption,
      letterhead_font,
      letterhead-seal: letterhead_seal,
    )
  }

  // ── Date ─────────────────────────────────────────────────────────────────
  // Ch. 15: "Place the date 1 inch from the right edge, 1.75 inches from
  // the top of the page."
  v(1.75in - spacing.margin)
  align(right)[#format-date(actual_date, addressee-type: addressee_type)]

  // ── Return address ───────────────────────────────────────────────────────
  // "Place the sender's return address flush with the left margin on the
  // second line below the date."
  blank-line()
  for (i, line) in ensure-array(return_address).enumerate() {
    [#line]
    if i < ensure-array(return_address).len() - 1 { linebreak() }
  }

  // ── Receiver's address ───────────────────────────────────────────────────
  // "Place the address of the individual the letter is being sent to on the
  // third line below the return address."
  blank-lines(2)
  for (i, line) in ensure-array(receiver_address).enumerate() {
    [#line]
    if i < ensure-array(receiver_address).len() - 1 { linebreak() }
  }

  // ── Salutation ───────────────────────────────────────────────────────────
  // "Place the salutation on the second line below the receiver's address."
  blank-line()
  [#salutation]

  // ── Gap before body ──────────────────────────────────────────────────────
  // Ch. 15: "Start the text of a letter on the second line below the salutation."
  blank-line()
  it
}
