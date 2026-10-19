// Type and geometry every citation shares, in points on a us-letter page.

#let font = "TeX Gyre Termes"

#let size = (
  title: 22pt,
  medal: 18pt,
  certify: 16pt,
  heading: 14pt,
  line: 12pt,
)

// Baseline to baseline, from the line above; `title` from the medal image's foot,
// and `preamble` a multiple of the preamble's size.
#let pitch = (
  title: 17.5pt,
  preamble: 2.7,
  medal: 32pt,
  cluster: 18pt,
  awarded: 30.5pt,
  recipient: 28pt,
  for-line: 29.5pt,
  reason: 27.5pt,
  accomplishments: 27pt,
  single: 14pt,
)

#let medal-image = (top: 76pt, height: 136pt)

// The paragraph sets at the largest size that fits its space, down to `min`.
#let accomplishments = (
  max: 10pt,
  min: 8pt,
  step: 0.25pt,
  side: 72pt,
  pitch: 1.01em,
  // The clip's top stands `gap` below the ACCOMPLISHMENTS baseline, and the first
  // baseline `top-edge` below the clip's top, room for an accented capital.
  gap: 2.5pt,
  top-edge: 0.9em,
)

#let closing = (
  // The baseline of GIVEN UNDER MY HAND; the date's is a line below it.
  given: 637pt,
  // The paragraph ends this far above the "GIVEN UNDER MY HAND" baseline.
  clearance: 20pt,
  rule: 693pt,
  column: 72pt,
  rule-length: 180pt,
  // The signer writes in the space this tall above the rule.
  signing: 38pt,
  name-drop: 13.5pt,
  seal: (x: 459pt, y: 654pt, size: 68pt),
)

// The administrative line at the page foot: each entry's left edge, in the order
// Special Order, Condition, PAS, RDP.
#let footer = (
  baseline: 751.5pt,
  size: 8pt,
  stops: (139pt, 251pt, 328pt, 467pt),
)
