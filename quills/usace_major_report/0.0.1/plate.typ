#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usace-major-report:0.0.1": date-pattern, report, table-date-pattern

#let dist = qm.data.cui_distribution
#let dist-display = if dist.value == "Other" { dist.detail } else { dist.value }

#let previous-reports = qm.data.previous_reports.map(item => (
  number: item.number,
  title: item.title,
  date: qm.ink(item, "date", table-date-pattern),
))

#report(
  report-type: qm.data.report_type,
  report-number: qm.data.report_number,
  location-lines: qm.data.location_lines,
  project-name: qm.data.project_name,
  design-stage: qm.data.design_stage,
  date: qm.ink(qm.data, "date", date-pattern),
  cui-enabled: qm.data.cui_enabled,
  cui-controlled-by-component: qm.data.cui_controlled_by_component,
  cui-controlled-by-office: qm.data.cui_controlled_by_office,
  cui-categories: qm.data.cui_categories,
  cui-distribution: dist-display,
  cui-poc: qm.data.cui_poc,
  executive-summary: qm.data.executive_summary,
  appendices: qm.data.appendices,
  pertinent-data: qm.data.pertinent_data,
  previous-reports: previous-reports,
  acronyms: qm.data.acronyms,
  body: {
    let b = qm.data.at("$body")
    if type(b) == str { [] } else { b }
  },
)
