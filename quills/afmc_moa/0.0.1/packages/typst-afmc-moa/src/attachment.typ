// attachment.typ — MOA attachment pages (DoDI 4000.19 Figure 1)
//
// Attachment A is the reimbursable financial-details page, generated
// automatically from structured fields when `reimbursable` is true.
// Attachments B onward are user-authored `attachment` cards with a title
// and a freeform body, numbered the same way as the main body.

#import "body.typ": render-moa-body
#import "utils.typ": falsey, numbered-list

#let render-attachment-a(data) = {
  pagebreak()
  align(center)[
    #upper[Attachment A] \
    to \
    #data.subject, #data.agreement_number Financial details \
    for a reimbursable MOA
  ]
  v(1em)

  numbered-list("", (
    (active: true, render: n => [#n Reimbursable Support: #data.reimbursable_support]),
    (active: true, render: n => [#n Estimated Amount of Funds to Be Reimbursed: #data.estimated_amount, Appropriation: FY #data.appropriation_fy]),
    (
      active: not falsey(data.cost_center_provider) or not falsey(data.cost_center_receiver),
      render: n => [#n Cost Center Number: (if required) Provider #data.cost_center_provider, Receiver #data.cost_center_receiver.],
    ),
    (active: true, render: n => [#n Financial Points of Contact: Provider: #data.financial_poc_provider Receiver: #data.financial_poc_receiver]),
    (
      active: not falsey(data.financial_additional_info),
      render: n => [#n #data.financial_additional_info],
    ),
  ))
}

/// Renders one card-driven attachment (B, C, ...).
///
/// - letter (str): Attachment letter, e.g. "B".
/// - data (dictionary): Top-level resolved MOA data (for subject/agreement_number).
/// - title (str): Attachment subject, printed on the cover line.
/// - body (content): Freeform attachment text, auto-numbered like the main body.
#let render-attachment-card(letter, data, title, body) = {
  pagebreak()
  align(center)[
    #upper[Attachment #letter] \
    to \
    #data.subject, #data.agreement_number #title
  ]
  v(1em)
  render-moa-body(body)
}
