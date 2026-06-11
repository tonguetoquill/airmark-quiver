// frontmatter.typ: Frontmatter show rule for the USAF personal letter
//
// This module implements the heading section of a USAF personal letter per
// AFH 33-337 "The Personal Letter" (cross-referenced to AFMAN 33-326 §4.1.1,
// which states the same layout with inch/line-space anchors). It handles:
// - Page setup with 1-inch margins and continuation-page numbering
// - Letterhead rendering
// - Date, sender's address, receiver's address, and salutation placement

#import "primitives.typ": *

#let frontmatter(
  recipient: none,
  salutation: none,
  sender: none,
  date: none,
  letterhead_title: "DEPARTMENT OF THE AIR FORCE",
  letterhead_caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead_seal: none,
  letterhead_seal_subtitle: none, // optional line under seal (9pt bold caps); ignored if no seal
  letterhead_font: DEFAULT_LETTERHEAD_FONTS,
  body_font: DEFAULT_BODY_FONTS,
  font_size: 12pt,
  it,
) = {
  assert(recipient != none, message: "recipient is required")
  assert(salutation != none, message: "salutation is required")

  let actual_date = if date == none { datetime.today() } else { date }

  // Document-wide typography settings
  set par(leading: spacing.line, spacing: spacing.line, justify: false)
  set block(above: spacing.line, below: 0em, spacing: 0em)
  set text(font: body_font, size: font_size, fallback: true)
  show raw: set text(font: DEFAULT_MONO_FONTS)

  set page(
    paper: "us-letter",
    // AFH 33-337: 1-inch margins on the left, right and bottom
    margin: (
      left: spacing.margin,
      right: spacing.margin,
      top: spacing.margin,
      bottom: spacing.margin,
    ),
    header: {
      // AFH 33-337 keeps a personal letter to one page when possible; when it
      // does run over, number continuation pages the same way as official
      // correspondence: page 2 onward, 0.5 inch from the top, flush right.
      context if counter(page).get().first() > 1 {
        place(
          dy: +.5in,
          block(
            width: 100%,
            align(right, text(12pt)[#counter(page).display()]),
          ),
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
  )

  // AFH 33-337 "The Personal Letter": "The date is placed 10 lines from the
  // top of the page on the right side" — i.e. 1.75 inches from the top edge
  // (AFMAN 33-326 §4.1.1.1). With a 1-inch top margin, advance the difference.
  v(1.75in - spacing.margin)

  // Measure and cache the line stride once for blank-line spacing and
  // orphan-control heuristics.
  context {
    let one-line = measure(par(spacing: 0pt)[x]).height
    let line-stride = measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
    LINE_STRIDE.update(line-stride)
  }

  render-date-element(actual_date)

  // AFMAN 33-326 §4.1.1.2: the sender's address element begins 2.5 inches
  // from the top of the page — 4 line spaces below the date (3 blank lines).
  // When the letterhead alone identifies the sender and no sender element is
  // supplied, the receiver's address element takes this anchor instead.
  blank-lines(3)
  if not falsey(sender) {
    render-address-element(sender)
    // AFMAN 33-326 §4.1.1.3: receiver's address three line spaces below the
    // sender's address element (2 blank lines).
    blank-lines(2)
  }
  render-address-element(recipient)

  // AFMAN 33-326 §4.1.1.4: salutation two line spaces under the receiver's
  // address (1 blank line).
  blank-line()
  render-salutation(salutation)

  // AFH 33-337: "Start the text of a letter two line spaces below the
  // salutation element" (1 blank line). Emitted here so the v() lands at the
  // same lexical level as the heading sections.
  blank-line()
  it
}
