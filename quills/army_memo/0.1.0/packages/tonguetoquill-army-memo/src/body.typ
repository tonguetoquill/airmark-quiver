// Paragraph numbering, indentation, sentence spacing and page breaking for the
// memorandum body: AR 25-50 2-4b and 2-5c.

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": memo-table-style, render-memo-table
#import "spacing.typ": *

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

/// The last gap a paragraph's content can be cut at with the part before it
/// setting in `keep` lines or fewer, at `width`; zero when there is none.
/// Ragged-right lines break greedily, so the part after it sets as the
/// paragraph's remaining lines do. Reads layout.
///
/// - body (content): The paragraph's content
/// - keep (int): The lines the part before the gap may take
/// - width (length): The width it sets at
/// -> int
#let gap-after-lines(body, keep, width) = {
  let gaps = 1000000 - cut-at-gap(body, 1000000).left
  let fits = k => line-count(par(cut-at-gap(body, k).head), width) <= keep
  if gaps < 1 or not fits(1) { return 0 }
  let (lo, hi) = (1, gaps)
  while lo < hi {
    let mid = calc.quo(lo + hi + 1, 2)
    if fits(mid) { lo = mid } else { hi = mid - 1 }
  }
  lo
}

// AR 25-50 2-5c(2): a sentence divided between pages has at least two words
// on each. Whether a cut at gap `g` leaves one word of a sentence alone.
#let parts-sentence(body, g) = {
  let parts = cut-at-gap(body, g)
  let b = tokens(flat(parts.head).split("\u{2029}").last())
  let a = tokens(flat(parts.tail).split("\u{2029}").first())
  if b.len() == 0 or a.len() == 0 { return false }
  let t = b + a
  let c = b.len()
  let ends = i => ends-sentence(t.at(i), t.at(i + 1), before: if i > 0 { t.at(i - 1) } else { "" })
  if ends(c - 1) { return false }
  let first = c - 1
  while first > 0 and not ends(first - 1) { first -= 1 }
  let last = c
  while last < t.len() - 1 and not ends(last) { last += 1 }
  c - first < 2 or last - c + 1 < 2
}

// The gap at or before `g` that leaves two words of a sentence on each side.
#let sentence-safe-gap(body, g) = {
  while g >= 1 and parts-sentence(body, g) { g -= 1 }
  g
}

// AR 25-50 2-5c(1),(2): a paragraph of more than three lines may divide
// between pages, keeping two lines and two words of a sentence on each.
// Where the page's last line falls inside it, the paragraph is cut there,
// at the gap before a sentence's first word or after its second-to-last,
// and sets as two blocks whose lines stand as one paragraph's would.
#let emit-paragraph(flow-text, lines, width, sticky: false) = {
  if lines <= 3 { return block(breakable: false, sticky: sticky, par(flow-text)) }
  context {
    let start = here().position()
    let reserve = if start.page == 1 {
      query(<army-memo-page-one-reserve>).map(m => m.value).sum(default: 0pt)
    } else { 0pt }
    let room = page.height - BOTTOM.to-absolute() - reserve - start.y - CAP_HEIGHT.to-absolute()
    let fit = if room < -0.01pt { 0 } else { calc.floor(room / LINE.to-absolute() + 0.001) + 1 }
    let keep = calc.min(fit, lines - 2)
    let g = if fit < lines and keep >= 2 {
      sentence-safe-gap(flow-text, gap-after-lines(flow-text, keep, width))
    } else { 0 }
    let parts = if g >= 1 { cut-at-gap(flow-text, g) }
    let head-lines = if g >= 1 { line-count(par(parts.head), width) } else { 0 }
    if head-lines < 2 or lines - head-lines < 2 {
      block(breakable: true, sticky: sticky, par(flow-text))
    } else {
      block(breakable: head-lines > 3, sticky: sticky, par(parts.head))
      block(breakable: lines - head-lines > 3, par(parts.tail))
    }
  }
}

