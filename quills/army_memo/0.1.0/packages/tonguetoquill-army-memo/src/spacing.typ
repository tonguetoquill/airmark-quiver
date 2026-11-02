// The gaps between the words of running text: sentence spacing, and the words
// a line or page break must not part.

#import "config.typ": *
#import "utils.typ": *

// AR 25-50 1-39b(9): two spaces after a sentence's closing period or question
// mark. A run of tokens ending in "." or "?", the word before it and the
// character after it, so "Tab A. The" and "Fig. 5. The" are read whole.
#let SENTENCE_RUN = regex("(?:\S+ )?(?:\S*?[.?][\"'”’)]{0,2} )+\S")
#let SENTENCE_START = regex("^[\p{Lu}\p{N}\"'“‘(]")
#let INITIALS = regex("^(\p{L}\.)*\p{L}$")
// Abbreviations that stand before a name.
#let TITLES = (
  "mr", "mrs", "ms", "messrs", "mmes", "dr", "prof", "rev", "fr", "hon", "pres",
  "sen", "rep", "gov", "supt", "st", "mt", "gen", "adm", "brig", "col", "lt",
  "capt", "cmdr", "maj", "sgt", "ft", "vs",
)
// Abbreviations that stand before a number, and end a sentence before a word.
#let NUMBER_LEADS = (
  "approx", "jan", "feb", "mar", "apr", "jun", "jul", "aug", "sep", "sept", "oct",
  "nov", "dec",
)
// Abbreviations that stand before a number or a designator such as "II", "A"
// or "A-1", and end a sentence before a word.
#let DESIGNATOR_LEADS = (
  "no", "nos", "vol", "fig", "figs", "para", "paras", "encl", "app", "art", "sec",
  "ch", "pt", "pp", "ref", "pg", "bldg", "rm", "ste", "apt", "ext", "tel",
)
#let DESIGNATOR = regex("^(\p{N}|[IVXLCDM]+(\P{L}|$)|\p{Lu}(-?\p{N}|\P{L}|$))")
// Words a single letter labels: "Tab A." ends a sentence where "John A." does not.
#let LETTER_LABELS = (
  "tab", "annex", "appendix", "attachment", "enclosure", "exhibit", "figure",
  "table", "chart", "map", "schedule", "phase", "stage", "step", "plan", "option",
  "section", "part", "paragraph", "subparagraph", "item", "line", "column", "row",
  "box", "level", "grade", "class", "category", "type", "model", "version",
  "series", "group", "company", "battery", "troop", "team", "unit", "gate", "area",
  "zone", "sector", "range", "site", "lot", "block", "building", "room",
  "objective",
)

/// Whether the space after `token` ends a sentence, given the word before it
/// and the one after.
///
/// - token (str): The word before the space
/// - next (str): The word after the space
/// - before (str): The word before `token`, or `""`
/// -> bool
#let ends-sentence(token, next, before: "") = {
  if next.match(SENTENCE_START) == none { return false }
  let core = token.trim(regex("[\"'”’)]+"), at: end)
  if core.ends-with("?") { return true }
  if not core.ends-with(".") { return false }
  let word = lower(core.slice(0, -1).trim(regex("^[^\p{L}\p{N}]+"), at: start))
  if word.match(INITIALS) != none {
    return word.clusters().len() == 1 and lower(before) in LETTER_LABELS
  }
  if word in TITLES { return false }
  if word in NUMBER_LEADS { return next.match(regex("^\p{N}")) == none }
  if word in DESIGNATOR_LEADS { return next.match(DESIGNATOR) == none }
  // "et al. (2020)" cites; "et al. The" ends.
  if word == "al" and lower(before) == "et" { return next.match(regex("^[(\p{N}]")) == none }
  true
}

// AR 25-50 1-25c: a date's day, month and year stay on one line.
#let MONTHS = "january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sept|sep|oct|nov|dec"
#let DAY = regex("^\p{N}{1,2}$")
#let MONTH = regex("(?i)^(?:" + MONTHS + ")\.?,?$")
#let YEAR = regex("^\p{N}{2}(?:\p{N}{2})?[.,;:?)\"'”’]*$")
/// A date in running text or an address: its day and month, and its year.
#let DATE_PARTS = regex("(?i)\b\p{N}{1,2}[ \u{a0}]+(?:" + MONTHS + ")\b\.?(?:[ \u{a0}]+\p{N}{2}(?:\p{N}{2})?\b)?")

