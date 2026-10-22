// Paragraph numbering, indentation, sentence spacing and page breaking for the
// memorandum body: AR 25-50 2-4b and 2-5c.

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": memo-table-style, render-memo-table

// AR 25-50 1-39b(9): two spaces after a sentence's closing period or question
// mark. A run of tokens ending in "." or "?", the word before it and the
// character after it, so "Tab A. The" and "Fig. 5. The" are read whole.
#let SENTENCE_RUN = regex("(?:\S+ )?(?:\S*?[.?][\"'”’)]{0,2} )+\S")
#let SENTENCE_START = regex("^[\p{Lu}\p{N}\"'“‘(]")
#let INITIALS = regex("^(\p{L}\.)*\p{L}$")
// Abbreviations that stand before a name.
#let TITLES = (
  "mr", "mrs", "ms", "dr", "st", "gen", "col", "lt", "capt", "maj", "sgt", "ft",
  "vs",
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
  "ch", "pt", "ref", "pg", "bldg", "rm", "ste", "apt", "ext", "tel",
)
#let DESIGNATOR = regex("^(\p{N}|[IVXLCDM]+(\P{L}|$)|\p{Lu}(-?\p{N}|\P{L}|$))")
// Words a single letter labels: "Tab A." ends a sentence where "John A." does not.
#let LETTER_LABELS = (
  "tab", "annex", "appendix", "enclosure", "exhibit", "figure", "table", "phase",
  "plan", "option", "section", "part", "company", "battery", "troop", "team",
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
  true
}

// The zero-width characters the first pass appends to a run.
#let JOINERS = regex("[\u{200B}\u{2060}]")

#let tokens(text) = text.replace(JOINERS, "").split(regex("\s+")).filter(t => t != "")

// The text a gap's decision reads, with each paragraph and table cell ended
// by U+2029.
#let flat(it) = {
  if type(it) == str { return it }
  if type(it) != content { return "" }
  let f = it.func()
  if f in (parbreak, table, table.header, table.footer, table.cell) { return "\u{2029}" }
  if f in ([ ].func(), linebreak) { return " " }
  if f == smartquote { return if it.at("double", default: true) { "\"" } else { "'" } }
  if it.has("text") { return flat(it.text) }
  if it.has("children") { return it.children.map(flat).join(default: "") }
  if it.has("body") { return flat(it.body) }
  if it.has("child") { return flat(it.child) }
  ""
}

// How the gap between `before` and `after` sets: "wide", two spaces where a
// sentence ends (AR 25-50 1-39b(9)); "glue", unbreakable, after a sentence's
// first word and before its last, so that a sentence divided between pages
// keeps two words on each (2-5c(2)); or none, a plain space.
#let gap-kind(before, after, glue) = {
  let b = tokens(before.split("\u{2029}").last())
  let a = tokens(after.split("\u{2029}").first())
  if b.len() == 0 or a.len() == 0 { return none }
  let token = b.last()
  let next = a.first()
  if ends-sentence(token, next, before: b.at(-2, default: "")) { return "wide" }
  if not glue { return none }
  let opens = b.len() == 1 or ends-sentence(b.at(-2), token, before: b.at(-3, default: ""))
  let closes = a.len() == 1 or ends-sentence(next, a.at(1), before: token)
  if opens or closes { "glue" } else { none }
}

// Elements whose body is running text, rebuilt around their spaced body.
#let SPANS = (strong, emph, underline, overline, strike, highlight, smallcaps, link)

#let rebuild(it, body) = {
  let fields = it.fields()
  let _ = fields.remove("body")
  let _ = fields.remove("label", default: none)
  if it.func() == link { link(fields.remove("dest"), ..fields, body) } else { (it.func())(..fields, body) }
}

