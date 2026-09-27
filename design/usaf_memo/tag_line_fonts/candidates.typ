// The tag line as the package sets it, 15pt in the letterhead blue, with the
// face swapped for each candidate and set in small caps.
//
// How a candidate reaches small caps is its `caps`:
//   "smcp"   — Typst `smallcaps()`, the face's OpenType smcp feature.
//   "native" — the face's default lowercase already are small caps. Cinzel
//              has no smcp; Cormorant SC's maps them back to lowercase, so
//              `smallcaps()` would undo them.
//   "synth"  — faked: the lowercase are set as capitals, scaled to the face's
//              own x-height. Typst does not synthesize small caps itself.
//   "none"   — as the tag line prints today.
//
// `slant` fakes an italic for a face that has none, by skewing the upright.

#let LETTERHEAD_COLOR = rgb("#355e93")

// A faked small cap stands this much over the face's x-height, the usual
// allowance so it does not read as a shrunken capital.
#let SYNTH_OVERSHOOT = 1.06

// A faked italic's slant, near a book italic's.
#let SLANT = -12deg

// `fallback: false` so a face missing a glyph shows as a gap, not as the next
// font's glyph passing for this one's.
#let tag-line(font, body, italic: false, caps: "smcp", slant: false) = {
  set text(
    font: font,
    fallback: false,
    size: 15pt,
    fill: LETTERHEAD_COLOR,
    style: if italic and not slant { "italic" } else { "normal" },
  )
  let set-caps = if caps == "smcp" { smallcaps(body) } else if caps == "synth" {
    context {
      // Glyph bounds, not the line box, so the ratio is the letters' own.
      let height(c) = measure(text(top-edge: "bounds", bottom-edge: "baseline", c)).height
      let scale = height("x") / height("H") * SYNTH_OVERSHOOT
      show regex("\p{Ll}+"): it => text(size: scale * 1em, upper(it))
      body
    }
  } else { body }
  if slant { box(skew(ax: SLANT, reflow: true, set-caps)) } else { set-caps }
}

#let candidates = (
  (label: [*NimbusRomNo9L* \ today, no small caps], font: "NimbusRomNo9L", caps: "none"),
  (label: [*NimbusRomNo9L* \ `smallcaps()` — no smcp, no change], font: "NimbusRomNo9L", caps: "smcp"),
  (label: [*NimbusRomNo9L* \ synthesized small caps], font: "NimbusRomNo9L", caps: "synth"),
  (label: [*Cinzel* \ the package's own; no italic face], font: "Cinzel", caps: "native"),
  (label: [*EB Garamond*], font: "EB Garamond", caps: "smcp"),
  (label: [*Cormorant* \ italic has no smcp], font: "Cormorant", caps: "smcp"),
  (label: [*Cormorant Garamond* \ italic has no smcp], font: "Cormorant Garamond", caps: "smcp"),
  (label: [*Cormorant SC* \ no italic face], font: "Cormorant SC", caps: "native"),
)

#let mottos = ("Aim High", "Semper Supra", "Ad Astra Per Aspera")
