// A USACE report appendix: CUI cover, roman CONTENTS, then a body headed
// APPENDIX A - TITLE whose sections, pages and captions carry the letter
// (A.1, A-1, Table A-1), matching the Portland District ENC standardized
// report appendix Word template.

#import "config.typ": *
#import "utils.typ": trim-inline, join-inline, blank, plain-text
#import "page.typ": document-setup
#import "cover.typ": cover-sheet
#import "frontmatter.typ": front-matter
#import "body.typ": mainmatter

#let appendix(
  letter: none,
  title: none,
  project-name: none,
  cui-enabled: true,
  cui-controlled-by-component: none,
  cui-controlled-by-office: none,
  cui-categories: none,
  cui-distribution: none,
  cui-poc: none,
  body: [],
) = {
  let letter = if blank(letter) { "A" } else { upper(plain-text(letter).trim()) }
  let title = if blank(title) { [] } else { trim-inline(title) }
  let document-title = "Appendix " + letter + if blank(title) { "" } else { " - " + plain-text(title).trim() }

  set document(
    title: document-title,
    author: "U.S. Army Corps of Engineers",
  )

  show: document-setup.with(cui-enabled: cui-enabled, project-name: project-name)

  if cui-enabled {
    set page(
      margin: 0pt,
      header: none,
      footer: none,
      numbering: none,
    )
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    cover-sheet(
      title: document-title,
      controlled-by-component: cui-controlled-by-component,
      controlled-by-office: cui-controlled-by-office,
      categories: join-inline(cui-categories),
      distribution: cui-distribution,
      poc: cui-poc,
    )
  }

  front-matter(letter: letter)

  pagebreak()
  mainmatter(letter: letter, title: title, body)
}
