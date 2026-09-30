#import "@local/quillmark-helper:0.1.0": data

// ─── tokens ──────────────────────────────────────────────────────────────────
// Grays only, and none lighter than a copier holds: the chart is read from a
// photocopy, so a distinction it makes is a value contrast or it is lost.
#let ink = luma(12%)
#let mute = luma(40%)
#let hair = luma(82%)

// One type scale. A size off it is a fit — a tour title or a chip set to the
// width it was given — and says so where it is set.
#let micro = 6pt
#let small = 7pt
#let base = 8pt
#let lead = 9pt
#let display = 18pt

// A heading sits nearer its own rule than the section above it; the gap
// between sections is the largest on the page.
#let section-gap = 14pt

// The name and the stratifications share a left column, and the facts and the
// qualifications the columns right of it, so the page keeps one set of edges.
#let rail = 2.5in
#let rail-gutter = 22pt
#let col-gutter = 14pt

#set page(width: 11in, height: 8.5in, margin: 0.45in)
#set text(size: base, fill: ink)
// Every gap on the page is set where it is wanted rather than inherited.
#set block(spacing: 0pt)
#set par(spacing: 0pt)

#set document(
  title: "Ribbon Chart — " + data.name,
  author: data.name,
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
#let blank(v) = { let t = trim(v); t == [] or t == "" }
#let dash = text(fill: mute)[—]

// The bundled fallback face carries no geometric glyphs — no ✓, ■, □, ●, ▸ — so
// a mark is drawn rather than set. Held against open is a value contrast, and
// the open box is stroked dark enough that a rater still finds it on a copy.
#let held-mark = box(baseline: 0.5pt, rect(width: 4.6pt, height: 4.6pt, fill: ink, stroke: 0.5pt + ink))
#let open-mark = box(baseline: 0.5pt, rect(width: 4.6pt, height: 4.6pt, fill: none, stroke: 0.5pt + mute))

#let eyebrow(label) = text(size: micro, weight: 700, tracking: 0.5pt, fill: mute, upper(label))

#let section-rule(title, aside: none) = block(above: section-gap, below: 6pt, stack(
  spacing: 3pt,
  grid(
    columns: (1fr, auto),
    align: (left + bottom, right + bottom),
    text(size: small, weight: 700, tracking: 0.7pt, upper(title)),
    if aside != none { text(size: micro, fill: mute, aside) },
  ),
  line(length: 100%, stroke: 0.6pt + ink),
))

#let fact(label, value, note: none) = stack(
  spacing: 3pt,
  eyebrow(label),
  text(size: lead, weight: 500, if value == none { dash } else { value }),
  ..if note != none { (text(size: micro, fill: mute, note),) },
)

#let show-date(d) = if d == none { none } else { d.display("[day padding:none] [month repr:short] [year]") }

// ─── the ladder ──────────────────────────────────────────────────────────────
// Every 17X board and school gate, as an offset from the year group, counted
// from the adjusted year group where one is set because that is the year a
// board counts from. The tier is how heavily it prints: a board is a date you
// are ranked against, a look is one of a numbered series, a course is neither.
#let ladder = (
  (3, "Cyber 200", "course"),
  (4, "SOS window", "course"),
  (8, "Maj board", "board"),
  (8, "IDE 1st look", "look"),
  (9, "Cyber 300", "course"),
  (9, "IDE 2nd look", "look"),
  (10, "IDE 3rd look", "look"),
  (11, "IDE final look", "look"),
  (12, "Lt Col board", "board"),
  (14, "SDE 1st look", "look"),
  (15, "SDE 2nd look", "look"),
  (16, "SDE 3rd look", "look"),
  (17, "SDE final look", "look"),
)

