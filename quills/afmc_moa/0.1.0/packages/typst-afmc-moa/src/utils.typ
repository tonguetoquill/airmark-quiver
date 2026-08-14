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

/// True when value is none / false / "" / empty content / empty array.
///
/// A `plaintext`/`richtext` field lowers to content when it holds text, but an
/// unset one arrives as the empty `str` — so both shapes have to be checked.
#let falsey(v) = (
  v == none or v == false
    or (type(v) == array and v.len() == 0)
    or (type(v) == str and v == "")
    or (type(v) == content and v == [])
)

/// Wrap a non-array value in a tuple; pass arrays through.
#let ensure-array(v) = {
  if v == none { () } else if type(v) == array { v } else { (v,) }
}

/// Strips the padding a `plaintext`/`richtext` field carries, so the value can
/// be interpolated straight into prose.
///
/// Such a field lowers to a sequence padded with space elements —
/// `[ ], [Air Force Materiel Command], [ ], [(AFMC)], [ ]` — and, as an array
/// item, a trailing `parbreak()`:  `[ ], [NASA/ABC], parbreak()`. Left alone
/// those print as "the Foo  and", "(NASA) .", or push each array element onto
/// its own line. Boxing the value hides them but makes it unbreakable, which
/// forces a long party name onto a line of its own; trimming keeps it
/// breakable and tight.
///
/// Non-content values (an unset field arrives as the empty `str`) pass through.
#let trim-inline(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

/// Join a value (or array of values) into one inline run, separated by `sep`.
///
/// `plaintext`/`richtext` fields lower to content, and `str + content` is not a
/// legal Typst addition, so every element is wrapped as content before joining.
///
/// - join-inline("foo") → [foo]
/// - join-inline(([a], [b]), sep: ", ") → [a, b]
/// - join-inline(()) → []
/// - join-inline(none) → []
#let join-inline(value, sep: ", ") = {
  if value == none { return [] }
  let items = if type(value) == array { value } else { (value,) }
  // `().join(..)` is `none`, not `[]` — coerce so an empty array stays falsey.
  let joined = items.map(item => [#trim-inline(item)]).join(sep)
  if joined == none { [] } else { joined }
}

/// Format a date value for inline display ("22 July 2026").
///
/// Dispatches on the shape a date field can arrive in:
/// - str: shown as-is (fixed text like a placeholder).
/// - datetime: a native Typst datetime (e.g. `datetime.today()`).
/// - dict: a Quillmark `date`/`datetime` field lowers to a click-to-edit value
///   object `{ value: datetime, display: closure }`; `display` is a stored
///   closure, so it must be called through parentheses — a dict has no
///   `.display` method.
#let format-date(d) = {
  if d == none {
    ""
  } else if type(d) == str {
    d
  } else {
    let pattern = "[day padding:none] [month repr:long] [year]"
    if type(d) == datetime { d.display(pattern) } else { (d.display)(pattern) }
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
