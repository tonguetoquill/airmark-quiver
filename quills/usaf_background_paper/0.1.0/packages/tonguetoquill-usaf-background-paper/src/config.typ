// Spacing, typography, and banner colors for the bullet background paper.

#let spacing = (
  // AFH 33-337 (27 May 2015), p. 226: "Margins: One (1) inch all around".
  margin: 1in,
)

// AFH 33-337: Times New Roman for text. NimbusRomNo9L is a metric-compatible
// clone; Liberation Mono sets raw text and carries its regular weight alone.
#let DEFAULT_BODY_FONTS = ("NimbusRomNo9L",)
#let DEFAULT_MONO_FONTS = ("Liberation Mono",)

// Extra space between the line boxes of one item. At 12pt this puts a wrapped
// bullet on the sample's single spacing, about 14pt baseline to baseline.
#let single-leading = 0.5em

// DoD/CAPCO marking colors, except CONFIDENTIAL and CUI, set black — the same
// map the memorandum uses.
#let CLASSIFICATION_COLORS = (
  "TOP SECRET": rgb(255, 103, 31),
  "SECRET": rgb(200, 16, 46),
  "CONFIDENTIAL": rgb(0, 0, 0),
  "CUI": rgb(0, 0, 0),
  "UNCLASSIFIED": rgb(0, 122, 51),
)
