#import "@local/quillmark-helper:0.1.0": data

#let ink = luma(12%)
#let mute = luma(45%)
#let faint = luma(62%)

#let margin = 0.45in
#set page(width: 11in, height: 8.5in, margin: margin)
#set text(size: 8pt, fill: ink)

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

// The bundled fallback face carries no geometric glyphs — no ✓, ■, □, ●, ▸ — so
// a mark is drawn rather than set. Held against open is a value contrast, which
// is what survives the photocopier these are read from.
#let held-mark = box(baseline: 0.5pt, rect(width: 4.6pt, height: 4.6pt, fill: ink, stroke: 0.5pt + ink))
#let open-mark = box(baseline: 0.5pt, rect(width: 4.6pt, height: 4.6pt, fill: none, stroke: 0.5pt + faint))

#let section-rule(title) = block(spacing: 0pt, below: 5pt)[
  #text(size: 6.6pt, weight: 700, tracking: 0.7pt)[#upper(title)]
  #v(2pt)
  #line(length: 100%, stroke: 0.6pt + ink)
]

#let fact(label, value) = block(spacing: 0pt)[
  #text(size: 5.8pt, weight: 600, tracking: 0.4pt, fill: mute)[#upper(label)]
  #v(1.5pt)
  #text(size: 8.5pt, weight: 500)[#if value == none { text(fill: faint)[—] } else { value }]
]

#let show-date(d) = if d == none { none } else { d.display("[day padding:none] [month repr:short] [year]") }
#let or-none(v) = if blank(v) { none } else { trim(v) }

// ─── inputs ──────────────────────────────────────────────────────────────────
#let quals = data.qualifications
#let comm-yg = data.commissioning_yg
#let adj-yg = data.at("adjusted_yg", default: none)
#let board-yg = if adj-yg != none { adj-yg } else { comm-yg }
#let start-year = data.timeline_start_year
#let years = calc.max(1, data.timeline_years)
#let cols = years * 2
#let last-year = start-year + years - 1
#let narrow = years > 12
#let band-height = 0.46in
#let label-width = 1.2in
#let chip-size = if narrow { 5.6pt } else { 6.2pt }
#let chip-inset = if narrow { 2pt } else { 3.5pt }

// A half-year column is H1 (Jan–Jun, even) or H2 (Jul–Dec, odd), and each one is
// a VML cycle: Winter moves land in the first half, Summer moves in the second.
#let cycle-of(col) = if calc.rem(col, 2) == 0 { "Winter" } else { "Summer" }
#let col-of(year, cycle) = (year - start-year) * 2 + if cycle == "Winter" { 0 } else { 1 }

#let duty = or-none(data.duty_title)
#let unit = or-none(data.unit)
#let move-year = data.at("move_year", default: none)

// Where the vectors branch. Everything left of it is the assignment you hold
// now, which is the same on every row, so it is drawn once across all of them.
#let move-col = if move-year == none { 0 } else { calc.max(0, col-of(move-year, data.move_cycle)) }
#let current-span = calc.min(move-col, cols)
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

// Three weights of gate, by what each one is: a board ranks you against a year
// group on a date, a look is one of a numbered series, a course is a seat. In a
// narrow window the chip's weight alone says board or look, as the legend
// does, so the word goes and the chip keeps to one line.
#let chip(label, tier, done: false) = {
  if narrow and tier != "course" { label = label.replace(regex(" (look|board)$"), "") }
  if done {
    box(inset: (x: 0.5pt, y: 2pt))[#text(size: chip-size, fill: faint)[#strike(stroke: 0.5pt + faint)[#label]]]
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
  tours: v.tours.map(t => (
    title: trim(t.title),
    span: calc.max(1, int(calc.round(float(t.years) * 2))),
    school: t.school,
  )),
))

// Tours lay end to end from the move, so each one's cycle is where the one
// before it ended rather than something to keep in step by hand.
//
// Nothing is dropped. A tour the window cuts keeps a torn edge and says which
// year it runs past; one starting beyond the window is counted on its row.
#let lay(tours) = {
  let cursor = move-col
  let out = ()
  for t in tours {
    out.push((tour: t, start: cursor, span: t.span))
    cursor += t.span
  }
  out.map(p => if p.start >= cols { (..p, beyond: true) } else {
    (..p, beyond: false, drawn: calc.min(p.span, cols - p.start), clipped: p.start + p.span > cols)
  })
}

