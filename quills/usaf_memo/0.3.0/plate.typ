#import "@local/quillmark-helper:0.1.0": data, form-field, signature-field
#import "@local/tonguetoquill-usaf-memo:4.0.0": backmatter, frontmatter, indorsement, mainmatter

// The letterhead arrives as one ordered array of lines. Element 0 is the title,
// set larger; the rest are caption lines beneath it. A single element renders
// the title alone — the package skips a falsey caption. An empty array renders
// no letterhead text at all, silently: the block is `place`d, so an empty title
// leaves no glyphs and takes no space from the flow, and the seal stands alone.
#let letterhead_lines = data.letterhead_title

// Body text size, in points. Also the height of one line of the indorsement
// header, which is what an omitted indorsement date reserves for its fill-in
// widget (`date-placeholder-slot`, whose slot is `1em` tall and 1in wide).
#let body_font_size = data.at("font_size", default: 12) * 1pt

// Frontmatter configuration
#show: frontmatter.with(
  // Letterhead configuration
  letterhead_title: letterhead_lines.at(0, default: ""),
  letterhead_caption: if letterhead_lines.len() > 1 { letterhead_lines.slice(1) } else { () },
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

  // Receiver information
  memo_for: data.memo_for,

  // Sender information (omitted for Memorandum for Record)
  ..if data.at("memo_from", default: ()).len() > 0 { (memo_from: data.memo_from) },

  // Subject line
  subject: data.subject,

  // Optional references
  ..if "references" in data { (references: data.references) },

  // Optional footer tag line
  ..if "tag_line" in data { (footer_tag_line: data.tag_line) },

  // Optional classification level
  ..if "classification" in data { (classification_level: data.classification) },

  ..if "dissemination" in data { (dissemination: data.dissemination) },

  // CUI designation indicator block fields (DoDM 5200.48)
  ..if "cui_controlled_by" in data { (cui_controlled_by: data.cui_controlled_by) },
  ..if "cui_category" in data { (cui_category: data.cui_category) },
  ..if "cui_limited_dissemination" in data { (cui_limited_dissemination: data.cui_limited_dissemination) },
  ..if "cui_poc" in data { (cui_poc: data.cui_poc) },

  // USAF vs DAF memorandum style (date format, body indentation)
  memo_style: data.at("memo_style", default: "usaf"),

  // Font size
  font_size: body_font_size,

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
  ..if "cc" in data { (cc: data.cc) },

  // Optional distribution
  ..if "distribution" in data { (distribution: data.distribution) },

  // Optional attachments
  ..if "attachments" in data { (attachments: data.attachments) },
)

// Indorsements - iterate through CARDS array and filter by CARD tag
#for (i, card) in data.at("$cards").enumerate() {
  if card.at("$kind") == "indorsement" {
    // The quillmark helper leaves an unset/whitespace-only markdown body as
    // the empty string `""`; only non-empty bodies are eval'd into content.
    // Pass truly empty content (`[]`) in the empty case so indorsement can
    // collapse the body's surrounding spacing.
    let body = card.at("$body", default: "")
    let body_content = if type(body) == str { [] } else { body }
    // Per AFH 33-337 Ch. 14, an indorsement is dated when the endorser signs
    // it (distinct from the originating memo's date). The signing date is
    // generally unknown at compile time, so a blank or omitted date leaves the
    // date slot fillable rather than stamping the compile date into it.
    let card_date = card.at("date", default: none)
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
      format: card.at("format", default: "standard"),
      date: resolved_date,
      // An omitted date becomes an empty AcroForm text box the endorser types
      // the signing date into, sized to the slot the package reserves for it.
      // Built only when there is no date to print: a widget over a printed date
      // would offer an edit that the rendered document does not carry back.
      ..if resolved_date == none {
        (date_field: form-field(
          "Ind_" + str(i) + "_Date",
          type: "text",
          width: 1in,
          height: body_font_size,
          field: card.at("$path") + "date",
        ))
      },
      ..if "action" in card { (action: card.action) },
      body_content,
    )
  }
}
