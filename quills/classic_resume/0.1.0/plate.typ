#import "@local/quillmark-helper:0.1.0": data, ink
#import "@local/ttq-classic-resume:0.1.0": (
  auto-link, default-config, entry, item-grid, resume, resume-header, section-header,
)

// `plaintext`/`richtext` fields lower to content carrying a space element on
// each side, so a filled one would print its padding inside a bold run or an
// italic one. A blank one lowers to "".
#let trim-inline(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

// `none` for a field the author left blank, so the components can drop what it
// would have occupied: a dated `entry` omits its whole second line when both
// halves are none, a linked one its annotation, an entry what is under it, and
// a section its heading.
#let or-none(v) = {
  let trimmed = trim-inline(v)
  if trimmed == [] or trimmed == "" { none } else { trimmed }
}

// The quillmark helper leaves an unset or whitespace-only markdown body as the
// empty string; only a non-empty body is eval'd into content.
#let body-of(card) = {
  let body = card.at("$body", default: "")
  if type(body) == str { none } else { body }
}

// A `string` field is text to compute with: a contact or a project link is read
// to find its target, and the name reaches `set document(author:)`, which takes
// no content. What prints is the field's ink twin, `printed`, which keeps the
// click target a value computed with loses.
#let linked(value, printed) = {
  let value = value.trim()
  if value == "" { none } else { auto-link(value, body: printed) }
}

#show: resume.with(
  // An enum's blank is authorable even where the schema declares a default.
  paper: if data.paper != "" { data.paper } else { "us-letter" },
  size: data.font_size * 1pt,
  margin: data.margin * 1in,

  // The package's stack names two families to fall back to; only the one this
  // quill bundles is in the render's font book, and naming the absent two
  // warns once per render.
  font: "EB Garamond",
  // EB Garamond has no ❖ (U+2756), the package's default separator: it prints
  // only where a second family is installed to lend the glyph, and draws from
  // that family rather than this one. ◆ is the nearest diamond EB Garamond
  // carries itself, and wants a point less to weigh the same: 6pt at 12pt.
  contact-separator: "◆",
  contact-separator-size: 0.5em,
)

// The package restyles lists to its square bullet inside an entry only. A
// section body is the other place a resume holds one, and a list that changed
// marker with its surroundings would read as two templates.
#show list: set list(
  marker: box(
    fill: black,
    width: default-config.marker-size,
    height: default-config.marker-size,
    baseline: default-config.marker-baseline,
  ),
  body-indent: default-config.marker-indent,
  indent: 0em,
)

#resume-header(
  name: if data.name.trim() != "" { ink(data).name },
  title: data.name.trim(),
  author: data.name.trim(),
  contacts: data.contacts.zip(ink(data).contacts)
    .map(((contact, printed)) => linked(contact, printed))
    .filter(contact => contact != none),
)

// The section titles are the PDF's outline, and a `details` cell cannot decline a
// heading as a body does, so one written there sets as a bold line outside it.
#let under-entry(details) = {
  let body = or-none(details)
  if body == none { return none }
  set heading(outlined: false, bookmarked: false)
  show heading: it => block(strong(it.body))
  body
}

#let dated(heading, dates, subtitle, location, details) = entry(
  heading: trim-inline(heading),
  form: "dated",
  dates: trim-inline(dates),
  subtitle: or-none(subtitle),
  location: or-none(location),
  body: under-entry(details),
)

// The rows an author filled in. A row left wholly blank, as a new one is, would
// print as an empty gap.
#let filled(rows) = rows.filter(row => row.values().any(value => {
  or-none(if type(value) == str { value.trim() } else { value }) != none
}))

// What each declared kind sets under its heading and body. A card of a kind
// the quill does not declare is warned on and left off the page: its fields
// are not this quill's to read.
#let rows = (
  summary: card => none,
  experience: card => for job in filled(card.jobs) {
    dated(job.company, job.dates, job.role, job.location, job.details)
  },
  education: card => for school in filled(card.schools) {
    dated(school.school, school.dates, school.degree, school.location, school.details)
  },
  skills: card => item-grid(
    items: filled(card.skills).map(row => (label: or-none(row.label), text: trim-inline(row.items))),
    columns: calc.max(1, card.columns),
  ),
  projects: card => for project in filled(card.projects) {
    entry(
      heading: trim-inline(project.name),
      form: "linked",
      url: linked(project.link, ink(project).link),
      body: under-entry(project.details),
    )
  },
  certifications: card => item-grid(
    items: card.items.map(or-none).filter(item => item != none),
    columns: calc.max(1, card.columns),
  ),
  other: card => for row in filled(card.entries) {
    dated(row.heading, row.dates, row.subtitle, row.location, row.details)
  },
)

#for card in data.at("$cards") {
  let kind = card.at("$kind", default: none)
  if type(kind) == str and kind in rows {
    let title = or-none(card.title)
    if title != none { section-header(title) }
    body-of(card)
    rows.at(kind)(card)
  }
}
