#import "@local/quillmark-helper:0.1.0": data, signature-field
#import "@local/typst-moa:0.1.0": attachment, attachment-card, backmatter, frontmatter, mainmatter

// Resolve optional fields with defaults; required fields are read directly
// since Quill.yaml enforces their presence.
#let resolved = (
  first_party_name: data.first_party_name,
  second_party_name: data.second_party_name,
  second_party_is_non_government: data.at("second_party_is_non_government", default: false),
  subject: data.subject,
  agreement_number: data.agreement_number,

  second_party_mailing_address: data.second_party_mailing_address,

  reimbursable: data.at("reimbursable", default: false),
  reimbursable_support: data.at("reimbursable_support", default: ""),
  estimated_amount: data.at("estimated_amount", default: ""),
  appropriation_fy: data.at("appropriation_fy", default: ""),
  cost_center_provider: data.at("cost_center_provider", default: ""),
  cost_center_receiver: data.at("cost_center_receiver", default: ""),
  financial_poc_provider: data.at("financial_poc_provider", default: ""),
  financial_poc_receiver: data.at("financial_poc_receiver", default: ""),
  financial_additional_info: data.at("financial_additional_info", default: ""),

  first_party_signatory: data.first_party_signatory,
  second_party_signatory: data.second_party_signatory,
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
    if card.at("$kind") == kind and "$body" in card {
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

// ── Attachments B, C, ...: iterate through CARDS array and filter by CARD tag
#for (i, card) in data.at("$cards").enumerate() {
  if card.at("$kind") == "attachment" {
    // The quillmark helper leaves an unset/whitespace-only markdown body as
    // the empty string `""`; only non-empty bodies are eval'd into content.
    let body = card.at("$body", default: "")
    let body_content = if type(body) == str { [] } else { body }
    attachment-card(numbering("A", i + 2), resolved, card.title, body_content)
  }
}
