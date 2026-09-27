// Every serif family on Google Fonts whose upright and italic both carry smcp
// (`fetch_fonts.py --survey`), less the Tiro Indic families, the SC cuts of
// families already here, and near-duplicates.

#import "candidates.typ": tag-line

#set page(width: 8.5in, height: auto, margin: 0.5in)
#set text(font: "NimbusRomNo9L", size: 10pt)

// Family names as Typst reads them: an optical-size axis names the instance
// after its default size.
#let survey = (
  ("EB Garamond", "the first round's pick"),
  ("Alegreya", ""),
  ("Ancizar Serif", ""),
  ("Andada Pro", ""),
  ("Bitter", "slab"),
  ("Bodoni Moda 11pt", "high contrast"),
  ("Bona Nova", ""),
  ("Brygada 1918", ""),
  ("Castoro", ""),
  ("Charis SIL", ""),
  ("Gentium Book Plus", ""),
  ("Ibarra Real Nova", ""),
  ("Literata 12pt", "italic small caps near upright"),
  ("Merriweather 18pt", ""),
  ("Neuton", ""),
  ("Noto Serif", ""),
  ("Petrona", ""),
  ("Piazzolla", ""),
  ("Playfair Display", "high contrast"),
  ("Poltawski Nowy", ""),
  ("Spectral", ""),
  ("STIX Two Text", "Times-like"),
  ("Zilla Slab", "slab"),
)

#let sample(font, italic) = stack(
  spacing: 7pt,
  tag-line(font, "Aim High", italic: italic),
  tag-line(font, "Ad Astra Per Aspera", italic: italic),
)

#text(size: 14pt, weight: "bold")[Tag line — Google Fonts with italic small caps]
#v(-4pt)
15pt, letterhead blue \#355e93, weight 400, Typst `smallcaps()`.
#v(6pt)

#table(
  columns: (1.7in, 1fr, 1fr),
  inset: (x: 8pt, y: 8pt),
  stroke: (x, y) => if y > 0 { (top: 0.5pt + luma(200)) },
  align: (left + horizon, center + horizon, center + horizon),
  table.header([], strong[Small caps], strong[Italic small caps]),
  ..survey.map(((font, note)) => (
    [*#font* #if note != "" [\ #note]],
    sample(font, false),
    sample(font, true),
  )).flatten(),
)
