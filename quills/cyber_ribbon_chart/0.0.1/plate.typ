#import "@local/quillmark-helper:0.1.0": data

#let ink = luma(12%)
#let mute = luma(45%)
#let faint = luma(62%)

#set page(width: 11in, height: 8.5in, margin: 0.45in)
#set text(font: "Figtree", size: 8pt, fill: ink)

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

// ─── the ladder ──────────────────────────────────────────────────────────────
// Every 17X board and school gate, as an offset from the year group, counted
// from the adjusted year group where one is set because that is the year a
// board counts from. The tier is how heavily it prints: a board is a date you
// are ranked against, a look is one of a numbered series, a course is neither.
#let ladder = (
  (3, "Cyber 200", "course"),
  (4, "SOS window", "course"),
  (7, "Maj board", "board"),
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
#let board-yg = if adj-yg != 0 { adj-yg } else { comm-yg }
#let start-year = data.timeline_start_year
#let years = calc.max(1, data.timeline_years)
#let cols = years * 2
#let narrow = years > 12
#let band-height = 0.52in
#let chip-size = if narrow { 5.6pt } else { 6.2pt }

// Three weights of gate, by what each one is: a board ranks you against a year
// group on a date, a look is one of a numbered series, a course is a seat.
#let chip(label, tier) = {
  if tier == "board" {
    box(fill: ink, inset: (x: 3.5pt, y: 2pt))[#text(size: chip-size, weight: 700, fill: white)[#label]]
  } else if tier == "look" {
    box(fill: none, stroke: 0.5pt + ink, inset: (x: 3.5pt, y: 2pt))[#text(size: chip-size, weight: 600)[#label]]
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
#let place(tours) = {
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
#let title-size(span) = if span <= 1 { 6.4pt } else if span == 2 { 7.2pt } else { 8pt }

// Half-columns back to years, so a stretched block prints the length it draws
// rather than the length it was given.
#let span-label(span) = {
  let years = span / 2
  if calc.rem(span, 2) == 0 { [#int(years) yr] } else { [#years yr] }
}

// ═══ IDENTITY ════════════════════════════════════════════════════════════════
#grid(
  columns: (2.7in, 1fr),
  column-gutter: 18pt,
  align: bottom,
  [
    #text(size: 17pt, weight: 800, tracking: -0.25pt)[#data.name]
    #if not blank(data.duty_title) [
      #v(2pt)
      #text(size: 8pt, weight: 500, fill: mute)[#data.duty_title]
    ]
  ],
  grid(
    columns: (1fr,) * 5,
    column-gutter: 12pt,
    align: top,
    fact("Commissioning YG", [#comm-yg]),
    fact("Adjusted YG", if adj-yg != 0 { [#adj-yg] } else { none }),
    fact("Date of rank", show-date(data.date_of_rank)),
    fact("Arrived station", show-date(data.date_arrived_station)),
    fact("Advanced degree", if blank(data.advanced_degree) { none } else { data.advanced_degree }),
  ),
)

#v(6pt)
#line(length: 100%, stroke: 1.3pt + ink)
#v(9pt)

// ═══ TIMELINE ════════════════════════════════════════════════════════════════
#let in-window(cy) = cy >= start-year and cy < start-year + years
#let ahead = ladder.filter(m => board-yg + m.at(0) >= start-year + years)

#block(spacing: 0pt)[
  #grid(columns: (1fr, auto), align: (left + bottom, right + bottom),
    text(size: 6.6pt, weight: 700, tracking: 0.7pt)[#upper("Assignment vectors & development timeline")],
    text(size: 6.2pt, fill: mute)[
      CY #start-year–#(start-year + years - 1) · counted from YG #board-yg
      #if ahead.len() > 0 [ · #ahead.len() later milestone#if ahead.len() > 1 [s] beyond #(start-year + years - 1)]
    ],
  )
  #v(2pt)
  #line(length: 100%, stroke: 0.6pt + ink)
]
#v(5pt)

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
#rows.push(table.cell(align: left + horizon, stroke: none)[
  #text(size: 6.4pt, weight: 600, fill: mute)[Eligibility]
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
  let placed = place(v.tours)
  let beyond = placed.filter(p => p.beyond)
  let top-rule = (top: 0.4pt + luma(80%))
  let tint = rank-tints.at(calc.min(rank, rank-tints.len() - 1))

  rows.push(table.cell(align: left + horizon, stroke: top-rule, inset: (right: 5pt, y: 3pt))[
    #text(size: 8.5pt, weight: 700)[#v.label]
    #if not blank(v.focus) or beyond.len() > 0 [
      #linebreak()
      #text(size: 6pt, fill: mute)[
        #if not blank(v.focus) [#v.focus]
        #if beyond.len() > 0 [
          #if not blank(v.focus) [ · ]
          +#beyond.len() past #(start-year + years)
        ]
      ]
    ]
  ])

  let at = 0
  let idx = 0
  for p in placed.filter(p => not p.beyond) {
    if p.start > at {
      rows.push(table.cell(colspan: p.start - at, stroke: top-rule)[])
      at = p.start
    }
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
        stroke: if p.tour.school { (paint: mute, thickness: 0.5pt, dash: (2pt, 1.5pt)) } else { 0.5pt + luma(55%) },
        inset: (x: 3pt, y: 2pt),
        baseline: 0pt,
      )[
        #set align(left + horizon)
        #text(size: title-size(p.drawn), weight: 600, style: if p.tour.school { "italic" } else { "normal" })[
          #p.tour.title
        ]
        #linebreak()
        #text(size: 5.8pt, fill: mute)[
          #span-label(p.span)#if p.held [ #sym.dagger] · #p.tour.vml#if p.clipped [ · runs past #(start-year + years - 1)]
        ]
      ]
    ])
    at = p.start + p.drawn
    idx += 1
  }
  if at < cols { rows.push(table.cell(colspan: cols - at, stroke: top-rule)[]) }
}

