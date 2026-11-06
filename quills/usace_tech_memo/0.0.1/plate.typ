#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usace-tech-memo:0.0.1": date-pattern, memo, statement-date-pattern, table-date-pattern

#let memo-fields = qm.data.memo
#let cui = qm.data.cui
#let front = qm.data.front_matter

#let dist = cui.distribution
#let dist-display = if dist.value == "Other" { dist.detail } else { dist.value }

#let previous-memos = front.previous_memos.map(item => (
  number: item.number,
  title: item.title,
  date: qm.ink(item, "date", table-date-pattern),
))

#memo(
  memo-number: memo-fields.memo_number,
  location-lines: memo-fields.location_lines,
  study-name: memo-fields.study_name,
  subject: memo-fields.subject,
  prepared-for: memo-fields.prepared_for,
  prepared-by: memo-fields.prepared_by,
  date: qm.ink(memo-fields, "date", date-pattern),
  marking: cui.marking,
  cui-controlled-by-component: cui.controlled_by_component,
  cui-controlled-by-office: cui.controlled_by_office,
  cui-categories: cui.categories,
  cui-distribution: dist-display,
  cui-distribution-reason: cui.distribution_reason,
  cui-distribution-date: qm.ink(cui, "distribution_date", statement-date-pattern),
  cui-distribution-office: cui.distribution_office,
  cui-poc: cui.poc,
  appendices: front.appendices,
  pertinent-data: front.pertinent_data,
  previous-memos: previous-memos,
  acronyms: front.acronyms,
  include-summary: memo-fields.include_summary,
  body: {
    let b = qm.data.at("$body")
    if type(b) == str { [] } else { b }
  },
)
