// Geometry and typography of an AR 25-50 memorandum. Lengths in pt are page
// positions measured from the top-left corner of a US Letter page.

// Termes' cap height. Every text line's top edge sits here, so a bold or
// italic run never grows its line.
#let CAP_HEIGHT = 0.662em

// `par.leading` and `par.spacing`: with the cap height, a 1.15em line pitch,
// single spacing in a 12pt Times face (AR 25-50 2-4b(2)).
#let LEADING = 0.488em
#let LINE = CAP_HEIGHT + LEADING

// AR 25-50 2-3c: 1-inch margins on the left, right and bottom.
#let MARGIN = 1in

#let DEFAULT_BODY_FONTS = ("TeX Gyre Termes",)
#let DEFAULT_MONO_FONTS = ("Liberation Mono",)

// AR 25-50 2-4b(3): each subparagraph level indents a quarter inch.
#let INDENT_STEP = 0.25in
// AR 25-50 1-39b(10): a quarter inch after the parenthesis of `(1)` and `(a)`.
#let PAREN_GAP = 0.25in
// AR 25-50 1-39b(9): two spaces after a period, as after `1.` and `a.`.
#let PERIOD_GAP = "  "

#let numbering-formats = ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n)))

// The DA letterhead template (AR 25-50 1-16): a 1-inch seal in the top-left
// corner, the department in 11pt bold capitals and the organization and
// address in 8pt bold capitals, centered on the page. None of it scales with
// the body text.
#let LETTERHEAD = (
  seal-left: 36pt,
  seal-top: 28.95pt,
  seal-size: 72pt,
  title-size: 11pt,
  title-baseline: 46.25pt,
  line-size: 8pt,
  line-baseline: 56.16pt,
  line-pitch: 9.2pt,
  max-width: 360pt,
)

// AR 25-50 2-4a(1): the office symbol is on the second line below the seal.
#let office-symbol-baseline(font-size) = LETTERHEAD.seal-top + LETTERHEAD.seal-size + 26.37pt * (font-size / 12pt)

// AR 25-50 2-5d: continuation pages are numbered at the center, about an inch
// from the bottom.
#let PAGE_NUMBER_BASELINE = 732.7pt

// The office-symbol line's right column, the width of the longest date.
#let DATE_WIDTH = 8.5em
#let DATE_GUTTER = 18pt

// AR 25-50 2-4a(5)(d): a THRU address stops short of the two boxes each
// office signs and comments in at the right margin.
#let THRU = (
  text-width: 276pt,
  box-width: 90pt,
  box-gap: 6pt,
  box-rise: 3pt,
)

// AR 25-50 2-4c(2)(a): the signature block begins at the center of the page,
// and 2-4c(3) lists enclosures at the left margin beside it.
#let SIGNATURE_INDENT = 4.25in - MARGIN
#let ENCLOSURE_WIDTH = SIGNATURE_INDENT - 18pt
#let TURNOVER = 0.25in
