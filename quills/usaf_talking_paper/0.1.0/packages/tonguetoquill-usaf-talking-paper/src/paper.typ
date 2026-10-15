// Air Force papers: AFH 33-337 (27 May 2015). The page setup is the point
// paper's (p. 224). The talking paper (p. 225) uses it with dash bullets.
// The background paper (pp. 228–229) and the position paper (p. 230) use it
// with the memorandum's paragraph numbering.

#import "config.typ": *

// The identification line in the sample reads "20 Jun 14".
#let date-pattern = "[day padding:none] [month repr:short] [year repr:last_two]"

#let falsey(value) = (
  value == none
    or value == false
    or (type(value) == array and value.len() == 0)
    or (type(value) == str and value.trim() == "")
    or value == []
)

// `plaintext` arrives with a space on each side. Drop those so a slash-joined
// line does not grow a space around every slash.
#let trim-inline(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak or c == linebreak()
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

// Level 0 is one hyphen. Each deeper level adds one, and a word space follows
// the marks so the item text starts where a wrapped line will hang.
#let dashes(level) = {
  let n = calc.max(1, calc.min(int(level) + 1, 6))
  let marks = "-" * n
  [#marks#h(0.33em)]
}

// Bullets and numbered items share one nesting depth, so an item gets one more
// dash than the item it sits under, whichever kind either one is.
#let list-depth = state("talking-paper-list-depth", 0)
#let nested(it) = {
  list-depth.update(d => d + 1)
  it
  list-depth.update(d => d - 1)
}
#let depth-dashes = context dashes(list-depth.get() - 1)