/// Sets every gap between words per `gap-kind`, reading the sentence around
/// each across bold, italic, links and the other runs of a paragraph. Table
/// cells take the sentence spacing only: a table breaks between rows.
///
/// - it (content): A paragraph, block quote or table
/// - glue (bool): Whether to keep sentences' first and last two words together
/// - before (str): The paragraph's text before `it`
/// - after (str): The paragraph's text after `it`
/// -> content
#let space-sentences(it, glue: true, before: "", after: "") = {
  if type(it) != content { return it }
  let f = it.func()
  let walk = (child, b, a) => space-sentences(child, glue: glue, before: b, after: a)
  if f == [ ].func() {
    let kind = gap-kind(before, after, glue)
    return if kind == "wide" { [#"  "] } else if kind == "glue" { [#"\u{a0}"] } else { it }
  }
  if f == text {
    let s = it.text
    if not s.contains(" ") { return it }
    let out = ""
    let at = 0
    for m in s.matches(regex("\s+")) {
      out += s.slice(at, m.start)
      let run = m.text
      let kind = if run.contains(" ") {
        gap-kind(before + s.slice(0, m.start), s.slice(m.end) + after, glue)
      }
      out += if kind == "wide" {
        if run.clusters().len() >= 2 { run } else { "  " }
      } else if kind == "glue" { run.replace(" ", "\u{a0}") } else { run }
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
    let cell = c => space-sentences(c, glue: false)
    return if key == "body" { table.cell(..fields, cell(inner)) } else { f(..fields, ..inner.map(cell)) }
  }
  if f == align { return align(it.alignment, walk(it.body, before, after)) }
  if f in SPANS { return rebuild(it, walk(it.body, before, after)) }
  if f == [*a* b].func() {
    let children = it.children
    let texts = children.map(flat)
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

#let sentence-spacing(body, glue: true) = {
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
  space-sentences(body, glue: glue)
}

/// Content cut at its `n`th breakable gap, a space between words: the part
/// before the gap and the part after it, or `tail: none` and the gaps still
/// to pass when `it` holds fewer.
///
/// - it (content)
/// - n (int): The gap to cut at, from 1
/// -> dictionary
#let cut-at-gap(it, n) = {
  let whole = left => (head: it, tail: none, left: left)
  if type(it) != content { return whole(n) }
  let f = it.func()
  if f == [ ].func() {
    return if n == 1 { (head: [], tail: [], left: 0) } else { whole(n - 1) }
  }
  if f == text {
    let gaps = it.text.matches(regex("[ \u{a0}]* [ \u{a0}]*"))
    if gaps.len() < n { return whole(n - gaps.len()) }
    let gap = gaps.at(n - 1)
    return (head: [#it.text.slice(0, gap.start)], tail: [#it.text.slice(gap.end)], left: 0)
  }
  let inner = if it.has("child") and it.has("styles") { it.child } else if f in SPANS { it.body }
  if inner != none {
    let part = cut-at-gap(inner, n)
    if part.tail == none { return whole(part.left) }
    let wrap = if f in SPANS { body => rebuild(it, body) } else { body => f(body, it.styles) }
    return (head: wrap(part.head), tail: wrap(part.tail), left: 0)
  }
  if f == [*a* b].func() {
    let children = it.children
    let left = n
    for (i, child) in children.enumerate() {
      let part = cut-at-gap(child, left)
      if part.tail != none {
        return (
          head: (children.slice(0, i) + (part.head,)).join(),
          tail: ((part.tail,) + children.slice(i + 1)).join(),
          left: 0,
        )
      }
      left = part.left
    }
    return whole(left)
  }
  whole(n)
}

/// A paragraph's content split before its last `count` lines, at the gap
/// where the greedy line breaking of a ragged-right paragraph ends the line
/// above them. Reads layout.
///
/// - body (content): The paragraph's content
/// - lines (int): Its line count
/// - count (int): The lines to split off
/// - width (length): The width it sets at
/// -> dictionary | none: `head` and `tail`, or none with no gap to cut at
#let split-last-lines(body, lines, count, width) = {
  let keep = lines - count
  let gaps = 1000000 - cut-at-gap(body, 1000000).left
  if gaps < 1 { return none }
  let fits = k => line-count(par(cut-at-gap(body, k).head), width) <= keep
  let (lo, hi) = (1, gaps)
  while lo < hi {
    let mid = calc.quo(lo + hi + 1, 2)
    if fits(mid) { lo = mid } else { hi = mid - 1 }
  }
  let parts = cut-at-gap(body, lo)
  (head: parts.head, tail: parts.tail)
}

// AR 25-50 2-4b(4)(b) and 1-39b(9): a run-in heading takes a period unless it
// ends in its own punctuation, and the gap after it is the one that
// punctuation takes.
#let run-in(heading) = {
  let last = plain-text(heading).replace(JOINERS, "").trim().clusters().at(-1, default: "")
  if last in (".", "?", "!") {
    (label: strong(heading), gap: PERIOD_GAP)
  } else if last in (":", ";", ",") {
    (label: strong(heading), gap: " ")
  } else {
    (label: strong[#heading.], gap: PERIOD_GAP)
  }
}

#let label-for(level, number) = numbering(numbering-formats.at(level, default: "i."), number)

// AR 25-50 2-4b(3) and 1-39b(9),(10): the designator a quarter inch in per
// level, two spaces after one ending in a period, a quarter inch after one
// ending in a parenthesis.
#let designator(level, number) = {
  let label = label-for(level, number)
  let gap = if type(label) == str and label.ends-with(")") { h(PAREN_GAP) } else { PERIOD_GAP }
  [#label#gap]
}

#let reset-levels-from(level-counts, start) = {
  for child in range(start, numbering-formats.len()) {
    level-counts.insert(str(child), 1)
  }
  level-counts
}

/// Where the text of the paragraph last numbered at a level starts, which a
/// continuation, block quote or table inside it lines up with. Zero at the
/// top level.
///
/// - level (int): Nesting level (0-based)
/// - level-counts (dictionary): The number the next paragraph at each level takes
/// -> length
#let text-offset(level, level-counts) = {
  if level <= 0 { return 0pt }
  let number = calc.max(1, level-counts.at(str(level), default: 1) - 1)
  INDENT_STEP * level + measure(designator(level, number)).width
}

// AR 25-50 2-5c(4): the closing never starts a page without the end of the
// text above it. When the last block's last lines begin on a page that has
// no room for the closing below the block, a bottom float takes the room
// below `keep`, the offset in the block where they begin, and they move on
// with the closing. Measured from where the block begins, which the float
// cannot move.
#let keep-with-closing(height, keep) = context {
  let need = query(<army-memo-closing-need>)
  if need.len() == 0 { return }
  let start = here().position()
  let reserve = if start.page == 1 {
    query(<army-memo-page-one-reserve>).map(m => m.value).sum(default: 0pt)
  } else { 0pt }
  let limit = page.height - BOTTOM.to-absolute() - reserve
  let last = start.y + height
  if start.y + keep < limit - 0.01pt and last + need.first().value > limit + 0.01pt {
    place(bottom, float: true, clearance: 0pt, block(height: limit - start.y - keep))
  }
}

// A table's grid, when its cells fill it in order one cell a slot: its
// column count and its header's cell count.
#let table-grid(t) = {
  let columns = if type(t.columns) == int { t.columns } else { t.columns.len() }
  let header = t.children.filter(c => c.func() == table.header)
  let plain = c => c.func() != table.cell or c.fields().keys().all(k => k in ("body", "label"))
  let cells = t.children.filter(c => c.func() not in (table.header, table.footer))
  let heads = header.map(h => h.children).join(default: ())
  if columns == 0 or header.len() > 1 or t.children.any(c => c.func() == table.footer) { return none }
  if not (cells + heads).all(plain) { return none }
  (columns: columns, header-rows: calc.quo(heads.len() + columns - 1, columns), rows: calc.quo(heads.len() + columns - 1, columns) + calc.quo(cells.len() + columns - 1, columns))
}

