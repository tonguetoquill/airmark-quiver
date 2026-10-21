#import "citation.typ": citation as base

#let citation(f) = base(
  f,
  image-file: "medal-afcm.png",
  title: [DEPARTMENT OF THE AIR FORCE],
  preamble: ([THIS IS TO CERTIFY THAT],),
  medal-name: [THE AIR AND SPACE COMMENDATION MEDAL],
  awarded: [HAS BEEN AWARDED TO],
)
