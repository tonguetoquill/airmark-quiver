#import "utils.typ": *

// The ENC templates' Standard Form 901 cover, placed where Word puts it.
// Positions are points from the page's top-left corner; a `y` is a baseline.

#let PURPLE = rgb("#3C1D59")
#let INK = rgb("#231F20")
#let BOX_X = 90pt
#let BOX_WIDTH = 432pt

// Word's character spacing, in twentieths of a point, and the 90% width of
// the form number, copied run by run from the templates' SF 901 text box.
#let TWIP = 0.05pt
#let SPACE = 0.2778em
#let narrow(body) = box(scale(x: 90%, origin: left, reflow: true, body))

#let ATTENTION_TEXT = (
  ("All", text(spacing: 100% + -6 * TWIP, " "), "individuals", text(spacing: 100% + -5 * TWIP, " "), "handling", text(spacing: 100% + -5 * TWIP, " "), "this", text(spacing: 100% + -5 * TWIP, " "), "information", text(spacing: 100% + -5 * TWIP, " "), "are", text(spacing: 100% + -5 * TWIP, " "), "required", text(spacing: 100% + -5 * TWIP, " "), "to", text(spacing: 100% + -5 * TWIP, " "), "protect it from unauthorized disclosure.").join(),
  ("Handling,", text(spacing: 100% + -5 * TWIP, " "), "storage,", text(spacing: 100% + -5 * TWIP, " "), "reproduction,", text(spacing: 100% + -4 * TWIP, " "), "and", text(spacing: 100% + -4 * TWIP, " "), "disposition", text(spacing: 100% + -4 * TWIP, " "), "of", text(spacing: 100% + -4 * TWIP, " "), "the", text(spacing: 100% + -4 * TWIP, " "), "attached", text(spacing: 100% + -4 * TWIP, " "), "document(s)", text(spacing: 100% + -4 * TWIP, " "), "must be in accordance with 32 CFR Part 2002 and applicable agency policy.").join(),
  (text(tracking: -4 * TWIP, "Access to and dissemination of Controlled Unclassified Information shall be allowed as necessary and permissible to any individual(s), organization(s), or "), text(tracking: -6 * TWIP, "grouping(s) of users, provided such access or dissemination is consistent with or in "), "furtherance", text(spacing: 100% + -14 * TWIP, " "), "of", text(spacing: 100% + -7 * TWIP, " "), "a", text(spacing: 100% + -8 * TWIP, " "), "Lawful", text(spacing: 100% + -8 * TWIP, " "), "Government", text(spacing: 100% + -8 * TWIP, " "), "Purpose", text(spacing: 100% + -8 * TWIP, " "), "and", text(spacing: 100% + -8 * TWIP, " "), "in", text(spacing: 100% + -8 * TWIP, " "), "a", text(spacing: 100% + -8 * TWIP, " "), "manner", text(spacing: 100% + -8 * TWIP, " "), "consistent", text(spacing: 100% + -8 * TWIP, " "), "with ", text(tracking: -2 * TWIP, "applicable"), text(spacing: 100% + -12 * TWIP, " "), text(tracking: -2 * TWIP, "law,"), text(spacing: 100% + -11 * TWIP, " "), text(tracking: -2 * TWIP, "regulations,"), text(spacing: 100% + -11 * TWIP, " "), text(tracking: -2 * TWIP, "and"), text(spacing: 100% + -11 * TWIP, " "), text(tracking: -2 * TWIP, "Government-wide"), text(spacing: 100% + -11 * TWIP, " "), text(tracking: -2 * TWIP, "policies.")).join(),
)

