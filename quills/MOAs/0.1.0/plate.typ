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

// ── Mainmatter: freeform body text, auto-numbered per DoDI 4000.19 ─────────
#mainmatter[
  #data.at("$body")
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
