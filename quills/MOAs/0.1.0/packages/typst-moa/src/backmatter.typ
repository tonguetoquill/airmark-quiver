// backmatter.typ — AGREED: two-column signature blocks + mid-point review
// (DoDI 4000.19 Figure 1). Wrapped in a single non-breakable block so the
// signature blocks are never split across a page, per the template note
// "Approval Authority signatures will never be alone on a blank page."

#import "config.typ": spacing
#import "utils.typ": LINE_STRIDE, blank-line, blank-lines, ensure-array, format-date

#let render-signature-column(signatory, signing-field, width) = context {
  let stride = LINE_STRIDE.get()
  if stride == none {
    let h = measure(par(spacing: 0pt)[x]).height
    stride = measure(par(spacing: 0pt)[x#linebreak()x]).height - h
  }
  block(width: width, breakable: false)[
    #if signing-field != none {
      place(dy: -(stride * 3), box(width: width, height: stride * 3, signing-field))
    }
    #blank-lines(3)
    #line(length: width)
    #v(2pt)
    Signature
    #v(1em)
    #signatory \
    Name and Title of Signatory
    #v(1em)
    #line(length: 60%)
    #v(2pt)
    (Date)
  ]
}

#let backmatter(
  first_party_name: none,
  second_party_name: none,
  first_party_signatory: none,
  second_party_signatory: none,
  mid_point_review_due_date: none,
  first_signing_field: none,
  second_signing_field: none,
) = context {
  let gutter = 0.5in
  let col-width = (page.width - 2 * spacing.margin - gutter) / 2

  block(breakable: false)[
    #v(1em)
    AGREED:
    #v(1em)
    #grid(
      columns: (col-width, gutter, col-width),
      [For the #first_party_name—], [], [For the #second_party_name—],
    )
    #v(1em)
    #grid(
      columns: (col-width, gutter, col-width),
      render-signature-column(first_party_signatory, first_signing_field, col-width),
      [],
      render-signature-column(second_party_signatory, second_signing_field, col-width),
    )
    #blank-lines(2)
    Mid-Point Review Due Date: #format-date(mid_point_review_due_date)
    #v(1em)
    Mid-Point Review completed by: #line(length: 3in) \
    #h(1.9in)Signature and Name of Reviewer
  ]
}
