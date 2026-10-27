#import "config.typ": *
#import "utils.typ": *
#import "page.typ": body-numbering

#let numbered-list(it, level, indent) = {
  let fmt = ENUM_FORMATS.at(calc.min(level, ENUM_FORMATS.len() - 1))
  let n = if type(it.start) == int { it.start } else { 1 }
  for item in it.children {
    let given = item.at("number", default: none)
    if type(given) == int { n = given }
    let label = [#numbering(fmt, n)#"  "]
    block(context {
      let offset = indent + measure(label).width
      show enum: inner => numbered-list(inner, level + 1, offset)
      [#h(indent)#label#item.body]
    })
    n += 1
  }
}

// Word's heading tab stops: the title starts this far from the margin.
#let HEADING_TABS = ("2": 0.5in, "3": 0.625in, "4": 0.75in)

#let section-figure-numbering(..nums) = context {
  str(counter(heading).get().first()) + "-" + str(nums.pos().first())
}

#let mainmatter(it) = {
  set page(numbering: body-numbering)
  counter(heading).update(0)

  set figure.caption(position: top, separator: [. ])
  show figure.caption: set text(size: SMALL_SIZE, weight: "bold")
  show figure.caption: set align(center)
  set figure(numbering: section-figure-numbering)
  show figure.where(kind: table): set figure(supplement: [Table])
  show figure.where(kind: image): set figure(supplement: [Figure])
  show figure.where(kind: math.equation): set figure(supplement: [Equation])
  show figure: set align(center)
  set image(width: FIGURE_WIDTH)

  set heading(numbering: "1.1", outlined: true)
  show heading.where(level: 4): set heading(outlined: false)
  show heading.where(level: 5): set heading(outlined: false, numbering: none)
  show heading.where(level: 6): set heading(outlined: false, numbering: none)
  show heading: set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 4): set text(style: "italic")
  show heading.where(level: 6): set text(weight: "regular")
  show heading: set block(above: 12pt, below: 12pt)
  show heading.where(level: 6): set block(above: 12pt, below: 3pt)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    counter(page).update(1)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: math.equation)).update(0)
    set align(center)
    v(12pt)
    block(sticky: true, above: 0pt, text(size: HEADING_1_SIZE, upper[
      SECTION #counter(heading).display((..n) => str(n.pos().first())) - #it.body
    ]))
  }

  show heading.where(level: 2): it => block(sticky: true, {
    box(width: HEADING_TABS.at("2"), counter(heading).display())
    upper(it.body)
  })
  show heading.where(level: 3): it => block(sticky: true, {
    box(width: HEADING_TABS.at("3"), counter(heading).display())
    it.body
  })
  show heading.where(level: 4): it => block(sticky: true, {
    box(width: HEADING_TABS.at("4"), counter(heading).display())
    it.body
  })
  show heading.where(level: 5): it => block(sticky: true, underline(it.body))
  show heading.where(level: 6): it => block(sticky: true, underline(it.body))

  show figure.caption: set text(font: DEFAULT_BODY_FONTS)
  show figure.caption: it => if blank(it.body) { [#it.supplement #it.counter.display(it.numbering)] } else { it }

  show enum: it => numbered-list(it, 0, 0pt)
  set list(marker: LIST_MARKERS, indent: 0.25in, body-indent: 0.35em)

  set table(
    stroke: TABLE_STROKE,
    inset: (x: 6pt, y: 4.5pt),
    align: (_, y) => if y == 0 { center } else { left },
    fill: (_, y) => if y == 0 { TABLE_HEADER_FILL },
  )
  show table.cell.where(y: 0): set text(weight: "bold")
  show table: set text(size: TABLE_SIZE)
  show table: it => figure(
    {
      show table: t => t
      it
    },
    kind: table,
    supplement: [Table],
    caption: [],
  )

  show math.equation.where(block: true): it => figure(
    {
      show math.equation.where(block: true): e => e
      it
    },
    kind: math.equation,
    supplement: [Equation],
    caption: [],
  )

  show quote.where(block: true): it => pad(left: 0.5in, it.body)

  it
}
