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
// Every 17X board and school gate, as an offset from the year group. Counted
// from the adjusted year group where one is set, because that is the year a
// board counts from.
#let ladder = (
  (3, "Cyber 200"),
  (4, "SOS board"),
  (7, "Maj board"),
  (8, "IDE 1st look"),
  (9, "Cyber 300"),
  (9, "IDE 2nd look"),
  (10, "IDE 3rd look"),
  (11, "IDE final look"),
  (12, "Lt Col board"),
  (14, "SDE 1st look"),
  (15, "SDE 2nd look"),
  (16, "SDE 3rd look"),
  (17, "SDE final look"),
)

// ─── the vocabulary ──────────────────────────────────────────────────────────
// Printed in full and marked against what the document claims, so an unmarked
// box is as much of the chart as a marked one. These labels are the `enum`
// members in Quill.yaml; design/cyber_ribbon_chart/check_vocabulary.mjs holds
// the two lists to each other.
#let vocabulary = (
  ("Leadership & Command", (
    "Sq/CC Candidate", "DO / Det CC Candidate", "Flight CC",
    "Director of Operations", "Detachment CC", "Squadron CC",
  )),
  ("Operations", (
    "DODIN Ops", "DCO (Defensive)", "OCO (Offensive)", "Crew CC",
    "Cyber Engineer", "Team Lead (MDT / CPT)", "Expeditionary Comms", "Mission CC",
  )),
  ("Staff & Functional", (
    "Exec / Aide / CAG", "HAF Staff", "MAJCOM / NAF Staff", "Joint Staff",
    "Instructor", "Joint Qualified Officer (JQO)",
  )),
  ("Education & PME", (
    "Commissioning Source DG", "SOS DG / Top Third", "Cyber 200", "Cyber 300",
    "IDE Candidate / Graduate", "SDE Candidate / Graduate", "Weapons School / WIC DG",
  )),
)

// ─── inputs ──────────────────────────────────────────────────────────────────
#let comm-yg = data.commissioning_yg
#let adj-yg = data.adjusted_yg
#let board-yg = if adj-yg != 0 { adj-yg } else { comm-yg }
#let start-year = data.timeline_start_year
#let years = calc.max(1, data.timeline_years)
#let cols = years * 2
#let narrow = years > 12
#let band-height = if narrow { 0.60in } else { 0.72in }
#let chip-size = if narrow { 5.6pt } else { 6.2pt }

// ─── vectors, gathered off the flat card list ────────────────────────────────
// A vector card opens a row and every tour after it belongs to that row, until
// the next vector card. A tour that arrives before any vector opens one, so a
// document that lists tours and forgets the vector still draws.
#let vectors = ()
#for card in data.at("$cards", default: ()) {
  let kind = card.at("$kind", default: none)
  if kind == "vector" {
    vectors.push((label: trim(card.label), focus: trim(card.focus), tours: ()))
  } else if kind == "tour" {
    if vectors.len() == 0 {
      vectors.push((label: [Vector 1], focus: [], tours: ()))
    }
    let last = vectors.last()
    last.tours.push((
      title: trim(card.title),
      duration: float(card.duration),
      vml: card.vml,
    ))
    vectors.at(vectors.len() - 1) = last
  }
}

// A half-year column is H1 (Jan–Jun, even) or H2 (Jul–Dec, odd). A VML cycle
// picks the phase a tour may start on, so a tour waits for its own cycle rather
// than butting against the one before it, and the wait is drawn as the gap it
// is. Nothing is dropped: a tour the window cuts keeps a torn edge, and one
// that falls past the window entirely is counted on the row's label.
#let place(tours) = {
  let cursor = 0
  let out = ()
  for t in tours {
    let phase = if t.vml == "Winter" { 0 } else { 1 }
    let start = cursor
    if calc.rem(start, 2) != phase { start += 1 }
    let span = calc.max(1, int(calc.round(t.duration * 2)))
    cursor = start + span
    if start >= cols {
      out.push((tour: t, beyond: true))
    } else {
      out.push((
        tour: t,
        beyond: false,
        start: start,
        span: calc.min(span, cols - start),
        clipped: start + span > cols,
      ))
    }
  }
  out
}

// The band is ruled to an even height, so a narrow block cannot grow to fit its
// title: the title sets to the block instead. A half-year column holds about
// eight characters, which is what `title` warns about in Quill.yaml.
#let title-size(span) = if span <= 1 { 6.4pt } else if span == 2 { 7.2pt } else { 8pt }

