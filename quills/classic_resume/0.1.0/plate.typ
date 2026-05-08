#import "@local/quillmark-helper:0.1.0": data
#import "@local/ttq-classic-resume:0.2.0": *

#show: resume

// Auto-link http(s):// and mailto: contacts. Everything else is plain text.
#let render-contact(s) = {
  if type(s) != str { return s }
  if s.starts-with("http://") or s.starts-with("https://") {
    let display = s.replace(regex("^https?://"), "").trim("/", at: end)
    link(s)[#display]
  } else if s.starts-with("mailto:") {
    link(s)[#s.slice(7)]
  } else {
    s
  }
}

// Build a bulleted list from an array of bullet items. Each item is either
// pre-rendered content (when declared `type: markdown`) or a string (which
// auto-coerces to text). `none` if the array is empty/missing.
#let bullets-body(items) = {
  if items == none or items.len() == 0 { return none }
  list(..items)
}

#header(
  name: data.at("name", default: none),
  contacts: data.at("contacts", default: ()).map(render-contact),
)

// Document body becomes the summary paragraph above the cards.
#let main-body = data.at("BODY", default: none)
#if main-body != none and type(main-body) != str { summary(main-body) }

#for card in data.at("CARDS", default: ()) {
  // Optional per-card section header. Renders nothing when blank.
  let h = card.at("header", default: "")
  if h != "" { section(h) }

  let t = card.CARD
  if t == "certifications" {
    skills(
      card.at("items", default: ()),
      columns: card.at("columns", default: 2),
    )
  } else if t == "skills" {
    skills(
      card.at("items", default: ()),
      columns: card.at("columns", default: 2),
    )
  } else if t == "experience" {
    for e in card.at("entries", default: ()) {
      entry(
        heading-left: e.at("role", default: none),
        heading-right: e.at("dates", default: none),
        subheading-left: e.at("organization", default: none),
        subheading-right: e.at("location", default: none),
        body: bullets-body(e.at("bullets", default: ())),
      )
    }
  } else if t == "education" {
    for e in card.at("entries", default: ()) {
      entry(
        heading-left: e.at("degree", default: none),
        heading-right: e.at("dates", default: none),
        subheading-left: e.at("school", default: none),
        subheading-right: e.at("location", default: none),
        body: bullets-body(e.at("bullets", default: ())),
      )
    }
  } else if t == "competition" {
    for e in card.at("entries", default: ()) {
      entry(
        heading-left: e.at("title", default: none),
        body: bullets-body(e.at("bullets", default: ())),
      )
    }
  } else if t == "project" {
    for e in card.at("entries", default: ()) {
      let url = e.at("url", default: "")
      entry(
        heading-left: e.at("name", default: none),
        heading-right: if url != "" { monolink(url) } else { none },
        body: bullets-body(e.at("bullets", default: ())),
      )
    }
  } else if t == "award" {
    for e in card.at("entries", default: ()) {
      let issuer = e.at("issuer", default: "")
      let title-bold = text(weight: "bold", e.at("title", default: ""))
      let left = if issuer != "" {
        [#title-bold — #issuer]
      } else {
        title-bold
      }
      compact-entry(left, right: e.at("date", default: none))
    }
  }
}
