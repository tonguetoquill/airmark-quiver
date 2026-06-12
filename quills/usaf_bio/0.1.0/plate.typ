#import "@local/quillmark-helper:0.1.0": data
#import "@local/wrap-it:0.1.1": wrap-content

// ---------------------------------------------------------------------------
// U.S. Air Force Official Biography — AFH 33-337 (Tongue and Quill), Ch. 20
//   - Arial (Arimo) 9 pt body, 1.15 line spacing, bold ALL-CAPS headings
//   - Banner: "BIOGRAPHY" / "UNITED STATES AIR FORCE", centered, bold
//   - Identification line: Arial 13.5 pt bold, uppercase, centered
//   - Official photo: 3.2 in x 4 in, upper right, flush with right margin,
//     aligned with the top of the first paragraph; text wraps around it
//   - Maximum two pages
// ---------------------------------------------------------------------------

#let body-size = 9pt
// Word renders Arial 9 pt at 1.15 line spacing with a ~11.9 pt baseline
// pitch; Typst line pitch here is leading + ~6.2 pt of glyph extent.
#let body-leading = 5.7pt
// A blank line between paragraphs in Word doubles the baseline pitch.
#let par-spacing = 17.6pt

#set page(
  paper: "us-letter",
  margin: 1in,
)
#set text(font: "Arimo", size: body-size, fallback: false)
#set par(leading: body-leading, spacing: par-spacing, justify: false)

// --- Banner ------------------------------------------------------------------
#let service = upper(data.at("service", default: "UNITED STATES AIR FORCE"))
#align(center)[
  #text(size: 14pt, weight: "bold")[BIOGRAPHY]
  #linebreak()
  #text(size: 14pt, weight: "bold")[#service]
]

// --- Identification line -------------------------------------------------------
#align(center, text(size: 13.5pt, weight: "bold", upper(data.name)))

// --- Section helpers -----------------------------------------------------------
// Sections are emitted as flat inline sequences (heading + linebreak-separated
// entries) rather than `par(..)` blocks so the photo text-wrap can split a
// section between lines, the way Word's square wrap does.
#let section(title, entries) = {
  parbreak()
  text(weight: "bold", upper(title))
  for it in entries {
    linebreak()
    it
  }
}

#let numbered(items) = items.enumerate().map(((i, a)) => [#(i + 1). #a])

// --- Document content (narrative + sections), wrapped around the photo --------
#let contents = {
  data.at("$body")

  if data.at("education", default: ()).len() > 0 {
    section("EDUCATION", data.education)
  }

  if data.at("assignments", default: ()).len() > 0 {
    section("ASSIGNMENTS", numbered(data.assignments))
  }

  if data.at("joint_assignments", default: ()).len() > 0 {
    section("SUMMARY OF JOINT ASSIGNMENTS", numbered(data.joint_assignments))
  }

  if data.at("flight_information", default: ()).len() > 0 {
    section("FLIGHT INFORMATION", data.flight_information)
  }

  if data.at("awards", default: ()).len() > 0 {
    section("MAJOR AWARDS AND DECORATIONS", data.awards)
  }

  if data.at("other_achievements", default: ()).len() > 0 {
    section("OTHER ACHIEVEMENTS", data.other_achievements)
  }

  if data.at("publications", default: ()).len() > 0 {
    section("PUBLICATIONS", data.publications)
  }

  if data.at("professional_memberships", default: ()).len() > 0 {
    section("PROFESSIONAL MEMBERSHIPS AND ASSOCIATIONS", data.professional_memberships)
  }

  if data.at("promotions", default: ()).len() > 0 {
    section("EFFECTIVE DATES OF PROMOTION", data.promotions.map(p => [#p.rank #p.date]))
  }

  if "current_as_of" in data and data.current_as_of != "" {
    parbreak()
    [(Current as of #data.current_as_of)]
  }
}

#if data.at("show_photo", default: true) {
  let photo = box(
    image("assets/photo_placeholder.png", width: 3.2in, height: 4in),
  )
  wrap-content(
    photo,
    contents,
    align: top + right,
    columns: (1fr, 3.2in),
    column-gutter: 0.25in,
  )
} else {
  contents
}
