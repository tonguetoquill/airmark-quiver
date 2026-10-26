// Air Force papers: AFH 33-337 (27 May 2015), chapter 16, pp. 222–228. The
// page is the point paper's. A bulleted list prints dashes, one more per level.
// A numbered list prints 1. / a. / (1) / (a). A plain paragraph is not numbered.

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

// Numbered-list depth, the same sequence the official memorandum uses.
#let narrative-formats = ("1.", "a.", "(1)", "(a)")

// p. 227, ¶5.c: a numbered paragraph wraps flush with the left margin. A
// subparagraph's number sits under its parent's text, as in the memorandum.
#let narrative-list(it, level, indent) = {
  let fmt = narrative-formats.at(calc.min(level, narrative-formats.len() - 1))
  let n = if type(it.start) == int { it.start } else { 1 }
  for item in it.children {
    let given = item.at("number", default: none)
    if type(given) == int { n = given }
    let label = [#numbering(fmt, n)#"  "]
    block(context {
      let offset = indent + measure(label).width
      show enum: inner => narrative-list(inner, level + 1, offset)
      [#h(indent)#label#item.body]
    })
    n += 1
  }
}

#let paper(
  document-title: [BULLET BACKGROUND PAPER],
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
  // On the one-inch line the identification line stands at the foot of the
  // first page's text area, which keeps this much clear above the margin.
  let id-clearance = if marked and id-line != none { 2 * font-size } else { 0pt }

  set text(font: DEFAULT_BODY_FONTS, size: font-size, fallback: true, hyphenate: false)
  set par(justify: false, leading: single-leading)
  show raw: set text(font: DEFAULT_MONO_FONTS)

  set page(
    paper: "us-letter",
    margin: spacing.margin,
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

    // p. 227, ¶5.a: title centered, all capitals, one inch from the top;
    // single-space a wrap, double-space between the title, ON, and the subject.
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
      let overhang = spacing.margin - block-bottom
      let reserved = calc.max(0pt, block-height - overhang)
      place(
        bottom,
        float: true,
        clearance: stride,
        box(width: 100%, height: reserved, {
          place(bottom + right, dy: overhang, indicator)
        }),
      )
    } else if id-clearance > 0pt {
      place(bottom, float: true, clearance: 0pt, v(id-clearance))
    }

    set par(leading: single-leading, spacing: item-gap)
    set block(above: item-gap, below: item-gap, spacing: item-gap)
    set list(marker: dashes, indent: 0pt, body-indent: 0pt, spacing: item-gap, tight: false)
    show enum: it => narrative-list(it, 0, 0pt)
    // pp. 222–224: one level of heading, in capitals, at the body's size and
    // weight, flush left, unnumbered, set off like any other item.
    show heading: heading => {
      set text(size: font-size, weight: "regular")
      set block(above: item-gap, below: item-gap)
      block(upper(heading.body))
    }
    show quote.where(block: true): q => pad(left: 0.5in, q.body)
    it
  }
}
