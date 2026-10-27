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
    block({
      show enum: inner => context {
        let offset = indent + measure(label).width
        numbered-list(inner, level + 1, offset)
      }
      context {
        let offset = indent + measure(label).width
        par(hanging-indent: offset)[
          #h(indent)#label#item.body
        ]
      }
    })
    n += 1
  }
}

#let style-figure(it) = {
  show table: t => t
  show math.equation.where(block: true): e => e
  set image(width: FIGURE_WIDTH)
  show image: i => i
  align(center, it)
}

#let wrap-table(it) = figure(
  {
    show table: t => t
    it
  },
  kind: table,
  supplement: [Table],
)

#let wrap-image(it) = figure(
  {
    show image: i => i
    set image(width: FIGURE_WIDTH)
    it
  },
  kind: image,
  supplement: [Figure],
)

#let wrap-equation(it) = figure(
  {
    show math.equation.where(block: true): e => e
    it
  },
  kind: math.equation,
  supplement: [Equation],
)

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

  set heading(numbering: (..nums) => numbering("1.1.1", ..nums.pos()) + ".", outlined: true)
  show heading.where(level: 4): set heading(outlined: false, numbering: none)
  show heading.where(level: 5): set heading(outlined: false, numbering: none)
  show heading.where(level: 6): set heading(outlined: false, numbering: none)

  show heading.where(level: 1): set text(size: HEADING_1_SIZE, weight: "bold")
  show heading.where(level: 2): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 3): set text(size: BODY_SIZE, weight: "bold")
  show heading.where(level: 4): set text(size: BODY_SIZE, weight: "bold")

  let omit = state("usace-omit-summary", false)
  let run-in = state("usace-run-in", none)
  let in-refs = state("usace-in-refs", false)

  show heading.where(level: 1): it => {
    let name = heading-name(it)
    if not include-summary and name == "summary" {
      omit.update(true)
      none
    } else {
      omit.update(false)
      in-refs.update(name == "references")
      pagebreak(weak: true)
      counter(page).update(1)
      block(above: 0pt, below: 8pt, it)
    }
  }

  show heading.where(level: 5): it => {
    run-in.update(it.body)
    none
  }
  show heading.where(level: 6): it => {
    run-in.update(it.body)
    none
  }

  show heading.where(level: 2): it => context {
    if omit.get() { none } else { block(above: 12pt, below: 6pt, it) }
  }
  show heading.where(level: 3): it => context {
    if omit.get() { none } else { block(above: 10pt, below: 4pt, it) }
  }
  show heading.where(level: 4): it => context {
    if omit.get() { none } else { block(above: 8pt, below: 4pt, it) }
  }

  show par: it => context {
    if omit.get() { none } else {
      let pending = run-in.get()
      let body = it.body
      if pending != none {
        run-in.update(none)
        body = [#text(weight: "bold")[#pending.]#h(0.4em)#body]
      }
      let plain = lower(plain-text(body).trim())
      if plain.starts-with("note.") or plain.starts-with("note:") {
        set text(size: SMALL_SIZE)
        par(body)
      } else if in-refs.get() {
        set par(hanging-indent: 0.5in)
        par(body)
      } else {
        par(body)
      }
    }
  }

  show enum: it => context {
    if omit.get() { none } else { numbered-list(it, 0, 0pt) }
  }
  set list(marker: LIST_MARKERS, indent: 0.15in, body-indent: 0.35em)
  show list: it => context { if omit.get() { none } else { it } }

  set table(stroke: TABLE_STROKE, inset: (x: 6pt, y: 4.5pt), align: left)
  show table.cell.where(y: 0): set text(weight: "bold")
  show table: it => context {
    if omit.get() { none } else {
      set text(size: TABLE_SIZE)
      wrap-table(it)
    }
  }

  show image: it => context {
    if omit.get() { none } else { wrap-image(it) }
  }

  show math.equation.where(block: true): it => context {
    if omit.get() { none } else { wrap-equation(it) }
  }

  show figure: it => context {
    if omit.get() { none } else { style-figure(it) }
  }

  show quote.where(block: true): it => context {
    if omit.get() { none } else { pad(left: 0.5in, it.body) }
  }

  it
}