#let line-stride() = {
  let one = measure(par(spacing: 0pt)[x]).height
  measure(par(spacing: 0pt)[x#linebreak()x]).height - one
}

#let classification-marking(level, dissemination) = {
  if falsey(level) or type(level) != str { return none }
  let base = level.trim()
  if base == "" { return none }
  if falsey(dissemination) { return [#base] }
  // `//` starts a line comment in markup, so the separator is interpolated.
  let separator = "//"
  [#base#separator#box(upper(dissemination))]
}

#let classification-color(level) = {
  if falsey(level) or type(level) != str { return black }
  CLASSIFICATION_COLORS.at(level.trim(), default: black)
}

#let cui-lines(controlled-by, category, limited, poc) = {
  let lines = ()
  if not falsey(controlled-by) { lines.push([Controlled By: #controlled-by]) }
  if not falsey(category) { lines.push([CUI Category: #category]) }
  if not falsey(limited) { lines.push([LDC: #upper(limited)]) }
  if not falsey(poc) { lines.push([POC: #poc]) }
  if lines.len() == 0 { none } else { lines.join(linebreak()) }
}

#let identification-line(originator, organization, office-symbol, phone, typist, date) = {
  let parts = (originator, organization, office-symbol, phone, typist).map(trim-inline).filter(p => not falsey(p))
  if not falsey(date) { parts.push(date) }
  if parts.len() == 0 { return none }
  parts.map(p => [#p]).intersperse([/]).sum()
}

// pp. 228–229: paragraphs are numbered as in the official memorandum, 1. / a. /
// (1) / (a). A single paragraph is not numbered. A bullet is a subparagraph.
#let narrative-formats = ("1.", "a.", "(1)", "(a)")

#let narrative-skip(c) = {
  if c == none or c == [] { return true }
  if type(c) != content { return false }
  c == [ ] or c.func() == parbreak or c.func() == linebreak
}

#let narrative-prefix(level, n) = {
  let fmt = narrative-formats.at(calc.min(level, narrative-formats.len() - 1))
  [#numbering(fmt, n)#h(0.5em)]
}

#let narrative-indent(level) = {
  if level <= 0 { return 0pt }
  range(level).map(l => measure(narrative-prefix(l, 1)).width).sum()
}

#let narrative-block(node) = {
  if type(node) != content or node == [ ] { return false }
  let f = node.func()
  (
    f == parbreak or f == heading or f == list or f == enum
      or f == list.item or f == enum.item or f == quote or f == table or f == par
  )
}

// The body arrives as runs of text split by smart quotes, with a paragraph
// break between paragraphs and list items beside them. Group each run into
// one paragraph. A bullet is a subparagraph one level down.
#let narrative-read(nodes, level, item-mode) = {
  let out = ()
  let inline = ()
  let opened = false
  for child in nodes {
    let boundary = (
      type(child) == content
        and (
          child.func() == parbreak
            or child.func() == heading
            or child.func() == list
            or child.func() == enum
            or child.func() == list.item
            or child.func() == enum.item
            or child.func() == quote
            or child.func() == par
            or (child.has("child") and child.has("styles"))
            or (
              child.has("children")
                and not child.has("text")
                and not child.has("body")
                and not narrative-block(child)
            )
        )
    )
    if boundary or narrative-block(child) {
      if inline.any(n => not narrative-skip(n)) {
        let kind = if not item-mode { "par" } else if opened { "cont" } else { "item" }
        out.push((level: level, kind: kind, body: inline.sum()))
        opened = true
      }
      inline = ()
      if type(child) != content or child.func() == parbreak {
        // A paragraph break only separates runs.
      } else if child.has("child") and child.has("styles") {
        out += narrative-read((child.child,), level, item-mode)
      } else if child.func() == list or child.func() == enum {
        for item in child.children {
          out += narrative-read((item,), level + 1, true)
        }
      } else if child.func() == list.item or child.func() == enum.item {
        let body = child.at("body")
        let nested = (
          type(body) == content
            and body.has("children")
            and not body.has("text")
            and body.func() != text
        )
        if nested {
          out += narrative-read(body.children, level + 1, true)
        } else {
          out += narrative-read((body,), level + 1, true)
        }
      } else if child.func() == heading {
        out.push((level: level, kind: "heading", body: child.body))
      } else if child.func() == quote {
        out.push((level: level, kind: "quote", body: child.body))
      } else if child.func() == par {
        out.push((level: level, kind: "par", body: child.body))
      } else if child.has("children") and not child.has("text") and not child.has("body") {
        out += narrative-read(child.children, level, item-mode)
      } else {
        out.push((level: level, kind: "par", body: child))
      }
    } else {
      inline.push(child)
    }
  }
  if inline.any(n => not narrative-skip(n)) {
    let kind = if not item-mode { "par" } else if opened { "cont" } else { "item" }
    out.push((level: level, kind: kind, body: inline.sum()))
  }
  out
}

#let narrative-gather(node, level) = {
  if type(node) != content { return () }
  narrative-read((node,), level, false)
}

#let narrative-body(body, item-gap) = {
  let entries = narrative-gather(body, 0)
  if entries.len() == 0 { return body }
  let number-pars = entries.filter(e => e.kind == "par" and e.level == 0).len() > 1
  let counts = (0, 0, 0, 0)
  let first = true
  for entry in entries {
    let level = entry.level
    let kind = entry.kind
    let numbered = kind == "item" or (kind == "par" and (level > 0 or number-pars))
    if numbered {
      counts.at(level) = counts.at(level) + 1
      for deeper in range(level + 1, counts.len()) { counts.at(deeper) = 0 }
    }
    let prefix = if numbered { narrative-prefix(level, counts.at(level)) } else { none }
    let pad-left = narrative-indent(level)
    if kind == "cont" { pad-left += measure(narrative-prefix(level, 1)).width }
    if not first { v(item-gap, weak: true) }
    first = false
    block(width: 100%, breakable: true, spacing: 0pt, above: 0pt, below: 0pt)[
      #set par(leading: single-leading, spacing: 0pt)
      #pad(left: pad-left)[#prefix#entry.body]
    ]
  }
}

#let paper(
  document-title: [BULLET BACKGROUND PAPER],
  narrative: false,
  subject: none,
  originator: none,
  organization: none,
  office-symbol: none,
  phone: none,
  typist: none,
  date: none,
  font-size: 12pt,
  classification-level: none,
  dissemination: none,
  cui-controlled-by: none,
  cui-category: none,
  cui-limited-dissemination: none,
  cui-poc: none,
  it,
) = {
  let marking = classification-marking(classification-level, dissemination)
  let marked = marking != none
  let banner-color = classification-color(classification-level)
  let cui = if (
    type(classification-level) == str and classification-level.trim().starts-with("CUI")
  ) {
    cui-lines(cui-controlled-by, cui-category, cui-limited-dissemination, cui-poc)
  } else {
    none
  }
  let id-line = identification-line(originator, organization, office-symbol, phone, typist, date)
  // The sample places the line in the footer, half an inch up. A bottom banner
  // occupies that band, so a marked paper uses the other placement the page
  // states: one inch from the bottom.
  let id-from-bottom = if marked { 1in } else { 0.5in }
  // Clearance for the identification line when it sits on the one-inch line,
  // inside the text area a one-inch margin would otherwise fill.
  let bottom-margin = if marked { spacing.margin + 2 * font-size } else { spacing.margin }

  set text(font: DEFAULT_BODY_FONTS, size: font-size, fallback: true, hyphenate: false)
  set par(justify: false, leading: single-leading)
  show raw: set text(font: DEFAULT_MONO_FONTS)

  set page(
    paper: "us-letter",
    margin: (x: spacing.margin, top: spacing.margin, bottom: bottom-margin),
    header: {
      // p. 227: page number from page 2, half an inch from the top, flush right.
      context if counter(page).get().first() > 1 {
        place(
          dy: 0.5in,
          block(width: 100%, align(right, text(size: font-size)[#counter(page).display()])),
        )
      }
      if marking != none {
        place(
          top + center,
          dy: 0.375in,
          text(size: font-size, fill: banner-color)[#strong(marking)],
        )
      }
    },
    footer: context {
      if marking != none {
        place(
          bottom + center,
          dy: -0.375in,
          text(size: font-size, fill: banner-color)[#strong(marking)],
        )
      }
      if counter(page).get().first() == 1 and id-line != none {
        place(
          bottom + left,
          dy: -id-from-bottom,
          block(width: 100%, id-line),
        )
      }
    },
  )

  context {
    let stride = line-stride()
    // Paragraph spacing stacks on top of the line box and drops the leading
    // the next line would have had, so a blank line is one stride only when
    // the spacing puts that leading back.
    let item-gap = stride + single-leading
    let subject-text = trim-inline(subject)

    // p. 224: title centered, all capitals, one inch from the top; single-space
    // a wrap, double-space between the title, ON, the subject, and the text.
    align(center)[
      #set par(leading: single-leading, spacing: item-gap)
      #document-title

      ON
      #if not falsey(subject-text) {
        parbreak()
        upper(subject-text)
      }
    ]

    // The gap the title's own paragraph spacing does not supply after its
    // last line. `weak` keeps it from stacking on the body's spacing.
    v(item-gap, weak: true)

    // DoDM 5200.48: the designation block is page 1, bottom right. It hangs
    // into the bottom margin and reserves whatever of it stands in the text.
    if cui != none {
      let indicator = box({
        set text(size: 10pt)
        set par(leading: 0.4em, spacing: 0pt)
        set align(left)
        cui
      })
      let block-height = measure(indicator).height
      // The block's bottom sits a line above the identification line. A long
      // point-of-contact line is wider than the space beside that line, so the
      // two have to stack.
      let block-bottom = id-from-bottom + 2 * font-size
      let overhang = bottom-margin - block-bottom
      let reserved = calc.max(0pt, block-height - overhang)
      place(
        bottom,
        float: true,
        clearance: stride,
        box(width: 100%, height: reserved, {
          place(bottom + right, dy: overhang, indicator)
        }),
      )
    }

    if narrative {
      narrative-body(it, item-gap)
    } else {
      set par(leading: single-leading, spacing: item-gap)
      set block(above: item-gap, below: item-gap, spacing: item-gap)
      show list: nested
      show enum: nested
      set list(marker: depth-dashes, indent: 0pt, body-indent: 0pt, spacing: item-gap, tight: false)
      set enum(
        numbering: (..) => depth-dashes,
        indent: 0pt,
        body-indent: 0pt,
        spacing: item-gap,
        tight: false,
      )
      show heading: heading => {
        set text(size: font-size, weight: "regular")
        block(heading.body)
      }
      show quote.where(block: true): q => pad(left: 0.5in, q.body)
      it
    }
  }
}
