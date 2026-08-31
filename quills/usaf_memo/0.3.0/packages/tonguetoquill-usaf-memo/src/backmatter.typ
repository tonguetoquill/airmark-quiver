// backmatter.typ: Backmatter rendering for USAF memorandum
//
// This module implements the backmatter (closing section) of a USAF memorandum per
// AFH 33-337 Chapter 14 "The Closing Section". It handles:
// - Authority line ("FOR THE COMMANDER") placement
// - Signature block placement and formatting
// - Attachments listing
// - Courtesy copy (cc:) distribution
// - Distribution lists

#import "primitives.typ": *

#let backmatter(
  signature_block: none,
  // Authority line above the signature block, e.g. "FOR THE COMMANDER". Set it
  // only when AFH 33-337 calls for one — a designated representative signing
  // for a specific action, the commander's or the coordinated headquarters
  // position, or a staff member signing within their area of responsibility.
  // `none` (or a blank field) renders no line, which is the case whenever the
  // commander signs personally.
  authority_line: none,
  signature_blank_lines: 4,
  signing_field: none,
  attachments: none,
  cc: none,
  distribution: none,
  leading_pagebreak: false,
) = {
  // Render backmatter sections without paragraph numbering
  render-signature-block(
    signature_block,
    // The memo's occupant of the closing-line slot. Cased on the way in, by the
    // element rather than by the slot: the authority line is uppercased, and
    // the personal letter's complimentary close — which sits in the same slot,
    // under the same five-line rule — must not be.
    closing-line: authority-line(authority_line),
    signature-blank-lines: signature_blank_lines,
    signing-field: signing_field,
  )
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    leading-pagebreak: leading_pagebreak,
  )
}
