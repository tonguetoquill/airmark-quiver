// Paragraph numbering, nesting, and indentation for the memorandum body.

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": render-memo-table

/// Gets the numbering format for a specific paragraph level.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> str | function
#let get-paragraph-numbering-format(level) = {
  paragraph-config.numbering-formats.at(level, default: "i.")
}

/// The number of the paragraph last emitted at a level. `level-counts` holds
/// the number the next one takes, so this is one less, and 1 before any.
///
/// - level (int): Paragraph nesting level (0-based)
/// - level-counts (dictionary): Maps level index strings to the next number at each level
/// -> int
#let emitted-number(level, level-counts) = {
  calc.max(1, level-counts.at(str(level), default: 1) - 1)
}

/// Calculates indentation for USAF-style paragraphs from explicit counter values.
///
/// - level (int): Paragraph nesting level (0-based)
/// - level-counts (dictionary): Maps level index strings to the next number at each level
/// -> length
#let calculate-indent-from-counts(level, level-counts) = {
  if level == 0 {
    return 0pt
  }
  let total-indent = 0pt
  for ancestor-level in range(level) {
    let ancestor-value = emitted-number(ancestor-level, level-counts)
    let ancestor-format = get-paragraph-numbering-format(ancestor-level)
    let ancestor-number = numbering(ancestor-format, ancestor-value)
    total-indent += measure([#ancestor-number#"  "]).width
  }
  total-indent
}

/// Calculates fixed indentation for DAF paragraph levels.
///
/// First nested level starts at `nested-first-level-indent` (1in); deeper levels
/// add `nested-step` (0.5in) per additional depth.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> length
#let calculate-daf-indent(level) = {
  if level <= 0 {
    return 0pt
  }
  daf-paragraph.nested-first-level-indent + (level - 1) * daf-paragraph.nested-step
}

#let reset-levels-from(level-counts, start, max-levels) = {
  for child in range(start, max-levels) {
    level-counts.insert(str(child), 1)
  }
  level-counts
}

