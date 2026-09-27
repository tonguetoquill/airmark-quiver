// The faces whose small caps are not their own lowercase: small caps come from
// smcp, or are faked. Cinzel is native but joins for its faked italic. What a
// face lacks is faked and marked: small caps as scaled capitals, an italic as
// the upright skewed.

#import "candidates.typ": tag-line

#set page(width: 6.5in, height: auto, margin: 0.35in)
#set text(font: "NimbusRomNo9L", size: 10pt)

// (family, note, upright caps, italic caps, italic faked by slant?)
#let pages = (
  (
    "Something faked",
    (
      ("NimbusRomNo9L", "today's face", "synth", "synth", false),
      ("Cinzel", "the package's own; native small caps", "native", "native", true),
      ("Source Serif 4", "", "smcp", "synth", false),
      ("Vollkorn", "", "smcp", "synth", false),
      ("Cardo", "", "smcp", "synth", false),
      ("Baskervville", "", "smcp", "synth", false),
      ("Sorts Mill Goudy", "", "smcp", "synth", false),
      ("Cormorant Garamond", "", "smcp", "synth", false),
      ("GFS Didot", "no italic face", "smcp", "smcp", true),
    ),
  ),
  (
    "Nothing faked: smcp upright and italic",
    (
      ("EB Garamond", "", "smcp", "smcp", false),
      ("STIX Two Text", "Times-like", "smcp", "smcp", false),
      ("Spectral", "", "smcp", "smcp", false),
      ("Castoro", "", "smcp", "smcp", false),
      ("Ibarra Real Nova", "", "smcp", "smcp", false),
      ("Brygada 1918", "", "smcp", "smcp", false),
    ),
  ),
)

#let faked(caps, slant) = {
  let what = ()
  if caps == "synth" { what.push("small caps") }
  if slant { what.push("italic") }
  if what.len() > 0 { text(size: 8.5pt, fill: luma(130), style: "italic")[faked #what.join(" and ")] }
}

// Lines are spaced by their ink: faces' own line metrics differ, and a faked
// small cap's shrunken run can pull a line box short.
#let cell(font, caps, italic, slant) = stack(
  spacing: 6pt,
  tag-line(font, "Aim High", italic: italic, caps: caps, slant: slant),
  tag-line(font, "Ad Astra Per Aspera", italic: italic, caps: caps, slant: slant),
  faked(caps, slant),
)

#set text(top-edge: "bounds", bottom-edge: "bounds")

#for (i, (title, faces)) in pages.enumerate() {
  if i > 0 { pagebreak() }
  text(size: 13pt, weight: "bold")[Non-native small caps — #title]
  v(-4pt)
  text(top-edge: "cap-height", bottom-edge: "baseline")[15pt, letterhead blue, weight 400. Grey notes mark what is faked.]
  v(2pt)
  table(
    columns: (1fr, 1fr),
    inset: (x: 4pt, y: 9pt),
    stroke: (x, y) => if y > 1 and calc.odd(y) { (top: 0.5pt + luma(200)) },
    align: center + horizon,
    table.header(strong[Small caps], strong[Italic small caps]),
    ..faces
      .map(((font, note, caps, italic-caps, slant)) => (
        table.cell(colspan: 2, align: left, inset: (top: 10pt, bottom: 0pt))[
          *#font* #if note != "" { text(fill: luma(90))[— #note] }
        ],
        cell(font, caps, false, false),
        cell(font, italic-caps, true, slant),
      ))
      .flatten(),
  )
}
