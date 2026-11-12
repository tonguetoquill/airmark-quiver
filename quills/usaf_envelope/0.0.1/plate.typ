#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usaf-envelope:0.0.1": envelope

// A text field arrives as content with a space on each side. The address is
// the writer's characters, in capitals, or it is nothing.
#let plain(value) = qm.str(value).trim()

#let shown(parent, key) = {
  let raw = plain(parent.at(key))
  if raw == "" { none } else { qm.region(parent.at("$path") + key, upper(raw)) }
}

#let shown-lines(parent, key) = {
  let base = parent.at("$path") + key + "."
  parent.at(key).enumerate().map(((i, item)) => {
    let raw = plain(item)
    if raw == "" { none } else { qm.region(base + str(i), upper(raw)) }
  }).filter(line => line != none)
}

#let delivery = qm.data.delivery
#let ret = qm.data.return
#let spec = qm.data.envelope

// Chapter 22 limits the address to five lines. The country is the last of
// those five. When it is filled and the five lines above it are filled too,
// the account or mail stop, the first and the optional one, is the line that
// does not print.
#let parts = (
  shown(delivery, "non_address"),
  shown(delivery, "attention"),
  shown(delivery, "recipient"),
  shown(delivery, "street"),
  shown(delivery, "city"),
).filter(line => line != none)
#let country = shown(delivery, "country")
#let delivery-lines = if country == none {
  parts
} else {
  let kept = if parts.len() > 4 { parts.slice(parts.len() - 4) } else { parts }
  kept + (country,)
}

#let who = plain(delivery.recipient)
#let size = {
  let named = spec.size
  if named == "" or named == none { "number-10" } else { named }
}

#envelope(
  size: size,
  title: if who == "" { "Envelope" } else { upper(who) },
  return-lines: shown-lines(ret, "lines"),
  official-business: if ret.official_business { qm.region(ret.at("$path") + "official_business", [OFFICIAL BUSINESS]) },
  delivery-lines: delivery-lines,
  marking: if spec.non_machineable { qm.region(spec.at("$path") + "non_machineable", [NON-MACHINEABLE]) },
)
