#import "@local/quillmark-helper:0.1.0": data, signature-field
#import "@local/typst-afmc-moa:0.1.0": (
  attachment, attachment-card, backmatter, frontmatter, mainmatter, trim-inline,
)

// Every text field is `plaintext`/`richtext`, so it arrives as content carrying
// a space element on each side. `trim-inline` strips those once, here, so the
// package can interpolate a field straight into prose without it printing as
// "the Foo  and" or "(NASA) ." — and without boxing, which would stop a long
// party name from wrapping.
#let text-field(key) = trim-inline(data.at(key))

// Resolve optional fields with defaults; required fields are read directly
// since Quill.yaml enforces their presence.
#let resolved = (
  first_party_name: text-field("first_party_name"),
  second_party_name: text-field("second_party_name"),
  second_party_is_non_government: data.second_party_is_non_government,
  subject: text-field("subject"),
  agreement_number: text-field("agreement_number"),

  // Joined inline by the package, which trims each line itself.
  second_party_mailing_address: data.second_party_mailing_address,

  reimbursable: data.reimbursable,
  reimbursable_support: text-field("reimbursable_support"),
  estimated_amount: text-field("estimated_amount"),
  appropriation_fy: text-field("appropriation_fy"),
  cost_center_provider: text-field("cost_center_provider"),
  cost_center_receiver: text-field("cost_center_receiver"),
  financial_poc_provider: text-field("financial_poc_provider"),
  financial_poc_receiver: text-field("financial_poc_receiver"),
  financial_additional_info: text-field("financial_additional_info"),

  first_party_signatory: text-field("first_party_signatory"),
  second_party_signatory: text-field("second_party_signatory"),
  mid_point_review_due_date: data.mid_point_review_due_date,
)

// ── Frontmatter: page setup, title block, intro paragraph ──────────────────
#show: frontmatter.with(
  first_party_name: resolved.first_party_name,
  second_party_name: resolved.second_party_name,
  second_party_is_non_government: resolved.second_party_is_non_government,
  second_party_mailing_address: resolved.second_party_mailing_address,
  subject: resolved.subject,
  agreement_number: resolved.agreement_number,
)

// The MOA's standard sections (Background, Authorities, ...) are authored
// as their own cards but rendered inline as the body's numbered paragraphs,
// chained into the same DoDI 4000.19 decimal numbering as the rest of the
// body (no page break, no numbering restart). Only the first card found of
// each kind is used.
#let card-body(kind) = {
  let bodies = ()
  for card in data.at("$cards") {
    if card.at("$kind", default: none) == kind and "$body" in card {
      bodies.push(card.at("$body"))
    }
  }
  if bodies.len() > 0 { bodies.at(0) } else { none }
}
#let background = card-body("background")
#let authorities = card-body("authorities")
#let purpose_and_scope = card-body("purpose_and_scope")
#let responsibilities_of_the_parties = card-body("responsibilities_of_the_parties")
#let personnel = card-body("personnel")
#let general_provisions = card-body("general_provisions")
#let financial_details = card-body("financial_details")
#let list_of_attachments = card-body("list_of_attachments")

// ── Mainmatter: every standard section is its own card, spliced together
// here in DoDI 4000.19 document order ─────────────────────────────────────
#mainmatter[
  #if background != none [#background]
  #if authorities != none [#authorities]
  #if purpose_and_scope != none [#purpose_and_scope]
  #if responsibilities_of_the_parties != none [#responsibilities_of_the_parties]
  #if personnel != none [#personnel]
  #if general_provisions != none [#general_provisions]
  #if financial_details != none [#financial_details]
  #if list_of_attachments != none [#list_of_attachments]
]

// ── Backmatter: AGREED signature blocks + mid-point review ─────────────────
#backmatter(
  first_party_name: resolved.first_party_name,
  second_party_name: resolved.second_party_name,
  first_party_signatory: resolved.first_party_signatory,
  second_party_signatory: resolved.second_party_signatory,
  mid_point_review_due_date: resolved.mid_point_review_due_date,
  first_signing_field: signature-field("first_party_signature"),
  second_signing_field: signature-field("second_party_signature"),
)

// ── Attachment A: only for reimbursable MOAs ────────────────────────────────
#if resolved.reimbursable { attachment(resolved) }

// ── Attachments B, C, ...: filter to attachment cards first, then letter them
// by their position among *attachments*. The standard sections above are also
// cards in the same `$cards` array, so enumerating the array as a whole would
// letter the first attachment by its global index (J, not B).
#let attachment_cards = data.at("$cards").filter(card => card.at("$kind", default: none) == "attachment")
#for (i, card) in attachment_cards.enumerate() {
  // The quillmark helper leaves an unset/whitespace-only markdown body as
  // the empty string `""`; only non-empty bodies are eval'd into content.
  let body = card.at("$body", default: "")
  let body_content = if type(body) == str { [] } else { body }
  attachment-card(numbering("A", i + 2), resolved, trim-inline(card.title), body_content)
}