/// The horizontal offset at which a paragraph's *text* sits: its indent plus
/// the width of the number label that precedes it.
///
/// This is where a later block of the same paragraph — a continuation, a block
/// quote, a table — lines up, so the callers share one measurement rather than
/// each spelling it. A top-level paragraph carries no indent and its label is the
/// left margin itself, so the offset is zero.
///
/// - level (int): Nesting level (0-based)
/// - level-counts (dictionary): Maps level index strings to the next number at each level
/// - indent-fn (function): `(level, level-counts) -> length`
/// -> length
#let paragraph-text-offset(level, level-counts, indent-fn) = {
  if level <= 0 { return 0pt }
  let number = emitted-number(level, level-counts)
  let number-text = numbering(get-paragraph-numbering-format(level), number)
  indent-fn(level, level-counts) + measure([#number-text#"  "]).width
}

/// Formats a paragraph (or continuation) with a given indent strategy.
///
/// - body (content): Paragraph content
/// - level (int): Nesting level (0-based)
/// - level-counts (dictionary): Current counter values per level
/// - indent-fn (function): `(level, level-counts) -> length`
/// - continuation (bool): If true, adds number-label width to alignment
/// -> content
#let format-par(body, level, level-counts, indent-fn, continuation: false) = {
  if continuation {
    // Offset the first line only, which is how the numbered paragraph this
    // block continues is set: its own wrapped lines return to the left margin
    // too, so the two read as one paragraph.
    [#h(paragraph-text-offset(level, level-counts, indent-fn))#body]
  } else {
    let indent-width = indent-fn(level, level-counts)
    let current-value = level-counts.at(str(level), default: 1)
    let number-text = numbering(get-paragraph-numbering-format(level), current-value)
    [#h(indent-width)#number-text#"  "#body]
  }
}

// AFH 33-337 "Do not place the signature element on a continuation page by
// itself." When the last element ends on a page with no room left for the
// signature block, a bottom float takes the room below the element's last two
// lines, so they start the next page above the signature. Measured from where
// the element begins, which the float cannot move, so the signature block
// stays on the later page and the float stays.
#let keep-tail-with-signature(height) = context {
  let start = here().position()
  let signature = query(selector(<usaf-memo-flow-anchor>).after(here()))
  if signature.len() == 0 or signature.first().location().page() == start.page { return }
  let reserve = if start.page == 1 {
    query(<usaf-memo-page-one-reserve>).map(m => m.value).sum(default: 0pt)
  } else { 0pt }
  let limit = page.height - spacing.margin - reserve
  if start.y + height <= limit {
    let tail = 2 * line-stride() - spacing.line.to-absolute()
    place(bottom, float: true, clearance: 0pt, block(height: limit - start.y - height + tail))
  }
}

// The elements of a body that `render-body` numbers, letters, or sets apart,
// in reading order. An item is `(content, nest-level, kind)`:
//
//   content    — the paragraph's inline content, the heading's or block
//                quote's body, or the table element
//   nest-level — list nesting depth, 0 at the top level
//   kind       — "par", "continuation", "heading", "table", or "quote"
//
// Read off the content tree rather than collected by show rules during a
// layout pass: state and counters set in one layout pass are read in the next,
// so a collected body only takes its final shape a few passes in, and every
// position-dependent decision after it (an indorsement's header, the tail kept
// with the signature) then needs more passes than Typst runs. Walking the tree
// gives the same items on the first pass.
//
// A paragraph is a run of inline content between block-level elements and
// paragraph breaks. Inside a list or enum item, the first paragraph is the item
// itself and each later one a continuation of it. A block quote's content stays
// verbatim, taking no number, letter, or bullet: it is where an author says a
// roster of names, a quoted passage, or an address is neither paragraph nor
// subparagraph. A `qm-table` wrapper's `align` places its table from outside
// it, so it is taken with the table. A `styled` wrapper — a `set` or `show`
// rule inside the body — is walked through, and its styles are reapplied to
// each item inside it.
#let body-items(body, nest-level: 0) = {
  if type(body) == str { body = [#body] }
  let items = ()
  let run = ()
  let first = nest-level > 0
  // A nested sequence is the same stream, not a container.
  let flatten(c) = if c.func() == [].func() { c.children.map(flatten).flatten() } else { (c,) }
  let children = flatten(body)
  for child in children + (parbreak(),) {
    let f = child.func()
    let is-table = f == table or (f == align and child.body.func() == table)
    let is-quote = f == quote and child.block
    let is-styled = child.has("child") and child.has("styles")
    let is-block = (
      f in (parbreak, heading, list.item, enum.item) or is-table or is-quote or is-styled
    )
    if not is-block {
      run.push(child)
      continue
    }
    // Typst drops the spaces at a paragraph's edges; a run keeps them.
    while run.len() > 0 and run.first().func() == [ ].func() { run = run.slice(1) }
    while run.len() > 0 and run.last().func() == [ ].func() { run = run.slice(0, -1) }
    if run.len() > 0 {
      items.push((
        content: run.join(),
        nest-level: nest-level,
        kind: if nest-level > 0 and not first { "continuation" } else { "par" },
      ))
      first = false
      run = ()
    }
    if f == heading {
      items.push((content: child.body, nest-level: nest-level, kind: "heading"))
      first = false
    } else if f in (list.item, enum.item) {
      items += body-items(child.body, nest-level: nest-level + 1)
      first = false
    } else if is-table {
      items.push((content: child, nest-level: nest-level, kind: "table"))
    } else if is-quote {
      items.push((content: child.body, nest-level: nest-level, kind: "quote"))
    } else if is-styled {
      let restyle = part => (child.func())(part, child.styles)
      for item in body-items(child.child, nest-level: nest-level) {
        items.push(item + (content: restyle(item.content)))
      }
    }
  }
  items
}

// AFH 33-337 "The Text of the Official Memorandum" §1-12: number and letter
// each paragraph and subparagraph as 1. / a. / (1) / (a); leave a top-level
// paragraph flush left and a lone paragraph unnumbered (§2); indent each
// subparagraph to align with the first character of its parent's text.
//
// The body is read into items (`body-items`) and each item is emitted in
// document order, numbered for its kind and nesting level.
#let render-body(content, memo-style: "usaf") = {
  let all-items = body-items(content)

  context {
    let heading-buffer = none
    let heading-level = 0
    // Zero-width paragraphs are dropped, so an empty body emits nothing and
    // collapses to zero vertical space. A table is kept whatever it measures.
    let items = all-items.filter(item =>
      item.kind == "table" or measure(item.content).width > 0pt
    )
    if items.len() == 0 { return }
    // Only top-level paragraphs count for AFH 33-337 §2 numbering purposes
    let par-count = items.filter(item => item.kind == "par").len()
    let total-count = items.len()

    // Numbers are tracked in a dictionary keyed by level index (as a string)
    // rather than in counters, whose updates do not propagate out of the
    // nested contexts this loop runs in.
    let max-levels = paragraph-config.numbering-formats.len()
    let level-counts = (:)
    for lvl in range(max-levels) {
      level-counts.insert(str(lvl), 1)
    }

    let i = 0
    let any-emitted = false
    for item in items {
      i += 1
      let kind = item.kind
      let item-content = item.content

      // A buffered heading runs into this element only when the two belong to
      // the same item: a later block of this list item ("continuation"), or,
      // at top level, the next paragraph. The first block of the *next* item,
      // a table (a block, with no line for a heading to run into), a block
      // quote (verbatim: a heading prepended to it would be ink the author did
      // not put inside the quote), and another heading all fail the test, and
      // each would otherwise carry the heading's text somewhere it was not
      // authored. Those emit the heading on its own line.
      if heading-buffer != none {
        let runs-in = (
          kind not in ("heading", "quote", "table")
            and item.nest-level == heading-level
            and (heading-level == 0 or kind == "continuation")
        )
        if runs-in {
          item-content = [#strong[#heading-buffer.] #item-content]
        } else {
          if any-emitted { blank-line() }
          strong[#heading-buffer.]
          any-emitted = true
        }
        heading-buffer = none
      }

      // Buffer this heading for the next element to run into. The level it was
      // captured at rides along: the run-in test needs it, and the buffer is
      // read one iteration later, by which time `item` is the *next* element.
      if kind == "heading" {
        heading-buffer = item-content
        heading-level = item.nest-level
        continue
      }

      let nest-level = item.nest-level
      let indent-fn = if memo-style == "daf" {
        (level, _counts) => calculate-daf-indent(level)
      } else {
        (level, counts) => calculate-indent-from-counts(level, counts)
      }
      let final-par = {
        if kind == "table" {
          // Hangs under the text of the paragraph it sits in, as a block quote
          // does. Its placement and `widths` measure against the width left
          // beside the offset, so it stays inside the text column.
          let placed = block(width: 100%, render-memo-table(item-content))
          let offset = paragraph-text-offset(nest-level, level-counts, indent-fn)
          if offset == 0pt { placed } else { pad(left: offset, placed) }
        } else if kind == "quote" {
          // A block quote is the body's unlabeled block: no number, no letter,
          // no bullet — the author's lines as written. It is placed, not
          // processed, which is what lets a memorandum carry a roster of names,
          // an address, or a quoted passage without AFH 33-337 numbering
          // claiming the first line of it.
          //
          // Two things are imposed, and both serve that reading.
          //
          // Where the block starts: at the offset where the text of the
          // paragraph it sits in starts, so a quote inside a subparagraph hangs
          // under that subparagraph's text instead of falling back to the left
          // margin. `pad` shifts the whole block, where a continuation takes a
          // first-line `h(..)`: a quote is kept for its line structure, and
          // lines that wrapped back to the margin would read as a block other
          // than the one authored. Top level offsets by 0pt — flush at the
          // margin, where an unnumbered line belongs.
          //
          // How its own paragraphs are spaced: `par.leading` and `par.spacing`
          // are both half an em in a memorandum, so a paragraph break inside
          // the quote would land on the page as an ordinary line break and read
          // as one block where the author wrote two. A blank line — what the
          // body puts between its own paragraphs — keeps that break visible.
          let quoted = {
            set par(spacing: spacing.line + line-stride())
            item-content
          }
          let offset = paragraph-text-offset(nest-level, level-counts, indent-fn)
          if offset == 0pt { quoted } else { pad(left: offset, quoted) }
        } else if kind == "continuation" {
          // Continuation block within a multi-block list item:
          // indent to align with preceding numbered paragraph's text, no new number.
          if memo-style == "daf" and nest-level == 0 {
            item-content
          } else {
            format-par(item-content, nest-level, level-counts, indent-fn, continuation: true)
          }
        } else if memo-style == "daf" {
          if nest-level > 0 {
            let par = format-par(item-content, nest-level, level-counts, indent-fn)
            level-counts.insert(str(nest-level), level-counts.at(str(nest-level), default: 1) + 1)
            level-counts = reset-levels-from(level-counts, nest-level + 1, max-levels)
            par
          } else {
            // DAF top-level paragraphs are unnumbered and first-line indented.
            // Reset nested counters so each new top-level paragraph restarts children.
            level-counts = reset-levels-from(level-counts, 0, max-levels)
            [#h(daf-paragraph.top-first-line-indent)#item-content]
          }
        } else if par-count > 1 {
          let par = format-par(item-content, nest-level, level-counts, indent-fn)
          level-counts.insert(str(nest-level), level-counts.at(str(nest-level)) + 1)
          level-counts = reset-levels-from(level-counts, nest-level + 1, max-levels)
          par
        } else {
          // AFH 33-337 §2: "A single paragraph is not numbered"
          item-content
        }
      }

      // Blank line between paragraphs. The header→body gap (i.e. before
      // the first emitted paragraph) is the caller's responsibility —
      // emitting it here would put the v() inside a nested
      // `context { for … }` block, where it does not combine with the
      // preceding header section's block-spacing the same way as a
      // top-level blank-line() call.
      if any-emitted { blank-line() }
      any-emitted = true
      if i == total-count {
        // AFH 33-337 "Signature Block": "Do not place the signature element on a
        // continuation page by itself." The signature block that follows has no
        // keep-with-previous of its own — Typst has no such property — so the
        // anchor comes from this side: a sticky last element is carried onto the
        // next page along with the signature instead of breaking away from it.
        //
        // Bounded, because a sticky block does not *split* at a page boundary,
        // it relocates whole; applied to a half-page block that turns an
        // ordinary mid-paragraph break into a wholesale jump. A third of the
        // text block covers what a memorandum actually ends on — a closing
        // paragraph, a short table. A longer block stays in place, and
        // `keep-tail-with-signature` moves only its last two lines.
        //
        // The budget is a fixed fraction rather than the space actually left
        // below this element, which is the question one would rather ask. A
        // position-dependent test cannot be answered honestly here: on the first
        // layout pass `here()` resolves against an empty introspector and reports
        // the top of the page, so every element measures as fitting and
        // relocates — and from the top of its new page the same test agrees, so
        // the wrong answer is a fixed point that later passes never revisit.
        let available-width = page.width - spacing.margin * 2
        let relocation-budget = (page.height - spacing.margin * 2) / 3
        let element-height = measure(final-par, width: available-width).height
        if element-height <= relocation-budget {
          block(sticky: true)[#final-par]
        } else {
          keep-tail-with-signature(element-height)
          block[#final-par]
        }
      } else {
        // A plain block, so that the document-wide `set block(above:
        // spacing.line)` contributes the same 0.5em above every paragraph as it
        // does above the last one. A bare emission skips `block.above` and
        // visibly compresses the gap.
        block[#final-par]
      }
    }

    // A heading with nothing after it never ran into anything, and the buffer
    // dies with the loop unless it is drained here. Sticky for the same reason
    // the last item is: a standalone heading is one line, so it keeps with the
    // signature block rather than opening a page alone.
    if heading-buffer != none {
      if any-emitted { blank-line() }
      block(sticky: true)[#strong[#heading-buffer.]]
    }
  }
}


