// body.typ: Paragraph body rendering for the USAF personal letter
//
// This module implements AFH 33-337 "The Text of the Personal Letter":
// - Text is single-spaced with one blank line between paragraphs
// - Paragraphs are never numbered
// - Major paragraphs indent the first line 0.5 inch; subparagraphs indent an
//   additional 0.5 inch per nesting level (AFMAN 33-326 §4.1.2)
//
// The two-pass collection architecture is shared with tonguetoquill-usaf-memo:
// the first hidden pass flattens markdown-converted paragraphs, list items,
// and tables into a buffer; the second pass re-emits them with letter
// formatting applied.

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": render-letter-table

/// Calculates the first-line indent for a letter paragraph.
///
/// Level 0 (major paragraph) indents 0.5in; each nesting level adds 0.5in.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> length
#let calculate-letter-indent(level) = {
  letter-paragraph.first-line-indent + calc.max(0, level) * letter-paragraph.nested-step
}

// AFH 33-337 "The Text of the Personal Letter" rendering
#let render-body(content) = {
  let PAR_BUFFER = state("PAR_BUFFER")
  PAR_BUFFER.update(())
  let NEST_DOWN = counter("NEST_DOWN")
  NEST_DOWN.update(0)
  let NEST_UP = counter("NEST_UP")
  NEST_UP.update(0)
  let IS_HEADING = state("IS_HEADING")
  IS_HEADING.update(false)

  // The first pass parses paragraphs, list items, etc. into standardized arrays
  let first_pass = {
    // Collect pars with nesting level
    show par: p => context {
      let nest_level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let is_heading = IS_HEADING.get()

      PAR_BUFFER.update(pars => {
        pars.push((
          content: text([#p.body]),
          nest_level: nest_level,
          kind: if is_heading { "heading" } else { "par" },
        ))
        pars
      })

      p
    }
    // Collect tables — captured as-is without paragraph indentation
    show table: t => context {
      PAR_BUFFER.update(pars => {
        pars.push((
          content: t,
          nest_level: -1,
          kind: "table",
        ))
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

      // Convert list/enum items to pars. Personal letters never number or
      // letter their paragraphs, so enum and list items both become plain
      // indented subparagraphs.
      show enum.item: it => {
        NEST_DOWN.step()
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      show list.item: it => {
        NEST_DOWN.step()
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }

      {
        // Typst bug bandaid:
        // `show par` will not collect wrappers unless there is content outside
        // Add zero width space to always have content outside of wrapper
        show strong: it => {
          [#it#sym.zws]
        }
        show emph: it => {
          [#it#sym.zws]
        }
        show underline: it => {
          [#it#sym.zws]
        }
        show raw: it => {
          [#it#sym.zws]
        }
        [#content#parbreak()]
      }
    }
  }
  // Use place() to prevent hidden content from affecting layout flow
  place(hide(first_pass))

  // Second pass: consume par buffer
  //
  // PAR_BUFFER item dictionary layout:
  //   item.content    — the paragraph body or table element
  //   item.nest_level — nesting depth (−1 for tables)
  //   item.kind       — "par", "heading", or "table"
  context {
    let heading_buffer = none
    // Filter out zero-width paragraphs so that an empty body emits nothing
    // and collapses to zero vertical space. Tables are always kept.
    let items = PAR_BUFFER.get().filter(item =>
      item.kind == "table" or measure(item.content).width > 0pt
    )
    if items.len() == 0 { return }
    let total_count = items.len()

    let i = 0
    let any_emitted = false
    for item in items {
      i += 1
      let kind = item.kind
      let item_content = item.content

      // Buffer headings for prepend to the next rendered element
      if kind == "heading" {
        heading_buffer = item_content
        continue
      }

      // Prepend buffered heading to the next non-heading element
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

      let final_par = {
        if kind == "table" {
          render-letter-table(item_content)
        } else {
          // AFH 33-337: paragraphs are unnumbered with a first-line indent;
          // subparagraphs indent an additional 0.5in per level.
          [#h(calculate-letter-indent(item.nest_level))#item_content]
        }
      }

      // Blank line between paragraphs. The salutation→text gap (before the
      // first emitted paragraph) is the caller's responsibility.
      if any_emitted { blank-line() }
      any_emitted = true
      if i == total_count {
        let available_width = page.width - spacing.margin * 2

        // Use the shared measured line stride used by blank-line spacing.
        let line_height = {
          let cached = LINE_STRIDE.get()
          if cached != none {
            cached
          } else {
            let one-line = measure(par(spacing: 0pt)[x]).height
            measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
          }
        }
        let par_height = measure(final_par, width: available_width).height
        let estimated_lines = calc.ceil(par_height / line_height)

        if estimated_lines < 4 {
          // Short content (< 4 lines): make sticky to keep with the closing
          block(sticky: true)[#final_par]
        } else {
          // Longer content (≥ 4 lines): use default breaking behavior
          block(breakable: true)[#final_par]
        }
      } else {
        // Wrap every non-last emission in a plain block so the document-wide
        // `set block(above: spacing.line)` rule contributes the same 0.5em
        // gap above every paragraph.
        block[#final_par]
      }
    }
  }
}
