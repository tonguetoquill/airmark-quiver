# Changelog

## Unreleased

- usaf_memo: a standard indorsement that gets pushed onto a new page now automatically renders the separate-page identifying header (`Nth Ind to ORIG, DATE, SUBJECT`), and the header is kept together with its body/signature so it is never stranded or orphaned across a page break.


## v0.26.0 - 2026-06-16

- Refactor CUI indicator block layout and styling (#82)


## v0.25.1 - 2026-06-10

- make fields in Additional section of Indorsement compact


## v0.25.0 - 2026-06-10

- Remove attachments and cc from usaf_memo indorsements (#79)
- Bump to @quillmark/wasm@0.90.0 and @quillmark/quiver@0.15.0


## v0.24.8 - 2026-06-08

- Remove attachments and cc from indorsements (usaf_memo) — AFH 33-337 does not define backmatter elements for indorsements


## v0.24.7 - 2026-06-07

- Remove body example for indorsements (usaf_memo)
- Replace Arimo font with Nimbus Roman No9 L (#77)


## v0.24.6 - 2026-06-05

- usaf_memo: order the Classification field group above Additional in the editor UI


## v0.24.5 - 2026-06-05

- Add adjustable letterhead emblem height for placement parity (#74)
- Swap Freedom250 emblem with Freedom250 + USAF 


## v0.24.4 - 2026-06-05

- chore: upgrade @quillmark/wasm to 0.88.0 and @quillmark/quiver to 0.13.0 (#72)


## v0.24.3 - 2026-06-03

- Fix CUI markings to comply with DoD CUI Registry (DoDM 5200.48) (#57)
- Add Liberation Mono font and configure monospace text rendering (#69)
- usaf_memo: make tag_line a Markdown field (#68)
- **Tag line is now a Markdown field** — `usaf_memo/0.2.0` `tag_line` changed
  from `string` to `markdown`. The organizational motto accepts standard
  Markdown emphasis (e.g. `*italics*`, `**bold**`). Existing plain-string tag
  lines continue to work unchanged.

## v0.24.2 - 2026-06-01

- usaf_memo: clarify that unclassified documents typically omit classification banner (#66)


## v0.24.1 - 2026-06-01

- fix(usaf-memo): wrap inline-reference in box() to prevent closing paren falling on new line (#64)

## v0.24.0 - 2026-06-01

- **References are now a Markdown field** — `usaf_memo/0.2.0` `references`
  items changed from `string` to `markdown`. Entries accept standard Markdown
  (e.g. `*Title*` for italic publication titles) and render as an
  auto-lettered `(a) (b) (c)` list per AFH 33-337. Existing plain-string
  references continue to work unchanged. (#55)
- **Single-reference rule** — when exactly one reference is supplied it is now
  rendered inline in parentheses after the SUBJECT line; the standalone
  References block only renders for two or more references, per AFH 33-337
  (`frontmatter.typ`, `primitives.typ`). (#54)
- Compatibility: `@quillmark/wasm` 0.87.0, `@quillmark/quiver` ^0.12.0.
  (#58, #59)
- CI: adopt the two-stage release workflow mirrored from quillmark. (#61)

## v0.23.0 - 2026-05-28

- Compatibility: `@quillmark/wasm` 0.85.0, which drops the `required` field
  axis in favor of the Endorsed / Must Fill model (a field is Must Fill iff it
  has no `default`). No quill schemas changed — all `required:` properties were
  already removed in the 0.84.0 migration. (#56)

## v0.22.1 - 2026-05-22

- Compatibility: `@quillmark/wasm` 0.84.0.

## v0.22.0 - 2026-05-22

- Compatibility: `@quillmark/wasm` 0.83.0. (#52)

## v0.21.0 - 2026-05-22

- Compatibility: migrate to `@quillmark/wasm` 0.82.0. (#51)

## v0.20.4 - 2026-05-19

- Pin the WASM peer dependency in `package-lock.json` and adjust spacing in
  `usaf_memo/0.2.0` `primitives.typ`. No rendering changes.

## v0.20.3 - 2026-05-19

- **Breaking default:** the Freedom 250 letterhead emblem is now opt-in. The
  runtime default for `freedom250` in `usaf_memo/0.2.0` (`plate.typ`) changed
  from `true` to `false`; set `freedom250: true` to keep the emblem.

## v0.20.2 - 2026-05-19

- Remove the `freedom250` schema default in `usaf_memo/0.2.0` (`Quill.yaml`) so
  the field is off unless explicitly enabled.
