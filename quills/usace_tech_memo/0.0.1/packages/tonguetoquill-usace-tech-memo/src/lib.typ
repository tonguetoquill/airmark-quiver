// A USACE ENC technical memorandum: CUI cover, title page, roman front
// matter, then a chapter-dash-numbered body (1-1), matching the Portland
// District ENC technical memorandum Word template.

#import "config.typ": *
#import "utils.typ": date-pattern, table-date-pattern, trim-inline, join-inline, blank, plain-text
#import "page.typ": document-setup, running-header, running-footer
#import "cover.typ": cover-sheet
#import "title.typ": title-page
#import "frontmatter.typ": front-matter
#import "body.typ": mainmatter

#let memo(
  memo-number: none,
  location-lines: (),
  study-name: none,
  subject: none,
  prepared-for: none,
  prepared-by: none,
  date: none,
  cui-enabled: true,
  cui-controlled-by-component: none,
  cui-controlled-by-office: none,
  cui-categories: none,
  cui-distribution: none,
  cui-poc: none,
  appendices: (),
  pertinent-data: none,
  previous-memos: (),
  acronyms: (),
  include-summary: true,
  body: [],
) = {
  set document(
    title: {
      let bits = (study-name, subject)
        .filter(v => not blank(v))
        .map(v => plain-text(v).trim())
      if bits.len() == 0 { "Technical Memorandum" } else { bits.join(" — ") }
    },
    author: if blank(prepared-by) {
      "U.S. Army Corps of Engineers"
    } else {
      plain-text(prepared-by).trim()
    },
  )

  show: document-setup.with(cui-enabled: cui-enabled)

  if cui-enabled {
    set page(
      margin: COVER_MARGIN,
      fill: SF901_PURPLE,
      header: none,
      footer: none,
      numbering: none,
    )
    cover-sheet(
      memo-number: memo-number,
      study-name: study-name,
      subject: subject,
      prepared-for: prepared-for,
      date: date,
      controlled-by-component: cui-controlled-by-component,
      controlled-by-office: cui-controlled-by-office,
      categories: join-inline(cui-categories),
      distribution: cui-distribution,
      poc: cui-poc,
    )
    pagebreak()
  }

  set page(margin: MARGIN, fill: white, header: none, footer: none, numbering: none)
  title-page(
    memo-number: memo-number,
    location-lines: location-lines,
    study-name: study-name,
    subject: subject,
    prepared-for: prepared-for,
    prepared-by: prepared-by,
    date: date,
  )

  set page(
    header: running-header(cui-enabled),
    footer: running-footer(cui-enabled),
  )
  front-matter(
    appendices: appendices,
    pertinent-data: pertinent-data,
    previous-memos: previous-memos,
    acronyms: acronyms,
  )

  pagebreak()
  mainmatter(include-summary: include-summary, body)
}
