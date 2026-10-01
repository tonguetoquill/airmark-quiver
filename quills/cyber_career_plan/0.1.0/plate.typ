#import "@local/quillmark-helper:0.1.0": data, roster

// ─── tokens ──────────────────────────────────────────────────────────────────
// Grays only, and none lighter than a copier holds: the chart is read from a
// photocopy, so a distinction it makes is a value contrast or it is lost.
#let ink = luma(12%)
#let mute = luma(40%)
#let hair = luma(82%)
#let shade = luma(88%)

// One type scale. A size off it is a fit, set to the width it was given, and
// says so where it is set.
#let micro = 6pt
#let small = 7pt
#let base = 8pt
#let lead = 9pt
#let display = 18pt

// Every row under the name hangs its label in one rail: the timeline's rows,
// the record's and the notes'. The labels are the page's headings, and the
// rail's edge is the one left edge everything after the name stands on.
#let rail = 1.2in
#let name-width = 2.5in

#let margin = 0.45in
#set page(width: 11in, height: 8.5in, margin: margin)
#set text(size: base, fill: ink)
// Every gap on the page is set where it is wanted rather than inherited.
#set block(spacing: 0pt)
#set par(spacing: 0pt)

#let officer = data.at("name", default: "").trim()
#set document(
  title: if officer == "" { "Career Plan" } else { "Career Plan — " + officer },
  author: officer,
)

// A `plaintext` field lowers to content padded with a space on each side, which
// would print inside a bold run and defeat an emptiness test.
#let trim(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let pad(c) = c == [ ] or c.func() == parbreak
  while kids.len() > 0 and pad(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and pad(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}
#let blank(v) = { let t = trim(v); t == none or t == [] or t == "" }
#let or-none(v) = if blank(v) { none } else { trim(v) }
#let plain(c) = if c == none { "" } else if type(c) == str { c } else if c.has("text") {
  c.text
} else if c.has("children") {
  c.children.map(plain).sum(default: "")
} else if c.func() == smartquote { "’" } else { " " }
#let dash = text(fill: mute)[—]

// The bundled fallback face carries no geometric glyphs — no ✓, ■, □, ●, ▸ — so
// a mark is drawn rather than set. Held against open is a value contrast, and
// the open box is stroked dark enough that a rater still finds it on a copy.
#let held-mark = box(baseline: 0.5pt, rect(width: 4.6pt, height: 4.6pt, fill: ink, stroke: 0.5pt + ink))
#let open-mark = box(baseline: 0.5pt, rect(width: 4.6pt, height: 4.6pt, fill: none, stroke: 0.5pt + mute))

#let eyebrow(body) = text(size: micro, weight: 700, tracking: 0.5pt, fill: mute, upper(body))
#let rail-label(body) = text(size: small, weight: 600, fill: mute, body)
#let divider(above) = block(above: above, below: 10pt, line(length: 100%, stroke: 0.5pt + ink))

#let show-date(d) = if d == none { none } else { d.display("[day padding:none] [month repr:short] [year]") }

// ─── inputs ──────────────────────────────────────────────────────────────────
#let quals = data.qualifications
#let comm-yg = data.commissioning_yg
// 0 is read as blank: it was this field's blank before the field took `?`.
#let adj-yg = { let v = data.at("adjusted_yg", default: none); if v == 0 { none } else { v } }
#let adjusted = adj-yg != none and adj-yg != comm-yg
#let board-yg = if adjusted { adj-yg } else { comm-yg }
// A required year not yet filled in arrives as 0. With no start year the window
// opens on the year group; with neither, as on a new chart, the axis counts
// from YG+0 and prints no calendar years rather than the years 0 to 11. With a
// start year but no year group there is nothing to count the ladder from, so
// the axis prints calendar years alone and no milestone is drawn.
#let start-year = if data.timeline_start_year == 0 { board-yg } else { data.timeline_start_year }
#let dated = start-year != 0
#let laddered = board-yg != 0 or not dated
#let yg-offset(k) = if k < 0 [YG#k] else [YG+#k]
// Eighteen is the widest the marks hold their columns at, and the schema cannot
// bound an integer, so a wider window draws at eighteen.
#let years = calc.clamp(data.timeline_years, 1, 18)
#let cols = years * 2
#let last-year = start-year + years - 1
#let window-end = if dated [#last-year] else { yg-offset(last-year - board-yg) }
#let in-window(y) = y >= start-year and y <= last-year
#let band-height = 0.46in
// Marks fit their year column: past twelve years they step off the scale.
#let narrow = years > 12
#let mark-size = if narrow { 5.6pt } else { micro }
#let mark-inset = if narrow { 2pt } else { 3.5pt }

