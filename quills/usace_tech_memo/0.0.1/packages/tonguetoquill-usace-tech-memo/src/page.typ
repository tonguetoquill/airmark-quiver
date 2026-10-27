#import "config.typ": *
#import "utils.typ": *

#let cui-banner() = text(size: BODY_SIZE, weight: "bold")[CUI]

#let running-header(cui-enabled) = {
  if cui-enabled {
    place(top + center, dy: BANNER_FROM_EDGE, cui-banner())
  }
}

#let running-footer(cui-enabled) = {
  context {
    let numbering = page.numbering
    if numbering != none {
      place(bottom + center, dy: -PAGE_NUMBER_FROM_EDGE, counter(page).display(numbering))
    }
    if cui-enabled {
      place(bottom + center, dy: -BANNER_FROM_EDGE, cui-banner())
    }
  }
}

#let document-setup(cui-enabled: true, it) = {
  set text(
    font: DEFAULT_BODY_FONTS,
    size: BODY_SIZE,
    fill: black,
    hyphenate: false,
    fallback: true,
  )
  set par(leading: LEADING, spacing: PAR_SPACING, justify: false)
  set block(spacing: PAR_SPACING)
  show raw: set text(font: DEFAULT_MONO_FONTS)
  show link: set text(fill: black)
  set page(
    paper: "us-letter",
    margin: MARGIN,
    header: running-header(cui-enabled),
    footer: running-footer(cui-enabled),
    numbering: none,
  )
  it
}
