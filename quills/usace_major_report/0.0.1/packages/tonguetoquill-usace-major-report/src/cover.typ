#import "config.typ": *
#import "utils.typ": *

#let cover-mark(weight: "regular") = text(
  size: 80pt,
  fill: white,
  weight: weight,
  tracking: 0.02em,
)[CUI]

#let cover-attention-label() = text(
  size: 16pt,
  fill: white,
  weight: "regular",
  tracking: 0.14em,
)[ATTENTION]

#let form-row(label, value, height: auto) = {
  let body = if blank(value) { label } else { [#label #h(0.2em)#value] }
  table.cell(
    inset: (x: 5pt, y: 3.5pt),
    {
      set text(size: 8.5pt, fill: black)
      set par(leading: 0.32em, spacing: 0pt)
      if height == auto {
        body
      } else {
        block(width: 100%, height: height, body)
      }
    },
  )
}

#let cover-sheet(
  memo-number: none,
  study-name: none,
  subject: none,
  prepared-for: none,
  date: none,
  controlled-by-component: none,
  controlled-by-office: none,
  categories: none,
  distribution: none,
  poc: none,
) = {
  set par(spacing: 0pt, leading: 0.35em)
  set block(spacing: 0pt)
  set align(center)

  let printed-date = format-date(date, pattern: table-date-pattern)
  let ldc = trim-inline(distribution)

  cover-mark(weight: "bold")
  v(0.22in)
  cover-attention-label()
  v(0.22in)

  set align(left)
  block(width: 100%, table(
    columns: 1,
    stroke: 0.65pt + black,
    fill: white,
    form-row([Date:], printed-date),
    form-row([Customer Name or Substituted Name:], trim-inline(prepared-for)),
    form-row([Project Number or Internal Number:], trim-inline(memo-number)),
    form-row([Project Name or Substituted Name:], trim-inline(study-name)),
    form-row([Part Number (Not CUI) or Internal Part Number:], none),
    form-row([Limited Dissemination Control:], ldc),
    form-row([Data Type Contained:], none),
    form-row([Data Type Contained (2):], none),
    form-row([Other Data:], none),
    form-row([Notes:], none, height: 0.58in),
    form-row([Controlled By:], trim-inline(controlled-by-component)),
    form-row([Controlled By:], trim-inline(controlled-by-office)),
    form-row([CUI Category(ies):], categories),
    form-row([Limited Dissemination Control:], ldc),
    form-row([Point of Contact (Name/Phone):], trim-inline(poc)),
  ))

  v(0.18in)
  align(center, cover-attention-label())
  v(0.08in)

  block(
    width: 100%,
    fill: white,
    stroke: 0.65pt + black,
    inset: (x: 12pt, top: 10pt, bottom: 8pt),
    {
      set text(size: 8.5pt, fill: black)
      set par(leading: 0.42em, spacing: 0.7em)
      align(center, SF901_ATTENTION)
      v(0.12in)
      align(right, text(size: 5.5pt, SF901_FOOTER))
    },
  )

  v(1fr)
  align(center, cover-mark())
}
