#import "config.typ": *
#import "utils.typ": *

#let cover-bar() = block(
  width: 100%,
  fill: black,
  inset: (y: 10pt),
  align(center, text(size: 22pt, weight: "bold", fill: white)[CUI]),
)

#let cover-field(label, value) = {
  grid(
    columns: (2.35in, 1fr),
    column-gutter: 10pt,
    row-gutter: 4pt,
    text(size: SMALL_SIZE, weight: "bold")[#label],
    {
      set text(size: SMALL_SIZE)
      if blank(value) {
        block(width: 100%, stroke: (bottom: 0.6pt + black), height: 1.05em)
      } else {
        block(width: 100%, stroke: (bottom: 0.6pt + black), inset: (bottom: 2pt), value)
      }
    },
  )
}

#let cover-sheet(
  memo-number: none,
  study-name: none,
  subject: none,
  controlled-by-component: none,
  controlled-by-office: none,
  categories: none,
  distribution: none,
  poc: none,
) = {
  set par(spacing: 0.55em, leading: 0.4em)

  let title-bits = ()
  if not blank(memo-number) {
    title-bits.push([Technical Memorandum No. #trim-inline(memo-number)])
  }
  if not blank(study-name) { title-bits.push(trim-inline(study-name)) }
  if not blank(subject) { title-bits.push(trim-inline(subject)) }
  let title = if title-bits.len() == 0 { [] } else { title-bits.join([; ]) }

  cover-bar()
  v(0.35in)
  align(center)[
    #text(size: 16pt, weight: "bold")[CONTROLLED UNCLASSIFIED INFORMATION]
  ]
  v(0.35in)

  cover-field([Document title], title)
  v(0.18in)
  cover-field([Controlled by (component)], trim-inline(controlled-by-component))
  v(0.18in)
  cover-field([Controlled by (office)], trim-inline(controlled-by-office))
  v(0.18in)
  cover-field([CUI category], categories)
  v(0.18in)
  cover-field([Distribution / LDC], distribution-text(distribution))
  v(0.18in)
  cover-field([POC], trim-inline(poc))

  v(0.4in)
  block(
    width: 100%,
    stroke: 1pt + black,
    inset: 12pt,
    {
      set text(size: SMALL_SIZE)
      set par(leading: 0.5em, spacing: 0.6em, justify: true)
      SF901_ATTENTION
    },
  )

  v(1fr)
  block(width: 100%, {
    set text(size: 8pt)
    SF901_FOOTER
  })
  v(0.2in)
  cover-bar()
}
