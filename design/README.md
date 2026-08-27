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

## usaf_appointment

Fixtures and a structural validator for the `usaf_appointment` quill.

```sh
# render a fixture to PDF (run from the repo root)
node design/usaf_appointment/render_fixture.mjs design/usaf_appointment/fixtures/maximal.md /tmp/appt.pdf

# check the rendered PDF: paragraph 1, numbering chain, appointee rows, column rule,
# supersession sentence, signature block placement
python3 design/usaf_appointment/validate_appointment.py design/usaf_appointment/fixtures/maximal.md /tmp/appt.pdf
```

`validate_appointment.py` needs `pymupdf` and `pyyaml`.

`minimal.md` is a two-appointee letter with only role, rank, name, and duty phone
filled, so the unused columns must hide; `maximal.md` fills every field (CUI//PRVCY
marking, references, cc, attachment, extra column, table after the body, custom
supersession wording); `roster.md` lists ten appointees, so the table has to carry a
full page's worth of rows without stranding the signature block.