// A half-year column is H1 (Jan–Jun, even) or H2 (Jul–Dec, odd), and each one is
// a VML cycle: Winter moves land in the first half, Summer moves in the second.
#let cycle-of(col) = if calc.rem(col, 2) == 0 { "Winter" } else { "Summer" }
#let col-of(year, cycle) = (year - start-year) * 2 + if cycle == "Winter" { 0 } else { 1 }

#let afsc = or-none(data.afsc)
#let duty = or-none(data.duty_title)
#let unit = or-none(data.unit)
#let move-year = data.at("move_year", default: none)

// Where the vectors branch. Everything left of it is the assignment you hold
// now, which is the same on every row, so it is drawn once across all of them.
// A move before the window is kept where it falls, so the tours after it are
// laid from their real start and cut at the left edge rather than shifted.
#let move-col = if move-year == none { 0 } else { col-of(move-year, data.move_cycle) }
#let current-span = if data.vectors.len() == 0 { 0 } else { calc.clamp(move-col, 0, cols) }

// ─── the ladder ──────────────────────────────────────────────────────────────
// Every 17X board and school gate, as an offset from the year group, counted
// from the adjusted year group where one is set because that is the year a
// board counts from. A board or a course falls in one year; IDE and SDE are
// each a window of four yearly looks, drawn as one span. A gate is done once
// any qualification it names is ticked (an IDE candidate has no looks left)
// and prints struck rather than as something still ahead.
#let held(keys) = keys.any(k => k in quals.education)
#let gates = (
  (yg: 3, name: "Cyber 200", board: false, by: ("cyber_200",)),
  (yg: 4, name: "SOS window", board: false, by: ("sos",)),
  (yg: 8, name: "Maj board", board: true, by: ()),
  (yg: 9, name: "Cyber 300", board: false, by: ("cyber_300",)),
  (yg: 12, name: "Lt Col board", board: true, by: ()),
).map(g => (..g, year: board-yg + g.yg, done: held(g.by)))
// A course whose year has passed unticked is what a rater most needs to see, so
// it stands before the window, in the rail, saying when it was due. A passed
// board is history.
#let gates = if laddered {
  gates.map(g => (..g, overdue: not g.board and not g.done and g.year < start-year))
} else { () }
#let looks = ("1st", "2nd", "3rd", "final")
#let windows = if laddered {
  (
    (yg: 8, name: "IDE", by: ("ide_candidate", "ide_graduate")),
    (yg: 14, name: "SDE", by: ("sde_candidate", "sde_graduate")),
  ).map(w => (..w, done: held(w.by), years: looks.enumerate().map(((k, _)) => board-yg + w.yg + k)))
} else { () }
#let ahead = (
  gates.filter(g => not g.done and g.year > last-year).len()
    + windows.filter(w => not w.done).map(w => w.years.filter(y => y > last-year).len()).sum(default: 0)
)

