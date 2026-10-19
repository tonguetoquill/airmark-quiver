#import "citation.typ": citation as base
#import "primitives.typ": heading-line

#let citation(f) = base(
  f,
  image-file: "medal-afam.png",
  title: [DEPARTMENT OF THE AIR FORCE],
  preamble: (heading-line(bold: true)[THIS IS TO CERTIFY THAT],),
  medal-name: [THE AIR AND SPACE ACHIEVEMENT MEDAL],
  awarded: [HAS BEEN AWARDED TO],
  given: (f.given,),
  signer: (f.commander_name, f.commander_title),
  signing-field: f.signing_field,
)
