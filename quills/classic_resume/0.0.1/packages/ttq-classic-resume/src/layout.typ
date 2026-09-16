// layout.typ
// The document-wide show rule.

#import "config.typ": config-state, default-config

/// Applies the resume styling to the whole document.
///
/// Use `#show: resume` for the defaults, or `#show: resume.with(size: 11pt)`
/// to override any key of `default-config`.
#let resume(..options, body) = {
  assert(
    options.pos().len() == 0,
    message: "resume: expected named options only, found "
      + str(options.pos().len()) + " positional argument(s)",
  )
  let unknown = options.named().keys().filter(key => key not in default-config)
  assert(
    unknown.len() == 0,
    message: "resume: unknown option(s) " + unknown.map(repr).join(", ")
      + "; expected one of " + default-config.keys().map(repr).join(", "),
  )

  let cfg = default-config + options.named()

  set page(paper: cfg.paper, margin: cfg.margin)
  set text(font: cfg.font, size: cfg.size)
  set par(leading: cfg.leading, spacing: cfg.leading, justify: false)

  // One vertical rhythm for every kind of block-level content.
  set block(above: cfg.leading, below: cfg.leading)
  set list(spacing: cfg.leading)

  // Hyperlinks are styled like the surrounding text: on paper the colour is
  // noise, and the link is still live in the PDF.
  show link: set text(fill: black)

  // Headings carry the document structure into the tagged PDF. The resume look
  // is applied here rather than inside the components, so that plain `=` and
  // `==` markup renders the same way: the name is the level 1 heading, a
  // section title the level 2 one. Both are set apart by weight and case
  // rather than by size.
  set heading(numbering: none)
  show heading: set text(size: cfg.size, weight: "bold")
  show heading: set block(above: cfg.leading, below: cfg.leading)
  // The name is enlarged inside the block, not on the heading itself, so that
  // the surrounding `em` spacing keeps resolving against the body size.
  show heading.where(level: 1): it => block(text(size: cfg.name-size, it.body))
  show heading.where(level: 2): it => {
    v(cfg.section-spacing)
    block(upper(it.body))
    block(above: cfg.leading, line(length: 100%, stroke: cfg.rule-stroke))
  }

  config-state.update(cfg)

  body
}
