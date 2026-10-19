#import "citation.typ": citation as base
#import "primitives.typ": heading-line

#let citation(f) = base(
  f,
  image-file: "medal-msm.png",
  title: [THE UNITED STATES OF AMERICA],
  preamble: (
    heading-line[TO ALL WHO SHALL SEE THESE PRESENTS, GREETING:],
    heading-line[THIS IS TO CERTIFY THAT THE PRESIDENT OF THE UNITED STATES OF],
    heading-line[AMERICA AUTHORIZED BY EXECUTIVE ORDER, 16 JANUARY 1969],
    heading-line[HAS],
    heading-line[AWARDED],
  ),
  medal-name: [THE MERITORIOUS SERVICE MEDAL],
  awarded: [TO],
  given: ([GIVEN UNDER MY HAND], f.signed_on),
  signer: (f.commander_name, f.commander_grade, f.commander_title),
  signing-field: f.signing_field,
)
