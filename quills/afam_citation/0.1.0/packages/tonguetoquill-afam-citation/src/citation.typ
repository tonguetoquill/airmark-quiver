#let font = "Liberation Serif"

#let blank(v) = v == none or v == [] or v == ""

#let ordinal(n) = {
  let mod = calc.rem(n, 10)
  let teen = n >= 11 and n <= 13
  let suffix = if teen or mod == 0 or mod >= 4 { "th" }
    else if mod == 1 { "st" }
    else if mod == 2 { "nd" }
    else { "rd" }
  str(n) + suffix
}

#let month-year(d) = upper(d.display("[month repr:long]")) + " " + str(d.year())

#let citation(f) = {
  set page(paper: "us-letter", margin: 0pt)
  set text(font: font, fill: black, hyphenate: false)
  set par(leading: 4.5pt, spacing: 0pt)

  place(top + left, dx: 187pt, dy: 32.6pt, image("medal.png", width: 242.9pt))

  place(center + top, dy: 164.8pt, text(size: 21.5pt, weight: "bold")[DEPARTMENT OF THE AIR FORCE])
  place(center + top, dy: 224.6pt, text(size: 11.7pt, weight: "bold")[THIS IS TO CERTIFY THAT])
  place(center + top, dy: 252.2pt, text(size: 15.6pt, weight: "bold")[THE AIR FORCE ACHIEVEMENT MEDAL])
  // A later award centers the cluster under the medal name. Basic prints no line.
  let cluster = if blank(f.oak_leaf_cluster) or f.oak_leaf_cluster == "Basic" { none } else { upper(f.oak_leaf_cluster) }
  let drop = if cluster == none { 0pt } else { 16pt }
  if cluster != none {
    place(center + top, dy: 271pt, text(size: 11.7pt, weight: "bold", cluster))
  }
  place(center + top, dy: 282.0pt + drop, text(size: 11.7pt, weight: "bold")[HAS BEEN AWARDED TO])
  place(center + top, dy: 306.6pt + drop, text(size: 9.8pt, upper(f.rank)))
  place(center + top, dy: 340.5pt + drop, text(size: 11.7pt, weight: "bold")[FOR])
  place(center + top, dy: 363.9pt + drop, text(size: 11.7pt, upper(f.service)))
  place(center + top, dy: 390.8pt + drop, text(size: 9.8pt)[#f.period_from #h(8pt) TO #h(8pt) #f.period_to])
  place(center + top, dy: 413.8pt + drop, text(size: 11.7pt, weight: "bold")[ACCOMPLISHMENTS])
  let story = block(width: 451.6pt, text(size: 9.8pt, f.accomplishments))
  let story-dy = 437pt + drop
  place(top + left, dx: 82.7pt, dy: story-dy, story)

  context {
    let story-h = measure(story).height
    let text-bottom = story-dy + story-h
    let given-dy = calc.max(493.3pt + drop, text-bottom + 16pt)
    let sign-dy = calc.max(584pt + drop, given-dy + 56pt)
    let seal-dy = if text-bottom > 520pt + drop { sign-dy - 8pt } else { 536pt + drop }

    place(top + left, dx: 464.7pt, dy: seal-dy, image("seal.png", width: 69.5pt))
    place(top + left, dx: 82.7pt, dy: given-dy, text(size: 11.7pt)[
      GIVEN UNDER MY HAND THIS
      #h(12pt)
      #if type(f.signed_on) == datetime {
        ordinal(f.signed_on.day())
        h(12pt)
        [DAY OF]
        h(12pt)
        month-year(f.signed_on)
      }
    ])
    place(top + left, dx: 82.7pt, dy: sign-dy, line(length: 211pt, stroke: 0.6pt))
    place(top + left, dx: 82.7pt, dy: sign-dy + 15.4pt, text(size: 11.7pt, f.commander_name))
    place(top + left, dx: 82.7pt, dy: sign-dy + 28.9pt, text(size: 11.7pt, f.commander_title))
  }
}
