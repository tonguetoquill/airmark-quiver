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
  // for the gap between paragraphs, blocks and list items; the two `*-spacing`
  // values are the extra breathing room above a section header and above an
  // entry.
  leading: 0.5em,
  section-spacing: 5pt,
  entry-spacing: 5pt,

  // Resume header. The separator keeps its own padding so that the space
  // around it does not change when its size does.
  name-size: 18pt,
  contact-separator: "❖",
  contact-separator-size: 7pt,
  contact-separator-padding: 0.5em,

  // Rule drawn underneath a section header. The gap between the rule and the
  // first entry of the section comes from that entry's `entry-spacing`.
  rule-stroke: 0.75pt,

  // Square bullet used by lists inside an entry. The negative baseline lifts
  // the square off the baseline so that it lines up with the middle of the
  // x-height instead of hanging below the line.
  marker-size: 3.5pt,
  marker-baseline: -0.07em,
  marker-indent: 0.8em,

  // Right-aligned annotation of a project entry, normally a URL. A font of
  // `auto` keeps the body font.
  annotation-font: auto,
  annotation-size: 8pt,
)

#let config-state = state("ttq-classic-resume:config", default-config)

// Runs `fn` with the active configuration. Components use this instead of
// reading `config-state` directly so that the `context` stays out of the way.
#let with-config(fn) = context fn(config-state.get())
