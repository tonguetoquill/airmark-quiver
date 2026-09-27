// Every Google Fonts family that is small caps natively and has an italic
// (`fetch_fonts.py --survey`), less Fragment Mono SC and the Alumni Sans SC
// display cut. Set as plain text: no `smallcaps()`.

#import "candidates.typ": tag-line

#set page(width: 8.5in, height: auto, margin: 0.5in)
#set text(font: "NimbusRomNo9L", size: 10pt)

// Family names as Typst reads them: an optical-size axis names the instance
// after its default size.
#let native = (
  ("Spectral SC", "serif"),
  ("Bona Nova SC", "serif"),
  ("Alegreya SC", "serif"),
  ("Playfair Display SC", "serif, high contrast"),
  ("Bodoni Moda SC 11pt", "serif, high contrast"),
  ("Alegreya Sans SC", "sans"),
  ("Arsenal SC", "sans"),
  ("Alumni Sans SC", "sans, condensed"),
)

#let sample(font, italic) = stack(
  spacing: 7pt,
  ..("Aim High", "Semper Supra", "Ad Astra Per Aspera").map(m => tag-line(
    font, m, italic: italic, caps: "native",
  )),
)

#text(size: 14pt, weight: "bold")[Tag line — native small caps with an italic]
#v(-4pt)
15pt, letterhead blue \#355e93, weight 400, plain text: the faces' own
lowercase are small caps.
#v(6pt)

#table(
  columns: (1.7in, 1fr, 1fr),
  inset: (x: 8pt, y: 8pt),
  stroke: (x, y) => if y > 0 { (top: 0.5pt + luma(200)) },
  align: (left + horizon, center + horizon, center + horizon),
  table.header([], strong[Small caps], strong[Italic small caps]),
  ..native.map(((font, note)) => ([*#font* \ #note], sample(font, false), sample(font, true))).flatten(),
)
