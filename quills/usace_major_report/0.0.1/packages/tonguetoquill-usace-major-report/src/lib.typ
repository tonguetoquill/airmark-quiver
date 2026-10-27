// A USACE ENC major maintenance or major rehabilitation report: CUI cover,
// title page, roman front matter, then SECTION-numbered body pages (1-1),
// matching the Portland District ENC MMR and MRR Word templates.

#import "config.typ": *
#import "utils.typ": date-pattern, table-date-pattern, trim-inline, join-inline, blank, plain-text, report-abbreviation, short-stage, statement-date-pattern
#import "page.typ": document-setup, running-header, running-header-lines, running-footer
#import "cover.typ": cover-sheet
#import "title.typ": title-page
#import "frontmatter.typ": front-matter
#import "body.typ": mainmatter

#let report(
  report-type: "Major Maintenance Report",
  report-number: none,
  location-lines: (),
  project-name: none,
  design-stage: none,
  date: none,
  cui-enabled: true,
  cui-controlled-by-component: none,
  cui-controlled-by-office: none,
  cui-categories: none,
  cui-distribution: none,
  cui-distribution-reason: none,
  cui-distribution-date: none,
  cui-distribution-office: none,
  cui-poc: none,
  executive-summary: none,
  appendices: (),
  pertinent-data: none,
  previous-reports: (),
  acronyms: (),
  body: [],
) = {
  let abbreviation = report-abbreviation(report-type)
  set document(
    title: if blank(project-name) { report-type } else { plain-text(project-name).trim() + " " + abbreviation },
    author: "U.S. Army Corps of Engineers",
  )

  show: document-setup.with(cui-enabled: cui-enabled)

  if cui-enabled {
    set page(
      margin: 0pt,
      header: none,
      footer: none,
      numbering: none,
    )
    cover-sheet(
      title: project-name,
      controlled-by-component: cui-controlled-by-component,
      controlled-by-office: cui-controlled-by-office,
      categories: join-inline(cui-categories),
      distribution: cui-distribution,
      poc: cui-poc,
      distribution-reason: cui-distribution-reason,
      distribution-date: cui-distribution-date,
      distribution-office: if blank(cui-distribution-office) { cui-controlled-by-office } else { cui-distribution-office },
    )
    pagebreak()
  }

  set page(margin: MARGIN, fill: white, numbering: none)
  title-page(
    report-type: report-type,
    report-number: report-number,
    location-lines: location-lines,
    project-name: project-name,
    design-stage: design-stage,
    date: date,
  )

  let title-line = (
    if blank(project-name) { none } else { upper(plain-text(project-name).trim()) },
    if blank(design-stage) { none } else { short-stage(design-stage) },
    abbreviation,
  ).filter(v => v != none).join(" ")
  // A running header that wraps pushes the text down, as Word's header does.
  context {
    let header = running-header-lines(cui-enabled, title-line)
    let height = measure(block(width: page.width - 2 * MARGIN, header)).height
    set page(
      header: running-header(cui-enabled, title-line),
      margin: (x: MARGIN, bottom: MARGIN, top: calc.max(MARGIN, BANNER_FROM_EDGE + height + 0.15in)),
    )
    front-matter(
      executive-summary: executive-summary,
      appendices: appendices,
      pertinent-data: pertinent-data,
      previous-reports: previous-reports,
      acronyms: acronyms,
    )

    pagebreak()
    mainmatter(body)
  }
}
