// Spacing, typography, and color constants for the personal letter layout.

#let spacing = (
  line: .5em, // `par.leading`: the gap between line boxes
  margin: 1in, // AFH 33-337: 1-inch left, right and bottom margins
  // AFH 33-337: the first page's text begins 1.75 inches from the top edge.
  first-page-top: 1.75in,
)

#let DEFAULT_LETTERHEAD_FONTS = ("Copperplate CC", "NimbusRomNo9L")
// AFH 33-337: "the standard font style is Times New Roman and the standard
// point size is 12 points". NimbusRomNo9L is a metric-compatible clone of it;
// Liberation Mono, which sets raw text, is one of Courier New.
#let DEFAULT_BODY_FONTS = ("NimbusRomNo9L",)
#let DEFAULT_MONO_FONTS = ("Liberation Mono",)
#let LETTERHEAD_COLOR = rgb("#355e93") // Faded USAF blue

// AFH 33-337: a personal letter's paragraphs are indented half an inch from
// the left margin and carry no number or letter.
#let letter-paragraph = (
  first-line-indent: 0.5in,
)

// DoD/CAPCO standard marking colors, except CONFIDENTIAL and CUI, which this
// template sets black.
#let CLASSIFICATION_COLORS = (
  "TOP SECRET": rgb(255, 103, 31),
  "SECRET": rgb(200, 16, 46),
  "CONFIDENTIAL": rgb(0, 0, 0),
  "CUI": rgb(0, 0, 0),
  "UNCLASSIFIED": rgb(0, 122, 51),
)
