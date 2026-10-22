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
    let (size, baseline) = if i == 0 {
      (LETTERHEAD.title-size, LETTERHEAD.title-baseline)
    } else {
      (LETTERHEAD.line-size, LETTERHEAD.line-baseline + (i - 1) * LETTERHEAD.line-pitch)
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

// AR 25-50 2-4a(1)-(3): the office symbol and its ARIMS record number at the
// left margin, wrapping flush left; the date on the same line, flush right.
#let render-office-symbol-row(office-symbol, record-number, date) = {
  let symbol = if blank(record-number) {
    [#office-symbol]
  } else {
    [#office-symbol (#box(record-number))]
  }
  grid(
    columns: (1fr, DATE_WIDTH),
    column-gutter: DATE_GUTTER,
    par(symbol), align(right, box(date)),
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
// each spanning the address's lines.
#let render-thru-address(address, fields) = context {
  let body = block(width: THRU.text-width, address)
  let height = measure(body).height + LEADING.to-absolute()
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
      for entry in thru { render-thru-address(hanging-address(entry.address), entry.fields) }
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
    par(entries.at(0))
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
        numbered-line(str(i + 1) + ".", entries.at(i))
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

// The authority line, the signature block and the enclosure listing: one unit
// that never breaks across pages (AR 25-50 2-5c(4)).
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
  })
}

/// The memorandum's table rules: 0.5pt black, no fill. A table takes the
/// fields in force where it is made, so these wrap the authored body.
///
/// - it (content): Content holding the tables
/// -> content
#let memo-table-style(it) = {
  set table(
    stroke: 0.5pt + black,
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


// A labelled list below the closing, one entry per line, flush left. The
// label keeps its first entry, and the rest may continue on the next page
// (AR 25-50 2-4a(5)(c)).
#let render-listing(label, entries) = {
  let entries = ensure-array(entries).filter(e => not blank(e))
  if entries.len() == 0 { return none }
  blank-line()
  block(breakable: false, {
    par(label)
    par(entries.at(0))
  })
  for entry in entries.slice(1) { par(entry) }
}

// AR 25-50 2-4a(5)(c), 2-4c(4) and 2-4c(5): DISTRIBUTION: on the second line
// below the signature block or enclosure listing, then CF: on the second line
// below the lowest element above it.
#let render-distribution-and-copies(
  distribution: (),
  cf: (),
  cf-without-enclosures: false,
  has-enclosures: false,
) = {
  render-listing([DISTRIBUTION:], distribution)
  render-listing(
    if cf-without-enclosures and has-enclosures [CF: (w/o encls)] else [CF:],
    cf,
  )
}
