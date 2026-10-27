#import "config.typ": *
#import "utils.typ": *
#import "cover.typ": page-one-cui

#let title-page(
  memo-number: none,
  location-lines: (),
  study-name: none,
  subject: none,
  prepared-for: none,
  prepared-by: none,
  date: none,
  page-one-cui-args: none,
) = {
  set par(leading: 0.45em, spacing: 0.45em)

  {
    set align(right)
    set text(size: TITLE_LINE_SIZE, weight: "bold")
    if blank(memo-number) {
      [TECHNICAL MEMORANDUM]
    } else {
      [TECHNICAL MEMORANDUM NO. #trim-inline(memo-number)]
    }
    v(0.28in)
    for line in ensure-array(location-lines) {
      if not blank(line) {
        par(upper(trim-inline(line)))
      }
    }
  }

  v(0.85in)
  set align(center)
  if not blank(study-name) {
    text(size: TITLE_STUDY_SIZE, weight: "bold")[#trim-inline(study-name)]
    v(0.28in)
  }
  if not blank(subject) {
    text(size: TITLE_SUBJECT_SIZE, weight: "bold")[#trim-inline(subject)]
    v(0.55in)
  }

  text(size: TITLE_KIND_SIZE, weight: "bold")[Technical Memorandum]
  v(0.45in)

  set text(size: TITLE_LINE_SIZE, weight: "bold")
  if not blank(prepared-for) {
    par[Prepared for: #trim-inline(prepared-for)]
  }
  if not blank(prepared-by) {
    par[Prepared by: #trim-inline(prepared-by)]
  }

  v(0.28in)
  let printed = format-date(date)
  if printed != none {
    par(printed)
  }

  v(1fr)

  if page-one-cui-args != none {
    page-one-cui(..page-one-cui-args)
  }
}
