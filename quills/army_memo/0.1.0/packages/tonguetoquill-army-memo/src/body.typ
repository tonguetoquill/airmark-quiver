// Paragraph numbering, indentation, sentence spacing and page breaking for the
// memorandum body: AR 25-50 2-4b and 2-5c.

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": memo-table-style, render-memo-table

// AR 25-50 1-39b(9): two spaces after a sentence's closing period or question
// mark. A run of tokens ending in "." or "?", the word before it and the
// character after it, so "Tab A. The" and "Fig. 5. The" are read whole.
#let SENTENCE_RUN = regex("(?:\S+ )?(?:\S*?[.?][\"”’)]{0,2} )+\S")
#let SENTENCE_START = regex("^[\p{Lu}\p{N}\"“‘(]")
#let INITIALS = regex("^(\p{L}\.)*\p{L}$")
// Abbreviations that stand before a name.
#let TITLES = (
  "mr", "mrs", "ms", "dr", "jr", "sr", "st", "gen", "col", "lt", "capt", "maj",
  "sgt", "ft", "vs",
)
// Abbreviations that stand before a number, and end a sentence before a word.
#let NUMBER_LEADS = (
  "no", "nos", "vol", "fig", "figs", "para", "paras", "encl", "approx", "jan",
  "feb", "mar", "apr", "jun", "jul", "aug", "sep", "sept", "oct", "nov", "dec",
)
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
  let core = token.trim(regex("[\"”’)]+"), at: end)
  if core.ends-with("?") { return true }
  if not core.ends-with(".") { return false }
  let word = lower(core.slice(0, -1).trim(regex("^[^\p{L}\p{N}]+"), at: start))
  if word.match(INITIALS) != none {
    return word.clusters().len() == 1 and lower(before) in LETTER_LABELS
  }
  if word in TITLES { return false }
  if word in NUMBER_LEADS { return next.match(regex("^\p{N}")) == none }
  true
}

#let words-of(text) = text.replace("\u{200B}", "").split(regex("\s"))

// Widens each space between two elements, such as a bold run-in label and the
// text after it, where a sentence ends: the regex below reads one run of text
// at a time and never sees across them.
#let widen-element-gaps(it) = {
  if type(it) != content { return it }
  if it.has("child") and it.has("styles") {
    return (it.func())(widen-element-gaps(it.child), it.styles)
  }
  if it.func() in (table, table.header, table.cell) {
    let fields = it.fields()
    let key = if it.func() == table.cell { "body" } else { "children" }
    let inner = fields.remove(key)
    return if key == "body" {
      table.cell(..fields, widen-element-gaps(inner))
    } else {
      (it.func())(..fields, ..inner.map(widen-element-gaps))
    }
  }
  if it.func() != [*a* b].func() { return it }
  let children = it.children
  let texts = children.map(plain-text)
  let out = ()
  for (i, child) in children.enumerate() {
    if child.func() == [ ].func() {
      let before = words-of(texts.slice(0, i).join(default: ""))
      let after = words-of(texts.slice(i + 1).join(default: ""))
      let token = before.last()
      let next = after.first()
      if token != "" and next != "" and ends-sentence(token, next, before: before.at(-2, default: "")) {
        out.push([#"  "])
        continue
      }
      out.push(child)
    } else {
      out.push(widen-element-gaps(child))
    }
  }
  out.join(default: [])
}

#let sentence-spacing(body) = {
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
  widen-element-gaps(body)
}

// AR 25-50 1-39b(9): a run-in heading takes a period unless it ends in its own
// punctuation, and the gap after it is the one that punctuation takes.
#let run-in(heading) = {
  let last = plain-text(heading).replace("\u{200B}", "").trim().clusters().at(-1, default: "")
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

// AR 25-50 2-5c(4): the text above the closing keeps its last two lines with
// it. A final paragraph that ends a page with room for none of the closing
// below it gives up its last two lines to the next page: a bottom float takes
// the room they would have filled. Measured from where the paragraph begins,
// which the float cannot move.
#let keep-last-lines(lines) = context {
  let need = query(<army-memo-closing-need>)
  if need.len() == 0 or lines < 4 { return }
  let line = LINE.to-absolute()
  let start = here().position()
  let first = start.y + CAP_HEIGHT.to-absolute()
  let reserve = if start.page == 1 {
    query(<army-memo-page-one-reserve>).map(m => m.value).sum(default: 0pt)
  } else { 0pt }
  let limit = page.height - MARGIN - reserve
  let fitting = calc.floor((limit - first) / line + 0.001) + 1
  let last = first + (lines - 1) * line
  if fitting >= lines and last + need.first().value > limit + 0.01pt {
    place(bottom, float: true, clearance: 0pt, block(height: limit - last + 1.5 * line))
  }
}

