// A USACE report appendix: CUI cover, roman CONTENTS, then a body headed
// APPENDIX A - TITLE whose sections, pages and captions carry the letter
// (A.1, A-1, Table A-1), matching the Portland District ENC standardized
// report appendix Word template.

#import "config.typ": *
#import "utils.typ": trim-inline, join-inline, blank, plain-text, statement-date-pattern
#import "page.typ": document-setup
#import "cover.typ": cover-sheet
#import "frontmatter.typ": front-matter
#import "body.typ": mainmatter

#let appendix(
  letter: none,
  title: none,
  project-name: none,
  marking: "off",
  cui-controlled-by-component: none,
  cui-controlled-by-office: none,
  cui-categories: none,
  cui-distribution: none,
  cui-distribution-reason: (),
  cui-distribution-date: none,
  cui-distribution-office: none,
  cui-poc: none,
  executive-summary: none,
  body: [],
) = {
  let letter = if blank(letter) { "A" } else { upper(plain-text(letter).trim()) }
  let title = if blank(title) { [] } else { trim-inline(title) }
  let document-title = "Appendix " + letter + if blank(title) { "" } else { " - " + plain-text(title).trim() }

  set document(
    title: document-title,
    author: "U.S. Army Corps of Engineers",
  )

  // off prints nothing. The cover is banners_and_cover only, so it
  // never prints without the banners.
  let print-banners = marking == "banners" or marking == "banners_and_cover"
  let print-cover = marking == "banners_and_cover"

  show: document-setup.with(cui-enabled: print-banners, project-name: project-name)

  let referral-office = if blank(cui-distribution-office) {
    cui-controlled-by-office
  } else {
    cui-distribution-office
  }

  let cui-args = (
    controlled-by-component: cui-controlled-by-component,
    controlled-by-office: cui-controlled-by-office,
    categories: join-inline(cui-categories),
    distribution: cui-distribution,
    poc: cui-poc,
    distribution-reasons: cui-distribution-reason,
    distribution-date: cui-distribution-date,
    distribution-office: referral-office,
    cui-enabled: print-banners,
  )

  if print-cover {
    set page(
      margin: 0pt,
      header: none,
      footer: none,
      numbering: none,
    )
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    cover-sheet(title: document-title, ..cui-args)
  }

  front-matter(
    letter: letter,
    executive-summary: executive-summary,
    page-one-cui-args: if marking == "banners" { cui-args } else { none },
  )

  pagebreak()
  mainmatter(letter: letter, title: title, body)
}
