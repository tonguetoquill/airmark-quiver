#import "@local/quillmark-helper:0.2.0" as qm

// Liberation Sans is the Arial-metric face. The official template sets the
// page in 9-point type on a 12.6-point line, section headings at 11 points,
// and the identification line at 13 points in the template blue. The banner
// and the footer rule are the template's artwork, repeated on every page.
// Text sits on a one-inch margin. The banner and the rule sit a quarter inch
// from the page edge, outside that margin.
#set page(
  paper: "us-letter",
  margin: (top: 108pt, bottom: 54pt, left: 72pt, right: 72pt),
  background: {
    place(
      top + left,
      dx: 18pt,
      dy: 17.52pt,
      image("assets/biography_header.png", width: 576.48pt, height: 66.72pt, fit: "stretch"),
    )
    place(
      top + left,
      dx: 18.72pt,
      dy: 755.04pt,
      image("assets/biography_footer.png", width: 575.04pt, height: 23.52pt, fit: "stretch"),
    )
  },
)
#set text(font: "Liberation Sans", size: 9pt, lang: "en", hyphenate: false)
#set par(leading: 6.45pt, justify: true, spacing: 12.6pt)
#set block(spacing: 0pt)

#let idn = qm.data.identification
#let narrative = qm.data.narrative
#let status = idn.status.value
#let military = status == "officer" or status == "enlisted"

#let person = qm.str(idn.name).trim()
#let rank-name = if military { qm.str(idn.status.full_rank).trim() } else { "" }
#let title = {
  let parts = ()
  if rank-name != "" { parts.push(rank-name) }
  if person != "" { parts.push(person) }
  if parts.len() == 0 { "" } else { parts.join(" ") }
}
#set document(title: title, author: person)

// A month with a day abbreviates, except March through July, which never do.
// A month with only a year is spelled out.
#let months-with-day = (
  "Jan.", "Feb.", "March", "April", "May", "June",
  "July", "Aug.", "Sept.", "Oct.", "Nov.", "Dec.",
)
#let months-long = (
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
)
#let ap-day(d) = {
  months-with-day.at(d.month() - 1) + " " + str(d.day()) + ", " + str(d.year())
}
#let ap-month(d) = months-long.at(d.month() - 1) + " " + str(d.year())

#let blank(v) = {
  if v == none or v == [] { true }
  else if type(v) == str { v.trim() == "" }
  else { qm.str(v).trim() == "" }
}

#let ink(row, key) = {
  let shown = qm.ink(row, key)
  if blank(shown) { none } else { shown }
}

#let comma-join(parts) = {
  let line = none
  for part in parts {
    if part != none {
      line = if line == none { part } else { [#line, #part] }
    }
  }
  line
}

#let date-span(row) = {
  let from = ink(row, "from")
  let to = ink(row, "to")
  if from != none and to != none { [#from – #to] }
  else if from != none { from }
  else { to }
}

// The plate adds the parentheses. A note that already contains a closing and
// an opening parenthesis keeps each deployment in its own pair.
#let with-deployment(line, row) = {
  let note = ink(row, "deployment")
  if note == none { line }
  else if line == none { [(#note)] }
  else { [#line (#note)] }
}

#let assignment-line(row, joint: false) = {
  let line = comma-join((
    date-span(row),
    ink(row, "duty_title"),
    ink(row, "organization"),
    ink(row, "installation"),
  ))
  if joint {
    let held = ink(row, "rank_held")
    if held != none {
      line = if line == none { [as a #held] } else { [#line, as a #held] }
    }
  }
  with-deployment(line, row)
}

// One line's glyph box is shorter than the 12.6-point line, so each line block
// carries the rest of that line as inset. A blank line is a whole extra line.
#let line-gap = 6.4pt
#let blank-line = block(height: 12.6pt)

// A wrapped assignment hangs under the text, level with the template's
// continuation at 13.6 points past the left margin.
#let numbered(n, body) = block(inset: (bottom: line-gap), grid(
  columns: (13.6pt, 1fr),
  column-gutter: 0pt,
  align: top,
  [#n.],
  body,
))

#let tight(body) = block(inset: (bottom: line-gap), body)

#let year-line(row) = {
  let year = if row.year != none { qm.ink(row, "year") } else { none }
  let entry = ink(row, "entry")
  if year == none and entry == none { return none }
  block(inset: (bottom: line-gap), {
    if year != none { year }
    if year != none and entry != none { " " }
    if entry != none { entry }
  })
}

#let numbered-entries(rows, joint: false) = {
  let out = ()
  let n = 0
  for row in rows {
    let line = assignment-line(row, joint: joint)
    if line != none {
      n += 1
      out.push(numbered(n, line))
    }
  }
  out
}

#let lines-of(items) = {
  items.map(item => if blank(item) { none } else { tight(item) }).filter(item => item != none)
}

// Text wraps in the column beside the frame and continues at full width once
// the frame's 4 inches are used. The frame is empty: public affairs places
// the service-dress photograph. A justified line's ink runs past the column
// edge, so the gutter is 17 points and about 12 points of white remain
// between that ink and the frame, as on the template.

#let beside-photo(blocks) = layout(size => {
  let photo-w = 3.2in
  let gap = 17pt
  let text-w = size.width - photo-w - gap
  let limit = 4in
  let beside = ()
  let below = ()
  let used = 0pt
  let open = true
  for block in blocks {
    let height = measure(width: if open { text-w } else { size.width }, block).height
    if open and (beside.len() == 0 or used + height <= limit) {
      beside.push(block)
      used += height
      if used >= limit { open = false }
    } else {
      open = false
      below.push(block)
    }
  }
  grid(
    columns: (text-w, photo-w),
    column-gutter: gap,
    align: top,
    stack(spacing: 0pt, ..beside),
    // The stroke is centered on the frame edge. This shift puts the top of
    // the frame on the first line of the narrative.
    move(dy: -0.6pt, rect(width: photo-w, height: 4in, stroke: 0.5pt + black)),
  )
  stack(spacing: 0pt, ..below)
})

#let rank-ink = if military { ink(idn.status, "full_rank") } else { none }
#let name-ink = ink(idn, "name")
#if rank-ink != none or name-ink != none {
  block(inset: (top: 13pt, bottom: 8.9pt), text(size: 13pt, weight: "bold", fill: rgb("#4472c4"), {
    set par(justify: false)
    if rank-ink != none { upper(rank-ink) }
    if rank-ink != none and name-ink != none { " " }
    if name-ink != none { upper(name-ink) }
  }))
}

