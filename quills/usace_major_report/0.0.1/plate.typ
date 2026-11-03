#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usace-major-report:0.0.1": date-pattern, report, statement-date-pattern, table-date-pattern

#let dist = qm.data.cui.distribution
#let dist-display = if dist.value == "Other" { dist.detail } else { dist.value }

#let previous-reports = qm.data.front_matter.previous_reports.map(item => (
  number: item.number,
  title: item.title,
  date: qm.ink(item, "date", table-date-pattern),
))

#report(
  report-type: qm.data.report.report_type,
  report-number: qm.data.report.report_number,
  location-lines: qm.data.report.location_lines,
  project-name: qm.data.report.project_name,
  design-stage: qm.data.report.design_stage,
  date: qm.ink(qm.data.report, "date", date-pattern),
  marking: qm.data.cui.marking,
  cui-controlled-by-component: qm.data.cui.controlled_by_component,
  cui-controlled-by-office: qm.data.cui.controlled_by_office,
  cui-categories: qm.data.cui.categories,
  cui-distribution: dist-display,
  cui-distribution-reason: qm.data.cui.distribution_reason,
  cui-distribution-date: qm.ink(qm.data.cui, "distribution_date", statement-date-pattern),
  cui-distribution-office: qm.data.cui.distribution_office,
  cui-poc: qm.data.cui.poc,
  executive-summary: qm.data.front_matter.executive_summary,
  appendices: qm.data.front_matter.appendices,
  pertinent-data: qm.data.front_matter.pertinent_data,
  previous-reports: previous-reports,
  acronyms: qm.data.front_matter.acronyms,
  body: {
    let b = qm.data.at("$body")
    if type(b) == str { [] } else { b }
  },
)
