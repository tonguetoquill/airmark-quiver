// primitives.typ: Reusable rendering primitives for USAF personal letter sections
//
// This module implements the visual rendering functions that produce AFH 33-337
// "The Personal Letter" compliant formatting. Inch and line-space anchors are
// cross-referenced to AFMAN 33-326 §4.1 ("Personalized Letter"), which states
// the same layout in measurable terms.
//
// AF correspondence counts line spaces inclusively: an element "on the second
// line below" another has exactly one blank line between them ("Double space
// equal 1 blank line" — AFH 33-337 personal letter figure note).

#import "config.typ": *
#import "utils.typ": *

// =============================================================================
// LETTERHEAD RENDERING
// =============================================================================
// AFH 33-337 "The Personal Letter": "Personal letters are usually prepared on
// letterhead stationery". Geometry mirrors the tonguetoquill-usaf-memo
// letterhead so both formats share identical stationery.

#let render-letterhead(
  title,
  caption,
  font,
  letterhead-seal: none,
  letterhead-seal-subtitle: none,
) = {
  font = ensure-array(font)
  title = upper(ensure-string(title))
  caption = upper(ensure-string(caption))

  // Letterhead corner geometry: the seal bleeds `corner-overhang` past the
  // page margin and centers on the title band.
  let corner-overhang = 0.5in
  let corner-width = 2in
  let band-height = 1in
  let band-top = -band-height / 2

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
      block[
        #fit-box(width: corner-width, height: band-height)[#letterhead-seal]
      ]
    } else {
      // Isolate seal column from document `font_size`: stack `em` spacing and
      // subtitle must not scale with body text. Subtitle is boxed so it stays
      // on one line and may extend past the seal's 2in column.
      block[
        #set text(9pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
        #stack(
          spacing: 0.5em,
          fit-box(width: corner-width, height: band-height)[#letterhead-seal],
          box(upper(ensure-string(letterhead-seal-subtitle))),
        )
      ]
    }
    place(
      left + top,
      dx: -corner-overhang,
      dy: band-top,
      seal-body,
    )
  }
}

// =============================================================================
// HEADING SECTION
// =============================================================================
// AFH 33-337 "The Personal Letter" heading:
// - Date: right side, 1.75 inches (10 line spaces) from the top of the page
// - Sender's address element: flush left below the date
// - Receiver's address element: below the sender's address
// - Salutation: "Dear" + title and last name, no trailing punctuation

// AFMAN 33-326 §4.1.1.1: "Type the date flush with the right margin"
#let render-date-element(date) = {
  align(right)[#display-date(date)]
}

// Address elements are flush left, one line per entry, no terminal punctuation.
// AFMAN 33-326 §4.1.1.2-.3: sender includes name, rank, duty title, and
// complete mailing address; receiver includes title/rank and full name along
// with the complete mailing address (rank never abbreviated).
#let render-address-element(lines) = {
  lines = ensure-array(lines)
  par(lines.map(line => ensure-string(line)).join(linebreak()))
}

// AFH 33-337: 'The salutation is normally in the format "Dear Xxxxx"' with no
// punctuation after. The caller supplies the full salutation line.
#let render-salutation(salutation) = {
  par(ensure-string(salutation))
}

// =============================================================================
// CLOSING SECTION
// =============================================================================
// AFH 33-337 "The Personal Letter":
// - Complimentary close "Sincerely" on the second line below the text, three
//   spaces to the right of page center (4.5in from the left page edge), with
//   no punctuation after it
// - Signature element on the fifth line below, aligned with the close; name
//   in uppercase, grade spelled out, service; no duty title (AFMAN 33-326
//   §4.1.3.3: "without the title portion")
// - No authority line (AFMAN 33-326 §4.1.3.2)

#let render-closing(
  close,
  signature-lines,
  signature-blank-lines: 4,
  signing-field: none,
) = {
  signature-lines = ensure-array(signature-lines)
  // Close sits on the second line below the text = 1 blank line.
  blank-line()
  let default-pad = CLOSING_ANCHOR - spacing.margin
  context {
    // Measure the close and every signature line at rendered settings to
    // detect long-name overflow. The signature element must stay aligned with
    // the close, so a long name shifts the whole closing block left together.
    let body-width = page.width - 2 * spacing.margin
    let widest = measure(text(hyphenate: false, ensure-string(close))).width
    for line in signature-lines {
      let w = measure(text(hyphenate: false, line)).width
      if w > widest { widest = w }
    }
    // Shift left just enough to fit; clamp at 0 so the block never crosses
    // the left margin.
    let available = body-width - default-pad
    let left-pad = if widest > available {
      let shifted = body-width - widest
      if shifted < 0pt { 0pt } else { shifted }
    } else {
      default-pad
    }
    let stride = {
      let s = LINE_STRIDE.get()
      if s == none {
        let one-line = measure(par(spacing: 0pt)[x]).height
        measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
      } else { s }
    }
    // breakable: false keeps the close, the signing gap, and the typed
    // signature element on one page.
    block(breakable: false)[
      #align(left)[
        #pad(left: left-pad)[
          #par(ensure-string(close))
        ]
      ]
      // Signature element on the fifth line below the close = 4 blank lines.
      #v(stride * signature-blank-lines)
      #if signing-field != none {
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
              // Long lines wrap with a small hanging indent so turnover text
              // starts under the third character of the line above.
              par(hanging-indent: .5em, line)
            }
          ]
        ]
      ]
    ]
  }
}

// =============================================================================
// TABLE RENDERING
// =============================================================================
// AFH 33-337 does not specify table formatting; follow the same plain style
// used by the memo package: 0.5pt black borders, bold header row.

#let render-letter-table(it) = {
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    stroke: 0.5pt + black,
    inset: (x: 0.5em, y: 0.4em),
  )
  it
}

// =============================================================================
// BACKMATTER SECTIONS
// =============================================================================
// AFMAN 33-326 §4.1.3.4-.5 (mirroring the official memorandum's closing
// section): "Attachment:"/"Attachments:" flush with the left margin, three
// line spaces after the signature element; "cc:" flush with the left margin,
// two line spaces below the attachment element (or three line spaces after
// the signature element when there is no attachment element).

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

#let calculate-backmatter-spacing(is-first-section) = {
  context {
    let line_count = if is-first-section { 2 } else { 1 }
    blank-lines(line_count)
  }
}

#let render-backmatter-sections(
  attachments: none,
  cc: none,
) = {
  if attachments != none and attachments.len() > 0 {
    calculate-backmatter-spacing(true)
    let attachment-count = attachments.len()
    let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
    let continuation-label = (
      (if attachment-count == 1 { "Attachment" } else { str(attachment-count) + " Attachments" })
        + " (listed on next page):"
    )
    // A single attachment is not numbered; numbering applies to two or more.
    let numbering-style = if attachment-count == 1 { none } else { "1." }
    render-backmatter-section(attachments, section-label, numbering-style: numbering-style, continuation-label: continuation-label)
  }

  if cc != none and cc.len() > 0 {
    calculate-backmatter-spacing(attachments == none or attachments.len() == 0)
    render-backmatter-section(cc, "cc:")
  }
}