// The band is ruled to an even height, so a narrow block cannot grow to fit its
// title: the title sets to the block instead. That is the ceiling `title`
// warns about in Quill.yaml — about twenty characters per year of length.
#let title-size(span) = {
  let w = span * col-width
  if w < 0.55in { 6pt } else if w < 1.3in { 7pt } else { 8pt }
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
#grid(
  columns: (2.7in, 1fr),
  column-gutter: 18pt,
  align: bottom,
  [
    #text(size: 17pt, weight: 800, tracking: -0.25pt)[#data.name]
    #if duty != none or unit != none [
      #v(2pt)
      #(
        if duty != none { text(size: 8pt, weight: 600, duty) },
        if unit != none { text(size: 8pt, weight: 500, fill: mute, unit) },
      ).filter(x => x != none).join(text(fill: mute)[ · ])
    ]
  ],
  grid(
    columns: (0.7fr, 1fr, 1fr, 1fr, 1fr, 1.4fr),
    column-gutter: 12pt,
    align: top,
    fact("AFSC", or-none(data.afsc)),
    fact("Commissioning YG", [#comm-yg]),
    fact("Adjusted YG", if adj-yg != none { [#adj-yg] } else { none }),
    fact("Date of rank", show-date(data.date_of_rank)),
    fact("Arrived station", show-date(data.date_arrived_station)),
    fact("Advanced degree", or-none(data.advanced_degree)),
  ),
)

#v(6pt)
#line(length: 100%, stroke: 1.3pt + ink)
#v(9pt)

// ═══ TIMELINE ════════════════════════════════════════════════════════════════
#let in-window(cy) = cy >= start-year and cy <= last-year
#let ahead = ladder.filter(m => m.year > last-year and not m.done)

#block(spacing: 0pt)[
  #grid(columns: (1fr, auto), align: (left + bottom, right + bottom),
    text(size: 6.6pt, weight: 700, tracking: 0.7pt)[#upper("Assignment vectors & development timeline")],
    text(size: 6.2pt, fill: mute)[
      CY #start-year–#last-year · counted from YG #board-yg
      #if ahead.len() > 0 [ · #ahead.len() later milestone#if ahead.len() > 1 [s] beyond #last-year]
    ],
  )
  #v(2pt)
  #line(length: 100%, stroke: 0.6pt + ink)
]
#v(5pt)

#let row-label(body) = table.cell(align: left + horizon, stroke: none)[
  #text(size: 6.4pt, weight: 600, fill: mute)[#body]
]

#let rows = ()

// year header
#rows.push(table.cell(stroke: none)[])
#for i in range(years) {
  rows.push(table.cell(colspan: 2, stroke: (bottom: 0.7pt + ink), inset: (bottom: 2.5pt))[
    #text(size: 8pt, weight: 700)[#(start-year + i)]
    #linebreak()
    #text(size: 5.8pt, fill: mute)[YG+#(start-year + i - board-yg)]
  ])
}

// milestone row
#rows.push(row-label[Eligibility])
#for i in range(years) {
  let hits = ladder.filter(m => m.year == start-year + i)
  rows.push(table.cell(colspan: 2, stroke: none, inset: (x: 1.5pt, y: 3pt))[
    #for m in hits [
      #block(spacing: 2pt, breakable: false)[#chip(m.label, m.tier, done: m.done)]
    ]
  ])
}

// one row per constraint: a bar from today to the end of the last year it holds,
// ruled under and closed at its end, so it reads as "until here"
#for (i, c) in constraints.enumerate() {
  rows.push(if i == 0 { row-label[Constraints] } else { table.cell(stroke: none)[] })
  let label = [#text(size: 6.2pt, weight: 600)[#c.note]#text(size: 5.8pt, fill: mute)[#(" · through " + str(c.through))]]
  // A bar too short for its label carries it past its end rather than
  // wrapping it, so every constraint costs the timeline one line.
  rows.push(table.cell(colspan: c.end, stroke: none, inset: (x: 1pt, y: 0.5pt))[
    #layout(size => {
      let fits = measure(label).width + 8pt <= size.width
      box(width: 100%, height: 8.5pt, stroke: (bottom: 0.9pt + ink, right: 0.9pt + ink))
      place(left + bottom, dx: if fits { 3pt } else { size.width + 3pt }, dy: -2pt, box(width: 3in, label))
    })
  ])
  if c.end < cols { rows.push(table.cell(colspan: cols - c.end, stroke: none)[]) }
}

