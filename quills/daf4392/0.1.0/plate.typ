#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/daf4392page2-pkg:0.1.0": form

#set text(font: "TeX Gyre Termes")

// Map snake_case Quill `data` keys to generated `form.typ` parameter names.
#let vals = (:)

// Mode of Transportation — enum string drives one of six checkboxes.
#let mode = qm.data.transportation_mode
#if mode != "" { vals.insert("mode_" + mode, true) }

// Header row
#if qm.data.departure_date != none { vals.insert("departure_date", qm.data.departure_date) }
#if qm.data.final_destination != "" { vals.insert("final_destination", qm.data.final_destination) }

// Proposed Travel Itinerary — one card per row, up to 10 rows.
#let itin-cols = ("date", "departure_point", "arrival_point", "rest_length", "mileage")
#{
  let row = 0
  for card in qm.data.at("$cards", default: ()) {
    if card.at("$kind", default: none) == "itinerary" and row < 10 {
      let n = str(row + 1)
      for col in itin-cols {
        let v = card.at(col, default: none)
        let display = if col == "date" { v } else if v == none { "" } else { str(v) }
        if display != none and display != "" { vals.insert("itin_" + col + "_" + n, display) }
      }
      row = row + 1
    }
  }
}

// Flight info — bold label prefixes a tentative/confirmed flight number.
#{
  let d = str(qm.data.dept_flight_num)
  if d != "" { vals.insert("dept_flight", [#text(weight: "bold")[Dept Flight:] #d]) }
  let a = str(qm.data.arrival_flight_num)
  if a != "" { vals.insert("arrival_flight", [#text(weight: "bold")[Arr Flight:] #a]) }
}

// Notes
#if qm.data.notes != "" { vals.insert("notes", qm.data.notes) }

// Acknowledgements
#if qm.data.organization != "" { vals.insert("organization", qm.data.organization) }
#if qm.data.briefed_date != none { vals.insert("briefed_date", qm.data.briefed_date) }
#if qm.data.briefee_name != "" { vals.insert("briefee_name", qm.data.briefee_name) }
#if qm.data.briefee_grade != "" { vals.insert("briefee_grade", qm.data.briefee_grade) }
#if qm.data.briefer_name != "" { vals.insert("briefer_name", qm.data.briefer_name) }
#if qm.data.briefer_grade != "" { vals.insert("briefer_grade", qm.data.briefer_grade) }

// Emergency contact — bold label prefixes a "name: phone" pair.
#{
  let en = str(qm.data.emergency_contact_name)
  let ep = str(qm.data.emergency_contact_phone)
  let contact = if en != "" and ep != "" { en + ": " + ep } else if en != "" { en } else { ep }
  if contact != "" {
    vals.insert("emergency_contact", [#text(weight: "bold")[EMERGENCY CONTACT:] #contact])
  }
}

#form(..vals)
