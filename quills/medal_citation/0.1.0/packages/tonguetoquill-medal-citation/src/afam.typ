#import "citation.typ": citation as base

#let citation(f) = base(
  f,
  image-file: "medal-afam.png",
  title: [DEPARTMENT OF THE AIR FORCE],
  preamble: ([THIS IS TO CERTIFY THAT],),
  medal-name: [THE AIR AND SPACE ACHIEVEMENT MEDAL],
  awarded: [HAS BEEN AWARDED TO],
)
