#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usace-tech-memo:0.0.1": date-pattern, memo, table-date-pattern

#let dist = qm.data.cui_distribution
#let dist-display = if dist.value == "Other" { dist.detail } else { dist.value }

#let previous-memos = qm.data.previous_memos.map(item => (
  number: item.number,
  title: item.title,
  date: qm.ink(item, "date", table-date-pattern),
))

#memo(
  memo-number: qm.data.memo_number,
  location-lines: qm.data.location_lines,
  study-name: qm.data.study_name,
  subject: qm.data.subject,
  prepared-for: qm.data.prepared_for,
  prepared-by: qm.data.prepared_by,
  date: qm.ink(qm.data, "date", date-pattern),
  cui-enabled: qm.data.cui_enabled,
  cui-controlled-by-component: qm.data.cui_controlled_by_component,
  cui-controlled-by-office: qm.data.cui_controlled_by_office,
  cui-categories: qm.data.cui_categories,
  cui-distribution: dist-display,
  cui-poc: qm.data.cui_poc,
  appendices: qm.data.appendices,
  pertinent-data: qm.data.pertinent_data,
  previous-memos: previous-memos,
  acronyms: qm.data.acronyms,
  include-summary: qm.data.include_summary,
  body: {
    let b = qm.data.at("$body")
    if type(b) == str { [] } else { b }
  },
)