// A board prints heaviest, since it is a date you are ranked against; a course
// is a seat, and prints plain. A board holds to one line: at eighteen years
// "Lt Col board" runs a little into YG+13, which the ladder leaves empty.
#let gate-mark(g) = {
  let plain-mark(body, ..style) = box(inset: (x: 0.5pt, y: 2pt), text(size: mark-size, ..style, body))
  if g.overdue {
    plain-mark([#g.name, due #g.year], weight: 600, style: "italic")
  } else if g.done {
    plain-mark(strike(stroke: 0.5pt + mute, g.name), fill: mute)
  } else if g.board {
    box(fill: ink, inset: (x: mark-inset, y: 2pt), text(size: mark-size, weight: 700, fill: white, g.name.replace(" ", "\u{a0}")))
  } else {
    plain-mark(g.name, fill: mute)
  }
}

// A window is one span over its looks in the chart, split by year and named
// once. Looks already past are history and the span opens at the left edge;
// looks past the window run it open into the right.
#let window-mark(w, shown) = {
  let paint = if w.done { mute } else { ink }
  let edge = 0.5pt + paint
  box(
    width: 100%,
    stroke: (
      top: edge,
      bottom: edge,
      left: if w.years.first() < start-year { none } else { edge },
      right: if w.years.last() > last-year { none } else { edge },
    ),
    grid(
      columns: (1fr,) * shown.len(),
      inset: (x: mark-inset, y: 2pt),
      stroke: (x, _) => (left: if x > 0 { 0.4pt + hair }),
      ..shown.enumerate().map(((n, k)) => {
        let name = [#if n == 0 [#w.name~]#looks.at(k)]
        text(size: mark-size, weight: 600, fill: paint, if w.done { strike(stroke: 0.5pt + mute, name) } else { name })
      }),
    ),
  )
}

// ─── vectors ─────────────────────────────────────────────────────────────────
#let ranks = ("Primary", "Alternate", "Backup")
#let current-stroke = 0.9pt + ink
#let constraint-stroke = 0.6pt + ink
#let school-stroke = (paint: mute, thickness: 0.5pt, dash: (2pt, 1.5pt))
#let tour-stroke = 0.5pt + luma(55%)

// Tours lay end to end from the move, so each one's cycle is where the one
// before it ended rather than something to keep in step by hand.
//
// Nothing is dropped. A tour the window cuts runs into the window's edge open
// and says which year it runs past; one starting beyond the window is counted
// on its row.
#let lay(tours) = {
  let cursor = move-col
  let out = ()
  for t in tours {
    out.push((tour: t, start: cursor, span: t.span))
    cursor += t.span
  }
  // A tour over before the window opens is history, not plan.
  out.filter(p => p.start + p.span > 0).map(p => {
    let from = calc.max(0, p.start)
    if from >= cols { (..p, beyond: true) } else {
      (
        ..p,
        beyond: false,
        from: from,
        drawn: calc.min(p.start + p.span, cols) - from,
        cut: p.start < 0,
        clipped: p.start + p.span > cols,
      )
    }
  })
}

#let vectors = data.vectors.enumerate().map(((i, v)) => (
  rank: ranks.at(i, default: "Vector " + str(i + 1)),
  track: or-none(v.track),
  // A length is rounded to the half-year first; one that rounds outside 0.5 to
  // 4 draws at the nearer end under a dagger the legend explains, since the
  // schema cannot bound a number.
  placed: lay(v.tours.map(t => {
    let halves = int(calc.round(float(t.years) * 2))
    (
      title: trim(t.title),
      span: calc.clamp(halves, 1, 8),
      out-of-range: halves < 1 or halves > 8,
      school: t.school,
    )
  })),
))

