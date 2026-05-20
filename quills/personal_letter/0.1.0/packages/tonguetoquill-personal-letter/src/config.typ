// config.typ: Configuration constants for personal letter template (AFH 33-337 Ch. 15)

// =============================================================================
// SPACING CONSTANTS
// =============================================================================

#let spacing = (
  line: .5em,   // Internal line spacing (par.leading)
  margin: 1in,  // AFH 33-337 Ch. 15: 1-inch margins (same as memo)
)

// =============================================================================
// TYPOGRAPHY DEFAULTS
// =============================================================================
// AFH 33-337 §5: Times New Roman 12pt (shared with memo standard)

#let DEFAULT_LETTERHEAD_FONTS = ("Copperplate CC", "NimbusRomNo9L", "times new roman")
#let DEFAULT_BODY_FONTS = ("NimbusRomNo9L", "times new roman")
#let LETTERHEAD_COLOR = rgb("#355e93")

// =============================================================================
// PARAGRAPH CONFIGURATION
// =============================================================================
// AFH 33-337 Ch. 15: "Do not number the paragraphs."
// Sub-paragraphs: "follow the same guidance for sub-paragraph numbering and
// indentation as in the official memorandum."
// Numbering applies only to levels 1+ (a., (1), (a), ...)

#let paragraph-config = (
  // Level 0 format is unused (top-level paragraphs are unnumbered)
  // Levels 1+: a., (1), (a), ...
  numbering-formats: ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n))),
)

// AFH 33-337 Ch. 15: "Indent the first line of text for all major paragraphs 0.5 inches"
#let PARA_FIRST_LINE_INDENT = 0.5in

// =============================================================================
// SIGNATURE / COMPLIMENTARY CLOSE PLACEMENT
// =============================================================================
// AFH 33-337 Ch. 15: "Place 'Sincerely' ... 4.5 inches from the left edge of
// the page or three spaces to the right of page center."
// "Place the signature element on the fifth line below and aligned with the
// complimentary close (4.5 inches from the left edge of the page)."

#let SIGNATURE_LEFT = 4.5in

// =============================================================================
// CLASSIFICATION COLORS
// =============================================================================

#let CLASSIFICATION_COLORS = (
  "TOP SECRET": rgb(255, 103, 31),
  "SECRET": rgb(200, 16, 46),
  "CONFIDENTIAL": rgb(0, 0, 0),
  "CUI": rgb(0, 0, 0),
  "UNCLASSIFIED": rgb(0, 122, 51),
)