#let duration-label(d) = {
  let whole = calc.floor(d)
  if d - whole == 0 { [#whole yr] } else if whole == 0 { [6 mo] } else { [#whole½ yr] }
}

// ═══ IDENTITY ════════════════════════════════════════════════════════════════
#grid(
  columns: (2.7in, 1fr),
  column-gutter: 18pt,
  align: bottom,
  [
    #text(size: 18pt, weight: 800, tracking: -0.25pt)[#data.name]
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

#v(8pt)
#line(length: 100%, stroke: 1.3pt + ink)
#v(12pt)

// ═══ TIMELINE ════════════════════════════════════════════════════════════════
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
      #block(spacing: 2pt, breakable: false)[
        #box(fill: luma(94%), stroke: (left: 1.5pt + ink), inset: (x: 3pt, y: 2pt))[
          #text(size: chip-size, weight: 600)[#m.at(1)]
        ]
      ]
    ]
  ])
}

// one row per vector
#let tints = (luma(91%), luma(80%))
#for v in vectors {
  let placed = place(v.tours)
  let beyond = placed.filter(p => p.beyond)
  let top-rule = (top: 0.4pt + luma(80%))

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
      colspan: p.span,
      fill: tints.at(calc.rem(idx, 2)),
      stroke: if p.clipped { (..top-rule, right: 1pt + ink) } else { top-rule },
      inset: (x: 4pt, y: 3pt),
      align: left + horizon,
    )[
      #text(size: title-size(p.span), weight: 600)[#p.tour.title]
      #linebreak()
      #text(size: 5.8pt, fill: mute)[
        #duration-label(p.tour.duration) · #p.tour.vml VML#if p.clipped [ · runs past #(start-year + years - 1)]
      ]
    ])
    at = p.start + p.span
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

#v(13pt)

// ═══ RECORD ══════════════════════════════════════════════════════════════════
#let held = (:)
#for row in data.qualifications { held.insert(row.qualification, trim(row.detail)) }

#let remarks = (
  ("Awards", data.awards),
  ("Certifications", data.certifications),
  ("Deployments", data.deployments),
).filter(r => r.at(1).len() > 0)

// The record column carries the stratifications and the remarks. With neither,
// it is not a narrow empty column beside the vocabulary — there is no column.
#let has-record = data.stratifications.len() > 0 or remarks.len() > 0

#let record-column = [
    #if data.stratifications.len() > 0 [
      #section-rule("Recent stratifications")
    ]
    #for s in data.stratifications {
      block(spacing: 9pt)[
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

    #if remarks.len() > 0 [
      #v(4pt)
      #section-rule("Awards · certifications · deployments")
      #for (label, lines) in remarks {
        block(spacing: 6pt)[
          #text(size: 5.8pt, weight: 600, tracking: 0.4pt, fill: mute)[#upper(label)]
          #v(1.5pt)
          #for l in lines [#block(spacing: 2.5pt)[#text(size: 7.6pt)[#l]]]
        ]
      }
    ]
]

#let vocabulary-column = [
    #section-rule("Qualifications & experience")
    #grid(
      columns: (1fr,) * vocabulary.len(),
      column-gutter: 14pt,
      ..vocabulary.map(group => {
        let (heading, items) = group
        [
          #text(size: 6.2pt, weight: 700, tracking: 0.4pt, fill: mute)[#upper(heading)]
          #v(3pt)
          #for label in items {
            let is-held = label in held
            block(spacing: 0pt, inset: (y: 2.2pt))[
              #grid(columns: (7.6pt, 1fr), align: (left + top, left + top))[
                #if is-held { held-mark } else { open-mark }
              ][
                #text(
                  size: 7.2pt,
                  weight: if is-held { 600 } else { 400 },
                  fill: if is-held { ink } else { luma(50%) },
                )[#label]
                #if is-held and not blank(held.at(label)) [
                  #linebreak()
                  #text(size: 6.6pt, style: "italic", fill: mute)[#held.at(label)]
                ]
              ]
            ]
          }
        ]
      }),
    )
]

#if has-record {
  grid(columns: (2.45in, 1fr), column-gutter: 24pt, record-column, vocabulary-column)
} else {
  vocabulary-column
}
