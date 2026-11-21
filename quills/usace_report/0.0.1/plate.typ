#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usace-report:0.0.1": appendix, memo, memo-date-pattern, report, report-date-pattern, statement-date-pattern, table-date-pattern

#let document = qm.data.document
#let cui = qm.data.cui

#let dist = cui.distribution
#let dist-display = if dist.value == "Other" { dist.detail } else { dist.value }

#let cui-args = (
  marking: cui.marking,
  cui-controlled-by-component: cui.controlled_by_component,
  cui-controlled-by-office: cui.controlled_by_office,
  cui-categories: cui.categories,
  cui-distribution: dist-display,
  cui-distribution-reason: cui.distribution_reason,
  cui-distribution-date: qm.ink(cui, "distribution_date", statement-date-pattern),
  cui-distribution-office: cui.distribution_office,
  cui-poc: cui.poc,
)

#let body = {
  let b = qm.data.at("$body")
  if type(b) == str { [] } else { b }
}

#let dated-rows(items) = items.map(item => (
  number: item.number,
  title: item.title,
  date: qm.ink(item, "date", table-date-pattern),
))

#if document.value == "Technical Memorandum" {
  let fields = document.memo
  let front = document.memo_front_matter
  memo(
    memo-number: fields.memo_number,
    location-lines: fields.location_lines,
    study-name: fields.study_name,
    subject: fields.subject,
    prepared-for: fields.prepared_for,
    prepared-by: fields.prepared_by,
    date: qm.ink(fields, "date", memo-date-pattern),
    ..cui-args,
    appendices: front.appendices,
    pertinent-data: front.pertinent_data,
    previous-memos: dated-rows(front.previous_memos),
    acronyms: front.acronyms,
    include-summary: fields.include_summary,
    body: body,
  )
} else if document.value == "Report Appendix" {
  let fields = document.appendix
  appendix(
    appendix-type: fields.appendix_type,
    letter: fields.appendix_letter,
    title: fields.appendix_title,
    project-name: fields.project_name,
    ..cui-args,
    executive-summary: fields.executive_summary,
    body: body,
  )
} else if document.value == "Report" {
  let fields = document.report
  let front = document.report_front_matter
  report(
    report-type: fields.report_type,
    report-number: fields.report_number,
    location-lines: fields.location_lines,
    project-name: fields.project_name,
    design-stage: fields.design_stage,
    date: qm.ink(fields, "date", report-date-pattern),
    ..cui-args,
    executive-summary: front.executive_summary,
    appendices: front.appendices,
    pertinent-data: front.pertinent_data,
    previous-reports: dated-rows(front.previous_reports),
    acronyms: front.acronyms,
    body: body,
  )
} else {
  report(..cui-args, body: body)
}
