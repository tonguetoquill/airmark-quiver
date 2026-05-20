// backmatter.typ: Closing section for personal letter (AFH 33-337 Ch. 15)
//
// Layout per Ch. 15 "The Closing Section":
//   [blank line]           ← "second line below text"
//   Sincerely              ← complimentary close, 4.5in from left
//   [4 blank lines]        ← "fifth line below" the close
//   [Signature element]    ← 4.5in from left; full sig block
//   [2 blank lines]        ← "third line below signature" for attachments
//   Attachment: / # Attachments:
//   [1 blank line]         ← "second line below attachment" for cc:
//   cc:                    (or 2 blank lines below signature if no attachment)

#import "primitives.typ": *

#let backmatter(
  signature_block: none,
  signing_field: none,
  attachments: none,
  cc: none,
) = {
  // "Place 'Sincerely' on the second line below the text" → 1 blank line
  blank-line()
  render-complimentary-close()

  // "Place the signature element on the fifth line below the complimentary close"
  // render-signature-block internally emits blank-lines(4) before the block.
  render-signature-block(signature_block, signature-blank-lines: 4, signing-field: signing_field)

  render-personal-letter-backmatter(attachments: attachments, cc: cc)
}
