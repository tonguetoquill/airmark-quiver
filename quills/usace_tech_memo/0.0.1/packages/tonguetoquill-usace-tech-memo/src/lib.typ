// A USACE ENC technical memorandum: CUI cover, title page, roman front
// matter, then a chapter-dash-numbered body (1-1), matching the Portland
// District ENC technical memorandum Word template.

#import "config.typ": *
#import "utils.typ": date-pattern, table-date-pattern, statement-date-pattern, trim-inline, join-inline, blank, plain-text
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
  cui-cover: true,
  cui-controlled-by-component: none,
  cui-controlled-by-office: none,
  cui-categories: none,
  cui-distribution: none,
  cui-distribution-reason: (),
  cui-distribution-date: none,
  cui-distribution-office: none,
  cui-poc: none,
  appendices: (),
  pertinent-data: none,
  previous-memos: (),
  acronyms: (),
  include-summary: true,
  body: [],
) = {
  let cover-title = {
    let bits = (study-name, subject)
      .filter(v => not blank(v))
      .map(v => plain-text(v).trim())
    if bits.len() == 0 {
      if blank(memo-number) { "Technical Memorandum" } else {
        "Technical Memorandum No. " + plain-text(memo-number).trim()
      }
    } else { bits.join(" — ") }
  }

  set document(
    title: cover-title,
    author: if blank(prepared-by) {
      "U.S. Army Corps of Engineers"
    } else {
      plain-text(prepared-by).trim()
    },
  )

  show: document-setup.with(cui-enabled: cui-enabled)

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
    cui-enabled: cui-enabled,
  )

  // Cover needs CUI on; when the cover is off the designation block,
  // statement and export warning move to the title page (para 3.1.j).
  let print-cover = cui-enabled and cui-cover
  let print-page-one-cui = cui-enabled and not cui-cover

  if print-cover {
    set page(
      margin: 0pt,
      header: none,
      footer: none,
      numbering: none,
    )
    cover-sheet(title: cover-title, ..cui-args)
    pagebreak()
  }

  // Title page carries the same CUI header/footer as every other page
  // (DoDI 5230.24 para 3.4.d). Cover itself has none.
  set page(
    margin: MARGIN,
    fill: white,
    header: running-header(cui-enabled),
    footer: running-footer(cui-enabled),
    numbering: none,
  )
  title-page(
    memo-number: memo-number,
    location-lines: location-lines,
    study-name: study-name,
    subject: subject,
    prepared-for: prepared-for,
    prepared-by: prepared-by,
    date: date,
    page-one-cui-args: if print-page-one-cui { cui-args } else { none },
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
