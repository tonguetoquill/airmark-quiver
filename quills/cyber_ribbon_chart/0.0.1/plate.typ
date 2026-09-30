#import "@local/quillmark-helper:0.1.0": data

// ─── tokens ──────────────────────────────────────────────────────────────────
// Grays only, and none lighter than a copier holds: the chart is read from a
// photocopy, so a distinction it makes is a value contrast or it is lost.
#let ink = luma(12%)
#let mute = luma(40%)
#let hair = luma(82%)

// One type scale. A size off it is a fit — a chip set to the width it was
// given — and says so where it is set.
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

#let margin = 0.45in
#set page(width: 11in, height: 8.5in, margin: margin)
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
#let blank(v) = { let t = trim(v); t == none or t == [] or t == "" }
#let or-none(v) = if blank(v) { none } else { trim(v) }
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

// ─── inputs ──────────────────────────────────────────────────────────────────
#let quals = data.qualifications
#let comm-yg = data.commissioning_yg
// 0 is read as blank: it was this field's blank before the field took `?`.
#let adj-yg = { let v = data.at("adjusted_yg", default: none); if v == 0 { none } else { v } }
#let adjusted = adj-yg != none and adj-yg != comm-yg
#let board-yg = if adjusted { adj-yg } else { comm-yg }
#let start-year = data.timeline_start_year
#let years = calc.max(1, data.timeline_years)
#let cols = years * 2
#let last-year = start-year + years - 1
#let narrow = years > 12
#let band-height = 0.46in
#let label-width = 1.2in
// Chips fit their year column: past twelve years they step off the scale.
#let chip-size = if narrow { 5.6pt } else { micro }
#let chip-inset = if narrow { 2pt } else { 3.5pt }

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
#let col-width = (11in - 2 * margin - label-width) / cols

// ─── the ladder ──────────────────────────────────────────────────────────────
// Every 17X board and school gate, as an offset from the year group, counted
// from the adjusted year group where one is set because that is the year a
// board counts from. The tier is how heavily it prints: a board is a date you
// are ranked against, a look is one of a numbered series, a course is neither.
// A gate is done once any qualification it names is ticked — an IDE candidate
// has no looks left — and prints struck rather than as something still ahead.
#let ide = ("ide_candidate", "ide_graduate")
#let sde = ("sde_candidate", "sde_graduate")
#let ladder = (
  (yg: 3, label: "Cyber 200", tier: "course", by: ("cyber_200",)),
  (yg: 4, label: "SOS window", tier: "course", by: ("sos",)),
  (yg: 8, label: "Maj board", tier: "board", by: ()),
  (yg: 8, label: "IDE 1st look", tier: "look", by: ide),
  (yg: 9, label: "Cyber 300", tier: "course", by: ("cyber_300",)),
  (yg: 9, label: "IDE 2nd look", tier: "look", by: ide),
  (yg: 10, label: "IDE 3rd look", tier: "look", by: ide),
  (yg: 11, label: "IDE final look", tier: "look", by: ide),
  (yg: 12, label: "Lt Col board", tier: "board", by: ()),
  (yg: 14, label: "SDE 1st look", tier: "look", by: sde),
  (yg: 15, label: "SDE 2nd look", tier: "look", by: sde),
  (yg: 16, label: "SDE 3rd look", tier: "look", by: sde),
  (yg: 17, label: "SDE final look", tier: "look", by: sde),
).map(m => (..m, year: board-yg + m.yg, done: m.by.any(k => quals.education.at(k).held)))
// A course whose year has passed unticked is what a rater most needs to see,
// so it prints at the left edge with its year rather than leaving the window.
// A passed look or board is history either way, so it goes.
#let ladder = ladder.map(m => (..m, overdue: m.tier == "course" and not m.done and m.year < start-year))