// The band is ruled to an even height, so a block cannot grow to fit its text:
// the text sheds what the block cannot hold instead. The notes go a phrase at a
// time, then the title steps down the scale, and each setting is tried flat and
// then turned up the side before the next. A block too small for any setting is
// left blank rather than overprinted; that is the ceiling `title` warns about in
// Quill.yaml, about twelve characters per year of length.
//
// The title is broken here rather than by the paragraph, between words only and
// each line as full as it will go, so "JFHQ-C" never strands its "C" and a word
// too long for the block rules the setting out rather than running past its
// edge. A note holds to one line, and turned up the side nothing breaks.
#let block-text(title, notes, ..style) = layout(size => {
  let (w, h) = (size.width, size.height)
  let words = plain(title).split(" ").filter(x => x != "")
  let face(s, body) = text(size: s, weight: 600, ..style, body)
  // The title in lines no wider than `room`, or in one line given none.
  let lines(s, room) = words.fold((), (out, x) => {
    if out.len() > 0 and (room == none or measure(face(s, out.last() + " " + x)).width <= room) {
      out.slice(0, -1) + (out.last() + " " + x,)
    } else { out + (x,) }
  })
  let typeset((s, n), room) = (
    ..if words.len() > 0 { (face(s, lines(s, room).join(linebreak())),) },
    ..if n != none { (text(size: micro, fill: mute, n),) },
  ).join(linebreak(), default: [])
  let within(c, room, w, h) = { let m = measure(typeset(c, room)); m.width <= w and m.height <= h }
  let settings = notes.map(n => (base, n)) + (base, small, micro).map(s => (s, none))
  block(width: w, height: h, settings.map(c => (
    if within(c, w, w, h) { align(left + horizon, typeset(c, w)) },
    if within(c, none, h, w) { align(center + bottom, rotate(-90deg, reflow: true, block(width: h, typeset(c, none)))) },
  )).flatten().find(s => s != none))
})

// A vector's label holds to its row the way a block's text does: it steps down
// the scale until it fits, every word within the rail. One too long at the
// smallest drops its rank, which the row's place already says, and keeps the
// whole lines the row holds.
#let track-label(name, sub) = layout(size => {
  let (w, h) = (size.width, size.height)
  let words = plain(name).split(" ").filter(x => x != "")
  let face(s, body) = text(size: s, weight: 700, body)
  let typeset(s) = [#face(s, name)#if sub != none [#linebreak()#text(size: micro, fill: mute, sub)]]
  let fits(s) = words.all(x => measure(face(s, x)).width <= w) and measure(block(width: w, typeset(s))).height <= h
  let s = (lead, base, small).find(fits)
  if s != none { return block(width: w, height: h, align(left + horizon, typeset(s))) }
  let one = measure(face(small, [A])).height
  let step = measure(face(small, [A#linebreak()A])).height - one
  let kept = one + calc.floor((h - one) / step) * step + 2pt
  block(width: w, height: h, align(left + horizon, block(width: w, height: kept, clip: true, face(small, name))))
})

#let span-label(span) = {
  let years = span / 2
  if calc.rem(span, 2) == 0 { [#int(years) yr] } else { [#years yr] }
}

#let constraints = data.constraints.map(c => (
  note: trim(c.note),
  through: c.through,
  end: calc.min(cols, (c.through - start-year + 1) * 2),
)).filter(c => c.end > 0)

// ═══ IDENTITY ════════════════════════════════════════════════════════════════
// The name stands on the facts' labels, and the line under it on their values:
// both hang from the top of their row by one edge, so the two sizes share a
// baseline, and a degree that wraps or a year group's note hangs below the row
// rather than lifting it. The AFSC, duty title and unit read as one line,
// breaking before the unit rather than inside it. The year group printed is the
// one the boards count from; an adjustment says where it came from, and an
// unadjusted one prints nothing more.
#let hang = 0.72 * lead
#let identity = layout(size => {
  set text(top-edge: hang)
  let parts = (
    if afsc != none { text(weight: 600, afsc) },
    if duty != none { text(weight: 600, duty) },
    if unit != none { text(weight: 500, fill: mute, unit) },
  ).filter(x => x != none)
  let sep = text(fill: mute)[ · ]
  if parts.len() < 2 or measure(parts.join(sep)).width <= size.width {
    parts.join(sep)
  } else {
    parts.slice(0, -1).join(sep) + linebreak() + parts.last()
  }
})
#let facts = (
  ("Year group", if board-yg != 0 [#board-yg], if adjusted [adjusted from #comm-yg]),
  ("Date of rank", show-date(data.date_of_rank), none),
  ("Arrived station", show-date(data.date_arrived_station), none),
  // A degree marked "(in progress)" says so in a note under it, as the year
  // group's adjustment does, rather than breaking inside the parenthesis.
  {
    let degree = or-none(data.advanced_degree)
    let flat = plain(degree).trim()
    let mark = "(in progress)"
    if degree != none and flat.ends-with(mark) and flat.len() > mark.len() {
      ("Advanced degree", flat.slice(0, -mark.len()).trim(), [in progress])
    } else { ("Advanced degree", degree, none) }
  },
)
#grid(
  columns: (name-width,) + (1fr,) * facts.len(),
  column-gutter: 16pt,
  row-gutter: 3pt,
  align: (_, y) => if y == 0 { bottom } else { top },
  // Raised clear of the line under it by the depth of its descenders.
  pad(bottom: 3pt, text(size: display, weight: 800, tracking: -0.3pt, officer)),
  ..facts.map(((name, ..)) => eyebrow(name)),
  identity,
  ..facts.map(((_, value, note)) => stack(
    spacing: 3pt,
    text(size: lead, weight: 500, top-edge: hang, if value == none { dash } else { value }),
    ..if note != none { (text(size: micro, fill: mute, note),) },
  )),
)