// AR 25-50 5-10b: the ZIP code two spaces after the State, on the State's
// line. A State is its two-letter abbreviation or its name's last word.
#let STATE_NAMES = "alabama|alaska|arizona|arkansas|california|colorado|connecticut|delaware|florida|georgia|hawaii|idaho|illinois|indiana|iowa|kansas|kentucky|louisiana|maine|maryland|massachusetts|michigan|minnesota|mississippi|missouri|montana|nebraska|nevada|hampshire|jersey|mexico|york|carolina|dakota|ohio|oklahoma|oregon|pennsylvania|island|tennessee|texas|utah|vermont|virginia|washington|wisconsin|wyoming|columbia|rico|guam|samoa|islands"
#let ZIP = regex("^\p{N}{5}(?:[-\u{2013}]\p{N}{4})?[.,;:)]*$")
// In running text a State is in capitals or capitalized, so "is 12345" is not one.
#let STATE = regex("^(?:\p{Lu}{2}|(?i:" + STATE_NAMES + "))$")
/// A State and its ZIP code in a line of an address or a listing.
#let STATE_ZIP = regex("\b(?:\p{Lu}{2}|(?i:" + STATE_NAMES + "))[\u{a0} ]{1,2}\p{N}{5}(?:[-\u{2013}]\p{N}{4})?\b")

/// Content with each date and each State and ZIP code kept on one line, and
/// the ZIP code two spaces after the State.
///
/// - body (str | content)
/// -> content
#let keep-together(body) = {
  show STATE_ZIP: it => box(it.text.replace(regex("[\u{a0} ]{1,2}"), "\u{a0}\u{a0}"))
  show DATE_PARTS: box
  body
}

// The zero-width characters the first pass appends to a run.
#let JOINERS = regex("[\u{200B}\u{2060}]")

#let tokens(text) = text.replace(JOINERS, "").split(regex("\s+")).filter(t => t != "")

// `flat` of each of a sequence's children: a footnote's mark, the run a
// zero-width weak space leads, reads as nothing.
#let flat-children(children, flat) = {
  let mark = false
  let out = ()
  for child in children {
    let f = child.func()
    if f == h and child.at("weak", default: false) and child.amount == 0pt {
      mark = true
      out.push("")
    } else if mark and child.has("child") and child.has("styles") {
      mark = false
      out.push("")
    } else {
      let t = flat(child)
      if t != "" { mark = false }
      out.push(t)
    }
  }
  out
}

// The text a gap's decision reads, with each paragraph and table cell ended
// by U+2029. A footnote's mark stands outside its sentence.
#let flat(it) = {
  if type(it) == str { return it }
  if type(it) != content { return "" }
  let f = it.func()
  if f in (parbreak, table, table.header, table.footer, table.cell) { return "\u{2029}" }
  if f in ([ ].func(), linebreak) { return " " }
  if f in (footnote, super) { return "" }
  if f == smartquote { return if it.at("double", default: true) { "\"" } else { "'" } }
  if it.has("text") { return flat(it.text) }
  if it.has("children") { return flat-children(it.children, flat).join(default: "") }
  if it.has("body") { return flat(it.body) }
  if it.has("child") { return flat(it.child) }
  ""
}

// How the gap between `before` and `after` sets: "wide", two spaces where a
// sentence ends (AR 25-50 1-39b(9)); "join", unbreakable, inside a date
// (1-25c); "zip", two unbreakable spaces between a State and its ZIP code
// (5-10b); "glue", unbreakable, after a sentence's first word and before its
// last, so that a sentence divided between pages keeps two words on each
// (2-5c(2)); or none, a plain space. `year` lets a date's year turn over.
#let gap-kind(before, after, glue, year: true) = {
  let b = tokens(before.split("\u{2029}").last())
  let a = tokens(after.split("\u{2029}").first())
  if b.len() == 0 or a.len() == 0 { return none }
  let token = b.last()
  let next = a.first()
  if ends-sentence(token, next, before: b.at(-2, default: "")) { return "wide" }
  if token.match(DAY) != none and next.match(MONTH) != none { return "join" }
  if (
    year
      and token.match(MONTH) != none
      and b.at(-2, default: "").match(DAY) != none
      and next.match(YEAR) != none
  ) { return "join" }
  if token.match(STATE) != none and next.match(ZIP) != none { return "zip" }
  if not glue { return none }
  let opens = b.len() == 1 or ends-sentence(b.at(-2), token, before: b.at(-3, default: ""))
  let closes = a.len() == 1 or ends-sentence(next, a.at(1), before: token)
  if opens or closes { "glue" } else { none }
}

#let GAPS = (wide: "  ", join: "\u{a0}", zip: "\u{a0}\u{a0}", glue: "\u{a0}")

// Elements whose body is running text, rebuilt around their spaced body.
#let SPANS = (strong, emph, underline, overline, strike, highlight, smallcaps, link)

#let rebuild(it, body) = {
  let fields = it.fields()
  let _ = fields.remove("body")
  let _ = fields.remove("label", default: none)
  if it.func() == link { link(fields.remove("dest"), ..fields, body) } else { (it.func())(..fields, body) }
}

