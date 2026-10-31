#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/afto244:0.0.1": cells, page-image

#set page(margin: 0pt, header: none, footer: none, numbering: none)
#set text(fill: black)

#let mark-stroke = 2pt + rgb("#ff0000")

#let dig(path) = {
  let cur = qm.data
  for part in path.split(".") {
    if type(cur) != dictionary { return none }
    cur = cur.at(part, default: none)
    if cur == none { return none }
  }
  cur
}

// Fit the value into its box. One line is centered; a wrapping cell starts at the top.
#let fit-text(body, w, h, multiline) = context {
  let avail-w = w - 3pt
  let avail-h = h - 1.5pt
  let max-size = if multiline { calc.min(11pt, h * 0.55) } else { calc.min(h * 0.72, 12pt) }
  let size = max-size
  while size > 5pt {
    let measured = if multiline {
      measure(block(width: avail-w, text(size: size, body)))
    } else {
      measure(text(size: size, body))
    }
    if measured.width <= avail-w and measured.height <= avail-h { break }
    size = size - 0.5pt
  }
  let valign = if multiline { top } else { horizon }
  box(
    width: w,
    height: h,
    clip: true,
    inset: (x: 1.5pt, y: 0.5pt),
    align(left + valign, text(size: size, body)),
  )
}

// The symbol is not the character. It is a red stroke across the whole box.
#let draw-mark(kind, w, h) = {
  if kind == "X" {
    place(line(start: (0pt, 0pt), end: (w, h), stroke: mark-stroke))
    place(line(start: (w, 0pt), end: (0pt, h), stroke: mark-stroke))
  } else if kind == "/" {
    place(line(start: (w, 0pt), end: (0pt, h), stroke: mark-stroke))
  } else if kind == "-" {
    place(line(start: (0pt, h / 2), end: (w, h / 2), stroke: mark-stroke))
  }
}

#let draw(page-number) = {
  for cell in cells {
    if cell.page != page-number - 1 { continue }
    let x = cell.x * 1pt
    let y = cell.y * 1pt
    let w = cell.w * 1pt
    let h = cell.h * 1pt
    let value = dig(cell.field)
    if cell.kind == "symbol" {
      // The widget rect sits inside the printed rules. Bleed out to those rules.
      let bleed = 1pt
      place(dx: x - bleed, dy: y - bleed, qm.region(cell.field, box(
        width: w + 2 * bleed,
        height: h + 2 * bleed,
        clip: true,
      )[
        #if type(value) == str and value != "" {
          draw-mark(value, w + 2 * bleed, h + 2 * bleed)
        }
      ]))
    } else {
      let shown = if cell.kind == "date" {
        qm.ink(qm.data, cell.field, "[year]-[month padding:zero]-[day padding:zero]")
      } else {
        qm.ink(qm.data, cell.field)
      }
      if shown != none {
        place(dx: x, dy: y, fit-text(shown, w, h, cell.multiline))
      }
    }
  }
}

#page(width: 828pt, height: 648pt, margin: 0pt, background: page-image(1))[
  #draw(1)
]
#page(width: 828pt, height: 648pt, margin: 0pt, background: page-image(2))[
  #draw(2)
]
