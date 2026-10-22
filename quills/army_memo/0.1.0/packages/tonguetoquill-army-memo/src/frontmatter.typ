// The memorandum's heading, and the page setup the rest of the document
// inherits: AR 25-50 2-3 through 2-5.

#import "primitives.typ": *

#let frontmatter(
  office-symbol: "",
  record-number: "",
  date: none,
  // The fill-in widget printed in the date's place when `date` is none.
  date-field: none,
  suspense: none,
  memo-for: (),
  memo-thru: (),
  // Per THRU address: `(comment: height => content, signature: height => content)`.
  thru-fields: (),
  subject: "",
  letterhead-title: ("DEPARTMENT OF THE ARMY",),
  // The seal, sized and offset so its disc is the 1-inch square it is placed in.
  letterhead-seal: none,
  body-font: DEFAULT_BODY_FONTS,
  font-size: 12pt,
  classification-level: none,
  dissemination: none,
  cui-controlled-by: none,
  cui-category: none,
  cui-limited-dissemination: none,
  cui-poc: none,
  it,
) = {
  let printed-date = if date != none { date } else if date-field != none { date-field } else { datetime.today().display(date-pattern()) }

  let classification-marking = if type(classification-level) != str or classification-level.trim() == "" {
    none
  } else if falsey(dissemination) {
    [#classification-level.trim()]
  } else {
    // `//` opens a comment in markup.
    let separator = "//"
    [#classification-level.trim()#separator#box(upper(dissemination))]
  }
  let banner = if classification-marking != none {
    text(12pt, font: DEFAULT_BODY_FONTS, weight: "bold", fill: black, top-edge: "cap-height")[#classification-marking]
  }

  // DoDM 5200.48: the CUI designation indicator block, page 1 only.
  let cui-indicator = if type(classification-level) == str and classification-level.trim().starts-with("CUI") {
    let lines = ()
    if not falsey(cui-controlled-by) { lines.push([Controlled By: #cui-controlled-by]) }
    if not falsey(cui-category) { lines.push([CUI Category: #cui-category]) }
    if not falsey(cui-limited-dissemination) { lines.push([LDC: #upper(cui-limited-dissemination)]) }
    if not falsey(cui-poc) { lines.push([POC: #cui-poc]) }
    if lines.len() > 0 { lines.join(linebreak()) }
  }

  set text(
    font: body-font,
    size: font-size,
    fill: black,
    hyphenate: false,
    top-edge: CAP_HEIGHT,
    bottom-edge: "baseline",
    fallback: true,
  )
  set par(leading: LEADING, spacing: LEADING, justify: false)
  set block(above: LEADING, below: LEADING)
  show raw: set text(font: DEFAULT_MONO_FONTS)
  show link: set text(fill: black)
  set page(paper: "us-letter")

  context {
    let line = LINE.to-absolute()
    let width = page.width - 2 * MARGIN
    let subject-lines = calc.max(1, line-count(subject-line(subject), width))
    let symbol-lines = calc.max(1, line-count(office-symbol, width))
    // AR 25-50 2-5: a continuation page repeats the office symbol an inch from
    // the top and the subject on the line below it, and its text resumes on
    // the third line below the subject.
    let top-margin = MARGIN + (symbol-lines + subject-lines + 2) * line
    let office-symbol-top = office-symbol-baseline(font-size) - CAP_HEIGHT.to-absolute()

    set page(
      margin: (left: MARGIN, right: MARGIN, bottom: MARGIN, top: top-margin),
      header: {
        context if here().page() > 1 {
          place(top + left, dy: MARGIN, block(width: 100%, {
            par(office-symbol)
            par(subject-line(subject))
          }))
        }
        if banner != none { place(top + center, dy: 0.375in, banner) }
      },
      footer: {
        context if here().page() > 1 {
          place(
            bottom + center,
            dy: PAGE_NUMBER_BASELINE - page.height,
            baselined(counter(page).display()),
          )
        }
        if banner != none {
          place(bottom + center, dy: -0.375in, text(bottom-edge: "baseline", banner))
        }
      },
      background: context if here().page() == 1 {
        render-letterhead(letterhead-title, seal: letterhead-seal)
        render-suspense(suspense, font-size)
      },
    )

    // A bottom float on page 1, so the body never runs under the block. Only
    // the part above the bottom margin is reserved; the rest overhangs into
    // the half-inch band at the page edge.
    if cui-indicator != none {
      let indicator-box = box({
        set text(font: DEFAULT_BODY_FONTS, size: 10pt, top-edge: "cap-height")
        set par(leading: 0.4em, spacing: 0pt)
        set align(left)
        cui-indicator
      })
      let overhang = MARGIN - 0.5in
      let reserved = measure(indicator-box).height - overhang
      place(
        bottom,
        float: true,
        clearance: LEADING,
        box(width: 100%, height: reserved, {
          place(bottom + right, dx: MARGIN - 0.5in, dy: overhang, indicator-box)
        }),
      )
      [#metadata(reserved + LEADING.to-absolute())<army-memo-page-one-reserve>]
    }

    v(office-symbol-top - top-margin)
    render-office-symbol-row(office-symbol, record-number, printed-date)
    // AR 25-50 2-4a(5): the address on the third line below the office symbol.
    blank-lines(2)
    render-address-section(memo-for, memo-thru, thru-fields)
    blank-line()
    par(subject-line(subject))
    // AR 25-50 2-4b(1): the text on the third line below the subject.
    blank-lines(2)
    it
  }
}
