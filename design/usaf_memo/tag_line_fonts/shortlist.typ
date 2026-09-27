// The letterhead-grade faces with small caps, one page per tier, at the
// footer's true 15pt on a narrow page so the sheet reads large. The italic
// column shows only a real italic small cap; a face without one says so.

#import "candidates.typ": tag-line

#set page(width: 6.5in, height: auto, margin: 0.35in)
#set text(font: "NimbusRomNo9L", size: 10pt)

// (family as Typst reads it, caps mode, italic small caps?, note)
#let tiers = (
  (
    "Native small caps, with italic",
    (
      ("Spectral SC", "native", true, ""),
      ("Playfair Display SC", "native", true, "high contrast"),
      ("Bodoni Moda SC 11pt", "native", true, "high contrast"),
      ("Alegreya SC", "native", true, "calligraphic"),
      ("Bona Nova SC", "native", true, "no bold italic"),
    ),
  ),
  (
    "Native small caps, no italic",
    (
      ("Cinzel", "native", false, "the package's own"),
      ("Cormorant SC", "native", false, ""),
      ("Vollkorn SC", "native", false, ""),
      ("IM FELL English SC", "native", false, "historical, rough"),
      ("Marcellus SC", "native", false, "flared, Trajan-like"),
      ("Baskervville SC", "native", false, ""),
      ("Mate SC", "native", false, ""),
      ("Sedan SC", "native", false, ""),
    ),
  ),
  (
    "Small caps by smcp, with italic small caps",
    (
      ("EB Garamond", "smcp", true, ""),
      ("STIX Two Text", "smcp", true, "Times-like"),
      ("Spectral", "smcp", true, "same design as Spectral SC"),
      ("Castoro", "smcp", true, ""),
      ("Ibarra Real Nova", "smcp", true, ""),
      ("Brygada 1918", "smcp", true, ""),
    ),
  ),
  (
    "Small caps by smcp, upright only",
    (
      ("Source Serif 4", "smcp", false, ""),
      ("Vollkorn", "smcp", false, "Vollkorn SC is its native cut"),
      ("Cardo", "smcp", false, ""),
      ("Baskervville", "smcp", false, "Baskervville SC is its native cut"),
      ("Sorts Mill Goudy", "smcp", false, ""),
      ("Cormorant Garamond", "smcp", false, ""),
      ("GFS Didot", "smcp", false, "no italic at all"),
    ),
  ),
)

#let sample(font, caps, italic) = stack(
  spacing: 6pt,
  ..("Aim High", "Ad Astra Per Aspera").map(m => tag-line(font, m, italic: italic, caps: caps)),
)

#for (i, (title, faces)) in tiers.enumerate() {
  if i > 0 { pagebreak() }
  text(size: 13pt, weight: "bold", title)
  v(-4pt)
  [15pt, letterhead blue, weight 400.]
  v(2pt)
  table(
    columns: (1fr, 1fr),
    inset: (x: 4pt, y: 8pt),
    stroke: (x, y) => if y > 0 and calc.even(y) { (top: 0.5pt + luma(200)) },
    align: center + horizon,
    ..faces
      .map(((font, caps, italic, note)) => (
        table.cell(colspan: 2, align: left, inset: (top: 8pt, bottom: 0pt))[
          *#font* #if note != "" { text(fill: luma(90))[— #note] }
        ],
        sample(font, caps, false),
        if italic { sample(font, caps, true) } else {
          text(fill: luma(140), style: "italic")[no italic small caps]
        },
      ))
      .flatten(),
  )
}