// Two typed spaces reach the content as a no-break space and a space. Every
// gap the plate sets is one of its own, so the no-break space goes.
#let TYPED_GAP = regex("\u{a0}+ ")
#let drop-typed-spaces(children) = {
  let out = ()
  for (i, child) in children.enumerate() {
    let next = children.at(i + 1, default: none)
    if (
      child.has("text")
        and type(child.text) == str
        and child.text.ends-with("\u{a0}")
        and next != none
        and (next.func() == [ ].func() or (next.has("text") and type(next.text) == str and next.text.starts-with(" ")))
    ) {
      let s = child.text.trim(regex("\u{a0}+"), at: end)
      if s != "" { out.push(if child.func() == text [#s] else { child }) }
    } else {
      out.push(child)
    }
  }
  out
}

// AR 25-50 2-5c(3): a hyphenated word does not divide between pages. A word
// joiner after its hyphen keeps it whole.
#let COMPOUND = regex("([\p{L}\p{N}])((?:-\p{L}[\p{L}\p{N}]*)+)")
#let join-compounds(s) = s.replace(COMPOUND, m => m.captures.at(0) + m.captures.at(1).replace("-", "-\u{2060}"))

/// Sets every gap between words per `gap-kind`, reading the sentence around
/// each across bold, italic, links and the other runs of a paragraph. Table
/// cells take no glue: a row does not divide between pages.
///
/// - it (content): A paragraph, block quote or table
/// - glue (bool): Whether to keep sentences' first and last two words, and
///   hyphenated words, together
/// - year (bool): Whether a date's year stays on its line
/// - before (str): The paragraph's text before `it`
/// - after (str): The paragraph's text after `it`
/// -> content
#let space-sentences(it, glue: true, year: true, before: "", after: "") = {
  if type(it) != content { return it }
  let f = it.func()
  let walk = (child, b, a) => space-sentences(child, glue: glue, year: year, before: b, after: a)
  if f == [ ].func() {
    let kind = gap-kind(before, after, glue, year: year)
    return if kind == none { it } else [#GAPS.at(kind)]
  }
  if f == text {
    let s = it.text.replace(TYPED_GAP, " ")
    if glue { s = join-compounds(s) }
    if not s.contains(" ") { return if s == it.text { it } else [#s] }
    let out = ""
    let at = 0
    for m in s.matches(regex("\s+")) {
      out += s.slice(at, m.start)
      let run = m.text
      out += if run.contains(" ") {
        let kind = gap-kind(before + s.slice(0, m.start), s.slice(m.end) + after, glue, year: year)
        if kind == none { " " } else { GAPS.at(kind) }
      } else { run }
      at = m.end
    }
    return [#(out + s.slice(at))]
  }
  if it.has("child") and it.has("styles") {
    return f(walk(it.child, before, after), it.styles)
  }
  if f in (table, table.header, table.footer, table.cell) {
    let fields = it.fields()
    let key = if f == table.cell { "body" } else { "children" }
    let inner = fields.remove(key)
    let _ = fields.remove("label", default: none)
    let cell = c => space-sentences(c, glue: false, year: false)
    return if key == "body" { table.cell(..fields, cell(inner)) } else { f(..fields, ..inner.map(cell)) }
  }
  if f == align { return align(it.alignment, walk(it.body, before, after)) }
  if f in SPANS { return rebuild(it, walk(it.body, before, after)) }
  if f == [*a* b].func() {
    let children = drop-typed-spaces(it.children)
    let texts = flat-children(children, flat)
    let out = ()
    for (i, child) in children.enumerate() {
      out.push(walk(
        child,
        before + texts.slice(0, i).join(default: ""),
        texts.slice(i + 1).join(default: "") + after,
      ))
    }
    return out.join(default: [])
  }
  it
}

/// Running text with its gaps set per `gap-kind`.
///
/// - body (str | content)
/// - glue (bool): See `space-sentences`
/// -> content
#let sentence-spacing(body, glue: false) = {
  show SENTENCE_RUN: it => {
    let parts = it.text.split(" ")
    let out = parts.at(0)
    for i in range(1, parts.len()) {
      let before = if i > 1 { parts.at(i - 2) } else { "" }
      out += if ends-sentence(parts.at(i - 1), parts.at(i), before: before) { "  " } else { " " }
      out += parts.at(i)
    }
    out
  }
  space-sentences(if type(body) == str [#body] else { body }, glue: glue)
}

// Characters a word too wide for its line breaks after first.
#let BREAK_AFTER = ("_", "/", "\\", ".", "-", ":", ";", ",", "=", "&", "?", "#", "+", "|", "@")
#let LONG_TOKEN = regex("[^\s\u{200B}]{12,}")

/// A show rule for `LONG_TOKEN` that lets a word wider than `width` break: after
/// its punctuation, and within a run still too wide, anywhere.
///
/// - width (length): The widest a line sets
/// -> function
#let break-long(width) = tok => context {
  if measure(tok).width <= width { return tok }
  let segments = ()
  let current = ""
  for c in tok.text.replace(JOINERS, "").clusters() {
    current += c
    if c in BREAK_AFTER {
      segments.push(current)
      current = ""
    }
  }
  if current != "" { segments.push(current) }
  segments.map(s => if measure([#s]).width > width { s.clusters().join("\u{200B}") } else { s }).join("\u{200B}")
}
