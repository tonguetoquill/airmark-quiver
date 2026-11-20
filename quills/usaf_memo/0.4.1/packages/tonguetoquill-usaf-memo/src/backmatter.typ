// The memorandum's closing section: AFH 33-337 Chapter 14 "The Closing Section".

#import "primitives.typ": *

#let backmatter(
  signature-block: none,
  // "FOR THE COMMANDER", or the appropriate title, where the signer acted for
  // the commander, the command section, or the headquarters. Blank is no line.
  authority-line: none,
  signature-blank-lines: 4,
  signing-field: none,
  // Two or more signers, each (lines, closing-line, signing-field), junior
  // first. Given, it stands in for the three parameters above; one signer
  // prints exactly as `signature-block` does.
  signers: none,
  attachments: none,
  cc: none,
  distribution: none,
  leading-pagebreak: false,
) = [#{
  // Two lead-in lines plus the continuation note's own line. With no section
  // below, nothing can run over, so the block reserves nothing and breaks where
  // it would on its own.
  let has-backmatter = (
    (attachments != none and attachments.len() > 0)
      or (cc != none and cc.len() > 0)
      or (distribution != none and distribution.len() > 0)
  )
  let reserved-lines = if has-backmatter { 3 } else { 0 }
  let signers = if signers == none { none } else { ensure-array(signers) }
  if signers != none and signers.len() == 1 {
    let only = signers.first()
    signature-block = only.at("lines", default: ())
    authority-line = only.at("closing-line", default: none)
    signing-field = only.at("signing-field", default: none)
    signers = none
  }
  if signers != none and signers.len() > 1 {
    render-signer-rows(
      signers.map(signer => signer + (closing-line: format-authority-line(signer.at("closing-line", default: none)))),
      signature-blank-lines: signature-blank-lines,
      reserved-lines: reserved-lines,
    )
  } else {
    render-signature-block(
      signature-block,
      reserved-lines: reserved-lines,
      // Cased by the element, not by the slot: the letter's complimentary close
      // fills the same slot and must not be uppercased.
      closing-line: format-authority-line(authority-line),
      signature-blank-lines: signature-blank-lines,
      signing-field: signing-field,
    )
  }
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    leading-pagebreak: leading-pagebreak,
  )
  // Labelled so `mainmatter` can split the closing off the body; `split-closing`.
}<usaf-memo-closing>]
