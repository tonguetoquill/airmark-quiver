#import "@local/quillmark-helper:0.1.0": data, signature-field
#import "@local/tonguetoquill-personal-letter:0.1.0": frontmatter, mainmatter, backmatter

// ── Heading section ──────────────────────────────────────────────────────────
// Ch. 15: date → return address → receiver's address → salutation
#show: frontmatter.with(
  date:             data.at("date", default: none),
  addressee_type:   data.at("addressee_type", default: "military"),
  return_address:   data.return_address,
  receiver_address: data.receiver_address,
  salutation:       data.salutation,
  font_size:        data.at("font_size", default: 12) * 1pt,
  letterhead_title:   data.at("letterhead_title", default: "DEPARTMENT OF THE AIR FORCE"),
  letterhead_caption: data.at("letterhead_caption", default: none),
  letterhead_seal: if data.at("letterhead_caption", default: none) != none {
    image(
      if data.at("letterhead_seal", default: "dow") == "dod" {
        "assets/dod_seal.png"
      } else {
        "assets/dow_seal.png"
      }
    )
  } else { none },
  ..if "classification" in data { (classification_level: data.classification) },
  ..if "dissemination"  in data { (dissemination:        data.dissemination)  },
)

// ── Body text ────────────────────────────────────────────────────────────────
// Ch. 15: unnumbered paragraphs, 0.5 in first-line indent, sub-pars follow memo
#show: mainmatter

#data.BODY

// ── Closing section ──────────────────────────────────────────────────────────
// Ch. 15: Sincerely → signature → attachments → cc:
#backmatter(
  signature_block: data.signature_block,
  signing_field:   signature-field("Signature"),
  ..if "attachments" in data { (attachments: data.attachments) },
  ..if "cc"          in data { (cc:          data.cc)          },
)