// ═══ PLAN ════════════════════════════════════════════════════════════════════
#let row-label(body) = table.cell(align: left + horizon, rail-label(body))
// An empty half-year is its own cell, so the year rules run through it.
#let empty(n, stroke: none) = range(n).map(_ => table.cell(stroke: stroke)[])

#let rows = ()

// the axis
#rows.push(table.cell[])
#for i in range(years) {
  let offset = yg-offset(start-year + i - board-yg)
  rows.push(table.cell(colspan: 2, stroke: (bottom: 0.7pt + ink), inset: (x: 3pt, bottom: 3pt))[
    #if not dated { text(weight: 700, offset) } else if laddered [
      #text(weight: 700)[#(start-year + i)]
      #linebreak()
      #text(size: micro, fill: mute, offset)
    ] else { text(weight: 700)[#(start-year + i)] }
  ])
}

// One row per constraint, under the axis: a bar from today to the end of the
// last year it holds, ruled under and closed at its end, so it reads as "until
// here". The band is not ruled by year, so a label too long for its bar runs
// on past its end, on one line, over nothing; one too long for that as well is
// cut at whichever edge leaves more of it, the bar's end or the page's.
#for (i, c) in constraints.enumerate() {
  rows.push(if i == 0 { row-label[Constraints] } else { table.cell[] })
  let note = [#text(size: micro, weight: 600)[#c.note]#text(size: micro, fill: mute)[#(" · through " + str(c.through))]]
  // The first stands clear of the axis, which would otherwise close its top.
  rows.push(table.cell(colspan: c.end, inset: (x: 1pt, top: if i == 0 { 3pt } else { 0.5pt }, bottom: 0.5pt))[
    #layout(size => {
      // A bar that runs past the window is left open at its end, since the
      // window's edge is not where it stops.
      let open = c.through > last-year
      let wide = measure(note).width
      let inside = size.width - 8pt
      // The half-years right of the bar, less this cell's own inset.
      let after = (size.width + 2pt) / c.end * (cols - c.end) - 4pt
      let (dx, room) = if wide <= inside or (wide > after and inside >= after) { (3pt, inside) } else { (size.width + 3pt, after) }
      box(width: 100%, height: 8.5pt, stroke: (bottom: constraint-stroke, right: if open { none } else { constraint-stroke }))
      // Clipped across only: the inset keeps the ascenders and descenders.
      place(left + bottom, dx: dx, box(width: calc.max(0pt, room), inset: (y: 2pt), clip: true, box(width: 10in, note)))
    })
  ])
  rows += empty(cols - c.end)
}

