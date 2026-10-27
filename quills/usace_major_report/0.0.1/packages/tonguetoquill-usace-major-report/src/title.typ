#import "config.typ": *
#import "utils.typ": *

#let title-page(
  report-type: none,
  report-number: none,
  location-lines: (),
  project-name: none,
  design-stage: none,
  date: none,
) = {
  set par(leading: 0.43em, spacing: 0.43em)

  {
    set align(right)
    set text(weight: "bold")
    let kind = upper(report-type)
    if blank(report-number) { par(kind) } else { par[#kind NO. #trim-inline(report-number)] }
    v(BODY_SIZE)
    for line in ensure-array(location-lines) {
      if not blank(line) {
        par(upper(trim-inline(line)))
      }
    }
  }

  v(1.45in)
  set align(center)
  if not blank(project-name) {
    text(size: TITLE_PROJECT_SIZE, weight: "bold")[#trim-inline(project-name)]
  }

  v(1fr)
  set text(size: TITLE_STAGE_SIZE, weight: "bold")
  let stage = if blank(design-stage) { none } else { trim-inline(design-stage) }
  par[#stage #report-abbreviation(report-type)]
  let printed = format-date(date)
  if printed != none {
    par(printed)
  }
  v(0.33in)
}
