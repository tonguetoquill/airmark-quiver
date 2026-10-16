#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/typst-af4141:0.1.0": form

#set text(font: "TeX Gyre Termes")

// A `type: date` field arrives as a native `datetime`, blank as `none`, and a
// `text` field as content. The form's cells are strings, so a date is formatted
// here rather than placed as ink and a text value is read through `qm.str`:
// `qm.ink` would give the glyphs a schema address, but the form draws each cell
// into a fixed box it builds itself, which takes a `str`.
#let form-cell(v) = {
  let pattern = "[month padding:none]/[day padding:none]/[year]"
  if v == none { "" }
  else if type(v) == datetime { v.display(pattern) }
  else { qm.str(v) }
}

// Column order within each 7-field row group
#let col-keys = (
  "date",
  "action",
  "written_grade",
  "written_grade_date",
  "positional_grade",
  "positional_grade_date",
  "auth_or_remarks",
)

// Build the values dictionary for the form
#let vals = (:)

// --- Admin fields (page 1 header) ---
#if qm.data.name != "" { vals.insert("commonforms_text_p1_1", qm.str(qm.data.name)) }
#if qm.data.unit != "" { vals.insert("commonforms_text_p1_2", qm.str(qm.data.unit)) }
#if qm.data.grade != "" { vals.insert("commonforms_text_p1_3", qm.str(qm.data.grade)) }
#if qm.data.commanders_auth != "" { vals.insert("commonforms_text_p1_116", qm.str(qm.data.commanders_auth)) }

// --- Experience table rows from CARDS ---
// The form supports 16 rows on page 1 and 21 rows on page 2 (37 total).
// Overflow rows are silently ignored.
#let max-rows = 37
#{
  let row = 0
  for card in qm.data.at("$cards") {
    if card.at("$kind", default: none) == "experience" {
      if row < max-rows {
        for (col, key) in col-keys.enumerate() {
          let value = form-cell(card.at(key, default: none))
          if value != "" {
            let field-name = if row < 16 {
              // Page 1: fields start at index 4, stride 7
              "commonforms_text_p1_" + str(4 + row * 7 + col)
            } else {
              // Page 2: fields start at index 1, stride 7
              "commonforms_text_p2_" + str(1 + (row - 16) * 7 + col)
            }
            vals.insert(field-name, value)
          }
        }
      }
      row = row + 1
    }
  }
}

// Render the form with assembled values
#form(..vals)
