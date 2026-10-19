#import "config.typ": *

#let blank(v) = v == none or v == [] or v == ""

#let ordinal-suffix(n) = {
  let mod = calc.rem(n, 10)
  let teen = calc.rem(n, 100) >= 11 and calc.rem(n, 100) <= 13
  if teen or mod == 0 or mod >= 4 { "th" }
  else if mod == 1 { "st" }
  else if mod == 2 { "nd" }
  else { "rd" }
}

#let heading-line(body, size: size.line, bold: false) = align(center, text(
  size: size,
  weight: if bold { "bold" } else { "regular" },
  body,
))

#let cluster-line(oak-leaf-cluster) = {
  if blank(oak-leaf-cluster) or oak-leaf-cluster == "Basic" { return none }
  heading-line(upper(oak-leaf-cluster), bold: true)
}

#let paragraph(body, text-size) = block(width: 100%, {
  // The first line's ascenders stand inside the clip.
  set text(size: text-size, top-edge: "ascender")
  set par(justify: true, leading: 0.5em, spacing: 0.65em)
  // A pasted line break reflows across the block.
  show linebreak: [ ]
  show parbreak: [ ]
  body
})

// Fills from the cursor to `bottom`, at the largest size that fits; past `min`
// it clips.
#let accomplishments-block(body, bottom) = context {
  let top = here().position().y
  let height = bottom - top
  let width = page.width - 2 * accomplishments.side
  let fits(s) = measure(width: width, paragraph(body, s)).height <= height
  let steps = int((accomplishments.max - accomplishments.min) / accomplishments.step)
  let chosen = range(steps + 1)
    .map(i => accomplishments.max - i * accomplishments.step)
    .find(fits)
  let text-size = if chosen == none { accomplishments.min } else { chosen }
  pad(x: accomplishments.side, block(height: height, clip: true, paragraph(body, text-size)))
}

// The signer's lines stand on the page bottom; the rule, the signing space and
// the date line rise above them, and the seal centers on the rule.
#let rule-top(signer-lines) = (
  closing.last-line - (signer-lines - 1) * closing.line-pitch - closing.name-drop
)

#let given-top(signer-lines, given-lines) = (
  rule-top(signer-lines) - closing.signing-gap - (given-lines - 1) * closing.line-pitch
)

#let closing-block(given, signer, signing-field: none) = {
  let rule-dy = rule-top(signer.len())
  let given-dy = given-top(signer.len(), given.len())
  let at(dy, body) = place(top + left, dx: closing.column, dy: dy, body)
  set text(size: size.line)
  for (i, l) in given.enumerate() { at(given-dy + i * closing.line-pitch, l) }
  if signing-field != none {
    let height = closing.signing-gap - closing.line-pitch
    at(rule-dy - height, signing-field(closing.rule, height))
  }
  at(rule-dy, line(length: closing.rule, stroke: 0.6pt))
  for (i, l) in signer.enumerate() {
    at(rule-dy + closing.name-drop + i * closing.line-pitch, l)
  }
  place(top + left, dx: closing.seal-x, dy: rule-dy - closing.seal / 2, image("seal.png", width: closing.seal))
}
