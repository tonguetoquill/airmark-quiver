# design/

Development scaffolding for quills — fixtures, render helpers, and validators.

This directory lives **outside `quills/`** on purpose: `package.json` publishes
`quills` and `Quiver.yaml` only, so nothing here ships to npm consumers.

## afmc_moa

Fixtures and a structural validator for the `afmc_moa` quill.

```sh
# render a fixture to PDF (run from the repo root)
node design/afmc_moa/render_fixture.mjs design/afmc_moa/fixtures/maximal.md /tmp/max.pdf

# check the rendered PDF against DoDI 4000.19 structural requirements
python3 design/afmc_moa/validate_moa.py design/afmc_moa/fixtures/maximal.md /tmp/max.pdf
```

`validate_moa.py` needs `pymupdf` and `pyyaml`.

`minimal.md` is a non-reimbursable MOA (no Attachment A); `maximal.md` is a
reimbursable one with two card-driven attachments, so it exercises the
Attachment A/B/C lettering.

## usaf_memo_appointment

Appointment letters on `usaf_memo@0.3.0`: fixtures with `member` cards, the
render harness, and a validator that reads the PDF back.

```sh
node design/usaf_memo_appointment/render_fixture.mjs design/usaf_memo_appointment/fixtures/roster.md /tmp/roster.pdf
python3 design/usaf_memo_appointment/validate_appointment.py design/usaf_memo_appointment/fixtures/roster.md /tmp/roster.pdf
```
Fixtures: `minimal` (two appointees, four columns), `maximal` (CUI, extra
column, table at end of body, custom supersession), `roster` (ten appointees).