// The assignment held now, drawn once across every vector row. Where it is
// too narrow to set across, it sets up the side.
#let current-block = {
  let lines = (
    text(size: 5.6pt, weight: 700, tracking: 0.5pt, fill: mute)[CURRENT],
    if duty != none { text(size: 7.2pt, weight: 600)[#duty] },
    if unit != none { text(size: 6.2pt, fill: mute)[#unit] },
    if move-year != none { text(size: 5.8pt, fill: mute)[to #data.move_cycle #move-year] },
  ).filter(l => l != none)
  let tall = vectors.len() * band-height
  box(width: 100%, height: 100%, stroke: current-stroke, inset: 3pt)[
    #set align(left + horizon)
    #if current-span * col-width >= 0.6in {
      lines.join(linebreak())
    } else {
      rotate(-90deg, reflow: true, box(width: tall - 8pt)[#set par(leading: 0.4em); #lines.join(linebreak())])
    }
  ]
}

// one row per vector
#for (rank, v) in vectors.enumerate() {
  let placed = lay(v.tours)
  let beyond = placed.filter(p => p.beyond)
  let top-rule = (top: 0.4pt + luma(80%))
  let tint = rank-tints.at(calc.min(rank, rank-tints.len() - 1))
  let sub = ()
  if v.track != none { sub.push(v.rank) }
  if beyond.len() > 0 { sub.push([+#beyond.len() past #last-year]) }

  rows.push(table.cell(align: left + horizon, stroke: top-rule, inset: (right: 5pt, y: 3pt))[
    #text(size: 8.5pt, weight: 700)[#if v.track != none { v.track } else { v.rank }]
    #if sub.len() > 0 [
      #linebreak()
      #text(size: 6pt, fill: mute)[#sub.join[ · ]]
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
    rows.push(table.cell(
      colspan: p.drawn,
      stroke: top-rule,
      inset: (x: 1pt, y: 2pt),
      align: left + horizon,
    )[
      // The block is drawn inside its cell rather than as the cell's fill, so
      // adjacent tours are parted by a gap and an edge instead of by a second
      // shade — which is what lets the shade say which vector this is.
      #box(
        width: 100%,
        height: 100%,
        fill: if p.tour.school { none } else { tint },
        stroke: if p.tour.school { school-stroke } else { tour-stroke },
        inset: (x: 3pt, y: 2pt),
        baseline: 0pt,
      )[
        #set align(left + horizon)
        #text(size: title-size(p.drawn), weight: 600, style: if p.tour.school { "italic" } else { "normal" })[
          #p.tour.title
        ]
        #linebreak()
        #text(size: 5.8pt, fill: mute)[
          #span-label(p.span)#if p.drawn * col-width >= 0.55in [ · #cycle-of(p.start)]#if p.clipped [ · runs past #last-year]
        ]
      ]
    ])
    at = p.start + p.drawn
  }
  if at < cols { rows.push(table.cell(colspan: cols - at, stroke: top-rule)[]) }
}

#table(
  columns: (label-width,) + (1fr,) * cols,
  rows: (auto, auto) + (auto,) * constraints.len() + (band-height,) * vectors.len(),
  stroke: none,
  inset: 2pt,
  ..rows,
)

// The legend names the marks this chart actually carries and no others.
#let drawn-tours = vectors.map(v => lay(v.tours).filter(p => not p.beyond)).flatten()
#let shown = ladder.filter(m => in-window(m.year))
#let swatch(..args) = box(width: 14pt, height: 6pt, ..args)
#let legend = ()
#if current-span > 0 { legend.push([#swatch(stroke: current-stroke) current assignment]) }
#if shown.any(m => m.tier == "board" and not m.done) { legend.push([#chip("board", "board") ranked against your year group]) }
#if shown.any(m => m.tier == "look" and not m.done) { legend.push([#chip("look", "look") one of a numbered series]) }
#if shown.any(m => m.done) { legend.push([#chip("done", "course", done: true) already done]) }
#if drawn-tours.any(p => not p.tour.school) { legend.push([#swatch(fill: rank-tints.at(0), stroke: tour-stroke) assignment]) }
#if drawn-tours.any(p => p.tour.school) { legend.push([#swatch(stroke: school-stroke) school]) }

#if legend.len() > 0 {
  v(3pt)
  text(size: 5.8pt, fill: mute, legend.join(h(6pt)))
}

#v(7pt)

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

#let strats = data.stratifications.sorted(key: s => -s.year)

// The stratifications sit beside the vocabulary; with none, there is no narrow
// empty column beside it, there is no column.
#let strats-column = [
    #section-rule("Recent stratifications")
    #for s in strats {
      block(spacing: 7pt)[
        #grid(columns: (0.44in, 1fr), column-gutter: 7pt, align: (right + top, left + top),
          text(size: 8.5pt, weight: 700)[#s.year],
          [
            #if not blank(s.rater) [#text(size: 8pt)[#s.rater]]
            #if not blank(s.rater) and not blank(s.hlr) [#linebreak()]
            #if not blank(s.hlr) [#text(size: 7.4pt, fill: mute)[#s.hlr]]
          ],
        )
      ]
    }
]

#let vocabulary-column = [
    #section-rule("Qualifications & experience")
    #grid(
      columns: (1fr,) * vocabulary.len(),
      column-gutter: 14pt,
      ..vocabulary.map(group => {
        let (heading, members) = group
        [
          #text(size: 6.2pt, weight: 700, tracking: 0.4pt, fill: mute)[#upper(heading)]
          #v(3pt)
          #set par(leading: 0.42em)
          #for (_, m) in members {
            block(spacing: 0pt, inset: (y: 1.1pt))[
              #grid(columns: (7.6pt, 1fr), align: (left + top, left + top))[
                #if m.held { held-mark } else { open-mark }
              ][
                #text(
                  size: 7.2pt,
                  weight: if m.held { 600 } else { 400 },
                  fill: if m.held { ink } else { luma(50%) },
                )[#m.title]
                #if not blank(m.detail) [
                  #text(size: 6.4pt, style: "italic", fill: mute)[#h(2pt)#trim(m.detail)]
                ]
              ]
            ]
          }
        ]
      }),
    )
]

