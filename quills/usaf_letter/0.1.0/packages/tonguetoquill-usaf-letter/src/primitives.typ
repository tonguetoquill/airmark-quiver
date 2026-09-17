// One rendering function per element of the personal letter, each placing its
// element where AFH 33-337 "The Personal Letter" puts it.

#import "config.typ": *
#import "utils.typ": *

// AFH 33-337 requires approved organizational letterhead and does not specify
// its placement; the geometry below follows standard USAF convention, and is
// the geometry the official memorandum is set on.
#let render-letterhead(
  title,
  caption,
  font,
  letterhead-seal: none,
  letterhead-seal-subtitle: none, // optional line under seal (9pt bold caps); ignored if no seal
) = {
  font = ensure-array(font)
  // `upper` takes content as readily as `str`, so the letterhead's uppercasing
  // survives a title or caption handed over as markup.
  title = upper(join-lines(title))
  caption = upper(join-lines(caption))

  // Seal geometry: the seal bleeds `corner-overhang` past the page margin and
  // centers on a band whose center sits at dy 0.
  let corner-overhang = 0.5in
  let corner-width = 2in
  let band-height = 1in
  let band-top = -band-height / 2

  // The centered title/caption is placed content (not width-constrained), so a
  // long caption would otherwise render on one line and run underneath the seal.
  // Bound the caption to the width that stays clear of the seal on both sides
  // and auto-shrink it to fit: the seal reaches `band-height - corner-overhang`
  // into the text area, so reserving that plus a gutter on each side keeps the
  // centered caption from touching the seal. `layout` resolves the text-area
  // width so the bound tracks the page/margins.
  let caption-gutter = 0.25in
  let caption-clear = (band-height - corner-overhang) + caption-gutter
  place(
    dy: 0.625in - spacing.margin,
    box(
      width: 100%,
      fill: none,
      stroke: none,
      layout(size => place(
        center + top,
        align(center)[
          #set text(12pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
          #title\
          #v(1pt)
          #if not falsey(caption) {
            fit-to-width(
              size.width - 2 * caption-clear,
              alignment: center,
              box(text(10.5pt)[#caption]),
            )
          }
        ],
      )),
    ),
  )

  if letterhead-seal != none {
    let seal-body = if falsey(letterhead-seal-subtitle) {
      block[
        #fit-box(width: corner-width, height: band-height)[#letterhead-seal]
      ]
    } else {
      // Isolate the seal column from the document `font-size`: the stack's `em`
      // spacing and the subtitle must not scale with body text. The subtitle is
      // wrapped in `box` so it stays on one line and may extend past the seal's
      // 2in column rather than wrapping.
      block[
        #set text(9pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
        // Spacing applies between positional stack children only, not one `[…]` body.
        #stack(
          spacing: 0.5em,
          fit-box(width: corner-width, height: band-height)[#letterhead-seal],
          box(upper(join-lines(letterhead-seal-subtitle))),
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

// AFH 33-337: "Place the date on the first line of the upper-right hand corner
// so that the date is flush with the right margin."
#let render-date-section(date) = {
  align(right)[#display-date(date)]
}

/// One stacked block of address lines, flush with the left margin.
///
/// AFH 33-337 gives the sender's block the second line below the date and the
/// receiver's the third line below the sender's last line, so the gap above is
/// the caller's.
///
/// - lines (str | content | array): Address lines, top to bottom
/// -> content
#let render-address-block(lines) = {
  join-lines(lines)
}

// AFH 33-337: the salutation sits on the second line below the receiver's
// address, and takes no punctuation after the receiver's last name.
#let render-salutation(salutation) = {
  blank-line()
  [#salutation]
}

// AFH 33-337: "The signature block for the personal letter is placed on the
// fifth line below the complimentary close", which itself sits on the second
// line below the last line of text. The block is anchored 4.5 inches from the
// left edge of the page — the Word template's 3.5-inch indent inside a 1-inch
// margin — and the complimentary close shares that anchor.
// AFH 33-337: "Do not place the signature element on a continuation page by
// itself."
#let render-signature-block(
  signature-lines,
  closing-line: none,
  signature-blank-lines: 4,
  signing-field: none,
) = {
  signature-lines = ensure-array(signature-lines)
  if falsey(closing-line) { closing-line = none }
  // `pad` is relative to the text area, hence (4.5in - margin).
  let default-pad = 4.5in - spacing.margin
  context {
    // Measure each line at its rendered settings to detect long-name overflow.
    // The closing line shares the anchor, so it joins the measurement: the
    // wider of the two decides the shift and they stay aligned.
    let body-width = page.width - 2 * spacing.margin
    let anchored-lines = signature-lines
    if closing-line != none { anchored-lines.push(closing-line) }
    let widest = 0pt
    for line in anchored-lines {
      let w = measure(text(hyphenate: false, line)).width
      if w > widest { widest = w }
    }
    let stride = line-stride()
    // If the widest line would overflow the right margin at the standard
    // anchor, shift the block left just enough to fit. Clamp at 0 so the
    // block never crosses the left margin.
    let available = body-width - default-pad
    let left-pad = if widest > available {
      let shifted = body-width - widest
      if shifted < 0pt { 0pt } else { shifted }
    } else {
      default-pad
    }
    block(breakable: false)[
      #let gap = stride * signature-blank-lines
      // The four blank lines between the close and the name are carried INSIDE
      // the unbreakable block rather than emitted ahead of it, which keeps the
      // gap and the block one indivisible unit. The total space above the block
      // is identical either way — `block.above` still contributes the same
      // 0.5em — but a gap left outside can be consumed at the foot of one page
      // while the block starts at the top margin of the next.
      //
      // The close takes one of the lines above it and the gap then measures
      // from the close, not from the text.
      #if closing-line != none {
        v(stride)
        pad(left: left-pad, text(hyphenate: false, closing-line))
      }
      #if signing-field != none {
        // The signing field covers those blank lines — where a signature is
        // actually written — so it is placed over the gap. It is placed BEFORE
        // the gap is emitted: `place` anchors at the current flow position, so
        // placing it after `v(gap)` anchors the box at the first name line and
        // paints it down over the printed signature block.
        //
        // The widget keeps its own size (the helper's default is 50pt tall and
        // it positions itself, so an `align` around it does nothing) and is
        // offset to the BOTTOM of the gap: it always ends where the printed
        // name begins, and whatever the gap has beyond the widget's height
        // stays clear between the close and the widget's frame.
        let widget-height = {
          let h = measure(signing-field).height
          if h > 0pt { h } else { 50pt }
        }
        let drop = gap - widget-height - 3pt
        place(
          dx: left-pad,
          dy: if drop > 0pt { drop } else { 0pt },
          box(width: body-width - left-pad, height: widget-height, signing-field),
        )
      }
      #v(gap)
      #align(left)[
        #pad(left: left-pad)[
          #text(hyphenate: false)[
            #for line in signature-lines {
              // AFH 33-337: "indent the next line to begin under the third
              // character of the line above" — a 2-character indent is about
              // 1em in Times New Roman 12pt.
              par(hanging-indent: .5em, line)
            }
          ]
        ]
      ]
    ]
  }
}

