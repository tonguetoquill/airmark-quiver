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

#let words(v) = if blank(v) { none } else { plain-text(v).trim() }

#let distribution-statement(distribution, reason, date, office) = {
  let statement = words(distribution)
  let date = if words(date) == none { none } else { upper(words(date)) }
  let office = words(office)
  if statement == "Distribution Statement A" {
    return [Distribution Statement A. Approved for public release: distribution is unlimited.]
  }
  if statement == "Distribution Statement F" {
    let by = (office, date).filter(v => v != none).join(" ")
    return [Distribution Statement F. Further distribution only as directed by #if by != none [#by ]or higher DoD authority.]
  }
  if statement not in AUDIENCES { return none }
  let audience = (AUDIENCES.at(statement), words(reason), date).filter(v => v != none).join("; ")
  [#statement. #audience.#if office != none [ Other requests for this document must be referred to #office.]]
}

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

#let cover-sheet(
  title: none,
  controlled-by-component: none,
  controlled-by-office: none,
  categories: none,
  distribution: none,
  poc: none,
  distribution-reason: none,
  distribution-date: none,
  distribution-office: none,
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
    let statement = distribution-statement(distribution, distribution-reason, distribution-date, distribution-office)
    if statement != none {
      set text(size: 10pt)
      blank-line
      statement
      if words(distribution-reason) == "Export Controlled" and words(distribution) != "Distribution Statement A" {
        blank-line
        EXPORT_CONTROL_WARNING
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
