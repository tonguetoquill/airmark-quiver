#import "config.typ": *

#let blank(v) = v == none or v == [] or v == ""

// A line set with no height, so `above` is its baseline's drop from the line
// above it.
#let heading-line(body, above: 0pt, size: size.line, bold: false) = {
  v(above)
  align(center, text(
    size: size,
    weight: if bold { "bold" } else { "regular" },
    top-edge: "baseline",
    body,
  ))
}

#let paragraph(body, text-size) = block(width: 100%, {
  set text(size: text-size, top-edge: accomplishments.top-edge)
  set par(justify: true, leading: accomplishments.pitch - accomplishments.top-edge)
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

#let closing-block(date, signer, signing-field: none) = {
  let at(dy, body) = place(top + left, dx: closing.column, dy: dy, body)
  let centered(dy, body) = place(top + left, dy: dy, block(width: 100%, body))
  set text(size: size.line, top-edge: "baseline")
  centered(closing.given, heading-line(size: size.heading)[GIVEN UNDER MY HAND])
  centered(closing.given + pitch.single, heading-line(date, bold: true))
  if signing-field != none {
    at(closing.rule - closing.signing, signing-field(closing.rule-length, closing.signing))
  }
  at(closing.rule, line(length: closing.rule-length, stroke: 0.6pt))
  for (i, l) in signer.enumerate() {
    at(closing.rule + closing.name-drop + i * pitch.single, l)
  }
  let seal = closing.seal
  place(top + left, dx: seal.x, dy: seal.y, image("seal.png", width: seal.size))
}

// `entries` pairs each label with its value; a blank value prints no entry.
#let footer-block(entries) = {
  set text(size: footer.size, weight: "bold", top-edge: "baseline")
  for ((label, value), stop) in entries.zip(footer.stops) {
    if not blank(value) { place(top + left, dx: stop, dy: footer.baseline)[#label: #value] }
  }
}
