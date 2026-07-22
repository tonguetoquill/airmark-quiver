// utils.typ — shared helpers for the personal letter package

#import "config.typ": CLASSIFICATION_COLORS, DEFAULT_LETTERHEAD_FONTS, LETTERHEAD_COLOR, spacing

// Line-stride cache (set once in frontmatter; read by blank-lines and body).
#let LINE_STRIDE = state("PL_LINE_STRIDE")

// ---------------------------------------------------------------------------
// Spacing helpers
// ---------------------------------------------------------------------------

/// Emit `count` blank line strides of vertical space.
#let blank-lines(count) = {
  if count <= 0 { return }
  context {
    let s = LINE_STRIDE.get()
    if s == none {
      let h = measure(par(spacing: 0pt)[x]).height
      s = measure(par(spacing: 0pt)[x#linebreak()x]).height - h
    }
    v(s * count)
  }
}

/// Emit one blank line of vertical space.
#let blank-line() = blank-lines(1)

// ---------------------------------------------------------------------------
// General helpers
// ---------------------------------------------------------------------------

/// True when value is none / false / "" / [].
#let falsey(v) = (
  v == none or v == false
    or (type(v) == array and v.len() == 0)
    or (type(v) == str   and v == "")
)

/// Wrap a non-array value in a tuple; pass arrays through.
#let ensure-array(v) = {
  if v == none { () }
  else if type(v) == array { v }
  else { (v,) }
}

/// Join an array with newlines; pass strings through.
#let ensure-string(v, sep: "\n") = {
  if v == none { "" }
  else if type(v) == array { v.join(sep) }
  else { str(v) }
}

// ---------------------------------------------------------------------------
// Date formatting
// ---------------------------------------------------------------------------

/// Format the date per addressee type.
/// military → "15 October 2014"   civilian → "October 15, 2014"
#let format-date(date, addressee-type: "military") = {
  if type(date) == str { date }
  else {
    let pat = if addressee-type == "civilian" {
      "[month repr:long] [day padding:none], [year]"
    } else {
      "[day padding:none] [month repr:long] [year]"
    }
    date.display(pat)
  }
}

// ---------------------------------------------------------------------------
// Classification
// ---------------------------------------------------------------------------

#let classification-color(level) = {
  if level == none or type(level) != str { return rgb(0, 0, 0) }
  let s = level.trim()
  for k in ("TOP SECRET", "SECRET", "CONFIDENTIAL", "CUI", "UNCLASSIFIED") {
    if s.starts-with(k) { return CLASSIFICATION_COLORS.at(k) }
  }
  rgb(0, 0, 0)
}

/// Build the full classification banner string (e.g. "CUI//NF").
#let classification-marking(level, dissemination) = {
  if level == none or type(level) != str { return none }
  let base = level.trim()
  if base == "" { return none }
  let disp = if dissemination == none or type(dissemination) != str { "" }
             else { dissemination.trim() }
  if disp != "" { base + "//" + upper(disp) } else { base }
}

// ---------------------------------------------------------------------------
// Sub-paragraph numbering  (for nested bullets inside the personal letter body)
// ---------------------------------------------------------------------------

#import "config.typ": SUBPAR_FORMATS

#let subpar-format(level) = SUBPAR_FORMATS.at(level, default: "i.")

/// Indentation for a sub-paragraph at `level` (1-based; level 0 = top-level).
/// Level 1 ("a.") aligns at PARA_INDENT; deeper levels accumulate label widths.
/// NOTE: must be called from within a `context` block (uses measure).
#let subpar-indent(level, counts) = {
  if level <= 0 { return 0pt }
  // Base: start from where the top-level paragraph text begins (0.5 in).
  import "config.typ": PARA_INDENT
  let total = PARA_INDENT
  // Add each intermediate label's width beyond level 1.
  for anc in range(1, level) {
    let val = counts.at(str(anc), default: 1)
    let lbl = numbering(subpar-format(anc), val)
    total += measure([#lbl#"  "]).width
  }
  total
}

/// Reset level-counts from `start` upward.
#let reset-counts-from(counts, start, max) = {
  for i in range(start, max) {
    counts.insert(str(i), 1)
  }
  counts
}

/// Render one sub-paragraph line (label + body or continuation indented body).
#let render-subpar(body, level, counts, continuation: false) = {
  let indent = subpar-indent(level, counts)
  if continuation {
    let lbl = numbering(subpar-format(level), counts.at(str(level), default: 1))
    [#h(indent + measure([#lbl#"  "]).width)#body]
  } else {
    let lbl = numbering(subpar-format(level), counts.at(str(level), default: 1))
    [#h(indent)#lbl#"  "#body]
  }
}

// ---------------------------------------------------------------------------
// fit-box
// ---------------------------------------------------------------------------

#let fit-box(width: 2in, height: 1in, alignment: left + horizon, body) = context {
  let s = measure(body)
  let f = calc.min(width / s.width, height / s.height) * 100%
  box(width: width, height: height, clip: true)[#align(alignment)[#scale(f, reflow: true)[#body]]]
}

// ---------------------------------------------------------------------------
// Letterhead
// ---------------------------------------------------------------------------

#let render-letterhead(
  title,
  caption,
  font,
  letterhead-seal: none,
  letterhead-seal-subtitle: none,
) = {
  font    = ensure-array(font)
  title   = upper(ensure-string(title))
  caption = upper(ensure-string(caption))

  // Title + caption centred at ~0.625in from top of page.
  place(
    dy: 0.625in - spacing.margin,
    box(width: 100%, fill: none, stroke: none)[
      #place(center + top, align(center)[
        #set text(12pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
        #title\
        #v(1pt)
        #text(10.5pt)[#caption]
      ])
    ],
  )

  // DoW / DoD seal in upper-left, sized 2in × 1in.
  if letterhead-seal != none {
    let seal-body = if letterhead-seal-subtitle == none or letterhead-seal-subtitle == "" {
      block[#fit-box(width: 2in, height: 1in)[#letterhead-seal]]
    } else {
      block[
        #set text(9pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
        #stack(
          spacing: 0.5em,
          fit-box(width: 2in, height: 1in)[#letterhead-seal],
          box(upper(ensure-string(letterhead-seal-subtitle))),
        )
      ]
    }
    place(left + top, dx: -0.5in, dy: -.5in, seal-body)
  }
}
