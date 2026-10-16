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
  set text(font: font, size: 12pt, fill: black, hyphenate: false)
  set par(leading: 4.5pt, spacing: 0pt)

  place(top + left, dx: 187pt, dy: 32.6pt, image("medal-afam.png", width: 242.9pt))

  place(center + top, dy: 164.8pt, text(size: 21.5pt, weight: "bold")[DEPARTMENT OF THE AIR FORCE])
  place(center + top, dy: 208.1pt, text(size: 11.7pt, weight: "bold")[THIS IS TO CERTIFY THAT])
  place(center + top, dy: 222.7pt, text(size: 15.6pt, weight: "bold")[THE AIR AND SPACE ACHIEVEMENT MEDAL])
  // A later award centers the cluster under the medal name. Basic prints no line.
  let cluster = if blank(f.oak_leaf_cluster) or f.oak_leaf_cluster == "Basic" { none } else { upper(f.oak_leaf_cluster) }
  let drop = if cluster == none { 0pt } else { 16pt }
  if cluster != none {
    place(center + top, dy: 250pt + drop, text(size: 11.7pt, weight: "bold", cluster))
  }
  place(center + top, dy: 275pt + drop, text(size: 11.7pt, weight: "bold")[HAS BEEN AWARDED TO])
  place(center + top, dy: 293pt + drop, text(size: 9.8pt, upper(f.rank)))
  place(center + top, dy: 308.5pt + drop, text(size: 11.7pt, weight: "bold")[FOR])
  place(center + top, dy: 326.6pt + drop, text(size: 11.7pt, upper(f.service)))
  place(center + top, dy: 343.3pt + drop, text(size: 9.8pt)[#f.period_from #h(8pt) TO #h(8pt) #f.period_to])
  place(center + top, dy: 369.8pt + drop, text(size: 11.7pt, weight: "bold")[ACCOMPLISHMENTS])
  // Certificate text block: 72pt inset, 468pt wide, clipped at 270pt. The 6.2pt leading is its 13.4pt line spacing.
  let story-dy = 380.7pt + drop
  let story = block(width: 468pt, {
    set par(justify: true, leading: 6.2pt)
    f.accomplishments
  })
  place(top + left, dx: 72pt, dy: story-dy, block(width: 468pt, height: 270pt, clip: true, story))

  context {
    let shown-h = calc.min(measure(story).height, 270pt)
    let given-dy = story-dy + shown-h + 14pt
    let sign-dy = given-dy + 36pt
    place(top + left, dx: 464.7pt, dy: sign-dy - 8pt, image("seal.png", width: 69.5pt))
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
