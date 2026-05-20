#import "@local/quillmark-helper:0.1.0": data, signature-field
#import "@local/tonguetoquill-personal-letter:0.1.0": backmatter, frontmatter, mainmatter

// Heading section
#show: frontmatter.with(
  // Letterhead
  letterhead_title: data.letterhead_title,
  letterhead_caption: data.letterhead_caption,
  letterhead_seal_subtitle: data.at("letterhead_seal_subtitle", default: none),
  letterhead_seal: image(
    if data.at("letterhead_seal", default: "dow") == "dod" {
      "assets/dod_seal.png"
    } else {
      "assets/dow_seal.png"
    }
  ),

  ..if data.at("freedom250", default: false) {
    (letterhead_emblem: image("assets/freedom250.png"))
  },

  // Letter heading fields
  date: data.at("date", default: none),
  addressee_type: data.at("addressee_type", default: "military"),
  return_address: data.return_address,
  receiver_address: data.receiver_address,
  salutation: data.salutation,

  // Optional footer and classification
  ..if "tag_line" in data { (footer_tag_line: data.tag_line) },
  ..if "classification" in data { (classification_level: data.classification) },
  ..if "dissemination" in data { (dissemination: data.dissemination) },

  // Font size
  font_size: data.at("font_size", default: 12) * 1pt,
)

// Body text
#mainmatter[
  #data.BODY
]

// Closing section
#backmatter(
  signature_block: data.signature_block,
  signing_field: signature-field("Signature"),
  ..if "cc" in data { (cc: data.cc) },
  ..if "attachments" in data { (attachments: data.attachments) },
)
