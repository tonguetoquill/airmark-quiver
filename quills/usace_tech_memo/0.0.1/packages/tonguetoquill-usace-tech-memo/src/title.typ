#import "config.typ": *
#import "utils.typ": *

#let title-page(
  memo-number: none,
  location-lines: (),
  study-name: none,
  subject: none,
  prepared-for: none,
  prepared-by: none,
  date: none,
) = {
  set par(leading: 0.55em, spacing: 0.7em)
  set align(center)

  v(0.6in)
  text(size: 16pt, weight: "bold")[
    #if blank(memo-number) [TECHNICAL MEMORANDUM] else [TECHNICAL MEMORANDUM NO. #trim-inline(memo-number)]
  ]

  v(0.7in)
  {
    set text(size: 13pt, weight: "bold")
    for line in ensure-array(location-lines) {
      if not blank(line) {
        par(upper(trim-inline(line)))
      }
    }
  }

  v(0.7in)
  if not blank(study-name) {
    text(size: 13pt, weight: "bold")[#trim-inline(study-name)]
    v(0.35in)
  }
  if not blank(subject) {
    text(size: 12pt)[#trim-inline(subject)]
    v(0.45in)
  }

  text(size: 12pt, weight: "bold")[Technical Memorandum]

  v(0.9in)
  if not blank(prepared-for) {
    par(text(size: SMALL_SIZE)[Prepared for])
    par(trim-inline(prepared-for))
    v(0.45in)
  }
  if not blank(prepared-by) {
    par(text(size: SMALL_SIZE)[Prepared by])
    par(trim-inline(prepared-by))
  }

  v(0.7in)
  let printed = format-date(date)
  if printed != none {
    par(printed)
  }

  v(1fr)
}
