// frontmatter.typ — page setup, title block, and intro paragraph for a
// DoDI 4000.19 Memorandum of Agreement (Figure 1)

#import "config.typ": DEFAULT_BODY_FONTS, TITLE_TOP_GAP, spacing
#import "utils.typ": LINE_STRIDE, blank-line, blank-lines, falsey, join-inline

#let frontmatter(
  first_party_name: none,
  second_party_name: none,
  second_party_is_non_government: false,
  second_party_mailing_address: none,
  subject: none,
  agreement_number: none,
  body_font: DEFAULT_BODY_FONTS,
  font_size: 12pt,
  it,
) = {
  assert(first_party_name != none, message: "first_party_name is required")
  assert(second_party_name != none, message: "second_party_name is required")
  assert(subject != none, message: "subject is required")
  assert(agreement_number != none, message: "agreement_number is required")

  // ── Document-wide typography ─────────────────────────────────────────────
  set par(leading: spacing.line, spacing: spacing.line, justify: false)
  set block(above: spacing.line, below: 0em, spacing: 0em)
  set text(font: body_font, size: font_size, fallback: true)

  // ── Page geometry ────────────────────────────────────────────────────────
  set page(
    paper: "us-letter",
    margin: (top: spacing.margin, bottom: spacing.margin, left: spacing.margin, right: spacing.margin),
    header: context if counter(page).get().first() > 1 {
      place(dy: +.5in, block(width: 100%, align(right, text(12pt)[#counter(page).display()])))
    },
  )

  // ── Cache line stride ────────────────────────────────────────────────────
  context {
    let h1 = measure(par(spacing: 0pt)[x]).height
    LINE_STRIDE.update(measure(par(spacing: 0pt)[x#linebreak()x]).height - h1)
  }

  // ── Title block ──────────────────────────────────────────────────────────
  v(TITLE_TOP_GAP)
  align(center)[
    #upper[MEMORANDUM OF AGREEMENT] \
    BETWEEN \
    THE #upper(first_party_name) \
    AND \
    THE #upper(second_party_name) \
    FOR \
    #upper(subject) \
    #agreement_number
  ]

  blank-lines(2)

  // ── Intro paragraph ──────────────────────────────────────────────────────
  // Figure 1: "This is a memorandum of agreement (MOA) between the [First
  // Party] and the [Second Party] [if the Second Party is a non-governmental
  // entity, include its address]. When referred to collectively, the [First
  // Party] and the [Second Party] are referred to as the 'Parties.'"
  let second-party-clause = if second_party_is_non_government {
    [#second_party_name (#join-inline(second_party_mailing_address))]
  } else {
    second_party_name
  }
  block[
    #h(0.5in)This is a memorandum of agreement (MOA) between the #first_party_name and the #second-party-clause. When referred to collectively, the #first_party_name and the #second_party_name are referred to as the "Parties."
  ]

  blank-line()
  it
}
