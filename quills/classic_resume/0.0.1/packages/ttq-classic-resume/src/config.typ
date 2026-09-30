// config.typ
// Defaults for the template, plus the state that carries them to components.
//
// `resume` stores the effective configuration in `config-state`; components
// read it back through `with-config`. That way a `#show: resume.with(..)`
// override reaches every component without threading arguments through each
// individual call.

#let default-config = (
  // Body font. The first installed family wins, so the bundled EB Garamond is
  // preferred while Typst's built-in serif faces act as a fallback.
  font: ("EB Garamond", "Libertinus Serif", "New Computer Modern"),
  size: 12pt,
  paper: "us-letter",
  margin: 0.5in,

  // Vertical rhythm. `leading` is used for the leading inside a paragraph and
  // for the gap between paragraphs, blocks and list items; each `*-spacing`
  // value is added to it for one wider gap: above a section header, under its
  // rule, between two entries, and under the name and contacts. The gap under
  // the rule is the same whether an entry, a list of items or prose follows it,
  // and an entry or a list of items keeps it from a paragraph above it too.
  leading: 0.5em,
  section-spacing: 5pt,
  rule-spacing: 3.5pt,
  entry-spacing: 5pt,
  header-spacing: 10pt,

  // Resume header. The separator stands between two contacts on one line,
  // never at either end of one, with a word space and this padding on each
  // side of it.
  name-size: 18pt,
  contact-separator: "❖",
  contact-separator-size: 7pt,
  contact-separator-padding: 0.25em,

  // Rule drawn underneath a section header.
  rule-stroke: 0.75pt,

  // Square bullet used by lists inside an entry. The negative baseline lifts
  // the square off the baseline so that it lines up with the middle of the
  // x-height instead of hanging below the line.
  marker-size: 3.5pt,
  marker-baseline: -0.07em,
  marker-indent: 0.8em,

  // Right-aligned annotation of a linked entry, normally a URL. A font of
  // `auto` keeps the body font; an `em` size follows the body size.
  annotation-font: auto,
  annotation-size: 0.85em,

  // Name and page number over every page after the first; `false` leaves
  // those pages bare.
  continuation-header: true,
)

#let config-state = state("ttq-classic-resume:config", default-config)

// Runs `fn` with the active configuration. Components use this instead of
// reading `config-state` directly so that the `context` stays out of the way.
#let with-config(fn) = context fn(config-state.get())
