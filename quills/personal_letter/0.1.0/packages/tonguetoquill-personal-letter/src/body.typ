// body.typ — paragraph body rendering for AFH 33-337 Ch. 15 personal letter
//
// Rules (Ch. 15 "The Text of the Personal Letter"):
//   • Do not number paragraphs.
//   • Indent the first line of each major paragraph 0.5 inches.
//   • All second and subsequent lines are flush with the left margin.
//   • Sub-paragraphs follow the same numbering/indentation as the memo
//     (a., (1), (a) … starting at 0.5 in from the left).

#import "config.typ": PARA_INDENT, SUBPAR_FORMATS, spacing
#import "utils.typ": *

// ---------------------------------------------------------------------------
// Table styling (inherited from memo conventions — no specific Ch.15 rule)
// ---------------------------------------------------------------------------
#let render-table(it) = {
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(stroke: 0.5pt + black, inset: (x: 0.5em, y: 0.4em))
  it
}

// ---------------------------------------------------------------------------
// render-body
// ---------------------------------------------------------------------------
#let render-body(content) = {
  // ── State / counters ──────────────────────────────────────────────────────
  let BUF          = state("PL_BUF")
  let NEST_DOWN    = counter("PL_ND")
  let NEST_UP      = counter("PL_NU")
  let IS_HEADING   = state("PL_HEADING")
  let FIRST_IN_ITEM= state("PL_FIRST")
  BUF.update(())
  NEST_DOWN.update(0)
  NEST_UP.update(0)
  IS_HEADING.update(false)
  FIRST_IN_ITEM.update(false)

  // ── First pass: collect paragraphs into BUF ───────────────────────────────
  let first_pass = {
    show par: p => context {
      let level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let heading = IS_HEADING.get()
      let first   = FIRST_IN_ITEM.get()
      let cont    = level > 0 and not first

      BUF.update(buf => {
        buf.push((
          content:   text([#p.body]),
          level:     level,
          kind:      if heading { "heading" } else if cont { "cont" } else { "par" },
        ))
        buf
      })
      if level > 0 and first { FIRST_IN_ITEM.update(false) }
      p
    }

    show table: t => context {
      BUF.update(buf => { buf.push((content: t, level: -1, kind: "table")); buf })
      t
    }

    {
      show heading: h => {
        IS_HEADING.update(true)
        [#parbreak()#h.body#parbreak()]
        IS_HEADING.update(false)
      }
      show list.item: it => {
        NEST_DOWN.step()
        FIRST_IN_ITEM.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      show enum.item: it => {
        NEST_DOWN.step()
        FIRST_IN_ITEM.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      {
        // Ensure show-par fires even for inline-only content (Typst quirk).
        show strong:    it => [#it#sym.zws]
        show emph:      it => [#it#sym.zws]
        show underline: it => [#it#sym.zws]
        show raw:       it => [#it#sym.zws]
        [#content#parbreak()]
      }
    }
  }
  place(hide(first_pass))

  // ── Second pass: render collected items ───────────────────────────────────
  context {
    let items = BUF.get().filter(it =>
      it.kind == "table" or measure(it.content).width > 0pt
    )
    if items.len() == 0 { return }

    let max-lvl = SUBPAR_FORMATS.len()
    let counts  = (:)
    for i in range(max-lvl) { counts.insert(str(i), 1) }

    let heading-buf = none
    let emitted     = false
    let total       = items.len()
    let idx         = 0

    for item in items {
      idx += 1
      let kind    = item.kind
      let body    = item.content
      let level   = item.level

      // Buffer headings to prepend to the next non-heading element.
      if kind == "heading" {
        heading-buf = body
        continue
      }

      // Prepend any buffered heading as bold text.
      if heading-buf != none {
        if kind == "table" {
          blank-line()
          strong[#heading-buf.]
          heading-buf = none
        } else {
          body = [#strong[#heading-buf.] #body]
          heading-buf = none
        }
      }

      let final = {
        if kind == "table" {
          render-table(body)

        } else if kind == "cont" {
          // Continuation line within a multi-block list item.
          if level <= 0 {
            body  // top-level continuation: flush left
          } else {
            render-subpar(body, level, counts, continuation: true)
          }

        } else if level <= 0 {
          // Top-level paragraph: unnumbered, first-line indent.
          // Reset nested counters so each new main paragraph restarts sub-numbering.
          counts = reset-counts-from(counts, 1, max-lvl)
          [#h(PARA_INDENT)#body]

        } else {
          // Sub-paragraph: numbered per memo rules (a., (1), …)
          let par = render-subpar(body, level, counts)
          counts.insert(str(level), counts.at(str(level), default: 1) + 1)
          counts = reset-counts-from(counts, level + 1, max-lvl)
          par
        }
      }

      // ── Orphan prevention (same rule as the memo) ──────────────────────
      if emitted { blank-line() }
      emitted = true

      if idx == total {
        // Last paragraph: keep short ones sticky with the signature block.
        let avail = page.width - spacing.margin * 2
        let lh = {
          let s = LINE_STRIDE.get()
          if s != none { s } else {
            let h = measure(par(spacing: 0pt)[x]).height
            measure(par(spacing: 0pt)[x#linebreak()x]).height - h
          }
        }
        let lines = calc.ceil(measure(final, width: avail).height / lh)
        if lines < 4 {
          block(sticky: true)[#final]
        } else {
          block(breakable: true)[#final]
        }
      } else {
        block[#final]
      }
    }
  }
}
