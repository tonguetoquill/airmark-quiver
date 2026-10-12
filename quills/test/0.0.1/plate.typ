#import "@local/quillmark-helper:0.1.0": data, display, ink

#set page(paper: "us-letter", margin: 1in)
#set text(size: 11pt)

#let title = data.title.trim()
#let named = data.author.trim() != ""
#let dated = data.date != none
#set document(
  title: if title != "" { title } else { "Test" },
  author: data.author.trim(),
)

// A `plaintext` field lowers to content with a space on each side.
#let trim-inline(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

#if title != "" [
  #align(center, text(size: 16pt, weight: "bold")[#ink(data).title])
]

#if named or dated [
  #align(center)[
    #if named [#ink(data).author]
    #if named and dated [, ]
    #if dated [#display("date", "[day padding:none] [month repr:long] [year]")]
  ]
]

#data.at("$body", default: "")

#if data.note != "" [
  #block(above: 1.2em, inset: (left: 0.6em), stroke: (left: 1pt))[
    #trim-inline(data.note)
  ]
]

#for card in data.at("$cards", default: ()) {
  if card.at("$kind", default: none) == "item" {
    let body = card.at("$body", default: "")
    block(above: 1em)[
      #if card.label != "" [
        #text(weight: "bold")[#trim-inline(card.label)]
      ]
      #if type(body) != str [#body]
    ]
  }
}
