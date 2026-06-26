#import "@local/quillmark-helper:0.1.0": data
#import "@local/wrap-it:0.1.1": wrap-content

// ---------------------------------------------------------------------------
// U.S. Air Force Official Biography — AFH 33-337 (Tongue and Quill), Ch. 20
// Layout matched against the official Word template
// (Official_Bio_Template_7oct2020.dotx, e-Publishing):
//   - US letter, 1 in margins; body Arial (Arimo) 9 pt, justified,
//     1.15 line spacing (Word w:line=276), blank line between paragraphs
//   - First-page-only banner in the header area (0.5 in from the page top):
//     "BIOGRAPHY" in Times New Roman (NimbusRomNo9L) 28 pt regular and the
//     service line in Arial 14 pt italic with 3 pt letter tracking, centered
//   - Identification line: Arial 13.5 pt bold caps, left-aligned
//   - Official photo: 3.2 in x 4 in (Word table cell 4608 x 5760 twips),
//     floated right with 0.125 in text gutter, top aligned with the first
//     paragraph; text wraps around it
//   - Section headings: Arial 9 pt bold ALL CAPS, no colon
//   - ASSIGNMENTS / CAREER CHRONOLOGY and SUMMARY OF JOINT ASSIGNMENTS:
//     auto-numbered entries with a 0.1875 in hanging indent
//   - Trailing "(Current as of Month Year)" uses the Section Heading style
//     (bold, ALL CAPS) per the template
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
#set par(leading: body-leading, spacing: par-spacing, justify: true)

// --- First-page banner (Word first-page header, 0.5 in from page top) -------
// Replicates the template's header paragraph stack: two empty Arial 9 single-
// spaced lines, BIOGRAPHY (28 pt, 1 pt space after), two empty lines, the
// service line (14 pt), and two trailing empty lines that push the body down.
#let service = upper(data.at("service", default: "UNITED STATES AIR FORCE"))
#let hline = 10.35pt // single-spaced Arial 9 header line
#let banner-stack = stack(
  block(height: 2 * hline),
  block(
    height: 33.2pt, // 28 pt single-spaced line + 1 pt space after
    width: 100%,
    align(center + horizon, text(font: "NimbusRomNo9L", size: 28pt)[BIOGRAPHY]),
  ),
  block(height: 2 * hline),
  block(
    height: 16.1pt,
    width: 100%,
    align(center + horizon, text(size: 14pt, style: "italic", tracking: 3pt, service)),
  ),
  block(height: 2 * hline),
)
#place(top + center, dy: -0.5in, banner-stack)
// Body resumes below the header block (0.5 in + stack height), not at the
// 1 in margin, exactly as Word pushes the first-page body down.
#v(0.5in + 111.6pt - 1in)

// --- Identification line (left-aligned per template's Normal-based style) ---
#text(size: 13.5pt, weight: "bold", upper(data.name))

// --- Section helpers -----------------------------------------------------------
// Sections are emitted as flat inline sequences (heading + linebreak-separated
// entries) rather than `par(..)` blocks so the photo text-wrap can split a
// section between lines, the way Word's square wrap does. `hanging` applies
// Word's List Paragraph geometry (0.1875 in hanging indent): the paragraph
// indents every line after the first, and each entry's first line backs out
// of the indent so only wrapped continuation lines are inset.
#let section(title, entries, hanging: 0pt) = {
  parbreak()
  {
    set par(hanging-indent: hanging)
    text(weight: "bold", upper(title))
    for it in entries {
      linebreak()
      if hanging != 0pt { h(-hanging) }
      it
    }
  }
}

// Numbered section (ASSIGNMENTS, SUMMARY OF JOINT ASSIGNMENTS): decimal
// numbering with the template's 0.1875 in hanging indent.
#let numbered-section(title, items) = section(
  title,
  items.enumerate().map(((i, it)) => [#(i + 1). #it]),
  hanging: 0.1875in,
)

// --- Document content (narrative + sections), wrapped around the photo --------
#let contents = {
  data.at("$body")

  if data.at("education", default: ()).len() > 0 {
    section("EDUCATION", data.education)
  }

  if data.at("assignments", default: ()).len() > 0 {
    let heading = if data.at("civilian", default: false) { "CAREER CHRONOLOGY" } else { "ASSIGNMENTS" }
    numbered-section(heading, data.assignments)
  }

  if data.at("joint_assignments", default: ()).len() > 0 {
    numbered-section("SUMMARY OF JOINT ASSIGNMENTS", data.joint_assignments)
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

  if data.at("badges", default: ()).len() > 0 {
    section("OCCUPATIONAL BADGES", data.badges)
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

  // The template styles this line as a Section Heading (bold, ALL CAPS).
  if "current_as_of" in data and data.current_as_of != "" {
    parbreak()
    text(weight: "bold", upper[(Current as of #data.current_as_of)])
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
    column-gutter: 0.125in,
  )
} else {
  contents
}
