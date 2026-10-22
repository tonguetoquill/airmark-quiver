// The memorandum's closing: AR 25-50 2-4c.

#import "primitives.typ": *

#let backmatter(
  signature-block: (),
  // "FOR THE COMMANDER" where the signer acts for the commander. Blank is no line.
  authority-line: none,
  signature-blank-lines: 4,
  signing-field: none,
  enclosures: (),
  distribution: (),
  cf: (),
  cf-without-enclosures: false,
) = [#{
  render-closing(
    signature-block,
    authority-line: authority-line,
    signature-blank-lines: signature-blank-lines,
    signing-field: signing-field,
    enclosures: enclosures,
  )
  // The page the body's last lines are kept on needs the closing's extent
  // below the last body line.
  context {
    let line = LINE.to-absolute()
    let rows = calc.max(
      line-count(render-signature-lines(signature-block), page.width - 2 * MARGIN - SIGNATURE_INDENT),
      line-count(render-enclosures(enclosures), ENCLOSURE_WIDTH),
      1,
    )
    let lead = if format-authority-line(authority-line) == none { 0 } else { 2 }
    [#metadata((lead + signature-blank-lines + rows) * line)<army-memo-closing-need>]
  }
  render-distribution-and-copies(
    distribution: distribution,
    cf: cf,
    cf-without-enclosures: cf-without-enclosures,
    has-enclosures: ensure-array(enclosures).any(e => not blank(e)),
  )
}<army-memo-closing>]