#table(
  columns: (1.2in,) + (1fr,) * cols,
  rows: (auto, auto) + (band-height,) * vectors.len(),
  stroke: none,
  inset: 2pt,
  ..rows,
)

// The legend names the marks this chart actually carries and no others.
#let drawn-tours = vectors.map(v => place(v.tours).filter(p => not p.beyond)).flatten()
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
  v(3pt)
  text(size: 5.8pt, fill: mute, legend.join(h(6pt)))
}

#v(9pt)

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

// The stratifications sit beside the vocabulary; with none, there is no narrow
// empty column beside it, there is no column.
#let strats-column = [
    #section-rule("Recent stratifications")
    #for s in data.stratifications {
      block(spacing: 7pt)[
        #grid(columns: (0.44in, 1fr), column-gutter: 7pt, align: (right + top, left + top),
          text(size: 8.5pt, weight: 700)[#s.year],
          [
            #if not blank(s.duty_strat) [#text(size: 8pt)[#s.duty_strat]]
            #if not blank(s.duty_strat) and not blank(s.senior_rater_strat) [#linebreak()]
            #if not blank(s.senior_rater_strat) [#text(size: 7.4pt, fill: mute)[#s.senior_rater_strat]]
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
                  #linebreak()
                  #text(size: 6.4pt, style: "italic", fill: mute)[#trim(m.detail)]
                ]
              ]
            ]
          }
        ]
      }),
    )
]

#if data.stratifications.len() > 0 {
  grid(columns: (2.45in, 1fr), column-gutter: 24pt, strats-column, vocabulary-column)
} else {
  vocabulary-column
}

// Three lists side by side across the full width. Stacked in a narrow column
// they cost three times the height and read as one long list.
#if remarks.len() > 0 [
  #v(8pt)
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
#v(9pt)
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