// The table inside `it` with only its header, when `header` holds, and the
// body rows `keep` accepts set. The other rows' cells stack, hidden, in one
// row of no height and no rules where those rows stood, so the columns stay
// as wide as the whole table sets them.
#let table-rows(it, keep, header: true) = {
  if type(it) != content { return it }
  let f = it.func()
  if it.has("child") and it.has("styles") { return f(table-rows(it.child, keep, header: header), it.styles) }
  if f == align { return align(it.alignment, table-rows(it.body, keep, header: header)) }
  if f != table { return it }
  let grid = table-grid(it)
  let fields = it.fields()
  let children = fields.remove("children")
  let _ = fields.remove("label", default: none)
  let body = c => if c.func() == table.cell { c.body } else { c }
  let collapse = bodies => table.cell(inset: 0pt, stroke: none, block(height: 0pt, clip: true, hide(stack(..bodies))))
  let hidden = range(grid.columns).map(_ => ())
  let (head, before, after) = ((), (), ())
  let slot = grid.header-rows * grid.columns
  for child in children {
    if child.func() == table.header {
      if header { head.push(child) } else {
        let cells = child.fields()
        let inner = cells.remove("children")
        let _ = cells.remove("label", default: none)
        head.push(table.header(..cells, ..inner.map(c => collapse((body(c),)))))
      }
      continue
    }
    let row = calc.quo(slot, grid.columns)
    let column = calc.rem(slot, grid.columns)
    slot += 1
    if keep(row) {
      if hidden.all(h => h.len() == 0) { before.push(child) } else { after.push(child) }
    } else {
      hidden.at(column).push(body(child))
    }
  }
  let stacked = if hidden.any(h => h.len() > 0) { hidden.map(collapse) } else { () }
  table(..fields, ..head, ..before, ..stacked, ..after)
}

