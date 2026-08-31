// The memorandum's closing section: AFH 33-337 Chapter 14 "The Closing Section".

#import "primitives.typ": *

#let backmatter(
  signature_block: none,
  signature_blank_lines: 4,
  signing_field: none,
  attachments: none,
  cc: none,
  distribution: none,
  leading_pagebreak: false,
) = {
  render-signature-block(signature_block, signature-blank-lines: signature_blank_lines, signing-field: signing_field)
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    leading-pagebreak: leading_pagebreak,
  )
}
