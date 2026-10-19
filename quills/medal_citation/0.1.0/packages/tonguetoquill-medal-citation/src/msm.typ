#import "citation.typ": citation as base
#import "config.typ": size

#let citation(f) = base(
  f,
  image-file: "medal-msm.png",
  title: [THE UNITED STATES OF AMERICA],
  preamble: (
    [TO ALL WHO SHALL SEE THESE PRESENTS, GREETING:],
    [THIS IS TO CERTIFY THAT THE PRESIDENT OF THE UNITED STATES OF],
    [AMERICA AUTHORIZED BY EXECUTIVE ORDER, 16 JANUARY 1969],
    [HAS],
    [AWARDED],
  ),
  preamble-size: size.line,
  medal-name: [THE MERITORIOUS SERVICE MEDAL],
  awarded: [TO],
)
