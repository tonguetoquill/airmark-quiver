#import "config.typ": *
#import "utils.typ": *
#import "page.typ": body-numbering
#import "cover.typ": page-one-cui

// Front headings are unnumbered Heading 2s, Word's TOC 2 level, so CONTENTS
// lists them indented with the A.1 sections.
#let fm-heading(title, above: 0pt, below: 16pt) = {
  show heading: set block(above: above, below: below)
  heading(level: 2, numbering: none, outlined: true, upper(title))
}

#let fm-heading-style(it) = block(
  width: 100%,
  align(center, text(size: HEADING_1_SIZE, weight: "bold", it.body)),
)

#let outline-entry(letter, it) = {
  let loc = it.element.location()
  let is-heading = it.element.func() == heading
  let level = if is-heading { it.element.level } else { 0 }
  context {
    let front = is-heading and it.element.numbering == none and level == 2
    let n = counter(page).at(loc).first()
    let page-number = if front { upper(numbering("i", n)) } else { body-numbering(letter)(n) }
    let fill = [#h(0.3em)#box(width: 1fr, repeat[.])#h(0.3em)#page-number]
    link(loc, if front {
      pad(left: TOC_INDENT, [#it.body()#fill])
    } else if level == 1 {
      block(above: 4pt, below: 4pt, text(weight: "bold", [#upper(it.body())#fill]))
    } else if is-heading {
      let tab = TOC_TABS.at(level - 2)
      let body = if level == 2 { upper(it.body()) } else { it.body() }
      pad(left: TOC_INDENT, grid(
        columns: (tab - TOC_INDENT, 1fr),
        it.prefix(), [#body#fill],
      ))
    } else if blank(it.body()) {
      block[#it.prefix()#fill]
    } else {
      block[#it.prefix(). #it.body()#fill]
    })
  }
}

#let list-section(title, target) = context {
  if query(target).len() > 0 {
    fm-heading(title, above: 32pt)
    outline(title: none, target: target)
  }
}

#let front-matter(letter: "A", page-one-cui-args: none) = {
  pagebreak(weak: true)
  set page(numbering: "i")
  counter(page).update(1)

  if page-one-cui-args != none {
    place(bottom + right, float: true, {
      set text(top-edge: "cap-height", bottom-edge: "baseline")
      page-one-cui(..page-one-cui-args)
    })
  }

  show heading.where(level: 2, numbering: none): fm-heading-style
  show outline.entry: outline-entry.with(letter)

  fm-heading(below: 20pt)[CONTENTS]
  set text(size: SMALL_SIZE)
  set par(spacing: 0pt)
  set block(spacing: 0pt)
  outline(title: none, depth: 3)

  list-section([TABLES], figure.where(kind: table))
  list-section([EQUATIONS], figure.where(kind: math.equation))
}