#let FORM_LINES = (
  (narrow[Standard], h(SPACE * 1 + 1 * TWIP), narrow[Form], h(SPACE * 1 + 2 * TWIP), narrow[901], h(SPACE * 1 + 2 * TWIP), narrow[(11-#text(tracking: -5 * TWIP, "18)")]).join(),
  (narrow[Prescribed], h(SPACE * 0.9 + -1 * TWIP), narrow[by], h(SPACE * 1 + -3 * TWIP), narrow[GSA/ISOO], h(SPACE * 1 + 21 * TWIP), narrow[|], h(SPACE * 0.9 + -1 * TWIP), narrow[32], h(SPACE * 1 + -2 * TWIP), narrow[CFR], h(SPACE * 0.9 + -1 * TWIP), narrow(text(tracking: -4 * TWIP, "2002"))).join(),
)

// DoDI 5230.24 (10 January 2023): the statements in paragraph 4.2, set out as
// in Figure 2, and the export-control warning in Figure 3.
#let AUDIENCES = (
  "Distribution Statement B": "Distribution authorized to U.S. Government agencies",
  "Distribution Statement C": "Distribution authorized to U.S. Government agencies and their contractors",
  "Distribution Statement D": "Distribution authorized to the Department of Defense and U.S. DoD contractors only",
  "Distribution Statement E": "Distribution authorized to DoD Components only",
)

#let EXPORT_CONTROL_WARNING = [WARNING - This document contains technical data whose export is restricted by the Arms Export Control Act (Section 2751 of Title 22, United States Code) or the Export Control Reform Act of 2018 (Chapter 58 Sections 4801-4852 of Title 50, United States Code). Violations of these export laws are subject to severe criminal penalties. Disseminate in accordance with provisions of DoD Directive 5230.25 and DoD Instruction 2040.02.]

// Table 1 + para 4.3: which defense categories may accompany each letter.
// Export Controlled is limited to B–E (para 3.4.i).
#let REASON_LETTERS = (
  "Controlled Technical Information": ("B", "C", "D", "E", "F"),
  "CTI": ("B", "C", "D", "E", "F"),
  "Contractor Performance Evaluation": ("B", "E", "F"),
  "Critical Technology": ("B", "C", "D", "E", "F"),
  "Direct Military Support": ("E", "F"),
  "Export Controlled": ("B", "C", "D", "E"),
  "Foreign Government Information": ("B", "C", "D", "E", "F"),
  "International Agreements": ("B", "C", "D", "E", "F"),
  "Operations Security": ("B", "E", "F"),
  "Patents and Inventions": ("B", "E", "F"),
  "Proprietary Business Information": ("B", "E", "F"),
  "Small Business Innovation Research": ("B", "E", "F"),
  "Software Documentation": ("B", "C", "D", "E", "F"),
  "Test and Evaluation": ("B", "E", "F"),
  "Vulnerability Information": ("B", "C", "D", "E", "F"),
)

#let REASON_NAMES = (
  "CTI": "Controlled Technical Information",
)

#let words(v) = if blank(v) { none } else { plain-text(v).trim() }

#let reason-name(v) = {
  let raw = words(v)
  if raw == none { none } else { REASON_NAMES.at(raw, default: raw) }
}

#let reason-list(reasons) = {
  ensure-array(reasons)
    .map(reason-name)
    .filter(v => v != none)
}

#let statement-letter(distribution) = {
  let statement = words(distribution)
  if statement == none { return none }
  let prefix = "Distribution Statement "
  if not statement.starts-with(prefix) { return none }
  let letter = statement.slice(prefix.len())
  if letter.len() == 1 { letter } else { none }
}

#let distribution-errors(distribution, reasons, cui-enabled: true) = {
  let errors = ()
  let statement = words(distribution)
  let letter = statement-letter(distribution)
  let named = reason-list(reasons)

  if cui-enabled and statement == "Distribution Statement A" {
    errors.push("Distribution Statement A means public release and cannot be used when CUI is on (DoDI 5230.24 para 4.2.a).")
  }

  if named.contains("Export Controlled") and letter not in ("B", "C", "D", "E") {
    errors.push("Export Controlled requires Distribution Statement B, C, D, or E (DoDI 5230.24 para 3.4.i).")
  }

  if letter != none and letter != "A" {
    for reason in named {
      let allowed = REASON_LETTERS.at(reason, default: none)
      if allowed == none {
        errors.push(reason + " is not a DoDI 5230.24 Table 1 defense category.")
      } else if letter not in allowed {
        errors.push(reason + " is not authorized with Distribution Statement " + letter + " (DoDI 5230.24 Table 1).")
      }
    }
  }

  if named.len() > 3 {
    errors.push("At most three reasons may accompany a distribution statement (DoDI 5230.24 para 4.1.d).")
  }

  errors
}

#let distribution-check(distribution, reasons, cui-enabled: true) = {
  let errors = distribution-errors(distribution, reasons, cui-enabled: cui-enabled)
  if errors.len() == 0 { none } else {
    text(fill: rgb("#b00000"), weight: "bold", size: 10pt)[
      CHECK DISTRIBUTION STATEMENT: #errors.join(" ")
    ]
  }
}

#let distribution-statement(distribution, reasons, date, office) = {
  let statement = words(distribution)
  let date = if words(date) == none { none } else { upper(words(date)) }
  let office = words(office)
  let named = reason-list(reasons)
  let reason-text = if named.len() == 0 { none } else { named.join(", ") }

  if statement == "Distribution Statement A" {
    return [Distribution Statement A. Approved for public release: distribution is unlimited.]
  }
  if statement == "Distribution Statement F" {
    let by = (office, date).filter(v => v != none).join(" ")
    return [Distribution Statement F. Further distribution only as directed by #if by != none [#by ]or higher DoD authority.]
  }
  if statement not in AUDIENCES { return none }
  let audience = (AUDIENCES.at(statement), reason-text, date).filter(v => v != none).join("; ")
  [#statement. #audience.#if office != none [ Other requests for this document must be referred to #office.]]
}

#let export-controlled(reasons) = reason-list(reasons).contains("Export Controlled")

#let centered-at(y, body) = place(top + left, dy: y, block(width: 612pt, {
  set text(top-edge: "baseline", bottom-edge: "baseline")
  align(center, body)
}))

