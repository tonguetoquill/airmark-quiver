#import "@local/quillmark-helper:0.1.0": data, signature-field
#import "@local/tonguetoquill-personal-letter:0.1.0": backmatter, frontmatter, mainmatter

// Frontmatter configuration (heading section)
#show: frontmatter.with(
  // Letterhead configuration
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

  // Date
  date: data.at("date", default: none),

  // Optional sender's address element (omit when the letterhead identifies the sender)
  ..if data.at("sender", default: ()).len() > 0 { (sender: data.sender) },

  // Receiver's address element
  recipient: data.recipient,

  // Salutation ("Dear Xxxxx", no punctuation)
  salutation: data.salutation,

  // Font size
  font_size: data.at("font_size", default: 12) * 1pt,
)

// Mainmatter (text of the letter)
#mainmatter[
  #data.at("$body")
]

// Backmatter (closing section)
#backmatter(
  // Complimentary close ("Sincerely", no punctuation)
  close: data.at("close", default: "Sincerely"),

  // Signature element
  signature_block: data.signature_block,
  signing_field: signature-field("Signature"),

  // Optional attachments
  ..if "attachments" in data { (attachments: data.attachments) },

  // Optional cc
  ..if "cc" in data { (cc: data.cc) },
)
