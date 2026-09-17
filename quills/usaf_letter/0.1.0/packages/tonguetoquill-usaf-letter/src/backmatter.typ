// The personal letter's closing: AFH 33-337's complimentary close, signature
// block, attachment element and courtesy copy element.

#import "primitives.typ": *

#let backmatter(
  signature-block: none,
  // "Sincerely", or whichever close the Forms of Address table gives for the
  // receiver. Blank is no line.
  complimentary-close: none,
  signature-blank-lines: 4,
  signing-field: none,
  attachments: none,
  cc: none,
) = [#{
  render-signature-block(
    signature-block,
    closing-line: complimentary-close,
    signature-blank-lines: signature-blank-lines,
    signing-field: signing-field,
  )
  render-backmatter-sections(attachments: attachments, cc: cc)
  // Labelled so `mainmatter` can split the closing off the body; `split-closing`.
}<usaf-letter-closing>]
