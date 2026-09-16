#import "@local/quillmark-helper:0.1.0": data
#import "@local/ttq-classic-resume:0.1.0": (
  default-config, entry, item-grid, resume, resume-header, section-header,
)

// `plaintext`/`richtext` fields lower to content carrying a space element on
// each side, so a blank one is not `[]` and a filled one would print its
// padding inside a bold run or an italic one.
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
// halves are none, and a linked one its annotation.
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

// A variant-bearing enum rests as `{value: …, …}`; a bare string is the
// discriminant before that container is built.
#let member(field) = {
  if type(field) == dictionary { field.at("value", default: "") } else { field }
}

#let stock-title = (
  experience: "Work Experience",
  education: "Education",
  projects: "Projects",
  skills: "Skills",
  certifications: "Certifications",
  summary: "Summary",
)

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
  // carries itself, and wants a point less to weigh the same.
  contact-separator: "◆",
  contact-separator-size: 6pt,
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

// `name` and `contacts` are read as `string` rather than `plaintext`, which
// lowers to content: the name reaches `set document(author:)`, which takes no
// content, and `link-contacts` linkifies a str while passing content through.
#resume-header(
  name: data.name,
  contacts: data.contacts,
  link-contacts: data.link_contacts,
)

// One flat card list. A section prints its heading (and, for skills and
// certifications, its list); every entry after it belongs to that heading
// until the next section card.
#for card in data.at("$cards") {
  let kind = card.at("$kind", default: none)

  if kind == "section" {
    let topic = member(card.topic)
    let title = or-none(card.title)
    if title == none { title = stock-title.at(topic, default: none) }
    let extra = or-none(card.extra)
    if title != none or extra != none {
      section-header(if title != none { title } else { [] }, extra: extra)
    }
    body-of(card)

    // These fields exist only in the live world; the branch is what makes
    // reading them total, the same as `classification` on the memo plate.
    if topic == "certifications" {
      item-grid(
        items: card.topic.at("items", default: ()).map(trim-inline),
        columns: card.topic.at("columns", default: 2),
      )
    } else if topic == "skills" {
      item-grid(
        items: card.topic.at("labeled_items", default: ()).map(row => (
          label: trim-inline(row.label),
          text: trim-inline(row.text),
        )),
        columns: card.topic.at("columns", default: 2),
      )
    }
  } else if kind == "entry" {
    let form = member(card.form)
    if form == "linked" {
      let url = card.form.at("url", default: "")
      entry(
        heading: trim-inline(card.heading),
        form: "linked",
        url: if url != "" { url } else { none },
        body: body-of(card),
      )
    } else {
      entry(
        heading: trim-inline(card.heading),
        form: "dated",
        dates: trim-inline(card.form.at("dates", default: "")),
        subtitle: or-none(card.form.at("subtitle", default: "")),
        location: or-none(card.form.at("location", default: "")),
        body: body-of(card),
      )
    }
  }
}
