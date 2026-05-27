// form.typ (generated — do not edit)
#import "lib.typ": render-form

#let form(
  debug: false,
  mode_pmv: false,  // checkbox
  mode_airplane: false,  // checkbox
  mode_bus: false,  // checkbox
  mode_train: false,  // checkbox
  mode_motorcycle: false,  // checkbox
  mode_other: false,  // checkbox
  departure_date: "",  // text
  final_destination: "",  // text
  itin_date_1: "",  // text
  itin_departure_point_1: "",  // text
  itin_arrival_point_1: "",  // text
  itin_rest_length_1: "",  // text
  itin_mileage_1: "",  // text
  itin_date_2: "",  // text
  itin_departure_point_2: "",  // text
  itin_arrival_point_2: "",  // text
  itin_rest_length_2: "",  // text
  itin_mileage_2: "",  // text
  itin_date_3: "",  // text
  itin_departure_point_3: "",  // text
  itin_arrival_point_3: "",  // text
  itin_rest_length_3: "",  // text
  itin_mileage_3: "",  // text
  itin_date_4: "",  // text
  itin_departure_point_4: "",  // text
  itin_arrival_point_4: "",  // text
  itin_rest_length_4: "",  // text
  itin_mileage_4: "",  // text
  itin_date_5: "",  // text
  itin_departure_point_5: "",  // text
  itin_arrival_point_5: "",  // text
  itin_rest_length_5: "",  // text
  itin_mileage_5: "",  // text
  itin_date_6: "",  // text
  itin_departure_point_6: "",  // text
  itin_arrival_point_6: "",  // text
  itin_rest_length_6: "",  // text
  itin_mileage_6: "",  // text
  itin_date_7: "",  // text
  itin_departure_point_7: "",  // text
  itin_arrival_point_7: "",  // text
  itin_rest_length_7: "",  // text
  itin_mileage_7: "",  // text
  itin_date_8: "",  // text
  itin_departure_point_8: "",  // text
  itin_arrival_point_8: "",  // text
  itin_rest_length_8: "",  // text
  itin_mileage_8: "",  // text
  itin_date_9: "",  // text
  itin_departure_point_9: "",  // text
  itin_arrival_point_9: "",  // text
  itin_rest_length_9: "",  // text
  itin_mileage_9: "",  // text
  itin_date_10: "",  // text
  itin_departure_point_10: "",  // text
  itin_arrival_point_10: "",  // text
  itin_rest_length_10: "",  // text
  itin_mileage_10: "",  // text
  dept_flight: "",  // text
  arrival_flight: "",  // text
  notes: "",  // text
  organization: "",  // text
  briefed_date: "",  // text
  briefee_name: "",  // text
  briefee_grade: "",  // text
  briefer_name: "",  // text
  briefer_grade: "",  // text
  emergency_contact: "",  // text
) = render-form(
  schema: json("FIELDS.json"),
  backgrounds: ("page1.png",),
  values: (
    "mode_pmv": mode_pmv,
    "mode_airplane": mode_airplane,
    "mode_bus": mode_bus,
    "mode_train": mode_train,
    "mode_motorcycle": mode_motorcycle,
    "mode_other": mode_other,
    "departure_date": departure_date,
    "final_destination": final_destination,
    "itin_date_1": itin_date_1,
    "itin_departure_point_1": itin_departure_point_1,
    "itin_arrival_point_1": itin_arrival_point_1,
    "itin_rest_length_1": itin_rest_length_1,
    "itin_mileage_1": itin_mileage_1,
    "itin_date_2": itin_date_2,
    "itin_departure_point_2": itin_departure_point_2,
    "itin_arrival_point_2": itin_arrival_point_2,
    "itin_rest_length_2": itin_rest_length_2,
    "itin_mileage_2": itin_mileage_2,
    "itin_date_3": itin_date_3,
    "itin_departure_point_3": itin_departure_point_3,
    "itin_arrival_point_3": itin_arrival_point_3,
    "itin_rest_length_3": itin_rest_length_3,
    "itin_mileage_3": itin_mileage_3,
    "itin_date_4": itin_date_4,
    "itin_departure_point_4": itin_departure_point_4,
    "itin_arrival_point_4": itin_arrival_point_4,
    "itin_rest_length_4": itin_rest_length_4,
    "itin_mileage_4": itin_mileage_4,
    "itin_date_5": itin_date_5,
    "itin_departure_point_5": itin_departure_point_5,
    "itin_arrival_point_5": itin_arrival_point_5,
    "itin_rest_length_5": itin_rest_length_5,
    "itin_mileage_5": itin_mileage_5,
    "itin_date_6": itin_date_6,
    "itin_departure_point_6": itin_departure_point_6,
    "itin_arrival_point_6": itin_arrival_point_6,
    "itin_rest_length_6": itin_rest_length_6,
    "itin_mileage_6": itin_mileage_6,
    "itin_date_7": itin_date_7,
    "itin_departure_point_7": itin_departure_point_7,
    "itin_arrival_point_7": itin_arrival_point_7,
    "itin_rest_length_7": itin_rest_length_7,
    "itin_mileage_7": itin_mileage_7,
    "itin_date_8": itin_date_8,
    "itin_departure_point_8": itin_departure_point_8,
    "itin_arrival_point_8": itin_arrival_point_8,
    "itin_rest_length_8": itin_rest_length_8,
    "itin_mileage_8": itin_mileage_8,
    "itin_date_9": itin_date_9,
    "itin_departure_point_9": itin_departure_point_9,
    "itin_arrival_point_9": itin_arrival_point_9,
    "itin_rest_length_9": itin_rest_length_9,
    "itin_mileage_9": itin_mileage_9,
    "itin_date_10": itin_date_10,
    "itin_departure_point_10": itin_departure_point_10,
    "itin_arrival_point_10": itin_arrival_point_10,
    "itin_rest_length_10": itin_rest_length_10,
    "itin_mileage_10": itin_mileage_10,
    "dept_flight": dept_flight,
    "arrival_flight": arrival_flight,
    "notes": notes,
    "organization": organization,
    "briefed_date": briefed_date,
    "briefee_name": briefee_name,
    "briefee_grade": briefee_grade,
    "briefer_name": briefer_name,
    "briefer_grade": briefer_grade,
    "emergency_contact": emergency_contact,
  ),
  debug: debug,
)
