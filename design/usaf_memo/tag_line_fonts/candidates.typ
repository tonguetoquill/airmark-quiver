// The tag line as the package sets it, 15pt in the letterhead blue, with the
// face swapped for each candidate and set in small caps.
//
// How a candidate reaches small caps is its `caps`:
//   "smcp"   — Typst `smallcaps()`, the face's OpenType smcp feature.
//   "native" — the face's default lowercase already are small caps. Cormorant
//              SC's smcp maps them back to lowercase, so `smallcaps()` would
//              undo them.
//   "synth"  — the face has no smcp, so the lowercase are set as capitals at
//              `SYNTH_SCALE`. Typst does not synthesize small caps itself.
//   "none"   — as the tag line prints today.

#let LETTERHEAD_COLOR = rgb("#355e93")

// A touch over NimbusRomNo9L's x-height (0.68 of its cap height), so a
// synthesized small cap stands just above the lowercase it replaces.
#let SYNTH_SCALE = 0.72

#let candidates = (
  (label: [*NimbusRomNo9L* \ today, no small caps], font: "NimbusRomNo9L", caps: "none"),
  (label: [*NimbusRomNo9L* \ `smallcaps()` — no smcp, no change], font: "NimbusRomNo9L", caps: "smcp"),
  (label: [*NimbusRomNo9L* \ synthesized small caps], font: "NimbusRomNo9L", caps: "synth"),
  (label: [*EB Garamond*], font: "EB Garamond", caps: "smcp"),
  (label: [*Cormorant* \ italic has no smcp], font: "Cormorant", caps: "smcp"),
  (label: [*Cormorant Garamond* \ italic has no smcp], font: "Cormorant Garamond", caps: "smcp"),
  (label: [*Cormorant SC* \ no italic face], font: "Cormorant SC", caps: "native"),
)

#let mottos = ("Aim High", "Semper Supra", "Ad Astra Per Aspera")

// `fallback: false` so a face missing a glyph shows as a gap, not as the next
// font's glyph passing for this one's.
#let tag-line(font, body, italic: false, caps: "smcp") = {
  set text(
    font: font,
    fallback: false,
    size: 15pt,
    fill: LETTERHEAD_COLOR,
    style: if italic { "italic" } else { "normal" },
  )
  show regex("\p{Ll}+"): it => if caps == "synth" {
    text(size: SYNTH_SCALE * 1em, upper(it))
  } else { it }
  if caps == "smcp" { smallcaps(body) } else { body }
}
