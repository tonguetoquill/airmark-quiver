#import "@local/quillmark-helper:0.2.0" as qm

// Liberation Sans is the Arial-metric face. AFH 33-337 sets the biography in
// Arial 9-point with 1.15 line spacing, and the identification line at 13.5.
#set page(paper: "us-letter", margin: 0.5in)
#set text(font: "Liberation Sans", size: 9pt, lang: "en", hyphenate: false)
#set par(leading: 0.45em, justify: false, spacing: 0.65em)

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

#let numbered(n, body) = block(
  inset: (bottom: 1.5pt),
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.45em,
    align: top,
    [#n.],
    body,
  ),
)

#let tight(body) = block(inset: (bottom: 1.5pt), body)

#let year-line(row) = {
  let year = if row.year != none { qm.ink(row, "year") } else { none }
  let entry = ink(row, "entry")
  if year == none and entry == none { return none }
  block(inset: (bottom: 1.5pt), grid(
    columns: (auto, 1fr),
    column-gutter: 0.55em,
    align: top,
    if year != none { year } else { [] },
    if entry != none { entry } else { [] },
  ))
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
// the frame's 4 inches are used. The frame is empty: the biography's
// photograph is placed there by public affairs.
#let beside-photo(blocks) = layout(size => {
  let photo-w = 3.2in
  let gap = 0.15in
  let text-w = size.width - photo-w - gap
  let limit = 4in
  let beside = ()
  let below = ()
  let used = 0pt
  let open = true
  for block in blocks {
    if open {
      let height = measure(width: text-w, block).height
      beside.push(block)
      used += height
      if used >= limit { open = false }
    } else {
      below.push(block)
    }
  }
  grid(
    columns: (text-w, photo-w),
    column-gutter: gap,
    align: top,
    stack(spacing: 0pt, ..beside),
    box(width: photo-w, height: 4in),
  )
  stack(spacing: 0pt, ..below)
})

#let rank-ink = if military { ink(idn.status, "full_rank") } else { none }
#let name-ink = ink(idn, "name")
#if rank-ink != none or name-ink != none {
  align(center, text(size: 13.5pt, weight: "bold", {
    if rank-ink != none { upper(rank-ink) }
    if rank-ink != none and name-ink != none { " " }
    if name-ink != none { upper(name-ink) }
  }))
  v(10pt)
}

#let section(title, entries) = {
  if entries.len() == 0 { return () }
  (block(inset: (top: 9pt, bottom: 2pt), strong(title)), ..entries)
}

#let paragraphs = {
  let out = ()
  for key in ("current_duty", "career", "further") {
    let shown = ink(narrative, key)
    if shown != none { out.push(block(inset: (bottom: 10pt), shown)) }
  }
  if status == "civilian" {
    for para in narrative.earlier {
      if not blank(para) { out.push(block(inset: (bottom: 10pt), para)) }
    }
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
    section(heading, (
      table(
        columns: (auto, auto),
        stroke: none,
        inset: (x: 0pt, y: 0.5pt),
        column-gutter: 1.25em,
        align: (left, left),
        ..rows.map(row => (
          if blank(row.rank) { [] } else { qm.ink(row, "rank") },
          if row.date == none { [] } else { ap-day(row.date) },
        )).flatten(),
      ),
    ))
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
    (block(inset: (top: 10pt))[(Current as of #ap-month(qm.data.as_of.date))],)
  } else { () },
)

#if narrative.photograph and blocks.len() > 0 {
  beside-photo(blocks)
} else if narrative.photograph {
  align(right, box(width: 3.2in, height: 4in))
} else {
  for block in blocks { block }
}
