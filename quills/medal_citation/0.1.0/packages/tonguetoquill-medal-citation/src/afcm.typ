#let font = "Liberation Serif"

#let blank(v) = v == none or v == [] or v == ""

#let citation(f) = {
  set page(paper: "us-letter", margin: 0pt)
  set text(font: font, size: 15pt, fill: black, hyphenate: false)
  set par(leading: 0.5em, spacing: 0.5em)

  // Headings sit 3pt right of the page center, matching the certificate.
  let heading(dy, size, weight, body) = {
    place(center + top, dx: 3pt, dy: dy, text(size: size, weight: weight, body))
  }

  place(top + left, dx: 203.3pt, dy: 57.7pt, image("medal-afcm.png", width: 211.6pt))

  heading(185.6pt, 24.5pt, "bold")[DEPARTMENT OF THE AIR FORCE]
  heading(226.2pt, 13.7pt, "bold")[THIS IS TO CERTIFY THAT]
  heading(246.3pt, 17.6pt, "bold")[THE AIR AND SPACE COMMENDATION MEDAL]
  // The medal name ends near 264pt and the next heading starts at 287pt.
  let cluster = if blank(f.oak_leaf_cluster) or f.oak_leaf_cluster == "Basic" { none } else { upper(f.oak_leaf_cluster) }
  if cluster != none {
    heading(267.5pt, 11.7pt, "bold", cluster)
  }
  heading(288.6pt, 13.7pt, "bold")[HAS BEEN AWARDED TO]
  heading(305.1pt, 9.8pt, "regular", upper(f.rank))
  heading(332.6pt, 13.7pt, "bold")[FOR]
  heading(359.6pt, 11.7pt, "regular", upper(f.service))
  heading(383.4pt, 9.8pt, "regular")[#f.period_from #h(8pt) TO #h(8pt) #f.period_to]
  heading(408.4pt, 13.7pt, "bold")[ACCOMPLISHMENTS]
  let story = block(width: 452.5pt, f.accomplishments)
  let story-dy = 434.9pt
  place(top + left, dx: 82.8pt, dy: story-dy, story)

  context {
    let story-h = measure(story).height
    let text-bottom = story-dy + story-h
    let given-dy = calc.max(489.2pt, text-bottom + 12pt)
    let date-dy = given-dy + 22pt
    let seal-dy = calc.max(538.4pt, date-dy + 16pt)
    let sign-dy = calc.max(602.4pt, seal-dy + 64pt)

    place(top + left, dx: 465.6pt, dy: seal-dy, image("seal.png", width: 69.7pt))
    heading(given-dy, 9.8pt, "regular")[GIVEN UNDER MY HAND]
    heading(date-dy, 9.8pt, "regular", f.signed_on)
    place(top + left, dx: 82.8pt, dy: sign-dy + 8.8pt, line(length: 200pt, stroke: 0.6pt))
    place(top + left, dx: 82.8pt, dy: sign-dy + 14.7pt, text(size: 11.7pt, f.commander_name))
    place(top + left, dx: 82.8pt, dy: sign-dy + 28.2pt, text(size: 11.7pt, f.commander_title))
  }
}