// Eligibility, in lanes the year rules start from: the boards and courses, each
// on its year, and under them the IDE and SDE windows, when one is in view.
#let spans = windows.map(w => (w, range(looks.len()).filter(k => in-window(w.years.at(k))))).filter(((_, shown)) => shown.len() > 0)
#let lanes = if spans.len() > 0 { 2 } else { 1 }
#rows.push(table.cell(rowspan: lanes, align: left + horizon, stack(
  spacing: 3pt,
  rail-label[Eligibility],
  ..gates.filter(g => g.overdue).map(gate-mark),
)))
#for i in range(years) {
  let here = gates.filter(g => g.year == start-year + i)
  rows.push(table.cell(colspan: 2, inset: (x: 1.5pt, y: 3pt), stack(spacing: 2pt, ..here.map(gate-mark))))
}
#if spans.len() > 0 {
  let at = 0
  for (w, shown) in spans {
    let from = (w.years.at(shown.first()) - start-year) * 2
    rows += empty(from - at)
    rows.push(table.cell(colspan: 2 * shown.len(), inset: (x: 1.5pt, top: 0pt, bottom: 3pt), window-mark(w, shown)))
    at = from + 2 * shown.len()
  }
  rows += empty(cols - at)
}

// The assignment held now, drawn once across every vector row. It reads like a
// tour block, title over a line of small print, and sheds what its space cannot
// hold the way one does; with nothing left, the header still names the job. The
// unit is left to the header throughout. A move past the window leaves the
// block open at the window's edge, as a tour the window cuts is.
#let current-block = block(
  width: 100%,
  height: 100%,
  stroke: (
    left: current-stroke,
    top: current-stroke,
    bottom: current-stroke,
    right: if move-col > cols { none } else { current-stroke },
  ),
  inset: (x: 3pt, y: 2pt),
  block-text(
    if duty != none { duty } else { [Current assignment] },
    ([Current · to #data.move_cycle #move-year], [to #data.move_cycle #move-year]),
  ),
)

// One row per vector. Its label says which it is, so every duty tour takes the
// one shade, and a school goes unshaded: a year in a classroom does not read as
// a year in a job.
#for (rank, v) in vectors.enumerate() {
  let beyond = v.placed.filter(p => p.beyond)
  let top-rule = (top: 0.4pt + hair)
  let sub = ()
  if v.track != none { sub.push(v.rank) }
  if beyond.len() > 0 { sub.push([+#beyond.len() past #window-end]) }

  rows.push(table.cell(stroke: top-rule, inset: (right: 5pt, y: 3pt))[
    #block(width: 100%, height: 100%, track-label(
      if v.track != none { v.track } else { [#v.rank] },
      if sub.len() > 0 { sub.join[ · ] },
    ))
  ])

  if rank == 0 and current-span > 0 {
    rows.push(table.cell(colspan: current-span, rowspan: vectors.len(), inset: (x: 1pt, y: 2pt))[#current-block])
  }

  let at = current-span
  for p in v.placed.filter(p => not p.beyond) {
    let edge = if p.tour.school { school-stroke } else { tour-stroke }
    let notes = (
      [#span-label(p.span)#if p.tour.out-of-range [#sym.dagger]],
      cycle-of(p.start),
      ..if p.clipped { ([runs past #window-end],) },
    )
    rows.push(table.cell(
      colspan: p.drawn,
      stroke: top-rule,
      inset: (left: if p.cut { 0pt } else { 1pt }, right: if p.clipped { 0pt } else { 1pt }, y: 2pt),
    )[
      // The block is drawn inside its cell rather than as the cell's fill, so
      // adjacent tours part by a gap and an edge. A tour the window cuts runs
      // to the window's edge with that end open.
      #block(
        width: 100%,
        height: 100%,
        fill: if p.tour.school { none } else { shade },
        stroke: (
          top: edge,
          bottom: edge,
          left: if p.cut { none } else { edge },
          right: if p.clipped { none } else { edge },
        ),
        inset: (x: 3pt, y: 2pt),
        block-text(
          p.tour.title,
          range(notes.len(), 0, step: -1).map(n => notes.slice(0, n).join[ · ]),
          style: if p.tour.school { "italic" } else { "normal" },
        ),
      )
    ])
    at = p.from + p.drawn
  }
  rows += empty(cols - at, stroke: top-rule)
}

// The years are ruled from the gates down, so a block is read against the gate
// above it without a straightedge. A rule stops where a block crosses it: the
// block is in front of the year, not cut by it. On a blank chart the rules are
// the grid a pen draws the vectors on. The window's far side is left open,
// because the career is not over where the chart stops.
#block(above: 18pt, table(
  columns: (rail,) + (1fr,) * cols,
  rows: (auto,) * (1 + constraints.len() + lanes) + (band-height,) * vectors.len(),
  stroke: none,
  inset: 2pt,
  ..range(years).map(i => table.vline(x: 1 + 2 * i, start: 1 + constraints.len(), stroke: 0.4pt + hair)),
  ..rows,
  table.hline(stroke: 0.4pt + hair),
))

// The gates and tours carry their own names. The legend keys only the marks
// that cannot, and only those this chart carries, beside a count of the gates
// past the window's far side.
#let drawn-tours = vectors.map(v => v.placed.filter(p => not p.beyond)).flatten()
#let swatch(..args) = box(width: 14pt, height: 6pt, baseline: 1pt, ..args)
#let key(mark, name) = [#mark#h(3pt)#name]
#let legend = (
  if current-span > 0 { key(swatch(stroke: current-stroke), [current assignment]) },
  if drawn-tours.any(p => p.tour.school) { key(swatch(stroke: school-stroke), [school]) },
  if drawn-tours.any(p => p.tour.out-of-range) { key(sym.dagger, [length outside 0.5–4 yr]) },
).filter(k => k != none)
#if legend.len() > 0 or ahead > 0 {
  block(above: 5pt, pad(left: rail, grid(
    columns: (1fr, auto),
    text(size: micro, fill: mute, legend.join(h(12pt), default: [])),
    if ahead > 0 { text(size: micro, fill: mute)[#ahead more milestone#if ahead > 1 [s] past #window-end] },
  )))
}

// ═══ RECORD ══════════════════════════════════════════════════════════════════
// The record that makes the plan credible, a row to a part: one with nothing
// in it goes rather than printing empty. Every first line in it hangs from the
// top of its row by one edge, so a label and its row share a baseline.
#let row-top = 5pt

// A matrix arrives as the members it holds; `roster` gives back the whole
// vocabulary in the order Quill.yaml declares it, held or not. The labels repeat
// each matrix's `title`, which the data does not carry. Every member prints: the
// open boxes say what has not been done yet as plainly as the filled ones say
// what has. What is held leads its row, and a member holds together on its line.
#let vocabulary = (
  ("Leadership & command", roster(quals, "command")),
  ("Operations", roster(quals, "operations")),
  ("Staff & functional", roster(quals, "staff")),
  ("Education & PME", roster(quals, "education")),
)
#let member(m) = box[
  #let detail = if m.held { m.value.detail } else { "" }
  #if m.held { held-mark } else { open-mark }#h(3pt)#text(
    weight: if m.held { 600 } else { 400 },
    fill: if m.held { ink } else { mute },
    m.title,
  )#if not blank(detail) [#h(2pt)#text(size: micro, style: "italic", fill: mute, trim(detail))]
]
#let members-row(rows) = {
  (rows.filter(m => m.held) + rows.filter(m => not m.held)).map(member).join([#h(10pt) ])
}

// A table, so each rater's column reads down the years. With no Higher Level
// Reviewer strat on any row, that column goes rather than printing empty. The
// rows are set at the record's size, so the table reads as one of its rows. A
// year not yet filled in arrives as 0, sorts last and prints a dash.
#let strats = data.stratifications.sorted(key: s => -s.year)
#let any-hlr = strats.any(s => not blank(s.hlr))
#let strat-cell(v) = if blank(v) { dash } else { trim(v) }
#let strats-table = table(
  columns: (auto,) * (if any-hlr { 3 } else { 2 }),
  column-gutter: 16pt,
  inset: (_, y) => (x: 0pt, top: if y == 0 { 0pt } else { 2pt }, bottom: 2pt),
  stroke: none,
  table.header([], eyebrow[Rater], ..if any-hlr { (eyebrow[HLR],) }),
  ..strats.map(s => (
    if s.year == 0 { dash } else { text(weight: 700)[#s.year] },
    strat-cell(s.rater),
    ..if any-hlr { (strat-cell(s.hlr),) },
  )).flatten(),
)

// The two things a board reads first, the stratifications and the awards,
// lead; the experience follows.
#let listed(name, lines) = if lines.len() > 0 { (([#name], lines.map(trim).join[ · ]),) }
#let record = (
  ..if strats.len() > 0 { (([Stratifications], strats-table),) },
  ..listed("Awards", data.awards),
  ..vocabulary.map(((name, members)) => ([#name], members-row(members))),
  ..listed("Certifications", data.certifications),
  ..listed("Deployments", data.deployments),
)

#divider(14pt)
#{
  set text(size: small, top-edge: row-top)
  grid(
    columns: (rail, 1fr),
    row-gutter: 7pt,
    ..record.map(((name, body)) => (rail-label(name), body)).flatten(),
  )
}

// ═══ NOTES ═══════════════════════════════════════════════════════════════════
// The one thing the page does that the browser tool it came from could not: a
// rater writes on it during the discussion, and the sheet becomes the record of
// the conversation. So the ruling prints whether or not anything was typed, the
// typed notes are set on it, and it runs to the foot of the page: whatever the
// record above leaves is room to write.
#divider(12pt)

// Narrow rule, a quarter inch: the tightest a pen writes on comfortably.
#let pitch = 18pt
#let baseline-drop = 13pt
#let rule-drop = baseline-drop + 2.5pt
#let ruling(n) = for k in range(n) {
  place(top + left, dy: k * pitch + rule-drop, line(length: 100%, stroke: 0.4pt + hair))
}

// Every line box is exactly one pitch tall with its baseline at the same drop,
// so the typed notes land on the rules however many lines they run to, and the
// rail's label sits on the first.
#let typed = data.at("$body", default: "")
#let on-ruling(body) = {
  set text(top-edge: baseline-drop, bottom-edge: baseline-drop - pitch)
  set par(leading: 0pt, spacing: 0pt)
  body
}

// What was typed, on at least the first rule, is the minimum and holds its
// height; the blank rules under it are whatever the page has left. The notes
// and the line they are signed on are one unit, so typed notes too long for the
// page carry the signature with them rather than leaving it alone overleaf.
//
// The section is one block sized to the rest of its page, which it reads off a
// mark left where it starts: the page cannot otherwise tell a block what is left
// of it, and the mark, being empty, stays put when the block does not fit. Notes
// too long for what is left make the block taller than that, and it goes to the
// next page whole.
#let signature = grid(
  columns: (rail, 1fr),
  rail-label[Discussed with],
  text(size: micro, fill: mute)[
    #box(width: 2.5in, stroke: (bottom: 0.4pt + mute))[]
    #h(12pt) on #box(width: 1.2in, stroke: (bottom: 0.4pt + mute))[]
  ],
)
#let signature-gap = 8pt
#block(height: 0pt)<notes-start>
#context {
  let width = 11in - 2 * margin - rail
  let notes = if type(typed) != str { on-ruling(typed) } else { [] }
  let used = int(calc.round(measure(block(width: width, notes)).height / pitch))
  let below = signature-gap + measure(signature).height
  let room = 8.5in - margin - locate(<notes-start>).position().y
  // The typed lines need only reach their last rule; the blank rules run on to
  // the signature's gap.
  let lines = calc.max(1, used)
  let need = (lines - 1) * pitch + rule-drop + below
  let rules = calc.max(lines, int(calc.floor((room - below - rule-drop) / pitch)) + 1)
  block(breakable: false, width: 100%, height: calc.max(room, need), {
    grid(
      columns: (rail, 1fr),
      on-ruling(rail-label[Notes]),
      block(width: 100%, { ruling(rules); notes }),
    )
    place(bottom + left, signature)
  })
}
