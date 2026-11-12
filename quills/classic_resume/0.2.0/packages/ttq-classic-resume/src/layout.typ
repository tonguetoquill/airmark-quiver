// layout.typ
// The document-wide show rule.

#import "config.typ": config-state, default-config

// The name at the left and the page count at the right, over every page after
// the first, so a page read apart from the first still says whose it is. The
// name is read back off the heading `resume-header` labels, so a level 1
// heading written in the body never stands in for it. Small and italic, it
// reads as a running head: a 0.5in margin leaves no room to set it further off
// the page.
#let _continuation-header(cfg) = context {
  if counter(page).get().first() > 1 {
    set text(size: cfg.annotation-size, style: "italic")
    let names = query(<ttq-classic-resume-name>)
    if names.len() > 0 { names.first().body }
    h(1fr)
    counter(page).display("1 of 1", both: true)
  }
}

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

  set page(
    paper: cfg.paper,
    margin: cfg.margin,
    header: if cfg.continuation-header { _continuation-header(cfg) },
  )
  set text(font: cfg.font, size: cfg.size)
  set par(leading: cfg.leading, spacing: cfg.leading, justify: false)

  // One vertical rhythm for every kind of block-level content. Block spacing
  // collapses to the larger of two neighbours' gaps, so a gap wider than
  // `leading` is set as a block's `above` or `below` rather than with `v`,
  // which would add to it.
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
  // A heading keeps with what follows it, so the section's first line is on
  // the page its rule is. Capitals set solid crowd each other, so the title is
  // tracked out a little.
  show heading.where(level: 2): it => block(
    above: cfg.leading + cfg.section-spacing,
    below: cfg.leading + cfg.rule-spacing,
    sticky: true,
    {
      text(tracking: 0.04em, upper(it.body))
      block(above: cfg.leading, line(length: 100%, stroke: cfg.rule-stroke))
    },
  )

  config-state.update(cfg)

  body
}
