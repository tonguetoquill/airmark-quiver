#import "config.typ": *
#import "utils.typ": *
#import "page.typ": section-page

// Front headings are unnumbered Heading 1s, so CONTENTS lists them; the
// executive summary's own headings are kept out of it.
#let fm-heading(title) = heading(level: 1, numbering: none, outlined: true, upper(title))

#let fm-heading-style(it) = {
  set align(center)
  block(
    width: 100%,
    above: 0pt,
    below: 12pt,
    text(size: HEADING_1_SIZE, weight: "bold", it.body),
  )
}

#let fm-page(title, body) = {
  pagebreak()
  fm-heading(title)
  set align(left)
  body
}

#let toc-row(loc, indent: 0pt, number: none, number-width: 0pt, body, page, weight: "regular", spacing: 4.3pt) = block(
  above: spacing,
  below: spacing,
  {
    set text(size: SMALL_SIZE, weight: weight)
    set par(hanging-indent: number-width, leading: 0.3em)
    pad(left: indent, link(loc, {
      if number != none { box(width: number-width, number) }
      body
      h(0.3em)
      box(width: 1fr, repeat[.])
      h(0.3em)
      page
    }))
  },
)

#let outline-entry(it) = context {
  let el = it.element
  let loc = el.location()
  if el.func() == heading {
    let nums = counter(heading).at(loc)
    if el.numbering == none {
      toc-row(loc, indent: 0.25in, upper(el.body), upper(numbering("i", counter(page).at(loc).first())))
    } else if el.level == 1 {
      toc-row(
        loc,
        [SECTION #nums.first() - #upper(el.body)],
        str(nums.first()) + "-1",
        weight: "bold",
        spacing: 8.3pt,
      )
    } else {
      toc-row(
        loc,
        indent: 0.25in,
        number: numbering("1.1", ..nums.slice(0, el.level)),
        number-width: if el.level == 2 { 0.4375in } else { 0.625in },
        if el.level == 2 { upper(el.body) } else { el.body },
        section-page(loc),
      )
    }
  } else {
    let prefix = [#el.supplement #counter(heading).at(loc).first()-#el.counter.at(loc).first()]
    let caption = if el.caption == none { none } else { el.caption.body }
    toc-row(loc, if blank(caption) { prefix } else [#prefix. #caption], section-page(loc))
  }
}

#let list-section(title, target, first) = {
  if not first { v(36pt) }
  fm-heading(title)
  outline(title: none, target: target)
}

#let executive-summary-page(body) = {
  if blank(body) { return }
  fm-heading[Executive Summary]
  let es = counter("executive-summary")
  es.update(0)
  set heading(numbering: none, outlined: false)
  show heading: it => block(above: 12pt, below: 12pt, sticky: true, {
    es.step()
    set text(size: BODY_SIZE, weight: "bold")
    context [#es.display(). #upper(it.body)]
  })
  body
}

#let lists-page() = context {
  let kinds = (
    ([Tables], figure.where(kind: table)),
    ([Figures], figure.where(kind: image)),
    ([Equations], figure.where(kind: math.equation)),
  ).filter(((_, target)) => query(target).len() > 0)
  if kinds.len() > 0 {
    pagebreak()
    for (i, (title, target)) in kinds.enumerate() {
      list-section(title, target, i == 0)
    }
  }
}

#let appendices-page(items) = {
  let rows = ()
  for (i, item) in ensure-array(items).enumerate() {
    let letter = if type(item) == dictionary {
      let given = item.at("letter", default: none)
      if blank(given) { numbering("A", i + 1) } else { trim-inline(given) }
    } else {
      numbering("A", i + 1)
    }
    let title = if type(item) == dictionary {
      trim-inline(item.at("title", default: none))
    } else {
      trim-inline(item)
    }
    if blank(letter) and blank(title) { continue }
    rows.push((letter, title))
  }
  if rows.len() == 0 { return }
  fm-page[Appendices][
    #grid(
      columns: (1.32in, 1fr),
      row-gutter: 0.6em,
      ..rows.map(((letter, title)) => ([APPENDIX #letter], upper(title))).flatten()
    )
  ]
}

#let pertinent-page(body) = {
  if blank(body) { return }
  fm-page[Pertinent Data][#body]
}

#let fm-table(columns, header, rows) = {
  show table.cell.where(y: 0): set text(weight: "bold")
  table(
    columns: columns,
    stroke: TABLE_STROKE,
    inset: (x: 5pt, y: 4pt),
    align: (_, y) => if y == 0 { center } else { left },
    fill: (_, y) => if y == 0 { TABLE_HEADER_FILL },
    table.header(..header),
    ..rows.flatten(),
  )
}

#let previous-reports-page(items) = {
  let rows = ()
  for item in ensure-array(items) {
    if type(item) != dictionary { continue }
    let number = trim-inline(item.at("number", default: none))
    let title = trim-inline(item.at("title", default: none))
    let date = format-date(item.at("date", default: none), pattern: table-date-pattern)
    if blank(number) and blank(title) and date == none { continue }
    rows.push((
      if blank(number) { [] } else { number },
      if blank(title) { [] } else { title },
      if date == none { [] } else { date },
    ))
  }
  if rows.len() == 0 { return }
  fm-page[Previous and Planned Reports][
    #fm-table((auto, 1fr, 1.31in), ([Number], [Title], [Date]), rows)
  ]
}

#let acronyms-page(items) = {
  let rows = ()
  for item in ensure-array(items) {
    if type(item) != dictionary { continue }
    let acronym = trim-inline(item.at("acronym", default: none))
    let description = trim-inline(item.at("description", default: none))
    if blank(acronym) and blank(description) { continue }
    rows.push((acronym, description))
  }
  if rows.len() == 0 { return }
  rows = rows.sorted(key: row => lower(plain-text(row.at(0)).trim()))
  fm-page[Acronyms and Abbreviations][
    #pad(left: 0.2in, fm-table((1.3in, 1fr), ([Acronym], [Description]), rows))
  ]
}

#let front-matter(
  executive-summary: none,
  appendices: (),
  pertinent-data: none,
  previous-reports: (),
  acronyms: (),
) = {
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)

  show heading.where(level: 1, numbering: none): fm-heading-style
  show outline.entry: outline-entry

  executive-summary-page(executive-summary)

  pagebreak(weak: true)
  fm-heading[Contents]
  outline(title: none, depth: 3)

  lists-page()
  appendices-page(appendices)
  pertinent-page(pertinent-data)
  previous-reports-page(previous-reports)
  acronyms-page(acronyms)
}
