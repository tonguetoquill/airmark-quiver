#import "config.typ": *
#import "utils.typ": *
#import "cover.typ": page-one-cui

#let title-page(
  report-type: none,
  report-number: none,
  location-lines: (),
  project-name: none,
  design-stage: none,
  date: none,
  page-one-cui-args: none,
) = {
  set par(leading: 0.43em, spacing: 0.43em)
  let locations = ensure-array(location-lines).filter(line => not blank(line))
  let printed = format-date(date)

  // A Phase 1A report has no number and no design stage, and names its
  // preparer where the others print the stage.
  if report-type == "Phase 1A Report" {
    {
      set align(right)
      set text(size: PHASE_1A_LOCATION_SIZE, weight: "bold")
      for line in locations { par(upper(trim-inline(line))) }
    }

    v(0.5in)
    set align(center)
    set text(size: TITLE_PROJECT_SIZE, weight: "bold")
    if not blank(project-name) { par(trim-inline(project-name)) }
    par(report-type)

    v(1fr)
    par(text(size: TITLE_STAGE_SIZE)[Prepared By:])
    set text(size: PHASE_1A_AGENCY_SIZE)
    par[US Army Corps of Engineers]
    par[Portland District]
    if printed != none {
      v(PHASE_1A_AGENCY_SIZE)
      par(printed)
    }
    v(0.2in)
  } else {
    {
      set align(right)
      set text(weight: "bold")
      let kind = upper(report-type)
      if blank(report-number) { par(kind) } else { par[#kind NO. #trim-inline(report-number)] }
      v(BODY_SIZE)
      for line in locations { par(upper(trim-inline(line))) }
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
    if printed != none {
      par(printed)
    }
    v(0.33in)
  }

  if page-one-cui-args != none {
    page-one-cui(..page-one-cui-args)
  }
}
