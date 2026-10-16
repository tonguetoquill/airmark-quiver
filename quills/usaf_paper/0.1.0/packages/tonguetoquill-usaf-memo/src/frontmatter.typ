// The memorandum's heading section, and the page setup the rest of the
// document inherits: AFH 33-337 Chapter 14 "The Heading Section".

#import "primitives.typ": *

#let frontmatter(
  subject: none,
  memo-for: none,
  memo-from: none,
  date: none,
  // Fill-in widget printed on the date line for an omitted `date`, in place of
  // today's date. An indorsement header restating the memo then leaves the date
  // out.
  date-field: none,
  references: none,
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead-seal: none,
  letterhead-seal-subtitle: none, // optional line under seal (9pt bold caps); ignored if no seal
  letterhead-emblem: none, // optional image placed opposite the seal (right side)
  letterhead-emblem-height: 1in, // emblem fit-box height; reduce for shorter emblems
  letterhead-font: DEFAULT_LETTERHEAD_FONTS,
  body-font: DEFAULT_BODY_FONTS,
  font-size: 12pt,
  memo-for-cols: 3,
  classification-level: none,
  dissemination: none,
  cui-controlled-by: none,
  cui-category: none,
  cui-limited-dissemination: none,
  cui-poc: none,
  footer-tag-line: none,
  memo-style: "usaf",
  it,
) = {
  assert(subject != none, message: "subject is required")
  assert(memo-for != none, message: "memo-for is required")
  assert(
    memo-style in ("usaf", "daf"),
    message: "memo-style must be \"usaf\" or \"daf\"",
  )

  let actual-date = if date != none { date } else if date-field != none { date-field } else { datetime.today() }

  // The banner is `LEVEL` or `LEVEL//SUFFIX`. `classification-level` is an enum
  // (a `str`), but `dissemination` may arrive as content, which `str + str`
  // cannot absorb — so the marking is assembled as content instead.
  let classification-marking = if classification-level == none or type(classification-level) != str {
    none
  } else {
    let base = classification-level.trim()
    if base == "" {
      none
    } else if falsey(dissemination) {
      [#base]
    } else {
      // `//` is a line comment in Typst markup, so the separator is
      // interpolated as a string rather than written literally. The suffix is
      // boxed so the markup block's edge newlines do not read as a space and
      // split the banner into `CUI// NF`.
      let separator = "//"
      [#base#separator#box(upper(dissemination))]
    }
  }
  let classification-color = get-classification-level-color(classification-level)

  // Build the CUI designation indicator block (DoDM 5200.48, Table 1), shown
  // only for CUI when at least one indicator field is set. Rendered as a
  // bottom-right page-1 float (see placement below).
  let cui-indicator = if (
    classification-level != none
    and type(classification-level) == str
    and classification-level.trim().starts-with("CUI")
  ) {
    // An indicator may arrive as content or as a `str`; `falsey` is the
    // presence test that reads both shapes.
    let lines = ()
    if not falsey(cui-controlled-by) {
      lines.push([Controlled By: #cui-controlled-by])
    }
    if not falsey(cui-category) {
      lines.push([CUI Category: #cui-category])
    }
    if not falsey(cui-limited-dissemination) {
      lines.push([LDC: #upper(cui-limited-dissemination)])
    }
    if not falsey(cui-poc) {
      lines.push([POC: #cui-poc])
    }
    if lines.len() > 0 { lines.join(linebreak()) } else { none }
  } else {
    none
  }

  let tag-line = if falsey(footer-tag-line) {
    none
  } else {
    align(center, text(fill: LETTERHEAD_COLOR, font: "Spectral SC", size: 15pt)[#footer-tag-line])
  }

  set par(leading: spacing.line, spacing: spacing.line, justify: false)
  set block(above: spacing.line, below: 0em, spacing: 0em)
  set text(font: body-font, size: font-size, fallback: true)
  show raw: set text(font: DEFAULT_MONO_FONTS)

  set page(
    paper: "us-letter",
    // AFH 33-337 §4: "Use 1-inch margins on the left, right and bottom"
    margin: (
      left: spacing.margin,
      right: spacing.margin,
      top: spacing.margin,
      bottom: spacing.margin,
    ),
    header: {
      // AFH 33-337 "Page numbering" §12: "The first page of a memorandum is never numbered.
      // Number the succeeding pages starting with page 2. Place page numbers 0.5-inch from
      // the top of the page, flush with the right margin."
      context if counter(page).get().first() > 1 {
        place(
          dy: +.5in,
          block(
            width: 100%,
            align(right, text(12pt)[#counter(page).display()]),
          ),
        )
      }

      if classification-marking != none {
        place(
          top + center,
          dy: 0.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: classification-color)[#strong(classification-marking)],
        )
      }
    },
    footer: {
      if classification-marking != none {
        place(
          bottom + center,
          dy: -.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: classification-color)[#strong(classification-marking)],
        )
      }

      // Page 1's tag line rides the indicator block's float when there is one.
      if tag-line != none {
        context if cui-indicator == none or here().page() > 1 {
          place(bottom + center, dy: -0.625in, tag-line)
        }
      }
    },
  )

  // DoDM 5200.48 §3: CUI designation indicator block — page 1 only, bottom-right
  // corner, dropped into the 0.5in page-edge band. Emitted as a bottom float so
  // it (1) reserves flow space, raising page 1's effective bottom margin so body
  // text never overlaps it, and (2) stays pinned to page 1 — as the first flow
  // content it can never be bumped to page 2. Page 1's tag line stands above the
  // block in the same float, since both claim the band.
  if cui-indicator != none {
    context {
      // The box shrink-wraps to its widest line; `set align(left)` keeps the
      // text flush-left within it, overriding the `align(right)` the placement
      // below imposes.
      let indicator-box = box({
        set text(font: DEFAULT_BODY_FONTS, size: 10pt)
        set par(leading: 0.4em, spacing: 0pt)
        set align(left)
        cui-indicator
      })
      let block-height = measure(indicator-box).height
      let tag-gap = 0.125in
      let stack-height = if tag-line == none {
        block-height
      } else {
        block-height + tag-gap + measure(tag-line, width: page.width - 2 * spacing.margin).height
      }
      // Reserve only the part of the stack inside the text area (`reserved`):
      // float a box of that height, then `place` the stack inside it pushed down
      // by `overhang` so the surplus overflows into the edge band. (A bare
      // `box(height: reserved, indicator-box)` overflows *upward* into the body
      // instead.) The inner `place`s add no size, so the box stays `reserved`
      // tall and the block's bottom lands 0.5in from the page edge.
      let overhang = spacing.margin - 0.5in
      let reserved = stack-height - overhang
      place(
        bottom,
        float: true,
        // Minimum gap to the body's last line; the actual gap is larger when the
        // next paragraph can't fit above the block and breaks to the next page.
        clearance: spacing.line,
        box(width: 100%, height: reserved, {
          // Slide the block's right edge into the page-edge band, 0.5in from
          // the border.
          place(bottom + right, dx: spacing.margin - 0.5in, dy: overhang, indicator-box)
          if tag-line != none {
            place(bottom + center, dy: overhang - block-height - tag-gap, tag-line)
          }
        }),
      )
    }
  }

  render-letterhead(
    letterhead-title,
    letterhead-caption,
    letterhead-font,
    letterhead-seal: letterhead-seal,
    letterhead-seal-subtitle: letterhead-seal-subtitle,
    letterhead-emblem: letterhead-emblem,
    letterhead-emblem-height: letterhead-emblem-height,
  )

  // AFH 33-337 "Date": "Place the date 1 inch from the right edge, 1.75 inches from the top"
  // Since we have a 1-inch top margin, we need (1.75in - margin) vertical space
  v(1.75in - spacing.margin)

  // Measure one line's stride once, under the typography just set, for the
  // blank-line spacing the sections below and the body are laid out on.
  context {
    let one-line = measure(par(spacing: 0pt)[x]).height
    LINE_STRIDE.update(measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line)
  }

  [#metadata((
    subject: subject,
    original-date: if date == none and date-field != none { none } else { actual-date },
    original-from: first-or-value(memo-from),
    body-font: body-font,
    font-size: font-size,
    memo-style: memo-style,
  )) <usaf-memo-config>]

  render-date-section(actual-date, memo-style: memo-style)
  render-for-section(memo-for, memo-for-cols)
  if not falsey(memo-from) { render-from-section(memo-from) }
  // Blank entries are dropped first so a stub `- ` left under `references:`
  // cannot pass as the lone reference and render an empty `()` after the subject.
  let refs = compact-references(references)
  let single-ref = if refs.len() == 1 { refs.at(0) } else { none }
  render-subject-section(subject, inline-reference: single-ref)
  render-references-section(refs)

  // AFH 33-337: "Begin text on second line below subject/references".
  // Emitted here (not inside body.typ) so the v() lands at the same lexical
  // level as the preceding header sections and combines correctly with their
  // block spacing.
  blank-line()
  it
}
