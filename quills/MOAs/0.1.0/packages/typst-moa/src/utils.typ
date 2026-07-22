// utils.typ — shared helpers for the MOA package

// Line-stride cache (set once in frontmatter; read by blank-lines).
#let LINE_STRIDE = state("MOA_LINE_STRIDE")

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
    or (type(v) == str and v == "")
)

/// Wrap a non-array value in a tuple; pass arrays through.
#let ensure-array(v) = {
  if v == none { () } else if type(v) == array { v } else { (v,) }
}

/// Join an array with a separator; pass strings through.
#let ensure-string(v, sep: "\n") = {
  if v == none { "" } else if type(v) == array { v.join(sep) } else { str(v) }
}

/// Format a date value for inline display ("22 July 2026"); pass strings through.
#let format-date(d) = {
  if d == none { "" } else if type(d) == str { d } else {
    d.display("[day padding:none] [month repr:long] [year]")
  }
}

// ---------------------------------------------------------------------------
// Decimal outline numbering
// ---------------------------------------------------------------------------

/// Builds the next chained decimal number string from a parent prefix.
/// decimal-numbering("", 1) -> "1."   decimal-numbering("4.", 1) -> "4.1."
#let decimal-numbering(prefix, n) = {
  if prefix == "" { str(n) + "." } else { prefix + str(n) + "." }
}

/// Renders a sequence of entries as consecutively-numbered siblings under
/// `prefix`, skipping entries whose `active` is false and renumbering the
/// remaining entries with no gaps.
///
/// - prefix (str): parent number string ("" at the top level, "4." under §4, …)
/// - items (array): each item is (active: bool, render: numstr => content)
#let numbered-list(prefix, items) = {
  let seq = items.filter(it => it.active)
  for (i, it) in seq.enumerate() {
    if i > 0 { blank-line() }
    (it.render)(decimal-numbering(prefix, i + 1))
  }
}