#if strats.len() > 0 {
  grid(columns: (2.45in, 1fr), column-gutter: 24pt, strats-column, vocabulary-column)
} else {
  vocabulary-column
}

// Three lists side by side across the full width. Stacked in a narrow column
// they cost three times the height and read as one long list.
#if remarks.len() > 0 [
  #v(6pt)
  #section-rule("Awards · certifications · deployments")
  #grid(
    columns: (1fr,) * 3,
    column-gutter: 24pt,
    ..remarks.map(((label, lines)) => [
      #text(size: 5.8pt, weight: 600, tracking: 0.4pt, fill: mute)[#upper(label)]
      #v(2pt)
      #for l in lines [#block(spacing: 2.5pt)[#text(size: 7.6pt)[#l]]]
    ]),
  )
]

// ═══ NOTES ═══════════════════════════════════════════════════════════════════
// The one thing the page does that the browser tool it came from could not: a
// rater writes on it during the discussion, and the sheet becomes the record of
// the conversation. So the lines print whether or not anything was typed above
// them.
#v(7pt)
#section-rule("Development notes")
#let typed = data.at("$body", default: "")
#if type(typed) != str [
  #block(spacing: 6pt)[#text(size: 7.6pt)[#typed]]
]
#for _ in range(2) {
  v(11pt)
  line(length: 100%, stroke: 0.4pt + luma(80%))
}
#v(8pt)
#text(size: 6.2pt, fill: mute)[
  Discussed with #box(width: 1.7in, stroke: (bottom: 0.4pt + luma(60%)))[]
  #h(10pt) on #box(width: 1in, stroke: (bottom: 0.4pt + luma(60%)))[]
]