// ─── inputs ──────────────────────────────────────────────────────────────────
#let comm-yg = data.commissioning_yg
#let adj-yg = data.adjusted_yg
#let adjusted = adj-yg != 0 and adj-yg != comm-yg
#let board-yg = if adjusted { adj-yg } else { comm-yg }
#let start-year = data.timeline_start_year
#let years = calc.max(1, data.timeline_years)
#let last-year = start-year + years - 1
#let cols = years * 2
#let narrow = years > 12
#let band-height = 0.52in
// Chips fit their year column: past twelve years they step off the scale.
#let chip-size = if narrow { 5.6pt } else { micro }
#let chip-inset = if narrow { 2pt } else { 3.5pt }

// Three weights of gate, by what each one is: a board ranks you against a year
// group on a date, a look is one of a numbered series, a course is a seat.
#let chip(label, tier) = {
  if tier == "board" {
    box(fill: ink, inset: (x: chip-inset, y: 2pt))[#text(size: chip-size, weight: 700, fill: white)[#label]]
  } else if tier == "look" {
    box(fill: none, stroke: 0.5pt + ink, inset: (x: chip-inset, y: 2pt))[#text(size: chip-size, weight: 600)[#label]]
  } else {
    box(inset: (x: 0.5pt, y: 2pt))[#text(size: chip-size, fill: mute)[#label]]
  }
}

// One tint per vector, darkest first, so the shade says which row this is.
// Adjacent tours part by a gap and an edge instead, and at the third rank the
// edge is doing all the work — which is what a photocopy leaves anyway.
#let rank-tints = (luma(86%), luma(92%), luma(96%))

// ─── vectors ─────────────────────────────────────────────────────────────────
#let vectors = data.vectors.enumerate().map(((i, v)) => (
  label: if blank(v.label) { [Vector #(i + 1)] } else { trim(v.label) },
  focus: trim(v.focus),
  tours: v.tours.map(t => (
    title: trim(t.title),
    duration: float(t.duration),
    vml: t.vml,
    school: t.school,
  )),
))

// A half-year column is H1 (Jan–Jun, even) or H2 (Jul–Dec, odd), and a VML
// cycle picks the phase a tour may start on. Where that means waiting, the wait
// is added to the tour before it rather than left as a hole: you hold a job
// until you move, and an empty half-year on a career chart reads as
// unemployment. Only the first tour can be preceded by nothing, and its indent
// is the half-year before a summer move.
//
// Nothing is dropped. A tour the window cuts keeps a torn edge and says which
// year it runs past; one starting beyond the window is counted on its row.
#let place-tours(tours) = {
  let cursor = 0
  let out = ()
  for t in tours {
    let phase = if t.vml == "Winter" { 0 } else { 1 }
    let start = cursor
    if calc.rem(start, 2) != phase { start += 1 }
    if start > cursor and out.len() > 0 {
      let prev = out.last()
      prev.span += start - cursor
      prev.held = true
      out.at(out.len() - 1) = prev
    }
    out.push((
      tour: t,
      start: start,
      span: calc.max(1, int(calc.round(t.duration * 2))),
      held: false,
    ))
    cursor = out.last().start + out.last().span
  }
  out.map(p => if p.start >= cols { (..p, beyond: true) } else {
    (..p, beyond: false, drawn: calc.min(p.span, cols - p.start), clipped: p.start + p.span > cols)
  })
}

// The band is ruled to an even height, so a narrow block cannot grow to fit its
// title: the title sets to the block instead. That is the ceiling `title`
// warns about in Quill.yaml — about twenty characters per year of length.
#let title-size(span) = if span <= 1 { 6.4pt } else if span == 2 { small } else { base }

// Half-columns back to years, so a stretched block prints the length it draws
// rather than the length it was given.
#let span-label(span) = {
  let years = span / 2
  if calc.rem(span, 2) == 0 { [#int(years) yr] } else { [#years yr] }
}

// ═══ IDENTITY ════════════════════════════════════════════════════════════════
// The year group printed is the one the boards count from. An adjustment says
// where it came from; an unadjusted one prints nothing more.
#grid(
  columns: (rail, 1fr),
  column-gutter: rail-gutter,
  align: bottom,
  stack(
    spacing: 6pt,
    text(size: display, weight: 800, tracking: -0.3pt, data.name),
    ..if not blank(data.duty_title) { (text(weight: 500, fill: mute, data.duty_title),) },
  ),
  grid(
    columns: (1fr,) * 4,
    column-gutter: col-gutter,
    align: top,
    fact("Year group", [#board-yg], note: if adjusted [adjusted from #comm-yg]),
    fact("Date of rank", show-date(data.date_of_rank)),
    fact("Arrived station", show-date(data.date_arrived_station)),
    fact("Advanced degree", if blank(data.advanced_degree) { none } else { data.advanced_degree }),
  ),
)

#v(7pt)
#line(length: 100%, stroke: 1.3pt + ink)

// ═══ TIMELINE ════════════════════════════════════════════════════════════════
#let in-window(cy) = cy >= start-year and cy < start-year + years
#let ahead = ladder.filter(m => board-yg + m.at(0) > last-year)

#section-rule(
  "Assignment vectors & development timeline",
  aside: [
    CY #start-year–#last-year · counted from YG #board-yg
    #if ahead.len() > 0 [ · #ahead.len() later milestone#if ahead.len() > 1 [s] beyond #last-year]
  ],
)

#let rows = ()

// year header
#rows.push(table.cell(stroke: none)[])
#for i in range(years) {
  rows.push(table.cell(colspan: 2, stroke: (bottom: 0.7pt + ink), inset: (x: 3pt, bottom: 3pt))[
    #text(weight: 700)[#(start-year + i)]
    #linebreak()
    #text(size: micro, fill: mute)[YG+#(start-year + i - board-yg)]
  ])
}

// milestone row
#rows.push(table.cell(align: left + horizon, stroke: none)[
  #text(size: small, weight: 600, fill: mute)[Eligibility]
])
#for i in range(years) {
  let cy = start-year + i
  let hits = ladder.filter(m => board-yg + m.at(0) == cy)
  rows.push(table.cell(colspan: 2, stroke: none, inset: (x: 1.5pt, y: 3pt))[
    #for m in hits [
      #block(spacing: 2pt, breakable: false)[#chip(m.at(1), m.at(2))]
    ]
  ])
}

