// body.typ: Paragraph body rendering for personal letter (AFH 33-337 Ch. 15)
//
// Per Ch. 15 "The Text of the Personal Letter":
//   - "Do not number the paragraphs."
//   - "Indent the first line of text for all major paragraphs 0.5 inches."
//   - "if there are sub-paragraphs, follow the same guidance for sub-paragraph
//     numbering and indentation as in the official memorandum."
//   - "All second and subsequent lines of text for all paragraphs are flush
//     with the left margin."

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": render-memo-table

#let render-body(content) = {
  let PAR_BUFFER = state("PL_PAR_BUFFER")
  PAR_BUFFER.update(())
  let NEST_DOWN = counter("PL_NEST_DOWN")
  NEST_DOWN.update(0)
  let NEST_UP = counter("PL_NEST_UP")
  NEST_UP.update(0)
  let IS_HEADING = state("PL_IS_HEADING")
  IS_HEADING.update(false)
  let ITEM_FIRST_PAR = state("PL_ITEM_FIRST_PAR")
  ITEM_FIRST_PAR.update(false)

  // First pass: collect paragraphs with nesting metadata
  let first_pass = {
    show par: p => context {
      let nest_level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let is_heading = IS_HEADING.get()
      let is_first_par = ITEM_FIRST_PAR.get()
      let is_continuation = nest_level > 0 and not is_first_par

      PAR_BUFFER.update(pars => {
        pars.push((
          content: text([#p.body]),
          nest_level: nest_level,
          kind: if is_heading { "heading" } else if is_continuation { "continuation" } else { "par" },
        ))
        pars
      })

      if nest_level > 0 and is_first_par {
        ITEM_FIRST_PAR.update(false)
      }

      p
    }

    show table: t => context {
      PAR_BUFFER.update(pars => {
        pars.push((content: t, nest_level: -1, kind: "table"))
        pars
      })
      t
    }

    {
      show heading: h => {
        IS_HEADING.update(true)
        [#parbreak()#h.body#parbreak()]
        IS_HEADING.update(false)
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

      {
        show strong: it => { [#it#sym.zws] }
        show emph: it => { [#it#sym.zws] }
        show underline: it => { [#it#sym.zws] }
        show raw: it => { [#it#sym.zws] }
        [#content#parbreak()]
      }
    }
  }
  place(hide(first_pass))

  // Second pass: render collected paragraphs with personal letter formatting
  context {
    let heading_buffer = none
    let items = PAR_BUFFER.get().filter(item =>
      item.kind == "table" or measure(item.content).width > 0pt
    )
    if items.len() == 0 { return }

    let max-levels = paragraph-config.numbering-formats.len()
    let level-counts = (:)
    for lvl in range(max-levels) {
      level-counts.insert(str(lvl), 1)
    }

    let indent-fn = (level, counts) => calculate-personal-letter-indent(level, counts)

    let i = 0
    let any_emitted = false
    let total_count = items.len()

    for item in items {
      i += 1
      let kind = item.kind
      let item_content = item.content

      if kind == "heading" {
        heading_buffer = item_content
        continue
      }

      if heading_buffer != none {
        if kind == "table" {
          blank-line()
          strong[#heading_buffer.]
          heading_buffer = none
        } else {
          item_content = [#strong[#heading_buffer.] #item_content]
          heading_buffer = none
        }
      }

      let nest_level = item.nest_level
      let final_par = {
        if kind == "table" {
          render-memo-table(item_content)
        } else if kind == "continuation" {
          if nest_level <= 0 {
            // Continuation of a top-level paragraph: flush left
            item_content
          } else {
            format-par(item_content, nest_level, level-counts, indent-fn, continuation: true)
          }
        } else if nest_level <= 0 {
          // Top-level paragraph: unnumbered, first-line indent 0.5in
          // Reset sub-paragraph counters for each new top-level paragraph
          level-counts = reset-levels-from(level-counts, 1, max-levels)
          [#h(PARA_FIRST_LINE_INDENT)#item_content]
        } else {
          // Sub-paragraph: numbered per USAF memo rules (a., (1), etc.)
          let par = format-par(item_content, nest_level, level-counts, indent-fn)
          level-counts.insert(str(nest_level), level-counts.at(str(nest_level), default: 1) + 1)
          level-counts = reset-levels-from(level-counts, nest_level + 1, max-levels)
          par
        }
      }

      // AFH 33-337 Ch. 15 orphan prevention: keep short last paragraphs
      // with the signature block (same rule as the official memo).
      if any_emitted { blank-line() }
      any_emitted = true
      if i == total_count {
        let available_width = page.width - spacing.margin * 2
        let line_height = {
          let cached = LINE_STRIDE.get()
          if cached != none { cached }
          else {
            let one-line = measure(par(spacing: 0pt)[x]).height
            measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
          }
        }
        let par_height = measure(final_par, width: available_width).height
        let estimated_lines = calc.ceil(par_height / line_height)

        if estimated_lines < 4 {
          block(sticky: true)[#final_par]
        } else {
          block(breakable: true)[#final_par]
        }
      } else {
        block[#final_par]
      }
    }
  }
}
