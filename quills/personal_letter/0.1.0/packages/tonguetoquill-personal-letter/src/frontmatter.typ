// frontmatter.typ: Heading section for personal letter (AFH 33-337 Ch. 15)
//
// Layout per Ch. 15 "The Heading Section":
//   Date         — 1 inch from right, 1.75 inches from top
//   [blank line]
//   Return addr  — 2nd line below date, flush left
//   [2 blank lines]
//   Receiver addr — 3rd line below return address (last line)
//   [blank line]
//   Salutation   — 2nd line below receiver address (last line)
//   [blank line]  ← "Start text on second line below salutation"
//   [body text]

#import "primitives.typ": *

#let frontmatter(
  return_address: none,
  receiver_address: none,
  salutation: none,
  date: none,
  addressee_type: "military",
  letterhead_title: "DEPARTMENT OF THE AIR FORCE",
  letterhead_caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead_seal: none,
  letterhead_seal_subtitle: none,
  letterhead_emblem: none,
  letterhead_font: DEFAULT_LETTERHEAD_FONTS,
  body_font: DEFAULT_BODY_FONTS,
  font_size: 12pt,
  classification_level: none,
  dissemination: none,
  footer_tag_line: none,
  it,
) = {
  assert(return_address != none, message: "return_address is required")
  assert(receiver_address != none, message: "receiver_address is required")
  assert(salutation != none, message: "salutation is required")

  let actual_date = if date == none { datetime.today() } else { date }

  let classification_marking = if classification_level == none or type(classification_level) != str {
    none
  } else {
    let base = classification_level.trim()
    if base == "" {
      none
    } else {
      let disp = if dissemination == none or type(dissemination) != str {
        ""
      } else {
        dissemination.trim()
      }
      if disp != "" { base + "//" + upper(disp) } else { base }
    }
  }
  let classification_color = get-classification-level-color(classification_level)

  set par(leading: spacing.line, spacing: spacing.line, justify: false)
  set block(above: spacing.line, below: 0em, spacing: 0em)
  set text(font: body_font, size: font_size, fallback: true)

  set page(
    paper: "us-letter",
    margin: (
      left: spacing.margin,
      right: spacing.margin,
      top: spacing.margin,
      bottom: spacing.margin,
    ),
    header: {
      // AFH 33-337 Ch. 15: same page-numbering rules as memo (first page not numbered)
      context if counter(page).get().first() > 1 {
        place(
          dy: +.5in,
          block(
            width: 100%,
            align(right, text(12pt)[#counter(page).display()]),
          ),
        )
      }

      if classification_marking != none {
        place(
          top + center,
          dy: 0.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: classification_color)[#strong(classification_marking)],
        )
      }
    },
    footer: {
      if classification_marking != none {
        place(
          bottom + center,
          dy: -.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: classification_color)[#strong(classification_marking)],
        )
      }

      if not falsey(footer_tag_line) {
        place(
          bottom + center,
          dy: -0.625in,
          align(center)[
            #text(fill: LETTERHEAD_COLOR, font: "cinzel", size: 15pt)[#footer_tag_line]
          ],
        )
      }
    },
  )

  render-letterhead(
    letterhead_title,
    letterhead_caption,
    letterhead_font,
    letterhead-seal: letterhead_seal,
    letterhead-seal-subtitle: letterhead_seal_subtitle,
    letterhead-emblem: letterhead_emblem,
  )

  // AFH 33-337 Ch. 15 "Date": 1.75 inches from top, 1 inch from right edge
  v(1.75in - spacing.margin)

  // Cache line stride for spacing calculations throughout the document
  context {
    let one-line = measure(par(spacing: 0pt)[x]).height
    let line-stride = measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
    LINE_STRIDE.update(line-stride)
  }

  // Store addressee_type for use in backmatter / mainmatter if needed
  [#metadata((addressee_type: addressee_type)) <personal-letter-config>]

  render-date-section(actual_date, addressee-type: addressee_type)

  // 2nd line below date → 1 blank line before return address
  blank-line()
  render-return-address(return_address)

  // 3rd line below return address (last line) → 2 blank lines
  blank-lines(2)
  render-receiver-address(receiver_address)

  // 2nd line below receiver address (last line) → 1 blank line before salutation
  blank-line()
  render-salutation(salutation)

  // "Start the text of a letter on the second line below the salutation" → 1 blank line
  blank-line()
  it
}