// one row per vector
#for (rank, v) in vectors.enumerate() {
  let placed = place-tours(v.tours)
  let beyond = placed.filter(p => p.beyond)
  let top-rule = (top: 0.4pt + hair)
  let tint = rank-tints.at(calc.min(rank, rank-tints.len() - 1))
  // An empty half-year is its own cell, so the year rules run through it.
  let empty(n) = range(n).map(_ => table.cell(stroke: top-rule)[])

  rows.push(table.cell(align: left + horizon, stroke: top-rule, inset: (right: 5pt, y: 3pt))[
    #text(size: lead, weight: 700)[#v.label]
    #if not blank(v.focus) or beyond.len() > 0 [
      #linebreak()
      #text(size: micro, fill: mute)[
        #if not blank(v.focus) [#v.focus]
        #if beyond.len() > 0 [
          #if not blank(v.focus) [ · ]
          +#beyond.len() past #last-year
        ]
      ]
    ]
  ])

  let at = 0
  for p in placed.filter(p => not p.beyond) {
    if p.start > at {
      rows += empty(p.start - at)
      at = p.start
    }
    let edge = if p.tour.school { (paint: mute, thickness: 0.5pt, dash: (2pt, 1.5pt)) } else { 0.5pt + luma(55%) }
    rows.push(table.cell(
      colspan: p.drawn,
      stroke: top-rule,
      inset: (left: 1pt, right: if p.clipped { 0pt } else { 1pt }, y: 2pt),
      align: left + horizon,
    )[
      // The block is drawn inside its cell rather than as the cell's fill, so
      // adjacent tours are parted by a gap and an edge instead of by a second
      // shade — which is what lets the shade say which vector this is. A tour
      // the window cuts runs to the frame with its far end open.
      #box(
        width: 100%,
        height: 100%,
        fill: if p.tour.school { none } else { tint },
        stroke: if p.clipped { (left: edge, top: edge, bottom: edge) } else { edge },
        inset: (x: 3pt, y: 2pt),
        baseline: 0pt,
      )[
        #set align(left + horizon)
        #text(size: title-size(p.drawn), weight: 600, style: if p.tour.school { "italic" } else { "normal" })[
          #p.tour.title
        ]
        #linebreak()
        #text(size: micro, fill: mute)[
          #span-label(p.span)#if p.held [ #sym.dagger] · #p.tour.vml#if p.clipped [ · runs past #last-year]
        ]
      ]
    ])
    at = p.start + p.drawn
  }
  rows += empty(cols - at)
}

