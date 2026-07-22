// config.typ — constants for AFH 33-337 Ch. 15 personal letter

// =============================================================================
// SPACING  (1-inch margins; same stock as the official memo)
// =============================================================================
#let spacing = (
  line: .5em,   // par.leading — tight single-spacing
  margin: 1in,  // left / right / top / bottom margins
)

// =============================================================================
// TYPOGRAPHY
// =============================================================================
// Ch. 15 inherits the same font standard as the memo (Times New Roman 12pt).
#let DEFAULT_BODY_FONTS        = ("NimbusRomNo9L", "times new roman")
#let DEFAULT_LETTERHEAD_FONTS  = ("Copperplate CC", "NimbusRomNo9L", "times new roman")
#let LETTERHEAD_COLOR          = rgb("#355e93")  // USAF blue for letterhead text

// =============================================================================
// PARAGRAPH
// =============================================================================
// Ch. 15: "Do not number the paragraphs."
// "if there are sub-paragraphs, follow the same guidance for sub-paragraph
//  numbering and indentation as in the official memorandum."
// Sub-paragraph numbering levels (level 0 = top-level, never numbered):
#let SUBPAR_FORMATS = ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n)))

// Ch. 15: "Indent the first line of text for all major paragraphs 0.5 inches."
#let PARA_INDENT = 0.5in

// =============================================================================
// CLOSING PLACEMENT
// =============================================================================
// Ch. 15: "Place 'Sincerely' … 4.5 inches from the left edge of the page …"
// "Place the signature element on the fifth line below and aligned with the
//  complimentary close (4.5 inches from the left edge of the page)."
#let CLOSE_LEFT = 4.5in

// =============================================================================
// CLASSIFICATION COLORS  (DoD/CAPCO standard)
// =============================================================================
#let CLASSIFICATION_COLORS = (
  "TOP SECRET":   rgb(255, 103, 31),
  "SECRET":       rgb(200,  16, 46),
  "CONFIDENTIAL": rgb(0,     0,  0),
  "CUI":          rgb(0,     0,  0),
  "UNCLASSIFIED": rgb(0,   122, 51),
)
