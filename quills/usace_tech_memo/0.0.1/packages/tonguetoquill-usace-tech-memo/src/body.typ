#import "config.typ": *
#import "utils.typ": *

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

#let RUN_IN = state("usace-run-in", none)

#let run-in-lead(body) = {
  let last = plain-text(body).trim().clusters().at(-1, default: "")
  text(weight: "bold", body)
  if last not in (".", "?", "!", ":", ";", ",") [.]
  h(0.4em)
}

#let flush-run-in() = context {
  let pending = RUN_IN.get()
  if pending != none {
    RUN_IN.update(none)
    block(width: 100%, { run-in-lead(pending) })
  }
}

#let mainmatter(include-summary: true, it) = {
  set page(numbering: "1")
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
  show heading.where(level: 1): set block(above: 16pt, below: 8pt)
  show heading.where(level: 2): set block(above: 12pt, below: 6pt)
  show heading.where(level: 3): set block(above: 10pt, below: 4pt)
  show heading.where(level: 4): set block(above: 8pt, below: 4pt)

  show heading.where(level: 1): it => {
    flush-run-in()
    let name = heading-name(it)
    if not include-summary and name == "summary" {
      none
    } else {
      it
    }
  }
  show heading.where(level: 2): it => {
    flush-run-in()
    it
  }
  show heading.where(level: 3): it => {
    flush-run-in()
    it
  }
  show heading.where(level: 4): it => {
    flush-run-in()
    it
  }
  // Heading 5 and 6 run in on the next paragraph. A block, not a paragraph,
  // is what the absorber returns, so this show rule does not match itself.
  show heading.where(level: 5): it => RUN_IN.update(it.body)
  show heading.where(level: 6): it => RUN_IN.update(it.body)
  show par: it => context {
    let pending = RUN_IN.get()
    if pending == none {
      it
    } else {
      RUN_IN.update(none)
      block(width: 100%, above: 0.8em, {
        run-in-lead(pending)
        it.body
      })
    }
  }

  show enum: it => {
    flush-run-in()
    numbered-list(it, 0, 0pt)
  }
  set list(marker: LIST_MARKERS, indent: 0.15in, body-indent: 0.35em)
  show list: it => {
    flush-run-in()
    it
  }

  set table(stroke: TABLE_STROKE, inset: (x: 6pt, y: 4.5pt), align: left)
  show table.cell.where(y: 0): set text(weight: "bold")
  show table: set text(size: TABLE_SIZE)
  show table: it => {
    flush-run-in()
    figure(
      {
        show table: t => t
        it
      },
      kind: table,
      supplement: [Table],
      caption: [],
    )
  }

  show math.equation.where(block: true): it => {
    flush-run-in()
    figure(
      {
        show math.equation.where(block: true): e => e
        it
      },
      kind: math.equation,
      supplement: [Equation],
      caption: [],
    )
  }

  show quote.where(block: true): it => {
    flush-run-in()
    pad(left: 0.5in, it.body)
  }

  it
}