// Three weights of gate, by what each one is: a board ranks you against a year
// group on a date, a look is one of a numbered series, a course is a seat. In a
// narrow window a look drops its word, which its outline says as the legend
// does; a board keeps it, since "Maj" alone reads as a rank.
#let chip(label, tier, done: false, overdue: none) = {
  if narrow and tier == "look" { label = label.replace(regex(" look$"), "") }
  if overdue != none {
    box(inset: (x: 0.5pt, y: 2pt))[#text(size: chip-size, weight: 600, style: "italic")[#label (#overdue)]]
  } else if done {
    box(inset: (x: 0.5pt, y: 2pt))[#text(size: chip-size, fill: mute)[#strike(stroke: 0.5pt + mute)[#label]]]
  } else if tier == "board" {
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
#let ranks = ("Primary", "Alternate", "Backup")

#let current-stroke = 0.9pt + ink
#let school-stroke = (paint: mute, thickness: 0.5pt, dash: (2pt, 1.5pt))
#let tour-stroke = 0.5pt + luma(55%)

// ─── vectors ─────────────────────────────────────────────────────────────────
#let vectors = data.vectors.enumerate().map(((i, v)) => (
  rank: ranks.at(i, default: "Vector " + str(i + 1)),
  track: or-none(v.track),
  // A length outside 0.5 to 4 draws at the nearer end under a dagger the
  // legend explains, since the schema cannot bound a number.
  tours: v.tours.map(t => (
    title: trim(t.title),
    span: calc.clamp(int(calc.round(float(t.years) * 2)), 1, 8),
    out-of-range: t.years < 0.25 or t.years > 4,
    school: t.school,
  )),
))

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

// The band is ruled to an even height, so a narrow block cannot grow to fit its
// title: the title sets to the block instead. That is the ceiling `title`
// warns about in Quill.yaml — about twelve characters per year of length.
#let title-size(span) = {
  let w = span * col-width
  if w < 0.55in { micro } else if w < 1.3in { small } else { base }
}

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
// The AFSC, duty title and unit read as one line under the name. The year group
// printed is the one the boards count from; an adjustment says where it came
// from, and an unadjusted one prints nothing more.
#grid(
  columns: (rail, 1fr),
  column-gutter: rail-gutter,
  align: bottom,
  stack(
    spacing: 6pt,
    text(size: display, weight: 800, tracking: -0.3pt, data.name),
    ..{
      let parts = (
        if afsc != none { text(weight: 600, afsc) },
        if duty != none { text(weight: 600, duty) },
        if unit != none { text(weight: 500, fill: mute, unit) },
      ).filter(x => x != none)
      if parts.len() > 0 { (parts.join(text(fill: mute)[ · ]),) } else { () }
    },
  ),
  grid(
    columns: (1fr,) * 4,
    column-gutter: col-gutter,
    align: top,
    fact("Year group", [#board-yg], note: if adjusted [adjusted from #comm-yg]),
    fact("Date of rank", show-date(data.date_of_rank)),
    fact("Arrived station", show-date(data.date_arrived_station)),
    fact("Advanced degree", or-none(data.advanced_degree)),
  ),
)

#v(7pt)
#line(length: 100%, stroke: 1.3pt + ink)

// ═══ TIMELINE ════════════════════════════════════════════════════════════════
#let in-window(cy) = cy >= start-year and cy <= last-year
#let ahead = ladder.filter(m => m.year > last-year and not m.done)

#section-rule(
  "Assignment vectors & development timeline",
  aside: [
    CY #start-year–#last-year · counted from YG #board-yg
    #if ahead.len() > 0 [ · #ahead.len() later milestone#if ahead.len() > 1 [s] beyond #last-year]
  ],
)

#let row-label(body) = table.cell(align: left + horizon, stroke: none)[
  #text(size: small, weight: 600, fill: mute)[#body]
]

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
#rows.push(row-label[Eligibility])
#for i in range(years) {
  let hits = ladder.filter(m => m.year == start-year + i or (i == 0 and m.overdue))
  rows.push(table.cell(colspan: 2, stroke: none, inset: (x: 1.5pt, y: 3pt))[
    #for m in hits [
      #block(spacing: 2pt, breakable: false)[#chip(m.label, m.tier, done: m.done, overdue: if m.overdue { m.year })]
    ]
  ])
}

