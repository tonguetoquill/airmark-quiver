// backmatter.typ: Backmatter rendering for the USAF personal letter
//
// This module implements the closing section of a USAF personal letter per
// AFH 33-337 "The Personal Letter" / AFMAN 33-326 §4.1.3. It handles:
// - Complimentary close ("Sincerely", no punctuation) at the 4.5in anchor
// - Signature element five line spaces below, aligned with the close
// - Attachments listing and courtesy copy (cc:) distribution

#import "primitives.typ": *

#let backmatter(
  close: "Sincerely",
  signature_block: none,
  signature_blank_lines: 4,
  signing_field: none,
  attachments: none,
  cc: none,
) = {
  render-closing(
    close,
    signature_block,
    signature-blank-lines: signature_blank_lines,
    signing-field: signing_field,
  )
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
  )
}