// The years are ruled from the axis down, so a block is read against the gate
// above it without a straightedge. A rule stops where a tour crosses it: the
// tour is in front of the year, not cut by it. On a blank chart the rules are
// the grid a pen draws the vectors on. The window's far side is left open,
// because the career is not over where the chart stops.
#table(
  columns: (1.2in,) + (1fr,) * cols,
  rows: (auto, auto) + (band-height,) * vectors.len(),
  stroke: none,
  inset: 2pt,
  ..range(years).map(i => table.vline(x: 1 + 2 * i, start: 1, stroke: 0.4pt + hair)),
  ..rows,
  table.hline(stroke: 0.4pt + hair),
)

// The legend names the marks this chart actually carries and no others.
#let drawn-tours = vectors.map(v => place-tours(v.tours).filter(p => not p.beyond)).flatten()
#let shown-tiers = ladder.filter(m => in-window(board-yg + m.at(0))).map(m => m.at(2)).dedup()
#let legend = ()
#if "board" in shown-tiers { legend.push([#chip("board", "board") ranked against your year group]) }
#if "look" in shown-tiers { legend.push([#chip("look", "look") one of a numbered series]) }
#if drawn-tours.any(p => not p.tour.school) {
  legend.push([#box(width: 14pt, height: 6pt, fill: rank-tints.at(0), stroke: 0.5pt + luma(55%)) assignment])
}
#if drawn-tours.any(p => p.tour.school) {
  legend.push([#box(width: 14pt, height: 6pt, stroke: (paint: mute, thickness: 0.5pt, dash: (2pt, 1.5pt))) school])
}
#if drawn-tours.any(p => p.held) { legend.push([#sym.dagger held to the next cycle]) }

#if legend.len() > 0 {
  v(5pt)
  text(size: micro, fill: mute, legend.join(h(12pt)))
}

// ═══ RECORD ══════════════════════════════════════════════════════════════════
// Every member arrives, held or not, in the order Quill.yaml declares it; an
// unheld member's detail arrives blank whatever the document retains.
#let quals = data.qualifications
#let vocabulary = (
  ("Leadership & Command", quals.command),
  ("Operations", quals.operations),
  ("Staff & Functional", quals.staff),
  ("Education & PME", quals.education),
)

#let remarks = (
  ("Awards", data.awards),
  ("Certifications", data.certifications),
  ("Deployments", data.deployments),
).filter(r => r.at(1).len() > 0)

// A table rather than a stack, so each rater's column reads down the years and
// neither line has to be recognized by its shade. With no Higher Level
// Reviewer strat on any row, the column goes rather than printing empty.
#let strats = data.stratifications
#let any-hlr = strats.any(s => not blank(s.hlr_strat))
#let strat-cell(v) = if blank(v) { dash } else { trim(v) }
#let strats-column = [
  #section-rule("Recent stratifications")
  #table(
    columns: (auto, 1fr) + if any-hlr { (1fr,) } else { () },
    column-gutter: 10pt,
    inset: (x: 0pt, y: 2.5pt),
    stroke: none,
    table.header([], eyebrow("Rater"), ..if any-hlr { (eyebrow("HLR"),) }),
    table.hline(stroke: 0.4pt + hair),
    ..strats.map(s => (
      text(weight: 700)[#trim(s.year)],
      strat-cell(s.rater_strat),
      ..if any-hlr { (strat-cell(s.hlr_strat),) },
    )).flatten(),
  )
]

