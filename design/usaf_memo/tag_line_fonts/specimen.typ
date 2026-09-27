// Every candidate side by side: small caps upright and italic.

#import "candidates.typ": *

#set page(width: 8.5in, height: auto, margin: 0.5in)
#set text(font: "NimbusRomNo9L", size: 10pt)

#let cell(c, italic: false) = stack(
  spacing: 8pt,
  ..mottos.map(m => tag-line(c.font, m, italic: italic, caps: c.caps)),
)

#text(size: 14pt, weight: "bold")[Tag line — small caps candidates]
#v(-4pt)
15pt, letterhead blue \#355e93, weight 400, as the memo footer sets it.
#v(6pt)

#table(
  columns: (2in, 1fr, 1fr),
  inset: (x: 8pt, y: 10pt),
  stroke: (x, y) => if y > 0 { (top: 0.5pt + luma(200)) },
  align: (left + horizon, center + horizon, center + horizon),
  table.header([], strong[Small caps], strong[Italic small caps]),
  ..candidates.map(c => (c.label, cell(c), cell(c, italic: true))).flatten(),
)
