// Spacing, normalization, and formatting helpers shared across the template.

#import "config.typ": *

/// Vertical space of `count` blank lines on top of the block spacing, so the
/// next line lands `count + 1` lines below the last.
///
/// - count (int): Number of blank lines
/// -> content
#let blank-lines(count) = if count > 0 { v(LINE * count) }

/// -> content
#let blank-line() = blank-lines(1)

/// Whether a value is blank: none, false, an empty array, `""`, or `[]`.
///
/// - value (any)
/// -> bool
#let falsey(value) = {
  (
    value == none
      or value == false
      or (type(value) == array and value.len() == 0)
      or (type(value) == str and value.trim() == "")
      or value == []
  )
}

/// The text a `str` or content value carries, without formatting.
///
/// - it (str | content)
/// -> str
#let plain-text(it) = {
  if type(it) == str { return it }
  if type(it) != content { return "" }
  if it.func() in ([ ].func(), linebreak, parbreak) { return " " }
  if it.has("text") { return plain-text(it.text) }
  if it.has("children") { return it.children.map(plain-text).join(default: "") }
  if it.has("body") { return plain-text(it.body) }
  if it.has("child") { return plain-text(it.child) }
  ""
}

/// Whether a value prints nothing: blank, or content with no text.
///
/// - value (any)
/// -> bool
#let blank(value) = falsey(value) or plain-text(value).trim() == ""

/// Shrinks content to fit within a maximum width, never enlarging it.
///
/// Pass a non-wrapping `box` as `body` so the measured width is the
/// single-line width and the result stays on one line.
///
/// - width (length): Maximum width the content may occupy
/// - alignment (alignment): Horizontal placement within the reserved width
/// - body (content): Content to fit
/// -> content
#let fit-to-width(width, alignment: left, body) = context {
  let s = measure(body)
  if s.width <= 0pt or width <= 0pt { return body }
  let f = calc.min(1, width / s.width) * 100%
  box(width: width)[
    #align(alignment)[
      #scale(f, reflow: true)[#body]
    ]
  ]
}

/// The date pattern AR 25-50 2-4a(3)(c) types: "13 October 2026". Exported so
/// a caller that formats the date itself matches this package.
///
/// -> str
#let date-pattern() = "[day padding:none] [month repr:long] [year]"

/// Normalizes a value to an array, wrapping a scalar and mapping `none` to `()`.
///
/// - value (any)
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

/// The lines a paragraph sets in at a width, read from its height.
///
/// Reads layout, so callers must already be in a `context`.
///
/// - body (content): The paragraph, or its content
/// - width (length): The width it sets at
/// -> int
#let line-count(body, width) = {
  let height = measure(block(width: width, body)).height
  if height <= 0pt { return 0 }
  calc.round((height - CAP_HEIGHT.to-absolute()) / LINE.to-absolute()) + 1
}
