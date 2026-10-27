#import "config.typ": *
#import "utils.typ": *

#let cui-banner() = text(size: BODY_SIZE, weight: "bold")[CUI]

// The SECTION heading in force at `loc`: the last numbered Heading 1 on or
// before its page, so a section's first page counts as that section.
#let section-at(loc) = {
  let sections = query(heading.where(level: 1))
    .filter(h => h.numbering != none and h.location().page() <= loc.page())
  if sections.len() == 0 { 1 } else { counter(heading).at(sections.last().location()).first() }
}

// ENC pages are numbered section-page: 1-1, 1-2, 2-1.
#let section-page(loc) = str(section-at(loc)) + "-" + str(counter(page).at(loc).first())

#let body-numbering(..nums) = context {
  str(section-at(here())) + "-" + str(nums.pos().at(0, default: 1))
}

#let running-header-lines(cui-enabled, title-line) = {
  let lines = ()
  if cui-enabled { lines.push(cui-banner()) }
  if title-line != none { lines.push(title-line) }
  stack(spacing: 0.35em, ..lines.map(line => align(center, line)))
}

#let running-header(cui-enabled, title-line) = {
  if cui-enabled or title-line != none {
    place(top + center, dy: BANNER_FROM_EDGE, block(width: 100%, running-header-lines(cui-enabled, title-line)))
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
    header: running-header(cui-enabled, none),
    footer: running-footer(cui-enabled),
    numbering: none,
  )
  it
}