#let vocabulary-column = [
  #section-rule("Qualifications & experience")
  #grid(
    columns: (1fr,) * vocabulary.len(),
    column-gutter: col-gutter,
    ..vocabulary.map(((heading, members)) => stack(
      spacing: 4pt,
      eyebrow(heading),
      ..members.values().map(m => grid(
        columns: (7.6pt, 1fr),
        align: (left + top, left + top),
        if m.held { held-mark } else { open-mark },
        [
          #set par(leading: 0.42em)
          #text(
            size: small,
            weight: if m.held { 600 } else { 400 },
            fill: if m.held { ink } else { mute },
          )[#m.title]
          #if not blank(m.detail) [
            #linebreak()
            #text(size: micro, style: "italic", fill: mute)[#trim(m.detail)]
          ]
        ],
      )),
    )),
  )
]

// The stratifications sit beside the vocabulary; with none, there is no narrow
// empty column beside it, there is no column. The block carries the gap its
// headings would, since a heading nested in a grid drops the space above it.
#block(above: section-gap, if strats.len() > 0 {
  grid(columns: (rail, 1fr), column-gutter: rail-gutter, strats-column, vocabulary-column)
} else {
  vocabulary-column
})

// Three lists side by side across the full width. Stacked in a narrow column
// they cost three times the height and read as one long list. They stand on
// the columns above them: the first under the stratifications and the other two
// each under a pair of qualification columns, or one to a qualification column
// where there are no stratifications.
#if remarks.len() > 0 {
  section-rule("Awards · certifications · deployments")
  grid(
    ..if strats.len() > 0 {
      (columns: (rail, 1fr, 1fr), column-gutter: (rail-gutter, col-gutter))
    } else {
      (columns: (1fr,) * vocabulary.len(), column-gutter: col-gutter)
    },
    ..remarks.map(((label, lines)) => stack(
      spacing: 4pt,
      eyebrow(label),
      ..lines.map(l => text(l)),
    )),
  )
}

// ═══ NOTES ═══════════════════════════════════════════════════════════════════
// The one thing the page does that the browser tool it came from could not: a
// rater writes on it during the discussion, and the sheet becomes the record of
// the conversation. So the ruling prints whether or not anything was typed, the
// typed notes are set on it, and it runs to the foot of the page: whatever the
// record above leaves is room to write.
#section-rule("Development notes")

// Narrow rule, a quarter inch: the tightest a pen writes on comfortably.
#let pitch = 18pt
#let baseline-drop = 13pt
#let rule-drop = baseline-drop + 2.5pt
#let ruling(n) = for k in range(n) {
  place(top + left, dy: k * pitch + rule-drop, line(length: 100%, stroke: 0.4pt + hair))
}

// Every line box is exactly one pitch tall with its baseline at the same drop,
// so the typed notes land on the rules however many lines they run to.
#let typed = data.at("$body", default: "")
#let on-ruling(body) = {
  set text(top-edge: baseline-drop, bottom-edge: baseline-drop - pitch)
  set par(leading: 0pt, spacing: 0pt)
  body
}

// What was typed and two blank lines under it are the minimum, and hold their
// height: a record too long for the page pushes it onto a second rather than
// eating the lines a rater writes on.
#block(width: 100%, layout(size => {
  let notes = if type(typed) != str { on-ruling(typed) } else { [] }
  let used = calc.round(measure(block(width: size.width, notes)).height / pitch)
  let n = int(used) + 2
  block(width: 100%, height: n * pitch, { ruling(n); notes })
}))
#block(width: 100%, height: 1fr, layout(size => ruling(calc.floor((size.height - rule-drop) / pitch) + 1)))

#v(10pt)
#text(size: micro, fill: mute)[
  Discussed with #box(width: 2in, stroke: (bottom: 0.4pt + mute))[]
  #h(12pt) on #box(width: 1in, stroke: (bottom: 0.4pt + mute))[]
]
