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
  place(top + left, dx: 464.7pt, dy: 536pt, image("seal.png", width: 69.5pt))

  place(center + top, dy: 164.8pt, text(size: 21.5pt, weight: "bold")[DEPARTMENT OF THE AIR FORCE])
  place(center + top, dy: 224.6pt, text(size: 11.7pt, weight: "bold")[THIS IS TO CERTIFY THAT])
  place(center + top, dy: 252.2pt, text(size: 15.6pt, weight: "bold")[THE AIR FORCE ACHIEVEMENT MEDAL])
  place(center + top, dy: 282.0pt, text(size: 11.7pt, weight: "bold")[HAS BEEN AWARDED TO])
  place(center + top, dy: 306.6pt, text(size: 9.8pt, upper(f.rank)))
  place(center + top, dy: 340.5pt, text(size: 11.7pt, weight: "bold")[FOR])
  place(center + top, dy: 363.9pt, text(size: 11.7pt, upper(f.service)))
  place(center + top, dy: 390.8pt, text(size: 9.8pt)[#f.period_from #h(8pt) TO #h(8pt) #f.period_to])
  place(center + top, dy: 413.8pt, text(size: 11.7pt, weight: "bold")[ACCOMPLISHMENTS])
  place(top + left, dx: 82.7pt, dy: 437pt, block(width: 451.6pt, text(size: 9.8pt, f.accomplishments)))

  place(top + left, dx: 82.7pt, dy: 493.3pt, text(size: 11.7pt)[
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

  place(top + left, dx: 82.7pt, dy: 584pt, line(length: 211pt, stroke: 0.6pt))
  place(top + left, dx: 82.7pt, dy: 599.4pt, text(size: 11.7pt, f.commander_name))
  place(top + left, dx: 82.7pt, dy: 612.9pt, text(size: 11.7pt, f.commander_title))
}
