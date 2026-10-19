#import "config.typ": *
#import "primitives.typ": *

// One certificate. A medal supplies its image, its title, the lines between the
// title and the medal's name, and the line that names the recipient; everything
// else is shared.
//
// - f (dictionary): oak_leaf_cluster, recipient, reason, period_from, period_to,
//   accomplishments, signed_on, signer_name, signer_grade,
//   signer_title, footer, an array of (label, value) pairs, and
//   signing_field, a function (width, height) => the widget over the signing
//   space.
// - preamble (array): lines at `preamble-size`, a line apart.
#let citation(
  f,
  image-file: none,
  title: none,
  preamble: (),
  preamble-size: size.certify,
  medal-name: none,
  awarded: none,
) = {
  set page(paper: "us-letter", margin: 0pt)
  set text(font: font, size: size.line, fill: black, hyphenate: false)
  set par(spacing: 0pt)

  let signer = (
    if not blank(f.signer_name) { text(weight: "bold", f.signer_name) },
    f.signer_grade,
    f.signer_title,
  ).filter(l => not blank(l))
  closing-block(f.signed_on, signer, signing-field: f.signing_field)
  footer-block(f.footer)

  v(medal-image.top)
  align(center, image(image-file, height: medal-image.height))
  heading-line(title, above: pitch.title, size: size.title)
  for (i, l) in preamble.enumerate() {
    let above = if i == 0 { pitch.preamble * preamble-size } else { pitch.single }
    heading-line(l, above: above, size: preamble-size)
  }
  heading-line(medal-name, above: pitch.medal, size: size.medal)
  let cluster = f.oak_leaf_cluster
  if not blank(cluster) {
    heading-line(cluster, above: pitch.cluster, size: size.heading)
  }
  heading-line(awarded, above: pitch.awarded, size: size.heading)
  heading-line(upper(f.recipient), above: pitch.recipient, bold: true)
  heading-line([FOR], above: pitch.for-line)
  heading-line(upper(f.reason), above: pitch.reason, bold: true)
  let period = if not (blank(f.period_from) and blank(f.period_to)) [#f.period_from TO #f.period_to]
  heading-line(period, above: pitch.single, bold: true)
  heading-line([ACCOMPLISHMENTS], above: pitch.accomplishments, size: size.heading)
  v(accomplishments.gap)

  accomplishments-block(f.accomplishments, closing.given - closing.clearance)
}
