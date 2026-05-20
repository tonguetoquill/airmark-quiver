// primitives.typ: Rendering primitives for personal letter (AFH 33-337 Ch. 15)

#import "config.typ": *
#import "utils.typ": *

// =============================================================================
// LETTERHEAD
// =============================================================================

#let render-letterhead(
  title,
  caption,
  font,
  letterhead-seal: none,
  letterhead-seal-subtitle: none,
  letterhead-emblem: none,
) = {
  font = ensure-array(font)
  title = ensure-string(title)
  caption = ensure-string(caption)
  title = upper(title)
  caption = upper(caption)

  place(
    dy: 0.625in - spacing.margin,
    box(
      width: 100%,
      fill: none,
      stroke: none,
      [
        #place(
          center + top,
          align(center)[
            #set text(12pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
            #title\
            #v(1pt)
            #text(10.5pt)[#caption]
          ],
        )
      ],
    ),
  )

  if letterhead-seal != none {
    let seal-body = if falsey(letterhead-seal-subtitle) {
      block[#fit-box(width: 2in, height: 1in)[#letterhead-seal]]
    } else {
      block[
        #set text(9pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
        #stack(
          spacing: 0.5em,
          fit-box(width: 2in, height: 1in)[#letterhead-seal],
          box(upper(ensure-string(letterhead-seal-subtitle))),
        )
      ]
    }
    place(left + top, dx: -0.5in, dy: -.5in, seal-body)
  }

  if letterhead-emblem != none {
    place(
      right + top,
      dx: 0.5in,
      dy: -.5in,
      block[#fit-box(width: 2in, height: 1in, alignment: right + horizon)[#letterhead-emblem]],
    )
  }
}

// =============================================================================
// HEADING SECTION (AFH 33-337 Ch. 15 "The Heading Section")
// =============================================================================

// AFH 33-337 Ch. 15 "Date": "Place the date 1 inch from the right edge,
// 1.75 inches from the top of the page."
#let render-date-section(date, addressee-type: "military") = {
  align(right)[#display-date(date, addressee-type: addressee-type)]
}

// AFH 33-337 Ch. 15 "Return Address": "Place the sender's return address flush
// with the left margin on the second line below the date."
#let render-return-address(lines) = {
  lines = ensure-array(lines)
  for (i, line) in lines.enumerate() {
    [#line]
    if i < lines.len() - 1 { linebreak() }
  }
}

// AFH 33-337 Ch. 15 "Receiver's Address": "Place the address of the individual
// the letter is being sent to on the third line below the return address."
#let render-receiver-address(lines) = {
  lines = ensure-array(lines)
  for (i, line) in lines.enumerate() {
    [#line]
    if i < lines.len() - 1 { linebreak() }
  }
}

// AFH 33-337 Ch. 15 "Salutation": "Place the salutation on the second line
// below the receiver's address." Begins with "Dear"; no punctuation after.
#let render-salutation(salutation) = {
  [#salutation]
}

// =============================================================================
// CLOSING SECTION
// =============================================================================

// AFH 33-337 Ch. 15 "Complimentary Close": "Place 'Sincerely' on the second
// line below the text and 4.5 inches from the left edge of the page or three
// spaces to the right of page center. Do not punctuate the complimentary close."
#let render-complimentary-close() = {
  let left-pad = SIGNATURE_LEFT - spacing.margin
  align(left)[
    #pad(left: left-pad)[Sincerely]
  ]
}

// AFH 33-337 Ch. 15 "Signature Element": "Place the signature element on the
// fifth line below and aligned with the complimentary close (4.5 inches from
// the left edge of the page). Use the sender's full signature block."
#let render-signature-block(signature-lines, signature-blank-lines: 4, signing-field: none) = {
  signature-lines = ensure-array(signature-lines)
  blank-lines(signature-blank-lines)
  let default-pad = SIGNATURE_LEFT - spacing.margin
  context {
    let body-width = page.width - 2 * spacing.margin
    let widest = 0pt
    for line in signature-lines {
      let w = measure(text(hyphenate: false, line)).width
      if w > widest { widest = w }
    }
    let available = body-width - default-pad
    let left-pad = if widest > available {
      let shifted = body-width - widest
      if shifted < 0pt { 0pt } else { shifted }
    } else {
      default-pad
    }
    block(breakable: false)[
      #if signing-field != none {
        let stride = {
          let s = LINE_STRIDE.get()
          if s == none {
            let one-line = measure(par(spacing: 0pt)[x]).height
            measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
          } else { s }
        }
        place(
          dx: left-pad,
          dy: -(stride * signature-blank-lines),
          box(width: body-width - left-pad, height: stride * signature-blank-lines, signing-field),
        )
      }
      #align(left)[
        #pad(left: left-pad)[
          #text(hyphenate: false)[
            #for line in signature-lines {
              par(hanging-indent: .5em, line)
            }
          ]
        ]
      ]
    ]
  }
}

// =============================================================================
// BACKMATTER SECTIONS (Attachment and cc:)
// =============================================================================
// AFH 33-337 Ch. 15 "Attachment Element": "Place 'Attachment:' (single) or
// '# Attachments:' (two or more) flush with the left margin, on the third
// line below the signature element."
// AFH 33-337 Ch. 15 "Courtesy Copy Element": "place 'cc:' flush with the
// left margin, on the second line below the attachment element. If the
// attachment element is not used, place 'cc:' on the third line below the
// signature element."

#let render-backmatter-section(
  content,
  section-label,
  numbering-style: none,
  continuation-label: none,
) = {
  let formatted-content = {
    text()[#section-label]
    linebreak()
    if numbering-style != none {
      let items = ensure-array(content)
      enum(..items, numbering: numbering-style)
    } else {
      ensure-string(content)
    }
  }

  context {
    let available-space = page.height - here().position().y - 1in
    if measure(formatted-content).height > available-space {
      let continuation-text = if continuation-label != none {
        text()[#continuation-label]
      } else {
        text()[#(section-label + " (continued on next page)")]
      }
      continuation-text
      pagebreak()
    }
    formatted-content
  }
}

#let render-personal-letter-backmatter(
  attachments: none,
  cc: none,
) = {
  let has-attachments = attachments != none and attachments.len() > 0
  let has-cc = cc != none and cc.len() > 0

  if has-attachments {
    // 3rd line below signature = 2 blank lines
    blank-lines(2)
    let count = attachments.len()
    let label = if count == 1 { "Attachment:" } else { str(count) + " Attachments:" }
    let continuation-label = (
      (if count == 1 { "Attachment" } else { str(count) + " Attachments" })
        + " (listed on next page):"
    )
    let numbering-style = if count == 1 { none } else { "1." }
    render-backmatter-section(
      attachments,
      label,
      numbering-style: numbering-style,
      continuation-label: continuation-label,
    )
  }

  if has-cc {
    if has-attachments {
      // 2nd line below attachment = 1 blank line
      blank-line()
    } else {
      // 3rd line below signature = 2 blank lines
      blank-lines(2)
    }
    render-backmatter-section(cc, "cc:")
  }
}

// =============================================================================
// TABLE RENDERING
// =============================================================================

#let render-memo-table(it) = {
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(stroke: 0.5pt + black, inset: (x: 0.5em, y: 0.4em))
  it
}