// An empty half-year is its own cell, so the year rules run through it.
#let empty(n, stroke: none) = range(n).map(_ => table.cell(stroke: stroke)[])

// one row per constraint: a bar from today to the end of the last year it holds,
// ruled under and closed at its end, so it reads as "until here"
#for (i, c) in constraints.enumerate() {
  rows.push(if i == 0 { row-label[Constraints] } else { table.cell(stroke: none)[] })
  let label = [#text(size: micro, weight: 600)[#c.note]#text(size: micro, fill: mute)[#(" · through " + str(c.through))]]
  // A bar too short for its label carries it past its end rather than
  // wrapping it, so every constraint costs the timeline one line.
  rows.push(table.cell(colspan: c.end, stroke: none, inset: (x: 1pt, y: 0.5pt))[
    #layout(size => {
      // A bar that runs past the window is left open at its end, since the
      // window's edge is not where it stops.
      let open = c.through > last-year
      let fits = measure(label).width + 8pt <= size.width
      box(width: 100%, height: 8.5pt, stroke: (bottom: 0.9pt + ink, right: if open { none } else { 0.9pt + ink }))
      place(left + bottom, dx: if fits { 3pt } else { size.width + 3pt }, dy: -2pt, box(width: 10in, label))
    })
  ])
  rows += empty(cols - c.end)
}

