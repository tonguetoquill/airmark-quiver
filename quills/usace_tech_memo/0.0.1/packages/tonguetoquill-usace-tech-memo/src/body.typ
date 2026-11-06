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
  show figure.caption: set align(center)
  show figure.where(kind: table): set figure(supplement: [Table])
  show figure.where(kind: image): set figure(supplement: [Figure])
  show figure.where(kind: math.equation): set figure(supplement: [Equation])
  show figure: set align(center)
  set image(width: FIGURE_WIDTH)

  // Markdown H1 is the template's Heading 2 (1.1 Purpose): the memo is chapter 1.
  set heading(numbering: (..nums) => numbering("1.1.1.1", 1, ..nums.pos()), outlined: true)
  show heading.where(level: 5): set heading(outlined: false, numbering: none)
  show heading.where(level: 6): set heading(outlined: false, numbering: none)

  show heading.where(level: 1): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 2): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 3): set text(size: BODY_SIZE, weight: "bold", style: "italic")
  show heading.where(level: 4): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 5): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 6): set text(size: BODY_SIZE)
  show heading.where(level: 1): set block(above: 12pt, below: 12pt)
  show heading.where(level: 2): set block(above: 12pt, below: 12pt)
  show heading.where(level: 3): set block(above: 12pt, below: 12pt)
  show heading.where(level: 4): set block(above: 12pt, below: 12pt)
  show heading.where(level: 5): set block(above: 12pt, below: 12pt)
  show heading.where(level: 6): set block(above: 12pt, below: 3pt)
  show heading.where(level: 4): set heading(outlined: false)

  show heading.where(level: 1): it => {
    let name = heading-name(it)
    if not include-summary and name == "summary" {
      none
    } else {
      block(sticky: true, {
        if it.numbering != none {
          numbering(it.numbering, ..counter(heading).at(it.location()))
          h(0.5em)
        }
        upper(it.body)
      })
    }
  }

  show heading.where(level: 5): it => block(sticky: true, {
    set text(weight: "bold")
    underline(it.body)
  })
  show heading.where(level: 6): it => block(sticky: true, underline(it.body))

  show figure.caption: it => if blank(it.body) { none } else { it }

  show enum: it => numbered-list(it, 0, 0pt)
  set list(marker: LIST_MARKERS, indent: 0.25in, body-indent: 0.35em)

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
