// lib.typ — public API for the typst-afmc-moa package
//
// Implements a DoDI 4000.19 Memorandum of Agreement (Figure 1).
//
// Basic usage:
//
//   #import "@local/typst-afmc-moa:0.1.0": frontmatter, mainmatter, attachment, attachment-card, backmatter
//
//   #show: frontmatter.with(
//     first_party_name:  "Air Force Materiel Command (AFMC)",
//     second_party_name: "National Aeronautics and Space Administration (NASA)",
//     subject:            "Reciprocal Use of Test Facilities",
//     agreement_number:   "AFMC-2026-0142",
//   )
//
//   // Freeform body text (paragraphs 1-N), auto-numbered per DoDI 4000.19
//   // Figure 1's chained decimal scheme (1., 4.1., 6.1.1.1.).
//   #mainmatter[
//     PURPOSE AND SCOPE: ...
//   ]
//
//   #backmatter(
//     first_party_name:      data.first_party_name,
//     second_party_name:     data.second_party_name,
//     first_party_signatory: data.first_party_signatory,
//     second_party_signatory: data.second_party_signatory,
//     mid_point_review_due_date: data.mid_point_review_due_date,
//   )
//
//   #if data.reimbursable { attachment(data) }
//
//   // Additional attachments (B, C, ...) from `attachment` cards.
//   #attachment-card("B", data, "Facility Safety Requirements")[
//     All personnel entering ... will complete ...
//   ]

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "attachment.typ": render-attachment-a as attachment, render-attachment-card as attachment-card
#import "backmatter.typ": backmatter
#import "utils.typ": trim-inline
