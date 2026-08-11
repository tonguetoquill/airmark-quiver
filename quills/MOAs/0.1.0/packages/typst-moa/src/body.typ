// body.typ — freeform paragraph body rendering for a DoDI 4000.19 MOA
//
// Parses arbitrary markdown-authored content into top-level paragraphs and
// nested list items, then numbers each one with DoDI 4000.19 Figure 1's
// chained decimal outline scheme (1., 4.1., 6.1.1.1.). Mirrors how
// tonguetoquill-usaf-memo's body.typ auto-numbers freeform memo paragraphs,
// adapted for MOA's decimal-chain format instead of AFH 33-337's
// numeral/letter/paren cycle, and for MOA's fixed per-depth indent (no
// hanging indent on wrapped lines).

#import "config.typ": indent-for
#import "utils.typ": blank-line, decimal-numbering

/// Renders freeform content as DoDI 4000.19 numbered paragraphs.
///
/// - content (content): The body content to render (paragraphs and nested
///   bullet/numbered lists — from markdown, or written directly in Typst).
/// -> content
#let render-moa-body(content) = {
  let PAR_BUFFER = state("MOA_PAR_BUFFER")
  PAR_BUFFER.update(())
  let NEST_DOWN = counter("MOA_NEST_DOWN")
  NEST_DOWN.update(0)
  let NEST_UP = counter("MOA_NEST_UP")
  NEST_UP.update(0)
  // Tracks whether the next paragraph is the first block in a list item.
  // When true, the next `show par` captures a numbered item; subsequent
  // paragraphs within the same item are continuations (no new number).
  let ITEM_FIRST_PAR = state("MOA_ITEM_FIRST_PAR")
  ITEM_FIRST_PAR.update(false)

  // First pass: parse paragraphs and list items into a flat buffer tagged
  // with nesting level. Rendered hidden so it doesn't affect layout.
  let first_pass = {
    show par: p => context {
      let nest_level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let is_first_par = ITEM_FIRST_PAR.get()
      let is_continuation = nest_level > 0 and not is_first_par

      PAR_BUFFER.update(pars => {
        pars.push((
          content: text([#p.body]),
          nest_level: nest_level,
          kind: if is_continuation { "continuation" } else { "par" },
        ))
        pars
      })

      if nest_level > 0 and is_first_par {
        ITEM_FIRST_PAR.update(false)
      }

      p
    }

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

    // Typst bug bandaid: `show par` will not collect wrappers unless there
    // is content outside the wrapper. Add a zero-width space so styled runs
    // (bold, italic, ...) always have such content.
    show strong: it => [#it#sym.zws]
    show emph: it => [#it#sym.zws]
    show underline: it => [#it#sym.zws]
    show raw: it => [#it#sym.zws]

    [#content#parbreak()]
  }
  // Use place() to prevent the hidden first pass from affecting layout flow.
  place(hide(first_pass))

  // Second pass: consume the buffer and render each paragraph with a
  // chained decimal number, first-line indented per its nesting depth.
  context {
    let items = PAR_BUFFER.get().filter(item => measure(item.content).width > 0pt)
    if items.len() == 0 { return }

    // `current-numstr.at(str(level))` is the decimal number of the most
    // recently emitted paragraph at that level (frozen for its children to
    // chain from). `next-index.at(str(level))` is the sibling index the
    // *next* paragraph at that level will receive.
    let current-numstr = (:)
    let next-index = (:)

    let any_emitted = false
    for item in items {
      let nest_level = item.nest_level
      let final_par = if item.kind == "continuation" {
        // Continuation block within a multi-block list item: indent to the
        // same first-line position as the preceding numbered paragraph, no
        // new number (MOA paragraphs have no hanging indent to align to).
        block[#h(indent-for(nest_level))#item.content]
      } else {
        let parent-prefix = if nest_level == 0 { "" } else { current-numstr.at(str(nest_level - 1), default: "") }
        let numstr = decimal-numbering(parent-prefix, next-index.at(str(nest_level), default: 1))
        let par = block[#h(indent-for(nest_level))#numstr #item.content]
        next-index.insert(str(nest_level), next-index.at(str(nest_level), default: 1) + 1)
        current-numstr.insert(str(nest_level), numstr)
        // A new item starts at `nest_level`: any deeper levels' sibling
        // counters must restart at 1 (inlined here, not a helper closure —
        // Typst closures capture outer dictionaries by value, so mutating
        // `next-index` from a nested function would not propagate out).
        for lvl in next-index.keys() {
          if int(lvl) > nest_level {
            next-index.insert(lvl, 1)
          }
        }
        par
      }

      if any_emitted { blank-line() }
      any_emitted = true
      final_par
    }
  }
}
