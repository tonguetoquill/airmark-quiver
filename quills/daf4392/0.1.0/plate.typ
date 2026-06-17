#import "@local/quillmark-helper:0.1.0": data
#import "@local/daf4392page2-pkg:0.1.0": form

#set text(font: "NimbusRomNo9L")

// Map snake_case Quill `data` keys to generated `form.typ` parameter names.
#let vals = (:)

// Mode of Transportation — enum string drives one of six checkboxes.
#let mode = data.at("transportation_mode", default: "")
#if mode != "" { vals.insert("mode_" + mode, true) }

// Header row
#if "departure_date" in data { vals.insert("departure_date", data.departure_date) }
#if "final_destination" in data { vals.insert("final_destination", data.final_destination) }

// Proposed Travel Itinerary — one card per row, up to 10 rows.
#let itin-cols = ("date", "departure_point", "arrival_point", "rest_length", "mileage")
#{
  let row = 0
  for card in data.at("$cards", default: ()) {
    if card.at("$kind") == "itinerary" and row < 10 {
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
  let d = str(data.at("dept_flight_num", default: ""))
  if d != "" { vals.insert("dept_flight", [#text(weight: "bold")[Dept Flight:] #d]) }
  let a = str(data.at("arrival_flight_num", default: ""))
  if a != "" { vals.insert("arrival_flight", [#text(weight: "bold")[Arr Flight:] #a]) }
}

// Notes
#if "notes" in data { vals.insert("notes", data.notes) }

// Acknowledgements
#if "organization" in data { vals.insert("organization", data.organization) }
#if "briefed_date" in data { vals.insert("briefed_date", data.briefed_date) }
#if "briefee_name" in data { vals.insert("briefee_name", data.briefee_name) }
#if "briefee_grade" in data { vals.insert("briefee_grade", data.briefee_grade) }
#if "briefer_name" in data { vals.insert("briefer_name", data.briefer_name) }
#if "briefer_grade" in data { vals.insert("briefer_grade", data.briefer_grade) }

// Emergency contact — bold label prefixes a "name: phone" pair.
#{
  let en = str(data.at("emergency_contact_name", default: ""))
  let ep = str(data.at("emergency_contact_phone", default: ""))
  let contact = if en != "" and ep != "" { en + ": " + ep } else if en != "" { en } else { ep }
  if contact != "" {
    vals.insert("emergency_contact", [#text(weight: "bold")[EMERGENCY CONTACT:] #contact])
  }
}

#form(..vals)
