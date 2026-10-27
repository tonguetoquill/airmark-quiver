#import "config.typ": *
#import "utils.typ": *

#let fm-heading(title, above: 0pt) = {
  set align(center)
  block(
    width: 100%,
    above: above,
    below: 14pt,
    text(size: HEADING_1_SIZE, weight: "bold")[#title],
  )
}

#let fm-section(title, body) = {
  fm-heading(title, above: 22pt)
  set text(size: SMALL_SIZE)
  set align(left)
  body
}

#let outline-entry(it) = {
  let loc = it.element.location()
  context {
    let num = str(counter(page).at(loc).first())
    link(loc, it.indented(
      it.prefix(),
      [#it.body()#h(0.3em)#box(width: 1fr, repeat[.])#h(0.3em)#num],
    ))
  }
}

#let list-section(title, target) = context {
  if query(target).len() == 0 { none } else {
    fm-section(title)[
      #outline(title: none, target: target, indent: 1em)
    ]
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
  fm-section[APPENDICES][
    #grid(
      columns: (1.1in, 1fr),
      column-gutter: 12pt,
      row-gutter: 8pt,
      ..rows.map(((letter, title)) => ([#letter], title)).flatten()
    )
  ]
}

#let pertinent-page(body) = {
  if blank(body) { return }
  fm-section[PERTINENT DATA][
    #set text(size: BODY_SIZE)
    #body
  ]
}

#let previous-memos-page(items) = {
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
  fm-section[PREVIOUS MEMORANDUMS][
    #set table(stroke: TABLE_STROKE, inset: (x: 6pt, y: 5pt), align: left)
    #show table.cell.where(y: 0): set text(weight: "bold")
    #table(
      columns: (1.15in, 1fr, 1.15in),
      [Number], [Title], [Date],
      ..rows.flatten(),
    )
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
  fm-section[ACRONYMS][
    #set table(stroke: TABLE_STROKE, inset: (x: 6pt, y: 5pt), align: left)
    #show table.cell.where(y: 0): set text(weight: "bold")
    #table(
      columns: (1.4in, 1fr),
      [Acronym], [Description],
      ..rows.flatten(),
    )
  ]
}

#let front-matter(
  appendices: (),
  pertinent-data: none,
  previous-memos: (),
  acronyms: (),
) = {
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)

  show outline.entry: outline-entry

  fm-heading[CONTENTS]
  set text(size: SMALL_SIZE)
  outline(title: none, indent: 1em, depth: 3)

  list-section([TABLES], figure.where(kind: table))
  list-section([FIGURES], figure.where(kind: image))
  list-section([EQUATIONS], figure.where(kind: math.equation))
  appendices-page(appendices)
  pertinent-page(pertinent-data)
  previous-memos-page(previous-memos)
  acronyms-page(acronyms)
}
