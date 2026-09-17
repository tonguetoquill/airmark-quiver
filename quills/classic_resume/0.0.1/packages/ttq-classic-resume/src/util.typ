// util.typ
// Helpers shared by the components.

// A contact line usually holds an email address, a profile link, a phone
// number and a city. Only the first three are worth turning into a link, and
// they are distinguishable by shape.
#let _email = regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")
#let _scheme = regex("^(https?://|www\\.)\\S+$")
#let _domain = regex("^[\\w-]+(\\.[\\w-]+)*\\.[A-Za-z]{2,24}(/\\S*)?$")
#let _phone = regex("^[+(\\d][\\d\\s()./+-]*\\d$")
#let _digit = regex("\\d")

// Turns a contact into a link when it looks like an email address, a web
// address or a phone number, and returns it unchanged otherwise. A city or a
// clearance level is therefore left alone, and so is anything that is already
// content, so callers can always pass their own `link(..)` instead.
#let auto-link(contact) = {
  if type(contact) != str {
    contact
  } else if contact.match(_email) != none {
    link("mailto:" + contact, contact)
  } else if contact.match(_scheme) != none {
    let href = if contact.starts-with("www.") { "https://" + contact } else { contact }
    link(href, contact)
  } else if contact.match(_domain) != none {
    link("https://" + contact, contact)
  } else if contact.match(_phone) != none and contact.matches(_digit).len() >= 7 {
    link("tel:" + contact.replace(regex("[^\\d+]"), ""), contact)
  } else {
    contact
  }
}
