# Contributing

## Questions, bugs, and ideas

- A quill that prints a document wrong: an issue naming the quill and its version, with the document and the page that came out wrong.
- A new quill or a change to one larger than a fix: open an issue before the pull request, so the form is agreed before it is built.
- A gap in Quillmark itself, something a `Quill.yaml` cannot say: an issue on [borb-sh/quillmark](https://github.com/borb-sh/quillmark/issues/new/choose).

## Pull requests

[README § Working on a quill](README.md#working-on-a-quill) covers designing a quill, the gate and the studio loop. A pull request keeps the rules in [`CLAUDE.md`](CLAUDE.md), which bind human contributors as they bind the agents that write most of this repository:

- `npm test` passes, with no warnings.
- A quill release is a new `quills/<name>/<x.y.z>/` directory, and released versions stay as they are.
- A user-facing change adds an entry under `## Unreleased` in `CHANGELOG.md`.

## License

A contribution is licensed under the Apache License 2.0 in [`LICENSE`](LICENSE), as its section 5 provides, with no further terms and no separate agreement to sign. A contribution to a part [README § License](README.md#license) names under another license, such as `classic_resume`'s MIT-licensed `ttq-classic-resume` package, is licensed under that part's license.