// The assignment held now, drawn once across every vector row. It reads like a
// tour block, title over a line of small print, and sheds what its space cannot
// hold: the small print a word at a time, then the flat setting for one up the
// side, then the text itself, since the header already names the job. The unit
// is left to the header throughout.
#let current-block = {
  let title = text(size: small, weight: 600, if duty != none { duty } else { [Current assignment] })
  let over(note) = (title, text(size: micro, fill: mute, note)).join(linebreak())
  let move = [to #data.move_cycle #move-year]
  let settings = (over[Current · #move], over(move), title)
  box(width: 100%, height: 100%, stroke: current-stroke, inset: 3pt, layout(size => {
    let fits(c, w, h) = { let m = measure(c); m.width <= w and m.height <= h }
    let flat = settings.find(c => fits(c, size.width, size.height))
    let up = settings.find(c => fits(c, size.height, size.width))
    block(width: size.width, height: size.height, if flat != none {
      align(left + horizon, flat)
    } else if up != none {
      align(left + bottom, rotate(-90deg, reflow: true, up))
    })
  }))
}

// one row per vector
#for (rank, v) in vectors.enumerate() {
  let placed = lay(v.tours)
  let beyond = placed.filter(p => p.beyond)
  let top-rule = (top: 0.4pt + hair)
  let tint = rank-tints.at(calc.min(rank, rank-tints.len() - 1))
  let sub = ()
  if v.track != none { sub.push(v.rank) }
  if beyond.len() > 0 { sub.push([+#beyond.len() past #last-year]) }

  rows.push(table.cell(align: left + horizon, stroke: top-rule, inset: (right: 5pt, y: 3pt))[
    #text(size: lead, weight: 700)[#if v.track != none { v.track } else { v.rank }]
    #if sub.len() > 0 [
      #linebreak()
      #text(size: micro, fill: mute)[#sub.join[ · ]]
    ]
  ])

  if rank == 0 and current-span > 0 {
    rows.push(table.cell(
      colspan: current-span,
      rowspan: vectors.len(),
      stroke: none,
      inset: (x: 1pt, y: 2pt),
    )[#current-block])
  }

  let at = current-span
  for p in placed.filter(p => not p.beyond) {
    let edge = if p.tour.school { school-stroke } else { tour-stroke }
    rows.push(table.cell(
      colspan: p.drawn,
      stroke: top-rule,
      inset: (left: if p.cut { 0pt } else { 1pt }, right: if p.clipped { 0pt } else { 1pt }, y: 2pt),
      align: left + horizon,
    )[
      // The block is drawn inside its cell rather than as the cell's fill, so
      // adjacent tours are parted by a gap and an edge instead of by a second
      // shade — which is what lets the shade say which vector this is. A tour
      // the window cuts runs to the window's edge with that end open.
      #box(
        width: 100%,
        height: 100%,
        fill: if p.tour.school { none } else { tint },
        stroke: (
          top: edge,
          bottom: edge,
          left: if p.cut { none } else { edge },
          right: if p.clipped { none } else { edge },
        ),
        inset: (x: 3pt, y: 2pt),
        baseline: 0pt,
        // A title past the guidance in Quill.yaml is cut at the block's edge
        // rather than printed over the next block.
        clip: true,
      )[
        #set align(left + horizon)
        #text(size: title-size(p.drawn), weight: 600, style: if p.tour.school { "italic" } else { "normal" })[
          #p.tour.title
        ]
        #linebreak()
        #text(size: micro, fill: mute)[
          #span-label(p.span)#if p.tour.out-of-range [#sym.dagger]#if p.drawn * col-width >= 0.55in [ · #cycle-of(p.start)]#if p.clipped [ · runs past #last-year]
        ]
      ]
    ])
    at = p.from + p.drawn
  }
  rows += empty(cols - at, stroke: top-rule)
}

// The years are ruled from the axis down, so a block is read against the gate
// above it without a straightedge. A rule stops where a block crosses it: the
// block is in front of the year, not cut by it. On a blank chart the rules are
// the grid a pen draws the vectors on. The window's far side is left open,
// because the career is not over where the chart stops.
#table(
  columns: (label-width,) + (1fr,) * cols,
  rows: (auto, auto) + (auto,) * constraints.len() + (band-height,) * vectors.len(),
  stroke: none,
  inset: 2pt,
  ..range(years).map(i => table.vline(x: 1 + 2 * i, start: 1, stroke: 0.4pt + hair)),
  ..rows,
  table.hline(stroke: 0.4pt + hair),
)

// The legend names the marks this chart actually carries and no others.
#let drawn-tours = vectors.map(v => lay(v.tours).filter(p => not p.beyond)).flatten()
#let shown = ladder.filter(m => in-window(m.year) or m.overdue)
#let swatch(..args) = box(width: 14pt, height: 6pt, ..args)
#let legend = ()
#if current-span > 0 { legend.push([#swatch(stroke: current-stroke) current assignment]) }
#if shown.any(m => m.tier == "board" and not m.done) { legend.push([#chip("board", "board") ranked against your year group]) }
#if shown.any(m => m.tier == "look" and not m.done) { legend.push([#chip("look", "look") one of a numbered series]) }
#if shown.any(m => m.done) { legend.push([#chip("done", "course", done: true) already done]) }
#if shown.any(m => m.overdue) { legend.push([#chip("course", "course", overdue: "year") passed unticked]) }
#if drawn-tours.any(p => not p.tour.school) { legend.push([#swatch(fill: rank-tints.at(0), stroke: tour-stroke) assignment]) }
#if drawn-tours.any(p => p.tour.school) { legend.push([#swatch(stroke: school-stroke) school]) }
#if drawn-tours.any(p => p.tour.out-of-range) { legend.push([#sym.dagger length entered outside 0.5–4 yr, drawn at the nearer end]) }

#if legend.len() > 0 {
  v(5pt)
  text(size: micro, fill: mute, legend.join(h(12pt)))
}

// ═══ RECORD ══════════════════════════════════════════════════════════════════
// Every member arrives, held or not, in the order Quill.yaml declares it; an
// unheld member's detail arrives blank whatever the document retains. The
// headings repeat each matrix's `title`, which the data does not carry.
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
#let strats = data.stratifications.sorted(key: s => -s.year)
#let any-hlr = strats.any(s => not blank(s.hlr))
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
      text(weight: 700)[#s.year],
      strat-cell(s.rater),
      ..if any-hlr { (strat-cell(s.hlr),) },
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
          // The detail runs on after the label: under it, the tallest column
          // costs the notes a line a detail.
          #if not blank(m.detail) [
            #text(size: micro, style: "italic", fill: mute)[#h(2pt)#trim(m.detail)]
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
