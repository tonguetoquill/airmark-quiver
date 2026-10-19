// Type and geometry every citation shares, in points on a us-letter page.

#let font = "Liberation Serif"

#let size = (
  title: 21.5pt,
  medal: 15.6pt,
  line: 11.7pt,
  small: 9.8pt,
)

// The paragraph sets at the largest size that fits its space, down to `min`.
#let accomplishments = (
  max: 15pt,
  min: 11pt,
  step: 0.5pt,
  side: 36pt,
)

#let medal-image = (top: 32pt, height: 96pt)

#let closing = (
  // The signer column's left edge: the date line, the rule, and the signer's lines.
  column: 82.7pt,
  rule: 211pt,
  // The signer writes between the date line and the rule.
  signing-gap: 44pt,
  line-pitch: 13.5pt,
  name-drop: 15.4pt,
  // The signer's last line starts here, so its descenders stay on the page.
  last-line: 769pt,
  seal-x: 464.7pt,
  seal: 69.5pt,
)
