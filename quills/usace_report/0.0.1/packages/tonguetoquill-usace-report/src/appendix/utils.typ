#import "config.typ": *
#import "../utils.typ": *

#let date-pattern = "[day padding:none] [month repr:long] [year]"

#let format-date(d, pattern: date-pattern) = {
  if d == none or d == [] or d == "" {
    none
  } else if type(d) == datetime {
    d.display(pattern)
  } else {
    d
  }
}
