#import "config.typ": *
#import "utils.typ": *
#import "page.typ": body-numbering

#let numbered-list(it, level, indent) = {
  let fmt = ENUM_FORMATS.at(calc.min(level, ENUM_FORMATS.len() - 1))
  let n = if type(it.start) == int { it.start } else { 1 }
  for item in it.children {
    let given = item.at("number", default: none)
    if type(given) == int { n = given }
    let number = numbering(fmt, n)
    block(context {
      let label = box(width: calc.max(LIST_TAB.to-absolute(), (measure(number).width + 0.25em).to-absolute()), number)
      let offset = indent + measure(label).width
      show enum: inner => numbered-list(inner, level + 1, offset)
      [#h(indent)#label#item.body]
    })
    n += 1
  }
}

#let IN_LIST = state("usace-in-list", false)

// The number sits in a tab stop as wide as the Word heading's, or a little
// wider when it outgrows the stop.
#let tabbed(number, tab, title) = context {
  let width = calc.max(tab.to-absolute(), (measure(number).width + 0.5em).to-absolute())
  [#box(width: width, number)#title]
}

// The appendix heading is Word's Heading 1. Markdown headings sit one level
// below it: a body # is Heading 2 (A.1), ## is A.1.1, ### is A.1.1.1.
#let mainmatter(letter: "A", title: none, it) = {
  set page(numbering: body-numbering(letter))
  counter(page).update(1)
  counter(heading).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: math.equation)).update(0)

  set figure(numbering: n => letter + "-" + str(n))
  set figure(gap: 3pt)
  set figure.caption(position: top, separator: [. ])
  show figure.caption: set text(font: DEFAULT_BODY_FONTS, size: SMALL_SIZE, weight: "bold")
  show figure.caption: set align(center)
  show figure.caption: it => if blank(it.body) {
    [#it.supplement #context it.counter.display(it.numbering)]
  } else { it }
  show figure: set align(center)
  show figure: set block(breakable: false)

  set heading(
    offset: 1,
    numbering: (..nums) => letter + "." + nums.pos().slice(1).map(str).join("."),
    outlined: true,
  )
  show heading: set text(size: BODY_SIZE, weight: "bold")
  show heading: set block(above: PAR_SPACING, below: PAR_SPACING, sticky: true)
  show heading.where(level: 4): set heading(outlined: false)
  show heading.where(level: 5): set heading(outlined: false)
  show heading.where(level: 6): set heading(outlined: false, numbering: none)
  show heading.where(level: 7): set heading(outlined: false, numbering: none)

  show heading.where(level: 1): it => align(center, text(size: HEADING_1_SIZE, upper(it.body)))
  show heading.where(level: 2): it => tabbed(counter(heading).display(it.numbering), HEADING_TABS.at(0), upper(it.body))
  show heading.where(level: 3): it => tabbed(counter(heading).display(it.numbering), HEADING_TABS.at(1), it.body)
  show heading.where(level: 4): it => tabbed(
    counter(heading).display(it.numbering),
    HEADING_TABS.at(2),
    text(style: "italic", it.body),
  )
  show heading.where(level: 5): it => tabbed(counter(heading).display(it.numbering), HEADING_TABS.at(2), it.body)
  show heading.where(level: 6): it => underline(evade: false, it.body)
  show heading.where(level: 7): it => text(weight: "regular", underline(evade: false, it.body))

  show enum: it => numbered-list(it, 0, 0pt)
  set list(
    marker: LIST_MARKERS.map(m => box(width: LIST_TAB, [#m#h(1fr)])),
    indent: 0pt,
    body-indent: 0pt,
  )
  // A bulleted list is spaced off the text around it like a paragraph, while a
  // nested list stays single-spaced with its parent, as Word's List Bullet 2.
  // A tight list otherwise attaches to the paragraph above it.
  show list: it => context if IN_LIST.get() {
    block(above: LEADING, below: LEADING, it)
  } else {
    block(above: PAR_SPACING, below: PAR_SPACING, inset: (left: BULLET_INDENT), {
      IN_LIST.update(true)
      it
      IN_LIST.update(false)
    })
  }

  set table(
    stroke: TABLE_STROKE,
    inset: (x: 5.4pt, y: 2pt),
    align: left,
    fill: (_, y) => if y == 0 { TABLE_HEADER_FILL },
  )
  show table.cell: set align(horizon)
  show table.cell.where(y: 0): set text(weight: "bold")
  show table.cell.where(y: 0): set align(center)
  show table: set text(size: TABLE_SIZE)
  show table: it => figure(
    {
      show table: t => t
      set align(left)
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

  v(PAR_SPACING, weak: false)
  heading(level: 1, offset: 0, numbering: none)[APPENDIX #letter - #title]
  it
}
