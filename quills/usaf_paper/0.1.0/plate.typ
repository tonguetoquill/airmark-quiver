#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usaf-paper:0.1.0": date-pattern as paper-date-pattern, paper
#import "@local/tonguetoquill-usaf-memo:5.0.0": (
  backmatter,
  date-pattern as memo-date-pattern,
  frontmatter,
  mainmatter,
)

#let body-font-size = qm.data.font_size * 1pt

// A blank date is filled in on the PDF. The slot is about as wide as
// "30 Sep 26" and sits on the line, so the identification line does not grow
// taller than a printed date.
#let paper-date-slot-width = body-font-size * 6.5
#let paper-date-slot = context box(
  width: paper-date-slot-width,
  height: measure[0].height,
  place(horizon + left, qm.form-field(
    "Date",
    type: "text",
    width: paper-date-slot-width,
    height: body-font-size,
    field: "date",
    font: "times",
    size: body-font-size,
    align: "left",
  )),
)

// Wide enough for the longest memorandum date, "September 30, 2026".
#let memo-date-slot-width = body-font-size * 8.5
#let memo-date-slot = context box(
  width: memo-date-slot-width,
  height: measure[0].height,
  place(horizon + left, qm.form-field(
    "Date",
    type: "text",
    width: memo-date-slot-width,
    height: body-font-size,
    field: "date",
    font: "times",
    size: body-font-size,
    align: "right",
  )),
)

#let filled(v) = v != none and v != "" and v != []

#let paper-field = qm.data.paper
#let paper-value = if type(paper-field) == str { paper-field } else { paper-field.value }

#let point = (
  "Talking Paper": (title: [TALKING PAPER], narrative: false),
  "Bullet Background Paper": (title: [BULLET BACKGROUND PAPER], narrative: false),
  "Background Paper": (title: [BACKGROUND PAPER], narrative: true),
  "Position Paper": (title: [POSITION PAPER], narrative: true),
)
#let spec = point.at(paper-value, default: none)

#let body = qm.data.at("$body")
#let body-content = if type(body) == str { [] } else { body }

#if paper-value == "Formal Trip Report" [
  #let memo-style = if paper-field.memo_style != "" { paper-field.memo_style } else { "usaf" }
  #let letterhead = paper-field.letterhead_title
  #let authored = qm.ink(qm.data, "date", memo-date-pattern(memo-style: memo-style))
  #show: frontmatter.with(
    letterhead-title: letterhead.at(0, default: ""),
    letterhead-caption: if letterhead.len() > 1 { letterhead.slice(1) } else { () },
    letterhead-seal-subtitle: paper-field.letterhead_seal_subtitle,
    letterhead-seal: image(
      if paper-field.letterhead_seal == "dod" {
        "assets/dod_seal.png"
      } else {
        "assets/dow_seal.png"
      }
    ),
    date: authored,
    date-field: memo-date-slot,
    memo-for: paper-field.memo_for,
    ..if paper-field.memo_from.len() > 0 { (memo-from: paper-field.memo_from) },
    subject: qm.data.subject,
    ..if paper-field.references.len() > 0 { (references: paper-field.references) },
    footer-tag-line: paper-field.tag_line,
    classification-level: qm.data.classification.value,
    dissemination: qm.data.dissemination,
    ..if qm.data.classification.value == "CUI" {
      (
        cui-controlled-by: qm.data.classification.controlled_by,
        cui-category: qm.data.classification.category,
        cui-limited-dissemination: qm.data.classification.limited_dissemination,
        cui-poc: qm.data.classification.poc,
      )
    },
    memo-style: memo-style,
    font-size: body-font-size,
    memo-for-cols: 1,
  )
  #mainmatter(body-content)
  #backmatter(
    authority-line: paper-field.authority_line,
    signature-block: paper-field.signature_block,
    signing-field: qm.signature-field(
      "Signature",
      field: "paper.signature_block",
      height: body-font-size * 2.5,
    ),
    ..if paper-field.cc.len() > 0 { (cc: paper-field.cc) },
    ..if paper-field.distribution.len() > 0 { (distribution: paper-field.distribution) },
    ..if paper-field.attachments.len() > 0 { (attachments: paper-field.attachments) },
  )
] else [
  #let authored-date = qm.ink(qm.data, "date", paper-date-pattern)
  #let any-id = if spec == none {
    false
  } else {
    (
      paper-field.originator,
      paper-field.organization,
      paper-field.office_symbol,
      paper-field.phone,
      paper-field.typist,
    ).any(filled)
  }
  #let date-ink = if authored-date != none {
    authored-date
  } else if any-id {
    paper-date-slot
  } else {
    none
  }
  #let title = if spec == none { [] } else { spec.title }
  #let narrative = if spec == none { false } else { spec.narrative }
  #show: paper.with(
    document-title: title,
    narrative: narrative,
    subject: qm.data.subject,
    originator: if spec == none { none } else { paper-field.originator },
    organization: if spec == none { none } else { paper-field.organization },
    office-symbol: if spec == none { none } else { paper-field.office_symbol },
    phone: if spec == none { none } else { paper-field.phone },
    typist: if spec == none { none } else { paper-field.typist },
    date: date-ink,
    font-size: body-font-size,
    classification-level: qm.data.classification.value,
    dissemination: qm.data.dissemination,
    ..if qm.data.classification.value == "CUI" {
      (
        cui-controlled-by: qm.data.classification.controlled_by,
        cui-category: qm.data.classification.category,
        cui-limited-dissemination: qm.data.classification.limited_dissemination,
        cui-poc: qm.data.classification.poc,
      )
    },
  )
  #if body != "" {
    body
  }
]
