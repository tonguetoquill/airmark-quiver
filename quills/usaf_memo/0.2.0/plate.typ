#import "@local/quillmark-helper:0.1.0": data, signature-field
#import "@local/tonguetoquill-usaf-memo:3.0.0": backmatter, frontmatter, indorsement, mainmatter

// Frontmatter configuration
#show: frontmatter.with(
  // Letterhead configuration
  letterhead_title: data.letterhead_title,
  letterhead_caption: data.letterhead_caption,
  letterhead_seal_subtitle: data.letterhead_seal_subtitle,
  // Enum blank is `""`, not a seal. Omit so the package renders none rather
  // than treating the blank as DoW.
  ..if data.letterhead_seal != "" {
    (letterhead_seal: image(
      if data.letterhead_seal == "dod" {
        "assets/dod_seal.png"
      } else {
        "assets/dow_seal.png"
      }
    ))
  },

  // Date
  date: data.date,

  // Receiver information
  memo_for: data.memo_for,

  // Sender information (omitted for Memorandum for Record)
  ..if data.memo_from.len() > 0 { (memo_from: data.memo_from) },

  // Subject line
  subject: data.subject,

  // Optional references
  ..if data.references.len() > 0 { (references: data.references) },

  // Optional footer tag line
  footer_tag_line: data.tag_line,

  // Optional classification level
  ..if data.classification != "" { (classification_level: data.classification) },

  ..if data.dissemination != "" { (dissemination: data.dissemination) },

  // CUI designation indicator block fields (DoDM 5200.48)
  ..if data.cui_controlled_by != "" { (cui_controlled_by: data.cui_controlled_by) },
  ..if data.cui_category != "" { (cui_category: data.cui_category) },
  ..if data.cui_limited_dissemination != "" { (cui_limited_dissemination: data.cui_limited_dissemination) },
  ..if data.cui_poc != "" { (cui_poc: data.cui_poc) },

  // USAF vs DAF memorandum style (date format, body indentation). Blank
  // falls through to the package's `"usaf"` default.
  ..if data.memo_style != "" { (memo_style: data.memo_style) },

  // Font size
  font_size: data.font_size * 1pt,

  // List recipients in vertical list
  memo_for_cols: 1,
)

// Mainmatter. The body's region needs no recovery step here: the package's
// render-body rebuilds paragraphs through a state buffer (AFH 33-337
// auto-numbering), but the rebuilt glyphs keep their spans, which is what
// the backend reads regions from.
#mainmatter[
  #data.at("$body")
]

// Backmatter
#backmatter(
  // Signature block
  signature_block: data.signature_block,
  signing_field: signature-field("Signature", field: "signature_block"),

  // Optional cc
  ..if data.cc.len() > 0 { (cc: data.cc) },

  // Optional distribution
  ..if data.distribution.len() > 0 { (distribution: data.distribution) },

  // Optional attachments
  ..if data.attachments.len() > 0 { (attachments: data.attachments) },
)

// Indorsements - iterate through CARDS array and filter by CARD tag
#for (i, card) in data.at("$cards").enumerate() {
  if card.at("$kind", default: none) == "indorsement" {
    // The quillmark helper leaves an unset/whitespace-only markdown body as
    // the empty string `""`; only non-empty bodies are eval'd into content.
    // Pass truly empty content (`[]`) in the empty case so indorsement can
    // collapse the body's surrounding spacing.
    let body = card.at("$body", default: "")
    let body_content = if type(body) == str { [] } else { body }
    // Per AFH 33-337 Ch. 14, an indorsement is dated when the endorser signs
    // it (distinct from the originating memo's date). The signing date is
    // generally unknown at compile time and filled in by hand, so a blank or
    // omitted date renders a fill-in line rather than stamping the compile date.
    let card_date = card.date
    let resolved_date = if card_date == none or card_date == "" {
      none
    } else {
      card_date
    }
    // The card's `$path` prefix composes its canonical schema addresses
    // (`$cards.indorsement.<n>.…`, per-kind ordinal) — the absolute loop
    // index `i` is NOT that ordinal once kinds interleave, so it stays a
    // widget-name suffix only. The card body's region rides its own glyph
    // spans through the package rebuild, per-card because each card's body
    // has its own backend-generated eval site.
    indorsement(
      from: card.at("from", default: ""),
      to: card.at("for", default: ""),
      signature_block: card.signature_block,
      signing_field: signature-field(
        "Ind_" + str(i) + "_Signature",
        field: card.at("$path") + "signature_block",
      ),
      ..if card.format != "" { (format: card.format) },
      date: resolved_date,
      ..if card.action != "" { (action: card.action) },
      body_content,
    )
  }
}
