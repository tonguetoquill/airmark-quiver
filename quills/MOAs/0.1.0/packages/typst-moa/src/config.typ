// config.typ — constants for the DoDI 4000.19 Memorandum of Agreement package

// =============================================================================
// SPACING  (1-inch margins, standard official-correspondence stock)
// =============================================================================
#let spacing = (
  line: .5em, // par.leading — single-spacing within a paragraph
  margin: 1in, // left / right / top / bottom margins
)

// =============================================================================
// TYPOGRAPHY
// =============================================================================
#let DEFAULT_BODY_FONTS = ("NimbusRomNo9L", "times new roman")

// =============================================================================
// DECIMAL OUTLINE NUMBERING
// =============================================================================
// DoDI 4000.19 Figure 1 uses chained decimal numbering (1., 4.1., 6.1.1.1.)
// with the first line of each item indented per its nesting depth; wrapped
// lines return to the left margin (no hanging indent). Tab stops taper after
// the first level (0.5in, then +0.4in per level), matching Figure 1's own
// spacing and the standard AFH 33-337 indent scheme used elsewhere in this
// repo — not a flat 0.5in-per-level step, which over-indents nested items.
#let INDENT_TABLE = (0pt, 0.5in, 0.9in, 1.3in)

#let indent-for(depth) = INDENT_TABLE.at(calc.min(depth, INDENT_TABLE.len() - 1))

// =============================================================================
// TITLE BLOCK / SIGNATURE PLACEMENT
// =============================================================================
#let TITLE_TOP_GAP = 0.5in // space from top margin to first title-block line
