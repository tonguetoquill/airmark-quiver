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
  // Two lead-in lines plus the continuation note's own line. With no section
  // below, nothing can run over, so the block reserves nothing and breaks where
  // it would on its own.
  let has-backmatter = (
    (attachments != none and attachments.len() > 0)
      or (cc != none and cc.len() > 0)
      or (distribution != none and distribution.len() > 0)
  )
  render-signature-block(
    signature_block,
    reserved-lines: if has-backmatter { 3 } else { 0 },
    // Cased by the element, not by the slot: the letter's complimentary close
    // fills the same slot and must not be uppercased.
    closing-line: format-authority-line(authority_line),
    signature-blank-lines: signature_blank_lines,
    signing-field: signing_field,
  )
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    leading-pagebreak: leading_pagebreak,
  )
  // Labelled so `mainmatter` can split the closing off the body; `split-closing`.
}<usaf-memo-closing>]