// Rendering takes two passes. The first lays the content out hidden, so that
// Typst's own show rules resolve, and buffers each paragraph, table and block
// quote with its nesting level. The second emits the buffer in document order,
// numbering as it goes.
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

  let first-pass = {
    show: memo-table-style
    show par: p => context {
      let nest-level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let is-continuation = nest-level > 0 and not ITEM_FIRST_PAR.get()
      let kind = if IS_HEADING.get() { "heading" } else if is-continuation { "continuation" } else { "par" }
      PAR_BUFFER.update(pars => {
        pars.push((content: text([#p.body]), nest-level: nest-level, kind: kind))
        pars
      })
      if nest-level > 0 and ITEM_FIRST_PAR.get() {
        ITEM_FIRST_PAR.update(false)
      }
      p
    }
    show table: t => context {
      let nest-level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      PAR_BUFFER.update(pars => {
        pars.push((content: t, nest-level: nest-level, kind: "table"))
        pars
      })
      t
    }
    // A `qm-table` wrapper's `align` places its table from outside it.
    show align: a => if a.body.func() == table {
      context {
        let nest-level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
        PAR_BUFFER.update(pars => {
          pars.push((content: a, nest-level: nest-level, kind: "table"))
          pars
        })
      }
    } else { a }
    // A block quote is the body's unnumbered block: its lines reach the page
    // as written. Returning `none` keeps its paragraphs from the `show par`
    // above.
    show quote.where(block: true): q => context {
      let nest-level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      PAR_BUFFER.update(pars => {
        pars.push((content: q.body, nest-level: nest-level, kind: "quote"))
        pars
      })
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
        // whole, so a zero-width space follows each wrapper.
        show strong: it => [#it#sym.zws]
        show emph: it => [#it#sym.zws]
        show underline: it => [#it#sym.zws]
        show raw: it => [#it#sym.zws]
        [#content#parbreak()]
      }
    }
  }
  place(hide(first-pass))

  context {
    let width = page.width - 2 * MARGIN
    let line = LINE.to-absolute()
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
    let items = cited + authored
    if items.len() == 0 { return }

    // AR 25-50 2-4b(4): a lone paragraph is not numbered; its subparagraphs
    // are still lettered.
    let numbered = items.filter(item => item.kind == "par" and item.nest-level == 0).len() > 1

    let level-counts = reset-levels-from((:), 0)
    let heading-buffer = none
    let heading-level = 0
    let any-emitted = false
    for (index, item) in items.enumerate() {
      let kind = item.kind
      let item-content = item.content
      let level = item.nest-level

      // A buffered heading runs into the next paragraph at its level, or the
      // next block of its own list item. Anything else gets it on a line of
      // its own.
      if heading-buffer != none {
        let runs-in = (
          kind not in ("heading", "quote", "table")
            and level == heading-level
            and (heading-level == 0 or kind == "continuation")
        )
        let lead = run-in(heading-buffer)
        if runs-in {
          item-content = [#lead.label#lead.gap#item-content]
        } else {
          if any-emitted { blank-line() }
          block(sticky: true, lead.label)
          any-emitted = true
        }
        heading-buffer = none
      }
      if kind == "heading" {
        heading-buffer = item-content
        heading-level = level
        continue
      }

      let emitted = if kind == "table" {
        let placed = block(width: 100%, pad(x: TABLE_STROKE / 2, render-memo-table(sentence-spacing(item-content))))
        let offset = text-offset(level, level-counts)
        if offset == 0pt { placed } else { pad(left: offset, placed) }
      } else if kind == "quote" {
        let quoted = {
          set par(spacing: LEADING + LINE)
          sentence-spacing(item-content)
        }
        let offset = text-offset(level, level-counts)
        if offset == 0pt { quoted } else { pad(left: offset, quoted) }
      } else if kind == "continuation" {
        par[#h(text-offset(level, level-counts))#sentence-spacing(item-content)]
      } else if numbered or level > 0 {
        let number = level-counts.at(str(level), default: 1)
        level-counts.insert(str(level), number + 1)
        level-counts = reset-levels-from(level-counts, level + 1)
        par[#h(INDENT_STEP * level)#designator(level, number)#sentence-spacing(item-content)]
      } else {
        par(sentence-spacing(item-content))
      }

      // AR 25-50 2-4b(2): one blank line between paragraphs and subparagraphs.
      if any-emitted { blank-line() }
      any-emitted = true

      let last = index == items.len() - 1 and heading-buffer == none
      let lines = if kind == "table" { none } else { line-count(emitted, width) }
      if last and kind == "table" {
        let height = measure(emitted, width: width).height
        block(sticky: height <= (page.height - 2 * MARGIN) / 3, emitted)
      } else if last {
        // AR 25-50 2-5c(4): the closing never starts a page without the last
        // two lines of the text above it.
        keep-last-lines(lines)
        block(breakable: lines > 3, sticky: lines <= 3, emitted)
      } else {
        // AR 25-50 2-5c(1): a paragraph of three lines or fewer never splits.
        block(breakable: kind == "table" or lines > 3, emitted)
      }
    }

    if heading-buffer != none {
      if any-emitted { blank-line() }
      block(sticky: true, run-in(heading-buffer).label)
    }
  }
}