/// Renders a table in the letter's style.
///
/// AFH 33-337 does not specify table formatting, so this follows the general
/// aesthetic of the standard: plain black borders, a bold header row, no
/// decorative fills, and the body font and size inherited from the surrounding
/// text.
///
/// - it (content): The table element to style and render
/// -> content
#let render-letter-table(it) = {
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    stroke: 0.5pt + black,
    inset: (x: 0.5em, y: 0.4em),
  )
  it
}

#let render-backmatter-section(content, section-label, numbering-style: none) = {
  // `breakable: false` keeps a listed element whole: it moves to the next page
  // rather than splitting across one.
  block(breakable: false)[
    #{
      // `text()` keeps the label from being laid out as a paragraph of its own.
      text()[#section-label]
      linebreak()
      if numbering-style != none {
        enum(..ensure-array(content), numbering: numbering-style)
      } else {
        join-lines(content)
      }
    }
  ]
}

// AFH 33-337: "Attachment:" (for a single attachment) or "# Attachments:" at
// the left margin, on the third line below the signature element; "cc:" on the
// second line below the attachment element, or on the third line below the
// signature element when there is no attachment element.
#let render-backmatter-sections(attachments: none, cc: none) = {
  let sections = ()

  if attachments != none and attachments.len() > 0 {
    let count = attachments.len()
    sections.push((
      content: attachments,
      label: if count == 1 { "Attachment:" } else { str(count) + " Attachments:" },
      // A single attachment is not numbered; numbering applies to two or more.
      numbering-style: if count == 1 { none } else { "1." },
    ))
  }

  if cc != none and cc.len() > 0 {
    sections.push((content: cc, label: "cc:", numbering-style: none))
  }

  for (index, section) in sections.enumerate() {
    blank-lines(if index == 0 { 2 } else { 1 })
    render-backmatter-section(
      section.content,
      section.label,
      numbering-style: section.numbering-style,
    )
  }
}
