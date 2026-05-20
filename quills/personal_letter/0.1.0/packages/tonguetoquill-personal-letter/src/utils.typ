// utils.typ: Utility functions for personal letter template

#import "config.typ": CLASSIFICATION_COLORS, paragraph-config, spacing

// Shared measured line-stride cache set once in frontmatter.
#let LINE_STRIDE = state("LINE_STRIDE")

/// Creates vertical spacing equivalent to `count` blank lines.
#let blank-lines(count) = {
  if count <= 0 { return }
  context {
    let stride = LINE_STRIDE.get()
    if stride == none {
      let one-line = measure(par(spacing: 0pt)[x]).height
      stride = measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
    }
    v(stride * count)
  }
}

/// Creates vertical spacing equivalent to one blank line.
#let blank-line() = blank-lines(1)

// =============================================================================
// GENERAL UTILITIES
// =============================================================================

/// Returns true for none, false, empty array, or empty string.
#let falsey(value) = {
  value == none or value == false or (type(value) == array and value.len() == 0) or (type(value) == str and value == "")
}

/// Scales content to fit within a box while maintaining aspect ratio.
#let fit-box(width: 2in, height: 1in, alignment: left + horizon, body) = context {
  let s = measure(body)
  let f = calc.min(width / s.width, height / s.height) * 100%
  box(width: width, height: height, clip: true)[
    #align(alignment)[
      #scale(f, reflow: true)[#body]
    ]
  ]
}

/// Formats a date for the personal letter heading.
///
/// - date (str|datetime): Date to format
/// - addressee-type (str): "military" → "Day Month Year"; "civilian" → "Month Day, Year"
#let display-date(date, addressee-type: "military") = {
  if type(date) == str {
    date
  } else {
    let pattern = if addressee-type == "civilian" {
      "[month repr:long] [day padding:none], [year]"
    } else {
      "[day padding:none] [month repr:long] [year]"
    }
    date.display(pattern)
  }
}

/// Returns the banner color for a classification level.
#let get-classification-level-color(level) = {
  if level == none or type(level) != str { return rgb(0, 0, 0) }
  let s = level.trim()
  let level-order = ("TOP SECRET", "SECRET", "CONFIDENTIAL", "CUI", "UNCLASSIFIED")
  for base-level in level-order {
    if s.starts-with(base-level) { return CLASSIFICATION_COLORS.at(base-level) }
  }
  rgb(0, 0, 0)
}

// =============================================================================
// TYPE NORMALIZATION
// =============================================================================

#let ensure-array(value) = {
  if value == none { () }
  else if type(value) == array { value }
  else { (value,) }
}

#let ensure-string(value, separator: "\n") = {
  if value == none { "" }
  else if type(value) == array { value.join(separator) }
  else { str(value) }
}

#let first-or-value(value) = {
  if value == none { none }
  else if type(value) == array { if value.len() > 0 { value.at(0) } else { none } }
  else { value }
}

// =============================================================================
// PARAGRAPH NUMBERING (SUB-PARAGRAPHS)
// =============================================================================

/// Returns the numbering format for a paragraph level (0-indexed).
/// Level 0 is unused for personal letter top-level paragraphs.
/// Level 1 = "a.", Level 2 = "(1)", Level 3 = "(a)", etc.
#let get-paragraph-numbering-format(level) = {
  paragraph-config.numbering-formats.at(level, default: "i.")
}

/// Calculates indent for a sub-paragraph in a personal letter.
///
/// Level 0: 0pt (handled by the 0.5in first-line h() spacer in body.typ)
/// Level 1 (a.): 0.5in — aligns the label with where main paragraph text starts
/// Level 2+: 0.5in + accumulated label widths
#let calculate-personal-letter-indent(level, level-counts) = {
  if level <= 0 { return 0pt }
  let total-indent = 0.5in
  for ancestor-level in range(1, level) {
    let ancestor-value = level-counts.at(str(ancestor-level), default: 1)
    let ancestor-format = get-paragraph-numbering-format(ancestor-level)
    let ancestor-number = numbering(ancestor-format, ancestor-value)
    total-indent += measure([#ancestor-number#"  "]).width
  }
  total-indent
}

/// Resets counter entries from `start` upward to 1.
#let reset-levels-from(level-counts, start, max-levels) = {
  for child in range(start, max-levels) {
    level-counts.insert(str(child), 1)
  }
  level-counts
}

/// Formats a sub-paragraph with label and indent.
#let format-par(body, level, level-counts, indent-fn, continuation: false) = {
  let indent-width = indent-fn(level, level-counts)
  if continuation {
    let current-value = level-counts.at(str(level), default: 1)
    let number-text = numbering(get-paragraph-numbering-format(level), current-value)
    [#h(indent-width + measure([#number-text#"  "]).width)#body]
  } else {
    let current-value = level-counts.at(str(level), default: 1)
    let number-text = numbering(get-paragraph-numbering-format(level), current-value)
    [#h(indent-width)#number-text#"  "#body]
  }
}
