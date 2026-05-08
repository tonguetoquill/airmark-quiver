// components.typ
// Resume building blocks. All components are content-typed and read shared
// spacing/metrics from the resume() config state.

#import "layout.typ": _get-config

#let _content-or-empty(c) = if c == none { [] } else { c }

// Default contacts separator: small, padded diamond.
#let _default-separator = box(inset: (left: 0.4em, right: 0.4em))[#text("❖", size: 8pt)]

// Header: name + contact line.
//
// `contacts` is an array of content (strings, links, etc.) joined by `separator`.
// Pass `name: none` to render only contacts; pass `contacts: ()` to render only the name.
#let header(
  name: none,
  contacts: (),
  separator: _default-separator,
) = {
  set align(left)

  if name != none {
    block(text(size: 18pt, weight: "bold", name))
  }

  if contacts.len() > 0 {
    if name != none {
      context v(_get-config().entry-spacing)
    }
    for (i, c) in contacts.enumerate() {
      if i > 0 { separator }
      c
    }
  }
}

// Section header: bold uppercase title with an optional rule beneath.
//
// `title` is content (so callers can pass already-styled content or icons).
// `extra` is an optional content fragment appended after the title (e.g. a date range).
// `rule: false` suppresses the underline.
#let section(title, extra: none, rule: true) = {
  set align(left)
  context v(_get-config().section-spacing)

  block({
    text(weight: "bold", upper(title))
    if extra != none {
      [ ]
      text(weight: "bold", extra)
    }
  })

  if rule {
    line(length: 100%, stroke: 0.75pt)
    v(-2pt)
  }
}

// Unified entry block. Subsumes the old `timeline-entry` and `project-entry`.
//
// Two header rows (both optional):
//   row 1: heading-left (bold)        | heading-right (bold)
//   row 2: subheading-left (italic)   | subheading-right (italic)
//
// `body` is content rendered below the header (typically a markdown list).
// All four corners and the body accept `none`; missing rows are skipped.
//
// For project-style entries, pass a `monolink(...)` as `heading-right`.
#let entry(
  heading-left: none,
  heading-right: none,
  subheading-left: none,
  subheading-right: none,
  body: none,
) = {
  context v(_get-config().entry-spacing)

  block(breakable: false, {
    let cells = ()
    if heading-left != none or heading-right != none {
      cells.push(align(left, text(weight: "bold", _content-or-empty(heading-left))))
      cells.push(align(right, text(weight: "bold", _content-or-empty(heading-right))))
    }
    if subheading-left != none or subheading-right != none {
      cells.push(align(left, text(style: "italic", _content-or-empty(subheading-left))))
      cells.push(align(right, text(style: "italic", _content-or-empty(subheading-right))))
    }

    if cells.len() > 0 {
      context grid(
        columns: (1fr, auto),
        row-gutter: _get-config().leading,
        ..cells,
      )
    }

    if body != none { body }
  })
}

// One-line entry for awards, certifications, publications, etc.
//
//   left  | right
#let compact-entry(left, right: none) = {
  context v(_get-config().entry-spacing)
  grid(
    columns: (1fr, auto),
    align(start, left),
    align(end, _content-or-empty(right)),
  )
}

// Summary / objective paragraph.
#let summary(body) = {
  context v(_get-config().entry-spacing)
  block(body)
}

// Skills (or any categorized/flat grid). Replaces the old `table` (which
// shadowed Typst's built-in).
//
// `items` is one of:
//   (content, content, ...)                     -- flat
//   ((category: content, text: content), ...)   -- categorized
//
// Mixed shapes raise an error rather than silently misrendering.
#let skills(items, columns: 2) = {
  if items.len() == 0 { return }

  let _is-cat(item) = type(item) == dictionary and "category" in item
  let categorized = _is-cat(items.at(0))
  for item in items {
    assert(
      _is-cat(item) == categorized,
      message: "skills(): all items must have the same shape (either all `(category, text)` dicts or all plain content).",
    )
  }

  context v(_get-config().entry-spacing)

  let render-cell(item) = if categorized {
    block({
      text(weight: "bold", item.category)
      linebreak()
      item.text
    })
  } else {
    item
  }

  context {
    let cfg = _get-config()
    pad(
      left: cfg.bullet-marker-size + cfg.bullet-indent,
      grid(
        columns: (1fr,) * columns,
        row-gutter: if categorized { cfg.leading + cfg.entry-spacing } else { cfg.leading },
        column-gutter: 1em,
        ..items.map(render-cell),
      ),
    )
  }
}

// Monospaced italic link, sized to sit under a bold heading on the right.
// Use as `heading-right: monolink("https://example.com")` in `entry(...)`.
//
// `url` may be a full URL (http/https/mailto), in which case it becomes a real
// `link(...)`; otherwise it renders as plain styled text.
#let monolink(url, label: none) = context {
  let cfg = _get-config()
  let display = if label == none { url } else { label }
  let is-url = type(url) == str and (
    url.starts-with("http://")
      or url.starts-with("https://")
      or url.starts-with("mailto:")
  )
  text(
    size: 8pt,
    font: cfg.mono-font,
    emph(if is-url { link(url, display) } else { display }),
  )
}
