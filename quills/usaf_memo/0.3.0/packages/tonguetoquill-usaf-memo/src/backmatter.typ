// The memorandum's closing section: AFH 33-337 Chapter 14 "The Closing Section".

#import "primitives.typ": *

#let backmatter(
  signature_block: none,
  // "FOR THE COMMANDER", or the appropriate title, where the signer acted for
  // the commander, the command section, or the headquarters. Blank is no line.
  authority_line: none,
  signature_blank_lines: 4,
  signing_field: none,
  attachments: none,
  cc: none,
  distribution: none,
  leading_pagebreak: false,
) = [#{
  render-signature-block(
    signature_block,
    // Cased by the element, not by the slot: the letter's complimentary close
    // fills the same slot and must not be uppercased.
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
  // Labelled so `mainmatter`, applied as a show rule over the rest of the
  // document, can tell the closing section from the body (see `split-closing`).
}<usaf-memo-closing>]
