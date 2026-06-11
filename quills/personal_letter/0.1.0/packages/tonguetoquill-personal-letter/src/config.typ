// config.typ: Configuration constants and defaults for the USAF personal letter
//
// This module defines core configuration values that implement AFH 33-337
// "The Personal Letter" formatting requirements (see also AFMAN 33-326,
// "Personalized Letter", for the inch/line-space anchors cited below).

// =============================================================================
// SPACING CONSTANTS
// =============================================================================

#let spacing = (
  line: .5em, // Internal line spacing for readability (`par.leading`; gap between line boxes)
  margin: 1in, // AFH 33-337: 1-inch margins on the left, right and bottom
)

// =============================================================================
// TYPOGRAPHY DEFAULTS
// =============================================================================
// AFH 33-337 "The Personal Letter": "Font size should be Times New Roman 12 point."

#let DEFAULT_LETTERHEAD_FONTS = ("Copperplate CC", "NimbusRomNo9L")
#let DEFAULT_BODY_FONTS = ("NimbusRomNo9L",) // Metric-compatible Times New Roman clone
// Static monospace face for raw/code text, metric-compatible with Courier New.
#let DEFAULT_MONO_FONTS = ("Liberation Mono",)
#let LETTERHEAD_COLOR = rgb("#355e93") // Faded USAF blue for letterhead

// =============================================================================
// PARAGRAPH CONFIGURATION
// =============================================================================
// AFH 33-337 "The Personal Letter" / AFMAN 33-326 §4.1.2:
// "DO NOT number paragraphs. Indent all major paragraphs 0.5 inch or five
// spaces; indent subparagraphs an additional 0.5 inch or five spaces."
// Indentation applies to the first line only; turnover lines return to the
// left margin (see the AFH 33-337 personal letter examples).

#let letter-paragraph = (
  first-line-indent: 0.5in,
  nested-step: 0.5in,
)

// =============================================================================
// CLOSING GEOMETRY
// =============================================================================
// AFH 33-337 / AFMAN 33-326 §4.1.3.1: the complimentary close (and the
// signature element aligned with it) sits "4.5 inches from the left edge of
// the page or three spaces to the right of page center". On 8.5in stock these
// coincide, so 4.5in is the canonical anchor.

#let CLOSING_ANCHOR = 4.5in
