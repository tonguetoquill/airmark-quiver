#import "config.typ": *
#import "utils.typ": *

#let body-numbering(letter) = (..nums) => letter + "-" + str(nums.pos().at(0, default: 1))

#let running-header(cui-enabled, project-name) = {
  let lines = ()
  if cui-enabled { lines.push[CUI] }
  if not blank(project-name) { lines.push(upper(trim-inline(project-name))) }
  if lines.len() > 0 {
    place(top + center, dy: HEADER_FROM_EDGE, {
      set text(size: SMALL_SIZE)
      set par(leading: LEADING, spacing: 0pt)
      set align(center)
      lines.join(linebreak())
    })
  }
}

#let running-footer(cui-enabled) = context {
  let numbering = page.numbering
  let lines = ()
  if numbering != none { lines.push(counter(page).display(numbering)) }
  if cui-enabled { lines.push[CUI] }
  if lines.len() > 0 {
    place(bottom + center, dy: -FOOTER_FROM_EDGE, {
      set par(leading: LEADING, spacing: 0pt)
      set align(center)
      lines.join(linebreak())
    })
  }
}

#let document-setup(cui-enabled: true, project-name: none, it) = {
  set text(
    font: DEFAULT_BODY_FONTS,
    size: BODY_SIZE,
    fill: black,
    hyphenate: false,
    fallback: true,
    top-edge: LINE_TOP,
    bottom-edge: LINE_BOTTOM,
  )
  set par(leading: LEADING, spacing: PAR_SPACING, justify: false)
  set block(spacing: PAR_SPACING)
  show raw: set text(font: DEFAULT_MONO_FONTS)
  show link: set text(fill: black)
  set page(
    paper: "us-letter",
    margin: MARGIN,
    header: running-header(cui-enabled, project-name),
    footer: running-footer(cui-enabled),
    numbering: none,
  )
  it
}
