// One rendering function per element of the memorandum, each placing it where
// AR 25-50 chapter 2 puts it.

#import "config.typ": *
#import "utils.typ": *

// A text line placed so its baseline lands on a page position.
#let baselined(body) = text(top-edge: "baseline", bottom-edge: "baseline", body)

// AR 25-50 1-16: the seal and the letterhead lines, page 1 only, in black
// (1-16b(3)). Placed against the page, so call it from the page background.
#let render-letterhead(lines, seal: none, font: DEFAULT_BODY_FONTS) = {
  if seal != none {
    place(top + left, dx: LETTERHEAD.seal-left, dy: LETTERHEAD.seal-top, seal)
  }
  for (i, line) in ensure-array(lines).enumerate() {
    let fixed = LETTERHEAD.line-baselines
    let (size, baseline) = if i == 0 {
      (LETTERHEAD.title-size, LETTERHEAD.title-baseline)
    } else if i <= fixed.len() {
      (LETTERHEAD.line-size, fixed.at(i - 1))
    } else {
      (LETTERHEAD.line-size, fixed.last() + (i - fixed.len()) * LETTERHEAD.line-pitch)
    }
    place(
      top + center,
      dy: baseline,
      fit-to-width(
        LETTERHEAD.max-width,
        alignment: center,
        box(baselined(text(size, font: font, weight: "bold", fill: black, upper(line)))),
      ),
    )
  }
}

