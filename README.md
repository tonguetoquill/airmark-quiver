# @airmark/quiver

A [Quillmark](https://github.com/nibsbin/quillmark) Source Quiver of Air Force
and DAF official-document Quills, sourced from
[tonguetoquill-collection](https://github.com/nibsbin/tonguetoquill-collection)
and aligned to the current Quillmark spec.

## Contents

| Quill        | Version | Description                                                                       |
|--------------|---------|-----------------------------------------------------------------------------------|
| `usaf_memo`  | 0.2.0   | USAF / DAF Official Memorandum (AFH 33-337)                                       |
| `af4141`     | 0.1.0   | AF Form 4141 — Individual's Record of Duties and Experience (Ground Environment)  |
| `daf1206`    | 0.1.0   | DAF Form 1206 — Nomination for Award                                              |
| `daf4392`    | 0.1.0   | DAF Form 4392 — Pre-Departure Safety Briefing (Page 2)                            |

## Install

```bash
npm install @airmark/quiver @quillmark/quiver @quillmark/wasm
```

This package ships only the Source Quiver assets (`Quiver.yaml` + `quills/`)
and exposes no JavaScript API. All loading is performed by `@quillmark/quiver`,
either from the on-disk package directory or from a packed archive fetched
over HTTP.

## Usage

### Load from the exported directory

Resolve the package's `Quiver.yaml` via `import.meta.resolve` and hand it to
`@quillmark/quiver`:

```ts
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { Quillmark, Document } from '@quillmark/wasm';
import { Quiver } from '@quillmark/quiver/node';

const quiverYaml = fileURLToPath(import.meta.resolve('@airmark/quiver/Quiver.yaml'));
const quiver = await Quiver.fromDir(path.dirname(quiverYaml));

const engine = new Quillmark();
const doc = Document.fromMarkdown(`~~~card-yaml
$quill: usaf_memo@0.2
$kind: main
memo_for: ["ORG/SYMBOL"]
memo_from: ["ORG/SYMBOL", "Organization Name", "123 Street Ave", "City ST 12345-6789"]
subject: Hello Quillmark
signature_block: ["FIRST M. LAST, Rank, USAF", "Duty Title"]
~~~

Body of the memo.`);

const quill = await quiver.getQuill(doc.quillRef, { engine });
const { artifacts } = quill.render(doc, { format: 'pdf' });
```

### Load a packed Quiver via HTTP

Publish a packed Quiver archive (e.g. as a CDN or GitHub release asset) and
load it in the browser or any fetch-capable runtime through `@quillmark/quiver`.
See the upstream `@quillmark/quiver` docs for the packed-format and HTTP API.

## Layout

This package is a [Source Quiver](https://www.npmjs.com/package/@quillmark/quiver)
conforming to the canonical layout:

```
Quiver.yaml
quills/
  <name>/
    <x.y.z>/
      Quill.yaml
      plate.typ
      assets/
      packages/
```

## Testing

`quiver.test.js` at the repo root runs the
[`@quillmark/quiver/testing`](https://www.npmjs.com/package/@quillmark/quiver)
suite under the built-in [`node:test`](https://nodejs.org/api/test.html) runner,
validating each `(quill, version)` pair through the full load +
`engine.quill(tree)` compile pipeline:

```bash
npm install
npm test
```

## License

Apache-2.0. Individual Quills carry their own licensing terms; see the
`packages/` directory inside each Quill for upstream font and template licenses.
