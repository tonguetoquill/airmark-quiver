// The agreement's closing section: a signature block for every signer, laid
// out as AFH 33-337 lays out dual signatures. Signers come junior to senior.
// Each row pairs the junior at the left margin with the senior at 4.5in from
// the left edge; with an odd count, the last and most senior signer stands
// alone at 4.5in. Rows stack down the page, and the attachment, cc and
// distribution elements follow the last row as they follow a memo's signature.

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

// One signer: `lines` is the signature block, `signing-field` an optional
// widget over the blank lines above it, `date` an optional date or fill-in
// slot printed on a "Date:" line below it.
#let render-signer(signer, width, stride, signature-blank-lines) = {
  let lines = ensure-array(signer.at("lines", default: ()))
  let signing-field = signer.at("signing-field", default: none)
  let date = signer.at("date", default: none)
  let gap = stride * signature-blank-lines
  block(width: width, breakable: false, above: 0pt, below: 0pt)[
    #if signing-field != none {
      let widget-height = {
        let h = measure(signing-field).height
        if h > 0pt { h } else { 50pt }
      }
      let drop = gap - widget-height - 3pt
      place(
        dy: if drop > 0pt { drop } else { 0pt },
        box(width: width, height: widget-height, signing-field),
      )
    }
    #v(gap)
    #text(hyphenate: false)[
      #for line in lines {
        let clusters = plain-text(line).clusters()
        let lead = clusters.slice(0, calc.min(2, clusters.len())).join()
        par(hanging-indent: measure(lead).width, line)
      }
      #if date != none {
        v(stride)
        par[Date: #date]
      }
    ]
  ]
}

#let agreement-backmatter(
  // Each: (lines: array, signing-field: content or none, date: content or none).
  signers: (),
  signature-blank-lines: 4,
  attachments: none,
  cc: none,
  distribution: none,
) = [#{
  // An added signer with no lines yet still holds a row: dropping one would
  // slide the senior signer onto the left margin. A blank name prints nothing;
  // the four lines and the signing field above it are the signature itself.
  let signers = ensure-array(signers)
  let has-backmatter = (
    (attachments != none and attachments.len() > 0)
      or (cc != none and cc.len() > 0)
      or (distribution != none and distribution.len() > 0)
  )
  // Pairs from the top, so an odd signer out is the last, most senior one.
  let rows = range(0, signers.len(), step: 2).map(i => signers.slice(i, calc.min(i + 2, signers.len())))
  context {
    let stride = line-stride()
    let body-width = page.width - 2 * spacing.margin
    let senior-pad = 4.5in - spacing.margin
    // A quarter inch keeps the junior's widget clear of the senior's.
    let junior-width = senior-pad - 0.25in
    let senior-width = body-width - senior-pad
    // No row to carry the anchor. A list that starts the next page is still
    // noted from the line it follows, and the reservation is reclaimed so the
    // list does not drop.
    if rows.len() == 0 and has-backmatter {
      block(breakable: false, above: 0pt, below: 0pt)[
        #metadata(none)<usaf-memo-flow-anchor>
        #v(stride * 3)
      ]
      v(stride * -3)
    }
    for (r, row) in rows.enumerate() {
      let last = r == rows.len() - 1
      // Lines reserved below the last row for the first backmatter lead-in
      // and its continuation note; reclaimed right after the row.
      let reserved = if last and has-backmatter { 3 } else { 0 }
      let (junior, senior) = if row.len() == 2 { (row.at(0), row.at(1)) } else { (none, row.at(0)) }
      block(breakable: false)[
        #grid(
          columns: (senior-pad, senior-width),
          if junior != none { render-signer(junior, junior-width, stride, signature-blank-lines) } else { [] },
          render-signer(senior, senior-width, stride, signature-blank-lines),
        )
        // The page the backmatter compares its own against. Inside the
        // unbreakable row, so it stays with the signatures.
        #metadata(none)<usaf-memo-flow-anchor>
        #v(stride * reserved)
      ]
      v(stride * -reserved)
    }
  }
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
  )
}<usaf-memo-closing>]