// AR 25-50 2-4a(4): "S: <date>" in bold, flush right, two lines above the
// date. Placed against the page, so call it from the page background.
#let render-suspense(suspense, font-size) = {
  if falsey(suspense) { return none }
  place(
    top + right,
    dx: -MARGIN,
    dy: office-symbol-baseline(font-size) - 2 * LINE.to-absolute(),
    baselined(text(weight: "bold")[S: #suspense]),
  )
}

// AR 25-50 2-4a(1)-(3): the office symbol, then one space and its ARIMS
// record number in parentheses, then any other information, at the left
// margin; the date on the same line, flush right. Other information that
// does not fit beside the symbol starts the second line, flush left.
#let render-office-symbol-row(office-symbol, record-number, info, date) = {
  let symbol = if blank(record-number) {
    [#office-symbol]
  } else {
    [#office-symbol~#box[(#record-number)]]
  }
  let left = if blank(info) {
    par(symbol)
  } else {
    layout(size => {
      let line = [#symbol #info]
      par(if measure(line).width <= size.width { line } else [#symbol#linebreak()#info])
    })
  }
  grid(
    columns: (1fr, DATE_WIDTH),
    column-gutter: DATE_GUTTER,
    left, align(right, box(date)),
  )
}

// An address line set flush left, its turnover indented a quarter inch
// (AR 25-50 2-4a(5)(b)).
#let hanging-address(address) = par(hanging-indent: TURNOVER, upper(address))

// "<lead> <address>" for one address, or the lead alone with the addresses on
// the lines below it.
#let render-addresses(lead, addresses) = {
  if addresses.len() == 1 {
    par[#lead #upper(addresses.at(0))]
  } else {
    par(lead)
    for address in addresses { hanging-address(address) }
  }
}

// One THRU address with its comment and signature boxes at the right margin,
// each spanning the address's lines and the blank line below them.
#let render-thru-address(address, fields) = context {
  let body = block(width: THRU.text-width, address)
  let height = measure(body).height + LEADING.to-absolute() + LINE.to-absolute() - THRU.box-clear
  let comment-x = THRU.text-width + THRU.box-gap
  let signature-x = comment-x + THRU.box-width + THRU.box-gap
  block({
    if fields != none {
      place(top + left, dx: comment-x, dy: -THRU.box-rise, (fields.comment)(height))
      place(top + left, dx: signature-x, dy: -THRU.box-rise, (fields.signature)(height))
    }
    body
  })
}

// AR 25-50 2-4a(5) and 2-7: MEMORANDUM FOR RECORD, FOR one or several
// addresses, or THRU one or several offices and then FOR.
#let render-address-section(memo-for, memo-thru, thru-fields) = {
  let memo-for = ensure-array(memo-for).filter(a => not blank(a))
  let thru = ensure-array(memo-thru)
    .enumerate()
    .filter(((i, a)) => not blank(a))
    .map(((i, a)) => (address: a, fields: ensure-array(thru-fields).at(i, default: none)))

  if thru.len() == 0 and memo-for.len() == 0 {
    par[MEMORANDUM FOR RECORD]
  } else if thru.len() == 0 {
    render-addresses([MEMORANDUM FOR], memo-for)
  } else {
    if thru.len() == 1 {
      render-thru-address(par[MEMORANDUM THRU #upper(thru.at(0).address)], thru.at(0).fields)
    } else {
      par[MEMORANDUM THRU]
      for (k, entry) in thru.enumerate() {
        if k > 0 { blank-line() }
        render-thru-address(hanging-address(entry.address), entry.fields)
      }
    }
    if memo-for.len() > 0 {
      blank-line()
      render-addresses([FOR], memo-for)
    }
  }
}

// AR 25-50 2-4a(6): SUBJECT: on the second line below the address, its
// turnover flush with the left margin.
#let subject-line(subject) = [SUBJECT: #subject]

/// The authority line uppercased and ending in one colon (AR 25-50 2-4c(1)).
/// Blank is no line.
///
/// - value (str | content | none)
/// -> content | none
#let format-authority-line(value) = {
  if blank(value) { return none }
  if plain-text(value).trim().ends-with(":") { upper(value) } else { [#upper(value):] }
}

// Whether an enclosure entry stands for one the body identifies (AR 25-50
// 4-2b): it prints "as".
#let as-stated(entry) = lower(plain-text(entry).trim()) in ("as", "as stated")

// AR 25-50 4-2c(1): a listed enclosure begins with a capital letter.
#let capitalize(it) = {
  if type(it) == str {
    return if it == "" { it } else { upper(it.first()) + it.slice(it.first().len()) }
  }
  if type(it) != content { return it }
  if it.func() == text { return text(capitalize(it.text)) }
  if it.has("child") and it.has("styles") { return (it.func())(capitalize(it.child), it.styles) }
  if it.func() in (strong, emph) { return (it.func())(capitalize(it.body)) }
  if it.has("children") {
    let children = it.children
    let first = children.position(c => plain-text(c).trim() != "")
    if first == none { return it }
    children.at(first) = capitalize(children.at(first))
    return children.join()
  }
  it
}

// A numbered line whose wrapped lines hang under its text.
#let numbered-line(label, body) = context {
  let lead = [#label#PERIOD_GAP]
  par(hanging-indent: measure(lead).width)[#lead#body]
}

// AR 25-50 2-4c(3) and chapter 4: "Encl" or "N Encls" at the left margin,
// with each described enclosure numbered beneath and a run of enclosures the
// body identifies collapsed to "1–3.  as".
#let render-enclosures(enclosures) = {
  let entries = ensure-array(enclosures).filter(e => not blank(e))
  let count = entries.len()
  let as-flags = entries.map(as-stated)
  if count == 0 {
    none
  } else if as-flags.all(f => f) {
    par(if count == 1 [Encl] else [Encls])
  } else if count == 1 {
    par[Encl]
    par(capitalize(entries.at(0)))
  } else {
    par[#str(count) Encls]
    let i = 0
    while i < count {
      if as-flags.at(i) {
        let j = i
        while j + 1 < count and as-flags.at(j + 1) { j += 1 }
        let label = if j > i { str(i + 1) + "–" + str(j + 1) + "." } else { str(i + 1) + "." }
        numbered-line(label, [as])
        i = j + 1
      } else {
        numbered-line(str(i + 1) + ".", capitalize(entries.at(i)))
        i += 1
      }
    }
  }
}

// AR 25-50 2-4c(2): the signature block at the center of the page, the name
// in capitals, a wrapped line hanging a quarter inch.
#let render-signature-lines(lines) = {
  for (i, line) in ensure-array(lines).enumerate() {
    par(hanging-indent: TURNOVER, if i == 0 { upper(line) } else { line })
  }
}

// The authority line, the signature block, the enclosure listing and `tail`,
// the start of the list below them: one unit that never breaks across pages
// (AR 25-50 2-5c(4)).
//
// AR 25-50 2-4c(1)-(3): the authority line at the left margin on the second
// line below the text; the signature block on the fifth line below the
// authority line, or below the text without one; the enclosure listing on
// the signature block's first line. The signing field covers the blank
// lines, ending 3pt above the name.
#let render-closing(
  signature-lines,
  authority-line: none,
  signature-blank-lines: 4,
  signing-field: none,
  enclosures: (),
  tail: none,
) = {
  let authority = format-authority-line(authority-line)
  let listing = render-enclosures(enclosures)
  block(breakable: false, width: 100%, {
    if authority != none {
      v(LINE)
      par(authority)
    }
    v(LINE * signature-blank-lines)
    grid(
      columns: (ENCLOSURE_WIDTH, SIGNATURE_INDENT - ENCLOSURE_WIDTH, 1fr),
      if listing == none [] else { listing },
      [],
      {
        if signing-field != none {
          context {
            let height = measure(signing-field).height
            place(top + left, dy: -3pt - height, signing-field)
          }
        }
        render-signature-lines(signature-lines)
      },
    )
    tail
  })
}

/// The memorandum's table rules: 0.5pt black, no fill. A table takes the
/// fields in force where it is made, so these wrap the authored body.
///
/// - it (content): Content holding the tables
/// -> content
#let memo-table-style(it) = {
  set table(
    stroke: TABLE_STROKE + black,
    inset: (x: 0.5em, y: 0.4em),
    fill: none,
  )
  it
}

/// Prints a table's header row bold, when it has one.
///
/// - it (content): The table element to render
/// -> content
#let render-memo-table(it) = {
  show table: t => if t.children.any(c => c.func() == table.header) {
    show table.cell.where(y: 0): set text(weight: "bold")
    t
  } else { t }
  it
}


// AR 25-50 2-4a(5): addresses take one case throughout, and the heading's
// are in capitals, so the DISTRIBUTION and CF entries are too.
#let listing-entries(entries) = ensure-array(entries).filter(e => not blank(e)).map(upper)

// How far below the closing's last line the bottom of the list's head lies,
// in lines: the head is what the closing keeps on its page.
#let listing-head-lines(distribution, cf, width) = {
  if distribution.len() > 0 { return 2 }
  if cf.len() > 0 { return 2 + line-count(par(cf.first()), width) }
  0
}

// AR 25-50 2-4a(5)(c): DISTRIBUTION: on the closing's page, on the second line
// below the signature block or enclosure listing. When its first entry does
// not fit below it there, the label reads "DISTRIBUTION: (see next page)" and
// the list starts the next page.
#let render-distribution-label(first-entry) = context {
  let line = LINE.to-absolute()
  let at = here().position()
  let reserve = if at.page == 1 {
    query(<army-memo-page-one-reserve>).map(m => m.value).sum(default: 0pt)
  } else { 0pt }
  let limit = page.height - MARGIN - reserve
  let baseline = at.y + CAP_HEIGHT.to-absolute()
  let entry-lines = line-count(par(first-entry), page.width - 2 * MARGIN)
  let fits = baseline + entry-lines * line <= limit + 0.01pt
  par(if fits [DISTRIBUTION:] else [DISTRIBUTION: (see next page)])
  [#metadata(fits)<army-memo-distribution-fits>]
}

// The lists below the closing, as `(head, rest)`: the head is what
// `render-closing` keeps on its page, and the rest may continue on the next.
// CF: follows the closing, or the distribution list, on the second line below
// it (AR 25-50 2-4c(5)).
#let render-distribution-and-copies(
  distribution: (),
  cf: (),
  cf-without-enclosures: false,
  has-enclosures: false,
) = {
  let cf-label = if cf-without-enclosures and has-enclosures [CF: (w/o encls)] else [CF:]
  if distribution.len() > 0 {
    let head = {
      blank-line()
      render-distribution-label(distribution.first())
    }
    // CF: keeps the distribution list's last entry on its page.
    let cf-head = if cf.len() > 0 {
      blank-line()
      par(cf-label)
      par(cf.first())
    }
    let last = distribution.len() - 1
    let rest = {
      // A first entry that does not fit below the label starts the next page
      // under the label again.
      context {
        let fits = query(<army-memo-distribution-fits>).all(m => m.value)
        block(breakable: false, {
          if not fits { par[DISTRIBUTION:] }
          par(distribution.first())
          if last == 0 { cf-head }
        })
      }
      for entry in distribution.slice(1, calc.max(1, last)) { par(entry) }
      if last > 0 {
        block(breakable: false, {
          par(distribution.at(last))
          cf-head
        })
      }
      for entry in cf.slice(calc.min(1, cf.len())) { par(entry) }
    }
    (head: head, rest: rest)
  } else if cf.len() > 0 {
    let head = {
      blank-line()
      par(cf-label)
      par(cf.first())
    }
    (head: head, rest: { for entry in cf.slice(1) { par(entry) } })
  } else {
    (head: none, rest: none)
  }
}