// Content without the spaces it begins with.
#let trim-start(it) = {
  if type(it) != content { return it }
  if it.func() == [ ].func() { return [] }
  if it.func() == text { return [#it.text.trim(at: start)] }
  if it.has("children") and it.children.len() > 0 {
    let rest = it.children.slice(1)
    let first = trim-start(it.children.first())
    return if first == [] { trim-start(rest.join(default: [])) } else { ((first,) + rest).join() }
  }
  if it.has("child") and it.has("styles") { return (it.func())(trim-start(it.child), it.styles) }
  it
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

// AR 25-50 2-4b(3) and figure 2-1: the designator a quarter inch in per
// level to the second subdivision, two spaces after it.
#let designator(level, number) = [#label-for(level, number)#PERIOD_GAP]

#let designator-indent(level) = INDENT_STEP * calc.min(level, INDENT_LEVELS)

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
  designator-indent(level) + measure(designator(level, number)).width
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
// quote, code block, display equation and rule with its nesting level. The
// second emits the buffer in document order, numbering as it goes.
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
  let nesting() = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)

  let first-pass = {
    show: memo-table-style
    show par: p => context {
      let nest-level = nesting()
      let first = nest-level > 0 and ITEM_FIRST_PAR.get()
      let kind = if IS_HEADING.get() { "heading" } else if nest-level > 0 and not first { "continuation" } else { "par" }
      buffer((content: text(font: text.font, p.body), nest-level: nest-level, kind: kind, first: first))
      if first {
        ITEM_FIRST_PAR.update(false)
      }
      p
    }
    show table: t => context {
      buffer((content: t, nest-level: nesting(), kind: "table"))
      t
    }
    // A `qm-table` wrapper's `align` places its table from outside it.
    show align: a => if a.body.func() == table {
      context buffer((content: a, nest-level: nesting(), kind: "table"))
    } else { a }
    // A block quote is the body's unnumbered block: its lines reach the page
    // as written. A code block, a display equation and a rule reach it
    // unnumbered too. Returning `none` keeps their paragraphs from the
    // `show par` above.
    show quote.where(block: true): q => context {
      buffer((content: q.body, nest-level: nesting(), kind: "quote"))
      none
    }
    show raw.where(block: true): r => context {
      buffer((content: r, nest-level: nesting(), kind: "code"))
      none
    }
    show math.equation.where(block: true): e => context {
      buffer((content: e, nest-level: nesting(), kind: "display"))
      none
    }
    show line: l => context {
      buffer((content: l, nest-level: nesting(), kind: "rule"))
      none
    }
    {
      show heading: h => {
        IS_HEADING.update(true)
        [#parbreak()#h.body#parbreak()]
        IS_HEADING.update(false)
      }
      // A term and its description are one paragraph, the term run in as a
      // heading is.
      show terms: it => {
        for item in it.children {
          let lead = run-in(item.term)
          [#parbreak()#lead.label#lead.gap#trim-start(item.description)#parbreak()]
        }
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
        // Inline code's face and size reach the paragraph as its own text's.
        show strong: it => [#it#sym.wj]
        show emph: it => [#it#sym.wj]
        show underline: it => [#it#sym.wj]
        show strike: it => [#it#sym.wj]
        show link: it => [#it#sym.wj]
        show raw.where(block: false): it => context [#text(font: DEFAULT_MONO_FONTS, size: text.size, it.text)#sym.wj]
        [#content#parbreak()]
      }
    }
  }
  place(hide(first-pass))

  context {
    let width = page.width - 2 * MARGIN
    show LONG_TOKEN: break-long(width)
    let authored = PAR_BUFFER.get().filter(item =>
      item.kind in ("table", "display", "rule") or measure(item.content).width > 0pt
    )
    // A body typed as a list, its paragraphs' numbers typed as Markdown's,
    // has no paragraph above its items: they are its paragraphs.
    if authored.len() > 0 and authored.all(item => item.nest-level > 0) {
      let base = calc.min(..authored.map(item => item.nest-level))
      authored = authored.map(item => {
        item.nest-level -= base
        if item.nest-level == 0 and item.kind == "continuation" { item.kind = "par" }
        item
      })
    }
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
      // A block quote's paragraphs keep each sentence's first and last two
      // words together; a paragraph is cut where a page divides it.
      let spaced = if kind in ("code", "display", "rule") { item.content } else {
        sentence-spacing(item.content, glue: kind == "quote")
      }
      let flow-text = if kind in ("table", "quote", "code", "display", "rule") { none } else if kind == "continuation" {
        [#h(text-offset(level, level-counts))#spaced]
      } else if numbered or level > 0 {
        let number = level-counts.at(str(level), default: 1)
        level-counts.insert(str(level), number + 1)
        level-counts = reset-levels-from(level-counts, level + 1)
        [#h(designator-indent(level))#designator(level, number)#spaced]
      } else { spaced }
      let offset = text-offset(level, level-counts)
      let indent(body) = {
        show LONG_TOKEN: break-long(width - offset)
        if offset == 0pt { body } else { pad(left: offset, body) }
      }
      // A code block sets in the mono face at the body's size and pitch, in
      // black, without highlighting. A word wider than the column breaks.
      let code(source) = indent(context {
        set text(font: DEFAULT_MONO_FONTS, size: text.size, fill: black)
        let lines = source.split("\n").map(line => line.replace(LONG_TOKEN, m => {
          let word = text(font: DEFAULT_MONO_FONTS, m.text)
          if measure(word).width <= width - offset { m.text } else { m.text.clusters().join("\u{200B}") }
        }))
        show raw: set text(font: DEFAULT_MONO_FONTS, size: text.size, fill: black)
        raw(lines.join("\n"), block: true)
      })
      // A rule stands in a line of its own.
      let rule(it) = indent(block(width: 100%, height: CAP_HEIGHT, {
        set line(stroke: TABLE_STROKE + black)
        place(horizon + left, it)
      }))
      let emitted = if kind == "table" {
        place-table(spaced)
      } else if kind == "code" {
        code(item.content.text)
      } else if kind == "quote" {
        set par(spacing: LEADING + LINE)
        indent(spaced)
      } else if kind == "display" {
        // Typst's math face, centered, as an equation sets where it is written.
        indent(block(width: 100%, {
          set text(font: "New Computer Modern Math")
          align(center, spaced)
        }))
      } else if kind == "rule" {
        rule(spaced)
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
        let g = sentence-safe-gap(flow-text, gap-after-lines(flow-text, lines - 2, width))
        if g < 1 {
          block(breakable: true, emitted)
        } else {
          let parts = cut-at-gap(flow-text, g)
          emit-paragraph(parts.head, line-count(par(parts.head), width), width)
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
      } else if kind in ("par", "continuation") {
        // A heading standing as a paragraph keeps with what follows it.
        emit-paragraph(flow-text, lines, width, sticky: item.at("heading", default: false))
      } else {
        // AR 25-50 2-5c(1): a block of three lines or fewer never splits.
        block(breakable: lines > 3, emitted)
      }
    }
  }
}
