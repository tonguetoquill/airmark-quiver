#import "config.typ": *
#import "../utils.typ": *

#let date-pattern = "[month repr:long] [year]"

#let format-date(d, pattern: date-pattern) = {
  if d == none or d == [] or d == "" {
    none
  } else if type(d) == datetime {
    d.display(pattern)
  } else {
    d
  }
}

#let report-abbreviation(report-type) = REPORT_ABBREVIATIONS.at(report-type, default: "MMR")

// The running header writes the title page's "30 Percent" as "30%".
#let short-stage(stage) = plain-text(stage).trim().replace(regex("\\s*(?i:percent)\\b"), "%")
