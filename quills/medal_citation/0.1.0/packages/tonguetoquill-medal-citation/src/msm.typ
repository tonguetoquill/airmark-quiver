#let font = "Liberation Serif"

#let blank(v) = v == none or v == [] or v == ""

#let citation(f) = {
  set page(paper: "us-letter", margin: 0pt)
  set text(font: font, size: 15pt, fill: black, hyphenate: false)
  set par(leading: 0.5em, spacing: 0.5em)

  // Headings sit 2.4pt right of the page center, matching the certificate.
  let heading(dy, size, weight, body) = {
    place(center + top, dx: 2.4pt, dy: dy, text(size: size, weight: weight, body))
  }

  place(top + left, dx: 187.6pt, dy: 47.3pt, image("medal-msm.png", width: 242.2pt))

  heading(162.7pt, 22.5pt, "bold")[THE UNITED STATES OF AMERICA]
  heading(188.0pt, 13.7pt, "regular")[TO ALL WHO SHALL SEE THESE PRESENTS, GREETING:]
  heading(203.9pt, 13.7pt, "regular")[THIS IS TO CERTIFY THAT THE PRESIDENT OF THE UNITED STATES OF]
  heading(219.8pt, 13.7pt, "regular")[AMERICA AUTHORIZED BY EXECUTIVE ORDER, 16 JANUARY 1969]
  heading(235.6pt, 13.7pt, "regular")[HAS]
  heading(251.5pt, 13.7pt, "regular")[AWARDED]
  heading(270.2pt, 17.6pt, "bold")[THE MERITORIOUS SERVICE MEDAL]
  // The medal name ends near 288pt and "TO" starts at 314pt.
  let cluster = if blank(f.oak_leaf_cluster) or f.oak_leaf_cluster == "Basic" { none } else { upper(f.oak_leaf_cluster) }
  if cluster != none {
    heading(293.5pt, 11.7pt, "bold", cluster)
  }
  heading(314.9pt, 12.7pt, "bold")[TO]
  heading(339.9pt, 9.8pt, "regular", upper(f.rank))
  heading(352pt, 12.7pt, "bold")[FOR]
  heading(366pt, 11.7pt, "regular", upper(f.service))
  heading(379pt, 9.8pt, "regular")[#f.period_from #h(8pt) TO #h(8pt) #f.period_to]
  heading(391pt, 12.7pt, "bold")[ACCOMPLISHMENTS]
  let side = 36pt
  let story-w = 612pt - side - side
  let story-dy = 429pt
  let story = block(width: story-w, {
    set par(justify: true, leading: 0.5em, spacing: 0.65em)
    show linebreak: [ ]
    show parbreak: [ ]
    f.accomplishments
  })
  place(top + left, dx: side, dy: story-dy, story)

  heading(694pt, 9.8pt, "regular")[GIVEN UNDER MY HAND]
  heading(706pt, 9.8pt, "regular", f.signed_on)
  place(top + left, dx: 82.7pt, dy: 726pt, line(length: 158pt, stroke: 0.6pt))
  place(top + left, dx: 271.8pt, dy: 718pt, image("seal.png", width: 69.6pt))
  place(top + left, dx: 82.7pt, dy: 734pt, text(size: 11.7pt, f.commander_name))
  place(top + left, dx: 82.7pt, dy: 748pt, text(size: 11.7pt, f.commander_grade))
  place(top + left, dx: 82.7pt, dy: 762pt, text(size: 11.7pt, f.commander_title))
}
