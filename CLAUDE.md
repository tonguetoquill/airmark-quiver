# @airmark/quiver

A Quillmark source quiver: `quills/<name>/<x.y.z>/`, starter documents in `templates/`. README.md covers layout, commands and deploys.

- `npm test` is the gate CI runs. A warning fails it like an error.
- A quill release is a new `quills/<name>/<x.y.z>/` directory. Released versions stay, so documents pinned to them keep resolving. `0.0.x` is the draft tier, packed only with `--drafts`.
- A user-facing change adds an entry under `## Unreleased` in `CHANGELOG.md`. `package.json`'s `version` is bumped by `release-prepare.yml`, never by hand.
- A `templates/templates.json` entry's `id` is permanent: renaming or removing one retires the template.
- Fixtures for long or wrapping values live in `design/<quill>/`, not in a quill's `example.md`.
- Write comments only where the code can't carry the fact: present tense, no history.
