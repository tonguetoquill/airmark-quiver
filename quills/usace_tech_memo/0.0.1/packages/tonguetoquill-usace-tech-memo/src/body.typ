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

#let mainmatter(include-summary: true, it) = {
  set page(numbering: body-numbering)
  counter(page).update(1)
  counter(heading).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: math.equation)).update(0)

  set figure.caption(position: top, separator: [. ])
  show figure.caption: set text(size: SMALL_SIZE, weight: "bold")
  show figure.where(kind: table): set figure(supplement: [Table])
  show figure.where(kind: image): set figure(supplement: [Figure])
  show figure.where(kind: math.equation): set figure(supplement: [Equation])
  show figure: set align(center)
  set image(width: FIGURE_WIDTH)

  set heading(numbering: (..nums) => numbering("1.1.1", ..nums.pos()) + ".", outlined: true)
  show heading.where(level: 4): set heading(outlined: false, numbering: none)
  show heading.where(level: 5): set heading(outlined: false, numbering: none)
  show heading.where(level: 6): set heading(outlined: false, numbering: none)

  show heading.where(level: 1): set text(size: HEADING_1_SIZE, weight: "bold")
  show heading.where(level: 2): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 3): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 4): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 5): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 6): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 2): set block(above: 12pt, below: 6pt)
  show heading.where(level: 3): set block(above: 10pt, below: 4pt)
  show heading.where(level: 4): set block(above: 8pt, below: 4pt)
  show heading.where(level: 5): set block(above: 0.8em, below: 0pt)
  show heading.where(level: 6): set block(above: 0.6em, below: 0pt)

  show heading.where(level: 1): it => {
    let name = heading-name(it)
    if not include-summary and name == "summary" {
      none
    } else {
      pagebreak(weak: true)
      counter(page).update(1)
      it
    }
  }

  show enum: it => numbered-list(it, 0, 0pt)
  set list(marker: LIST_MARKERS, indent: 0.15in, body-indent: 0.35em)

  set table(stroke: TABLE_STROKE, inset: (x: 6pt, y: 4.5pt), align: left)
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