#let white-box(y, height, inset, body) = place(top + left, dx: BOX_X, dy: y, block(
  width: BOX_WIDTH,
  height: height,
  fill: white,
  inset: inset,
  {
    // Word's single-spaced Arial line: 1.15 em, baseline 0.938 em below its top.
    set text(size: 12pt, top-edge: 0.938em, bottom-edge: -0.212em)
    set par(leading: 0pt, spacing: 0pt, justify: false)
    set block(spacing: 0pt)
    body
  },
))

#let blank-line = v(1.15em)

#let designation(label, value) = par[*#label*#if not blank(value) [ #trim-inline(value)]]

#let designation-block(
  controlled-by-component: none,
  controlled-by-office: none,
  categories: none,
  distribution: none,
  poc: none,
) = block(
  width: 3.4in,
  stroke: 0.6pt + black,
  inset: 6pt,
  {
    // Regular weight so a bold title page does not bleed into values; labels
    // stay bold via `designation`'s emphasis.
    set text(size: 9pt, weight: "regular")
    set par(leading: 0.35em, spacing: 0.35em)
    set align(left)
    designation([Controlled by:], controlled-by-component)
    designation([Controlled by:], controlled-by-office)
    designation([CUI Category:], categories)
    designation([Distribution/Limited Dissemination Control:], distribution)
    designation([POC:], poc)
  },
)

// Designation block, distribution statement and export warning for page 1 when
// the SF 901 cover is off (DoDI 5230.24 para 3.1.j, 3.4.f, 3.4.g).
#let page-one-cui(
  controlled-by-component: none,
  controlled-by-office: none,
  categories: none,
  distribution: none,
  poc: none,
  distribution-reasons: (),
  distribution-date: none,
  distribution-office: none,
  cui-enabled: true,
) = {
  let check = distribution-check(distribution, distribution-reasons, cui-enabled: cui-enabled)
  let statement = distribution-statement(
    distribution,
    distribution-reasons,
    distribution-date,
    distribution-office,
  )
  let warn = export-controlled(distribution-reasons) and words(distribution) != "Distribution Statement A"

  // align(right) places the stack; align(left) inside keeps the text flush.
  // Force regular weight: the title page sets bold for its own lines.
  align(right, {
    set text(size: 9pt, weight: "regular")
    set par(leading: 0.4em, spacing: 0.45em)
    designation-block(
      controlled-by-component: controlled-by-component,
      controlled-by-office: controlled-by-office,
      categories: categories,
      distribution: distribution,
      poc: poc,
    )
    v(0.12in)
    block(width: 3.4in, {
      set align(left)
      set text(size: 9pt, weight: "regular")
      if check != none {
        check
        v(0.08in)
      }
      if statement != none {
        statement
        if warn {
          v(0.08in)
          EXPORT_CONTROL_WARNING
        }
      }
    })
  })
}

#let cover-sheet(
  title: none,
  controlled-by-component: none,
  controlled-by-office: none,
  categories: none,
  distribution: none,
  poc: none,
  distribution-reasons: (),
  distribution-date: none,
  distribution-office: none,
  cui-enabled: true,
) = {
  // Word sets the templates without kerning.
  set text(fill: black, kerning: false)
  centered-at(11.26pt, text(size: 12pt)[CUI])
  place(top + left, dx: 18.85pt, dy: 18.15pt, rect(width: 576pt, height: 756pt, fill: PURPLE, stroke: none))

  let mark = text.with(size: 48pt, weight: "bold", fill: white)
  let attention = text(size: 20pt, fill: white)[ATTENTION]
  centered-at(73.24pt, mark[CUI])
  centered-at(111.1pt, attention)

  white-box(117.9pt, 288pt, (left: 8.65pt, right: 9.35pt), align(horizon, {
    align(center, strong(if blank(title) [] else { trim-inline(title) }))
    blank-line
    designation([Controlled by:], controlled-by-component)
    designation([Controlled by:], controlled-by-office)
    designation([CUI Category:], categories)
    designation([Distribution/Limited Dissemination Control:], distribution)
    designation([POC:], poc)
    let check = distribution-check(distribution, distribution-reasons, cui-enabled: cui-enabled)
    let statement = distribution-statement(
      distribution,
      distribution-reasons,
      distribution-date,
      distribution-office,
    )
    if check != none or statement != none {
      set text(size: 10pt)
      blank-line
      if check != none {
        check
        blank-line
      }
      if statement != none {
        statement
        if export-controlled(distribution-reasons) and words(distribution) != "Distribution Statement A" {
          blank-line
          EXPORT_CONTROL_WARNING
        }
      }
    }
  }))

  centered-at(461.5pt, attention)

  white-box(468.5pt, 194.4pt, (x: 9.35pt), {
    set text(fill: INK)
    for paragraph in ATTENTION_TEXT {
      align(center, paragraph)
      blank-line
    }
    for line in FORM_LINES { align(right, line) }
  })

  centered-at(722.44pt, mark[CUI])
}