#let find-table(it) = {
  if type(it) != content { return none }
  if it.func() == table { return it }
  if it.has("child") and it.has("styles") { return find-table(it.child) }
  if it.func() == align { return find-table(it.body) }
  none
}

// Rendering takes two passes. The first lays the content out hidden, so that
// Typst's own show rules resolve, and buffers each paragraph, table, block
// quote and code block with its nesting level. The second emits the buffer
// in document order, numbering as it goes.
#let render-body(content, references: ()) = {
  let PAR_BUFFER = state("PAR_BUFFER")
  PAR_BUFFER.update(())
  let NEST_DOWN = counter("NEST_DOWN")
  NEST_DOWN.update(0)
  let NEST_UP = counter("NEST_UP")
  NEST_UP.update(0)
  let IS_HEADING = state("IS_HEADING")
  IS_HEADING.update(false)
  // Whether the next paragraph is the first block of a list item; later ones
  // are continuations and take no number.
  let ITEM_FIRST_PAR = state("ITEM_FIRST_PAR")
  ITEM_FIRST_PAR.update(false)

  let buffer(item) = PAR_BUFFER.update(pars => {
    pars.push(item)
    pars
  })

  let first-pass = {
    show: memo-table-style
    show par: p => context {
      let nest-level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let first = nest-level > 0 and ITEM_FIRST_PAR.get()
      let kind = if IS_HEADING.get() { "heading" } else if nest-level > 0 and not first { "continuation" } else { "par" }
      buffer((content: text([#p.body]), nest-level: nest-level, kind: kind, first: first))
      if first {
        ITEM_FIRST_PAR.update(false)
      }
      p
    }
    show table: t => context {
      buffer((content: t, nest-level: NEST_DOWN.get().at(0) - NEST_UP.get().at(0), kind: "table"))
      t
    }
    // A `qm-table` wrapper's `align` places its table from outside it.
    show align: a => if a.body.func() == table {
      context buffer((content: a, nest-level: NEST_DOWN.get().at(0) - NEST_UP.get().at(0), kind: "table"))
    } else { a }
    // A block quote is the body's unnumbered block: its lines reach the page
    // as written. A code block reaches it unnumbered too. Returning `none`
    // keeps their paragraphs from the `show par` above.
    show quote.where(block: true): q => context {
      buffer((content: q.body, nest-level: NEST_DOWN.get().at(0) - NEST_UP.get().at(0), kind: "quote"))
      none
    }
    show raw.where(block: true): r => context {
      buffer((content: r, nest-level: NEST_DOWN.get().at(0) - NEST_UP.get().at(0), kind: "code"))
      none
    }
    {
      show heading: h => {
        IS_HEADING.update(true)
        [#parbreak()#h.body#parbreak()]
        IS_HEADING.update(false)
      }
      // No `context` wrapper: one here fails to converge on a body with many
      // list items.
      show enum.item: it => {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      show list.item: it => {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      {
        // `show par` does not capture an element that fills its paragraph
        // whole, so a word joiner follows each wrapper; it adds no break.
        show strong: it => [#it#sym.wj]
        show emph: it => [#it#sym.wj]
        show underline: it => [#it#sym.wj]
        show raw.where(block: false): it => [#it#sym.wj]
        [#content#parbreak()]
      }
    }
  }
  place(hide(first-pass))

  context {
    let width = page.width - 2 * MARGIN
    let authored = PAR_BUFFER.get().filter(item =>
      item.kind == "table" or measure(item.content).width > 0pt
    )
    // AR 25-50 2-4b(1)(a): references are the first paragraph, lettered when
    // there are two or more.
    let references = ensure-array(references).filter(r => not blank(r))
    let cited = if references.len() == 1 {
      ((content: [Reference.#PERIOD_GAP#references.at(0)], nest-level: 0, kind: "par"),)
    } else if references.len() > 1 {
      ((content: [References.], nest-level: 0, kind: "par"),) + references.map(r => (content: r, nest-level: 1, kind: "par"))
    } else { () }
    let buffered = cited + authored

    // A heading runs into the paragraph after it at its level, or the next
    // block of its own list item. Without one, it is a paragraph of its own
    // (AR 25-50 2-4b(4)(b)): numbered, its subparagraphs lettered under it.
    let items = ()
    let pending = none
    for (index, item) in buffered.enumerate() {
      let level = item.nest-level
      let opens-item = item.at("first", default: false)
      if item.kind == "heading" {
        let next = buffered.at(index + 1, default: none)
        let runs-in = (
          next != none
            and next.nest-level == level
            and next.kind == (if level == 0 { "par" } else { "continuation" })
        )
        if runs-in {
          pending = item
        } else {
          let kind = if level > 0 and not opens-item { "continuation" } else { "par" }
          items.push((content: run-in(item.content).label, nest-level: level, kind: kind, heading: true))
        }
        continue
      }
      let entry = item
      if pending != none {
        let lead = run-in(pending.content)
        entry.content = [#lead.label#lead.gap#entry.content]
        if pending.at("first", default: false) { entry.kind = "par" }
        pending = none
      }
      items.push(entry)
    }
    if items.len() == 0 { return }

    // AR 25-50 2-4b(4): a lone paragraph is not numbered; its subparagraphs
    // are still lettered.
    let numbered = items.filter(item => item.kind == "par" and item.nest-level == 0).len() > 1

    let level-counts = reset-levels-from((:), 0)
    for (index, item) in items.enumerate() {
      let kind = item.kind
      let level = item.nest-level
      let last = index == items.len() - 1

      let place-table(it) = {
        let placed = block(width: 100%, pad(x: TABLE_STROKE / 2, render-memo-table(it)))
        let offset = text-offset(level, level-counts)
        if offset == 0pt { placed } else { pad(left: offset, placed) }
      }
      let spaced = sentence-spacing(item.content)
      let flow-text = if kind in ("table", "quote", "code") { none } else if kind == "continuation" {
        [#h(text-offset(level, level-counts))#spaced]
      } else if numbered or level > 0 {
        let number = level-counts.at(str(level), default: 1)
        level-counts.insert(str(level), number + 1)
        level-counts = reset-levels-from(level-counts, level + 1)
        [#h(INDENT_STEP * level)#designator(level, number)#spaced]
      } else { spaced }
      // A code block sets in the mono face at the body's size and pitch, in
      // black, without highlighting.
      let indent(body) = {
        let offset = text-offset(level, level-counts)
        if offset == 0pt { body } else { pad(left: offset, body) }
      }
      let code(source) = indent({
        show raw: set text(font: DEFAULT_MONO_FONTS, size: text.size, fill: black)
        raw(source, block: true)
      })
      let emitted = if kind == "table" {
        place-table(spaced)
      } else if kind == "code" {
        code(item.content.text)
      } else if kind == "quote" {
        set par(spacing: LEADING + LINE)
        indent(spaced)
      } else { par(flow-text) }

      // AR 25-50 2-4b(2): one blank line between paragraphs and subparagraphs.
      if index > 0 { blank-line() }

      let lines = if kind == "table" { none } else { line-count(emitted, width) }
      if kind == "table" {
        if last {
          let found = find-table(item.content)
          let grid = if found != none { table-grid(found) }
          if grid == none {
            let height = measure(emitted, width: width).height
            block(sticky: height <= (page.height - 2 * MARGIN) / 3, emitted)
          } else if grid.rows - 2 <= grid.header-rows {
            block(breakable: false, sticky: true, emitted)
          } else {
            // The table's last two rows are a table of their own that sticks
            // to the closing, its columns as wide as the whole table's. It
            // repeats the header when it starts a page.
            let from = grid.rows - 2
            block(below: 0pt, {
              place-table(table-rows(spaced, row => row < from))
              [#metadata(none)<army-memo-table-head>]
            })
            block(above: 0pt, breakable: false, sticky: true, context {
              let head = query(<army-memo-table-head>)
              let moved = head.len() > 0 and here().page() > head.last().location().page()
              place-table(table-rows(spaced, row => row >= from, header: moved))
            })
          }
        } else {
          block(emitted)
        }
      } else if last and kind in ("par", "continuation") and lines > 3 {
        // AR 25-50 2-5c(4): the closing never starts a page without the last
        // two lines of the text above it. They are a block of their own that
        // sticks to the closing; the lines above may still divide (2-5c(1)).
        let parts = split-last-lines(flow-text, lines, 2, width)
        if parts == none {
          block(breakable: true, emitted)
        } else {
          block(breakable: lines > 5, par(parts.head))
          block(breakable: false, sticky: true, par(parts.tail))
        }
      } else if last and kind == "code" and item.content.text.split("\n").len() > 3 {
        let source = item.content.text.split("\n")
        block(breakable: true, code(source.slice(0, -2).join("\n")))
        block(breakable: false, sticky: true, code(source.slice(-2).join("\n")))
      } else if last and kind in ("quote", "code") and lines > 3 {
        let at = n => CAP_HEIGHT.to-absolute() + n * LINE.to-absolute()
        keep-with-closing(at(lines - 1), at(lines - 2.5))
        block(breakable: true, emitted)
      } else if last {
        block(breakable: false, sticky: true, emitted)
      } else {
        // AR 25-50 2-5c(1): a paragraph of three lines or fewer never splits.
        // A heading standing as a paragraph keeps with what follows it.
        block(breakable: lines > 3, sticky: item.at("heading", default: false), emitted)
      }
    }
  }
}