// The blank line before a heading is its own block, so a heading that breaks
// onto the next page does not carry that space with it. The heading stays
// with its first entry, 15.5 points from the heading top to that entry.
#let section(title, entries) = {
  if entries.len() == 0 { return () }
  (
    blank-line,
    block(breakable: false, {
      set par(justify: false)
      text(size: 11pt, weight: "bold", title)
      block(height: 7.8pt)
      entries.first()
    }),
    ..entries.slice(1),
  )
}

#let para(body) = block(inset: (bottom: line-gap), body)

#let paragraphs = {
  let bodies = ()
  for key in ("current_duty", "career", "further") {
    let shown = ink(narrative, key)
    if shown != none { bodies.push(shown) }
  }
  if status == "civilian" {
    for item in narrative.earlier {
      if not blank(item) { bodies.push(item) }
    }
  }
  let out = ()
  for (i, body) in bodies.enumerate() {
    if i > 0 { out.push(blank-line) }
    out.push(para(body))
  }
  out
}

// AFH 33-337 puts two spaces after each colon.
#let flight-lines = {
  let out = ()
  let rating = ink(qm.data.flight, "rating")
  let hours = ink(qm.data.flight, "flight_hours")
  let aircraft = ink(qm.data.flight, "aircraft")
  if rating != none { out.push(tight[Rating:~~#rating]) }
  if hours != none { out.push(tight[Flight hours:~~#hours]) }
  if aircraft != none { out.push(tight[Aircraft flown:~~#aircraft]) }
  out
}

#let promotion-block = {
  let rows = if military {
    qm.data.promotions.entries.filter(row => not blank(row.rank) or row.date != none)
  } else { () }
  if rows.len() == 0 { () } else {
    let heading = if qm.data.promotions.singular_heading {
      "EFFECTIVE DATE OF PROMOTION"
    } else {
      "EFFECTIVE DATES OF PROMOTION"
    }
    section(heading, rows.map(row => tight({
      if not blank(row.rank) { qm.ink(row, "rank") }
      if not blank(row.rank) and row.date != none { " " }
      if row.date != none { ap-day(row.date) }
    })))
  }
}

#let work-heading = if status == "civilian" { "CAREER CHRONOLOGY" } else { "ASSIGNMENTS" }
#let joint = if status == "officer" {
  section(
    "SUMMARY OF JOINT ASSIGNMENTS",
    numbered-entries(qm.data.joint_assignments.entries, joint: true),
  )
} else { () }

#let blocks = (
  ..paragraphs,
  ..section("EDUCATION", qm.data.education.entries.map(year-line).filter(line => line != none)),
  ..section(work-heading, numbered-entries(qm.data.assignments.entries)),
  ..joint,
  ..section("FLIGHT INFORMATION", flight-lines),
  ..section("MAJOR AWARDS AND DECORATIONS", lines-of(qm.data.awards.entries)),
  ..section("OTHER ACHIEVEMENTS", qm.data.achievements.entries.map(year-line).filter(line => line != none)),
  ..section("OCCUPATIONAL BADGES", lines-of(qm.data.badges.entries)),
  ..section("PUBLICATIONS", lines-of(qm.data.publications.entries)),
  ..section("PROFESSIONAL MEMBERSHIPS AND ASSOCIATIONS", lines-of(qm.data.memberships.entries)),
  ..promotion-block,
  ..if qm.data.as_of.date != none {
    (block(inset: (top: 12.6pt))[(Current as of #ap-month(qm.data.as_of.date))],)
  } else { () },
)

#if narrative.photograph and blocks.len() > 0 {
  beside-photo(blocks)
} else if narrative.photograph {
  align(right, rect(width: 3.2in, height: 4in, stroke: 0.5pt + black))
} else {
  for block in blocks { block }
}
