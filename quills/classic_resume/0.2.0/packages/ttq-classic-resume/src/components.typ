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

// Shared skeleton of `entry`: a grid of left/right aligned header cells
// followed by an optional bulleted body, kept together on one page. The gutter
// keeps a left cell that wraps off the right one. An entry taller than a page
// cannot be kept together, so it breaks where it must rather than running off
// the foot of one.
#let _entry(cfg, cells, body) = {
  let inner = {
    grid(columns: (1fr, auto), column-gutter: 1em, row-gutter: cfg.leading, ..cells)
    if body != none {
      _bulleted(cfg, body)
    }
  }
  block(
    above: cfg.leading + cfg.rule-spacing,
    below: cfg.leading + cfg.entry-spacing,
    layout(region => block(
      breakable: measure(block(width: region.width, inner)).height > region.height,
      inner,
    )),
  )
}

// Sets the contacts on as few lines as hold them, a separator between two on
// one line. A line therefore breaks only between contacts, and never starts or
// ends on a separator. The spaces around the separator are real ones, so text
// copied out of the PDF keeps the contacts apart.
#let _contact-lines(cfg, contacts) = layout(region => {
  // The separator's ink is centred on the x-height, where a middle dot sits,
  // whatever glyph and size it is set in.
  let glyph = text(size: cfg.contact-separator-size, cfg.contact-separator)
  let extent(top, bottom, body) = measure(text(top-edge: top, bottom-edge: bottom, body)).height
  let centre = extent("bounds", "baseline", glyph) - extent("bounds", "bounds", glyph) / 2
  let separator = [ #box(
      baseline: centre - extent("x-height", "baseline", [x]) / 2,
      inset: (x: cfg.contact-separator-padding),
      glyph,
    ) ]
  let lines = ()
  let current = ()
  for contact in contacts {
    if current.len() > 0 and measure((..current, contact).join(separator)).width > region.width {
      lines.push(current)
      current = ()
    }
    current.push(contact)
  }
  lines.push(current)
  lines.map(it => it.join(separator)).join(linebreak())
})

/// Name and contact line at the top of the resume.
///
/// The name becomes the level 1 heading of the document, and — unless `title`
/// and `author` say otherwise — the title and author of the exported PDF. A
/// `none` or empty name prints no heading and leaves both unset. With
/// `link-contacts` left on, email addresses, web addresses and phone numbers
/// among the contacts become links. Pass ready-made content instead of a
/// string to opt a single contact out.
#let resume-header(
  name: "",
  contacts: (),
  link-contacts: true,
  title: auto,
  author: auto,
) = {
  // Only the metadata that resolves to something is set, so that passing
  // `none` leaves Typst's own default in place. An author is text only.
  let metadata = (:)
  let title = if title == auto { name } else { title }
  let author = if author == auto { name } else { author }
  if title not in (none, "") { metadata.title = title }
  if type(author) == str and author != "" { metadata.author = author }
  set document(..metadata)

  let named = name not in (none, "")
  if named or contacts.len() > 0 {
    with-config(cfg => block(below: cfg.leading + cfg.header-spacing, {
      if named {
        [#heading(level: 1, name) <ttq-classic-resume-name>]
      }
      if contacts.len() > 0 {
        block(
          above: cfg.leading + cfg.entry-spacing,
          _contact-lines(cfg, contacts.map(contact => if link-contacts { auto-link(contact) } else { contact })),
        )
      }
    }))
  }
}

/// Section title with a rule underneath it, such as `Work Experience`.
///
/// `extra` is appended to the title in the same weight, for a qualifier like a
/// date range. The section becomes a level 2 heading, so `== Work Experience`
/// renders identically.
#let section-header(title, extra: none) = {
  heading(level: 2, if extra == none { title } else { [#title #extra] })
}

/// A resume row: dated (a job, a degree, an award) or linked (a project).
///
/// `dated` puts `dates` opposite `heading` and an optional italic second line
/// (`subtitle` / `location`). `linked` puts `url` opposite `heading`, small
/// and italic, and drops the second line; a `url` given as a string becomes a
/// link where a contact would. `body` is ordinary Typst markup — most often a
/// `- item` list, which picks up the square bullet of the template.
#let entry(
  heading: "",
  form: "dated",
  dates: none,
  subtitle: none,
  location: none,
  url: none,
  body: none,
) = with-config(cfg => {
  assert(
    form in ("dated", "linked"),
    message: "entry: `form` must be \"dated\" or \"linked\", found " + repr(form),
  )

  let cells = if form == "linked" {
    let annotation = if url != none {
      let label = text(
        size: cfg.annotation-size,
        font: if cfg.annotation-font == auto { cfg.font } else { cfg.annotation-font },
        style: "italic",
        url,
      )
      auto-link(url, body: label)
    }
    (align(left, text(weight: "bold", heading)), align(right, annotation))
  } else {
    let cells = (
      align(left, text(weight: "bold", heading)),
      align(right, text(weight: "bold", dates)),
    )
    if subtitle != none or location != none {
      cells.push(align(left, text(style: "italic", subtitle)))
      cells.push(align(right, text(style: "italic", location)))
    }
    cells
  }

  _entry(cfg, cells, body)
})

/// Multi-column list of short items, for certifications, skills or awards.
///
/// Two shapes are accepted and told apart by the first item: a flat array of
/// content, or an array of `(label: .., text: ..)` dictionaries, which puts
/// the label in bold above its text. A `none` or empty label prints no line.
#let item-grid(items: (), columns: 2) = {
  if items.len() == 0 {
    return
  }
  assert(
    type(columns) == int and columns >= 1,
    message: "item-grid: `columns` must be a positive integer, found " + repr(columns),
  )

  let labeled = type(items.at(0)) == dictionary and "label" in items.at(0)

  let cell(item) = if labeled {
    assert(
      type(item) == dictionary and "label" in item and "text" in item,
      message: "item-grid: every item must be a `(label: .., text: ..)` dictionary "
        + "when the first one is, found " + repr(item),
    )
    block({
      if item.label not in (none, "", []) {
        text(weight: "bold", item.label)
        linebreak()
      }
      item.text
    })
  } else {
    assert(
      type(item) != dictionary,
      message: "item-grid: a `(label: .., text: ..)` dictionary cannot be mixed with "
        + "plain items, found " + repr(item),
    )
    item
  }

  // The items start at the margin, as a section's prose and an entry's heading
  // do. Only a bullet's text is set in from it, where its marker explains why.
  with-config(cfg => block(
    above: cfg.leading + cfg.rule-spacing,
    grid(
      columns: (1fr,) * columns,
      // Labeled items are two lines tall, so they need the extra gap to
      // stay visually separated.
      row-gutter: if labeled { cfg.leading + cfg.entry-spacing } else { cfg.leading },
      column-gutter: 1em,
      ..items.map(cell),
    ),
  ))
}
