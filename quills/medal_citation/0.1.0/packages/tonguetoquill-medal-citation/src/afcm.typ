#import "citation.typ": citation as base
#import "primitives.typ": heading-line

#let citation(f) = base(
  f,
  image-file: "medal-afcm.png",
  title: [DEPARTMENT OF THE AIR FORCE],
  preamble: (heading-line(bold: true)[THIS IS TO CERTIFY THAT],),
  medal-name: [THE AIR AND SPACE COMMENDATION MEDAL],
  awarded: [HAS BEEN AWARDED TO],
  given: ([GIVEN UNDER MY HAND], f.signed_on),
  signer: (f.commander_name, f.commander_title),
  signing-field: f.signing_field,
)
