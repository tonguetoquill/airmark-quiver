#let font = "Liberation Serif"

#let blank(v) = v == none or v == [] or v == ""

#let citation(f) = {
  set page(paper: "us-letter", margin: 0pt)
  set text(font: font, fill: black, hyphenate: false)
  set par(leading: 4.5pt, spacing: 0pt)

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
  heading(376.5pt, 12.7pt, "bold")[FOR]
  heading(403.5pt, 11.7pt, "regular", upper(f.service))
  heading(416.2pt, 9.8pt, "regular")[#f.period_from #h(8pt) TO #h(8pt) #f.period_to]
  heading(442.4pt, 12.7pt, "bold")[ACCOMPLISHMENTS]
  let story = block(width: 451.5pt, text(size: 9.8pt, f.accomplishments))
  let story-dy = 468.8pt
  place(top + left, dx: 82.7pt, dy: story-dy, story)

  context {
    let story-h = measure(story).height
    let text-bottom = story-dy + story-h
    let given-dy = calc.max(512.6pt, text-bottom + 12pt)
    let date-dy = given-dy + 11pt
    let sign-dy = calc.max(568.1pt, date-dy + 36pt)
    let seal-dy = sign-dy + 13.1pt

    heading(given-dy, 9.8pt, "regular")[GIVEN UNDER MY HAND]
    heading(date-dy, 9.8pt, "regular", f.signed_on)
    place(top + left, dx: 82.7pt, dy: sign-dy + 8.8pt, line(length: 158pt, stroke: 0.6pt))
    place(top + left, dx: 271.8pt, dy: seal-dy, image("seal.png", width: 69.6pt))
    place(top + left, dx: 82.7pt, dy: sign-dy + 14.8pt, text(size: 11.7pt, f.commander_name))
    place(top + left, dx: 82.7pt, dy: sign-dy + 28.2pt, text(size: 11.7pt, f.commander_grade))
    place(top + left, dx: 82.7pt, dy: sign-dy + 41.6pt, text(size: 11.7pt, f.commander_title))
  }
}
