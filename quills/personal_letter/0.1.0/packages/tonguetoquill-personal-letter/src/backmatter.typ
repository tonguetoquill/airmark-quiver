// backmatter.typ — closing section for AFH 33-337 Ch. 15 personal letter
//
// Placement (Ch. 15 "The Closing Section"):
//
//   [body ends]
//   [1 blank line]     "second line below the text"
//   Sincerely          — 4.5 in from left edge
//   [4 blank lines]    "fifth line below" the complimentary close
//   [Signature block]  — aligned at 4.5 in from left edge
//   [2 blank lines]    "third line below the signature element"
//   Attachment: / # Attachments:   — flush left
//   [1 blank line]     "second line below the attachment element"
//   cc:                — flush left
//   (if no attachment: cc: is on the third line below the signature = 2 blank lines)

#import "config.typ": CLOSE_LEFT, spacing
#import "utils.typ": *

// ---------------------------------------------------------------------------
// Complimentary close
// ---------------------------------------------------------------------------
// Ch. 15: "Place 'Sincerely' on the second line below the text and
// 4.5 inches from the left edge of the page … Do not punctuate."
#let render-close() = {
  let left-pad = CLOSE_LEFT - spacing.margin
  align(left)[#pad(left: left-pad)[Sincerely]]
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------
// Ch. 15: "Place the signature element on the fifth line below and aligned
// with the complimentary close (4.5 inches from the left edge of the page).
// Use the sender's full signature block."
//
// The 4-blank-line gap ("fifth line below") is generated here before the block.
#let render-signature(lines, blank-before: 4, signing-field: none) = {
  lines = ensure-array(lines)
  blank-lines(blank-before)

  let pad-default = CLOSE_LEFT - spacing.margin
  context {
    let body-width = page.width - 2 * spacing.margin
    let widest = 0pt
    for l in lines {
      let w = measure(text(hyphenate: false, l)).width
      if w > widest { widest = w }
    }
    let avail = body-width - pad-default
    let left-pad = if widest > avail {
      let shifted = body-width - widest
      if shifted < 0pt { 0pt } else { shifted }
    } else {
      pad-default
    }

    block(breakable: false)[
      #if signing-field != none {
        let s = LINE_STRIDE.get()
        let stride = if s != none { s } else {
          let h = measure(par(spacing: 0pt)[x]).height
          measure(par(spacing: 0pt)[x#linebreak()x]).height - h
        }
        place(
          dx: left-pad,
          dy: -(stride * blank-before),
          box(width: body-width - left-pad, height: stride * blank-before, signing-field),
        )
      }
      #align(left)[
        #pad(left: left-pad)[
          #text(hyphenate: false)[
            #for l in lines { par(hanging-indent: .5em, l) }
          ]
        ]
      ]
    ]
  }
}

// ---------------------------------------------------------------------------
// Attachment and cc: elements
// ---------------------------------------------------------------------------
#let render-section(content, label, num-style: none, cont-label: none) = {
  let body = {
    text()[#label]
    linebreak()
    if num-style != none {
      enum(..ensure-array(content), numbering: num-style)
    } else {
      ensure-string(content)
    }
  }
  context {
    let space = page.height - here().position().y - 1in
    if measure(body).height > space {
      let cont = if cont-label != none { text()[#cont-label] }
                 else { text()[#(label + " (continued on next page)")] }
      cont
      pagebreak()
    }
    body
  }
}

#let render-backmatter(attachments: none, cc: none) = {
  let has-atch = attachments != none and attachments.len() > 0
  let has-cc   = cc          != none and cc.len()          > 0

  if has-atch {
    blank-lines(2)  // 3rd line below signature
    let n = attachments.len()
    let lbl  = if n == 1 { "Attachment:" } else { str(n) + " Attachments:" }
    let cont = if n == 1 { "Attachment (listed on next page):" }
               else { str(n) + " Attachments (listed on next page):" }
    render-section(attachments, lbl,
      num-style: if n == 1 { none } else { "1." },
      cont-label: cont)
  }

  if has-cc {
    // 2nd line below attachment, or 3rd line below signature if no attachment.
    if has-atch { blank-line() } else { blank-lines(2) }
    render-section(cc, "cc:")
  }
}

// ---------------------------------------------------------------------------
// Public function
// ---------------------------------------------------------------------------
#let backmatter(
  signature_block: none,
  signing_field:   none,
  attachments:     none,
  cc:              none,
) = {
  // "second line below the text" — 1 blank line before "Sincerely"
  blank-line()
  render-close()

  // "fifth line below the complimentary close" — 4 blank lines + sig block
  render-signature(signature_block, blank-before: 4, signing-field: signing_field)

  render-backmatter(attachments: attachments, cc: cc)
}
