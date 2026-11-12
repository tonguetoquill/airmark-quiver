// The face of an official envelope, AFH 33-337 (27 May 2015), chapter 22.
//
// The return address sits in the upper left. OFFICIAL BUSINESS, when the
// writer asked for it, is two lines below that block. The delivery address is
// 12pt Courier, blocked left near the middle of the OCR read area: from 5/8
// inch to 2 3/4 inches off the bottom, half an inch in from each side. The
// upper right is the postage corner and the lower right 4 3/4 by 5/8 inch is
// the barcode clear area. Neither is drawn. A label there is ink the writer
// did not ask for, and the sorter cannot read through it.

#let sizes = (
  "number-10": (9.5in, 4.125in),
  monarch: (7.5in, 3.875in),
  "6x9": (9in, 6in),
  "9x12": (12in, 9in),
  "10x13": (13in, 10in),
)

#let stride = 14pt
#let type-size = 12pt
// AFH 33-337's 1/8 inch corner sits inside a printer's unprintable edge.
#let return-inset = 0.25in
// The stamp or meter occupies the upper right. A return line stops short of it.
#let postage-width = 1.75in
#let ocr-side = 0.5in
#let ocr-bottom = 0.625in
#let ocr-top = 2.75in

// How wide the line's ink is. `measure` reads what prints, so it still
// reports the line when the helper packs a field differently. The width it
// is given is wider than any line. Measured in the page width, a hyphen is a
// break, the result is only the first piece, and the line is set in a box
// that narrow, each word on top of the next.
#let line-span(line) = measure(line, width: 100in).width

// Room above the em square. The capitals draw about a point above the line
// box, and a clip that starts on the line box slices their tops off.
#let clip-rise = 3pt

// One line, cut off at `max-width`. The inner box is the ink plus a little
// room, so a space or a hyphen is not a place to break: a second line would
// print on top of the line below. The outer box is taller than the line and
// the text sits below its top edge, so the clip takes the end of the line
// and leaves the tops of the letters.
#let clip-line(line, max-width) = box(
  width: max-width,
  height: stride + clip-rise,
  clip: true,
  pad(top: clip-rise, box(width: line-span(line) + 4pt, line)),
)

#let envelope(
  size: "number-10",
  return-lines: (),
  official-business: none,
  delivery-lines: (),
  marking: none,
  title: "Envelope",
) = {
  let dims = sizes.at(size, default: sizes.at("number-10"))
  let width = dims.at(0)
  let height = dims.at(1)

  set document(title: title)
  set page(width: width, height: height, margin: 0pt)
  set text(font: "Liberation Mono", size: type-size, fallback: false, hyphenate: false)
  set par(leading: stride - type-size, spacing: 0pt, justify: false)

  // One in-flow item, so the placed address is not the only thing on the page.
  hide[#box()]

  context {
    // Each return line takes the same 14pt step as the delivery address.
    // OFFICIAL BUSINESS is two steps below the last line, one blank line between.
    let return-width = width - return-inset - postage-width
    let y = return-inset
    for line in return-lines {
      place(top + left, dx: return-inset, dy: y - clip-rise, clip-line(line, return-width))
      y += stride
    }
    if official-business != none {
      let gap = if return-lines.len() == 0 { 0pt } else { stride }
      place(top + left, dx: return-inset, dy: y + gap, official-business)
    }

    let n = delivery-lines.len()
    let available = width - 2 * ocr-side
    let widest = 0pt
    for line in delivery-lines {
      let w = calc.min(line-span(line), available)
      if w > widest { widest = w }
    }
    let right-limit = width - ocr-side
    let x = width / 2
    if x + widest > right-limit { x = right-limit - widest }
    if x < ocr-side { x = ocr-side }
    let line-width = right-limit - x

    let block-h = if n == 0 { 0pt } else { type-size + (n - 1) * stride }
    let band-center = (ocr-bottom + ocr-top) / 2
    let bottom = band-center - block-h / 2
    if n > 0 and bottom < ocr-bottom { bottom = ocr-bottom }
    if n > 0 and bottom + block-h > ocr-top { bottom = ocr-top - block-h }
    let first-top = height - bottom - block-h

    if marking != none {
      let mark-y = if n == 0 { height - band-center - type-size / 2 } else { first-top - 2 * stride }
      place(top + left, dx: x, dy: mark-y, marking)
    }
    for (i, line) in delivery-lines.enumerate() {
      place(top + left, dx: x, dy: first-top + i * stride - clip-rise, clip-line(line, line-width))
    }
  }
}
