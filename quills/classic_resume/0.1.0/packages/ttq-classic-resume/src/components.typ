// components.typ
// The building blocks a resume is written with.

#import "config.typ": with-config
#import "util.typ": auto-link

// Restyles native `- item` lists to the square bullet of the template. It is a
// show rule rather than a custom list component so that the body of an entry
// stays ordinary Typst markup.
#let _bulleted(cfg, body) = {
  show list: set list(
    marker: box(
      fill: black,
      width: cfg.marker-size,
      height: cfg.marker-size,
      baseline: cfg.marker-baseline,
    ),
    body-indent: cfg.marker-indent,
    indent: 0em,
  )
  body
}

// Shared skeleton of `timeline-entry` and `project-entry`: a grid of
// left/right aligned header cells followed by an optional bulleted body, kept
// together on one page.
#let _entry(cfg, cells, body) = {
  v(cfg.entry-spacing)
  block(breakable: false, {
    grid(columns: (1fr, auto), row-gutter: cfg.leading, ..cells)
    if body != none {
      _bulleted(cfg, body)
    }
  })
}

/// Name and contact line at the top of the resume.
///
/// The name becomes the level 1 heading of the document, and — unless `title`
/// and `author` say otherwise — the title and author of the exported PDF.
/// Contacts are separated by a diamond and, with `link-contacts` left on, email
/// addresses, web addresses and phone numbers among them become links. Pass
/// ready-made content instead of a string to opt a single contact out.
#let resume-header(
  name: "",
  contacts: (),
  link-contacts: true,
  title: auto,
  author: auto,
) = {
  // Only the metadata that resolves to something is set, so that passing
  // `none` leaves Typst's own default in place.
  let metadata = (:)
  let title = if title == auto { name } else { title }
  let author = if author == auto { name } else { author }
  if title not in (none, "") { metadata.title = title }
  if author not in (none, "") { metadata.author = author }
  set document(..metadata)

  with-config(cfg => {
    heading(level: 1, name)
    v(cfg.entry-spacing)

    // A box rather than spaces, so that the padding is a real length and the
    // separator still cannot be split from the contacts on either side.
    let separator = box(
      inset: (x: cfg.contact-separator-padding),
      text(size: cfg.contact-separator-size, cfg.contact-separator),
    )
    contacts
      .map(contact => if link-contacts { auto-link(contact) } else { contact })
      .join(separator)
  })
}

/// Section title with a rule underneath it, such as `Work Experience`.
///
/// `extra` is appended to the title in the same weight, for a qualifier like a
/// date range. The section becomes a level 2 heading, so `== Work Experience`
/// renders identically.
#let section-header(title, extra: none) = {
  heading(level: 2, if extra == none { title } else { [#title #extra] })
}

/// Dated entry for a job, a degree or an award.
///
/// The headings sit on one row (left and right aligned), the subheadings on a
/// second one, and `body` holds ordinary Typst markup — most often a `- item`
/// list, which picks up the square bullet of the template.
#let timeline-entry(
  heading-left: "",
  heading-right: "",
  subheading-left: none,
  subheading-right: none,
  body: none,
) = with-config(cfg => {
  let cells = (
    align(left, text(weight: "bold", heading-left)),
    align(right, text(weight: "bold", heading-right)),
  )

  if subheading-left != none or subheading-right != none {
    cells.push(align(left, text(style: "italic", subheading-left)))
    cells.push(align(right, text(style: "italic", subheading-right)))
  }

  _entry(cfg, cells, body)
})

/// Project entry: a name, an optional annotation set to the right, and a body.
///
/// The annotation is usually a URL, and is linked when it looks like one.
#let project-entry(
  name: "",
  url: none,
  body: none,
) = with-config(cfg => {
  let annotation = if url != none {
    let label = text(
      size: cfg.annotation-size,
      font: if cfg.annotation-font == auto { cfg.font } else { cfg.annotation-font },
      style: "italic",
      url,
    )
    if type(url) == str and url.starts-with("http") { link(url, label) } else { label }
  }

  _entry(
    cfg,
    (align(left, text(weight: "bold", name)), align(right, annotation)),
    body,
  )
})

/// Multi-column list of short items, for certifications, skills or awards.
///
/// Two shapes are accepted and told apart by the first item: a flat array of
/// content, or an array of `(category: .., text: ..)` dictionaries, which puts
/// the category in bold above its text.
#let item-grid(items: (), columns: 2) = {
  if items.len() == 0 {
    return
  }
  assert(
    type(columns) == int and columns >= 1,
    message: "item-grid: `columns` must be a positive integer, found " + repr(columns),
  )

  let categorized = type(items.at(0)) == dictionary and "category" in items.at(0)

  let cell(item) = if categorized {
    assert(
      type(item) == dictionary and "category" in item and "text" in item,
      message: "item-grid: every item must be a `(category: .., text: ..)` dictionary "
        + "when the first one is, found " + repr(item),
    )
    block({
      text(weight: "bold", item.category)
      linebreak()
      item.text
    })
  } else {
    assert(
      type(item) != dictionary,
      message: "item-grid: a `(category: .., text: ..)` dictionary cannot be mixed with "
        + "plain items, found " + repr(item),
    )
    item
  }

  with-config(cfg => {
    v(cfg.entry-spacing)
    pad(
      // Line the items up with the bullets of the entries around them.
      left: cfg.marker-size + cfg.marker-indent,
      grid(
        columns: (1fr,) * columns,
        // Categorized items are two lines tall, so they need the extra gap to
        // stay visually separated.
        row-gutter: if categorized { cfg.leading + cfg.entry-spacing } else { cfg.leading },
        column-gutter: 1em,
        ..items.map(cell),
      ),
    )
  })
}
