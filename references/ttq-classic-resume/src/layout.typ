// layout.typ
// Page, text, and bullet defaults for the classic resume.

// Internal config state read by components for spacing and bullet metrics.
// Components fetch these via `context` so a single `resume(...)` call can
// retune the whole document without threading parameters everywhere.
#let _config-state = state("ttq-classic-resume", (
  font: ("EB Garamond",),
  font-size: 12pt,
  paper: "us-letter",
  margin: 0.5in,
  leading: 0.5em,
  section-spacing: 5pt,
  entry-spacing: 5pt,
  link-color: black,
  bullet-marker-size: 3.5pt,
  bullet-indent: 0.8em,
  mono-font: ("DejaVu Sans Mono", "Courier New"),
))

#let _get-config() = _config-state.get()

// Resume show rule. Wrap the document with `#show: resume.with(...)`.
//
// Knobs (all optional):
//   font, font-size, paper, margin       page + text basics
//   leading                              vertical rhythm (par + block + list)
//   section-spacing, entry-spacing       extra gap above sections / entries
//   link-color                           color applied to all `link(...)`
//   bullet-marker                        `auto` for filled square, or any content
//   bullet-marker-size, bullet-indent    metrics used when marker == auto
//   mono-font                            font stack for `monolink(...)`
#let resume(
  font: ("EB Garamond",),
  font-size: 12pt,
  paper: "us-letter",
  margin: 0.5in,
  leading: 0.5em,
  section-spacing: 5pt,
  entry-spacing: 5pt,
  link-color: black,
  bullet-marker: auto,
  bullet-marker-size: 3.5pt,
  bullet-indent: 0.8em,
  mono-font: ("DejaVu Sans Mono", "Courier New"),
  body,
) = {
  _config-state.update((
    font: font,
    font-size: font-size,
    paper: paper,
    margin: margin,
    leading: leading,
    section-spacing: section-spacing,
    entry-spacing: entry-spacing,
    link-color: link-color,
    bullet-marker-size: bullet-marker-size,
    bullet-indent: bullet-indent,
    mono-font: mono-font,
  ))

  set page(paper: paper, margin: margin)
  set text(font: font, size: font-size)
  set par(leading: leading, justify: false, spacing: leading)
  set block(above: leading, below: leading)

  let marker = if bullet-marker == auto {
    box(
      fill: black,
      width: bullet-marker-size,
      height: bullet-marker-size,
      baseline: 0.5em,
    )
  } else {
    bullet-marker
  }
  set list(
    spacing: leading,
    marker: marker,
    body-indent: bullet-indent,
    indent: 0em,
  )

  show link: set text(fill: link-color)

  body
}
