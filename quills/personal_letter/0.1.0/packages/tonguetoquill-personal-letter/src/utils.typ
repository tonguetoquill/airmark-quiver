// utils.typ: Utility functions for the Typst personal-letter package.
//
// Trimmed from the tonguetoquill-usaf-memo utilities: line-stride based
// blank-line spacing, type normalization, content fitting, and the USAF
// letter date format.

#import "config.typ": spacing

// Shared measured line-stride cache used by spacing and orphan heuristics.
// Value is a `length` set once in `frontmatter`.
#let LINE_STRIDE = state("LINE_STRIDE")

/// Creates vertical spacing equivalent to multiple blank lines.
///
/// Adds `count` wrapped-line strides on top of the natural inter-paragraph
/// gap, so a blank line occupies exactly the same vertical space as a line
/// produced by natural paragraph wrapping. The stride is measured from
/// `LINE_STRIDE` (cached in `frontmatter`) and falls back to an inline
/// measurement when the cache is unset.
///
/// - count (int): Number of blank lines to create
/// -> content
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
/// Convenience function for single line spacing.
///
/// -> content
#let blank-line() = blank-lines(1)

/// Checks if a value is "falsey" (none, false, empty array, or empty string).
///
/// - value (any): The value to check for "falsey" status
/// -> bool
#let falsey(value) = {
  value == none or value == false or (type(value) == array and value.len() == 0) or (type(value) == str and value == "")
}

/// Scales content to fit within a specified box while maintaining aspect ratio.
///
/// Used for the letterhead seal so it fits its corner band while preserving
/// proportions.
///
/// - width (length): Maximum width for the content (default: 2in)
/// - height (length): Maximum height for the content (default: 1in)
/// - alignment (alignment): Content alignment within the box (default: left+horizon)
/// - body (content): Content to scale and fit
/// -> content
#let fit-box(width: 2in, height: 1in, alignment: left + horizon, body) = context {
  let s = measure(body)
  let f = calc.min(width / s.width, height / s.height) * 100%
  box(width: width, height: height, clip: true)[
    #align(alignment)[
      #scale(f, reflow: true)[#body]
    ]
  ]
}

/// Formats a date for the letter heading.
///
/// - String: shown as-is (use for fixed text like placeholders).
/// - datetime: USAF letter style `DD Month YYYY` (AFMAN 33-326 §4.1.1.1:
///   "Use the format of day, month, year, e.g., 17 October 2005").
///
/// - date (str|datetime): Date to format for display
/// -> content
#let display-date(date) = {
  if type(date) == str {
    date
  } else {
    date.display("[day padding:none] [month repr:long] [year]")
  }
}

/// Ensures the input is an array. If already an array, returns as-is.
/// If not an array, wraps the value in a tuple; none becomes ().
///
/// - value: Any value to normalize to array form
/// -> array
#let ensure-array(value) = {
  if value == none {
    ()
  } else if type(value) == array {
    value
  } else {
    (value,)
  }
}

/// Ensures the input is a string. If an array, joins elements with the
/// specified separator; none becomes "".
///
/// - value: Any value to normalize to string form
/// - separator: String used when joining array elements (default: "\n")
/// -> str
#let ensure-string(value, separator: "\n") = {
  if value == none {
    ""
  } else if type(value) == array {
    value.join(separator)
  } else {
    str(value)
  }
}
