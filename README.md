# @airmark/quiver

A [Quillmark](https://github.com/nibsbin/quillmark) source quiver of Air Force
and DAF official-document quills, sourced from
[tonguetoquill-collection](https://github.com/nibsbin/tonguetoquill-collection)
and aligned to the current Quillmark spec.

## Contents

| Quill                | Version | Description                                                                      |
|----------------------|---------|----------------------------------------------------------------------------------|
| `usaf_memo`          | 0.3.0   | USAF / DAF Official Memorandum (AFH 33-337)                                      |
| `usaf_memo`          | 0.2.0   | Previous release, retained so documents pinned to `@0.2` keep resolving          |
| `usaf_letter`        | 0.1.0   | USAF / DAF Personal Letter (AFH 33-337)                                          |
| `af4141`             | 0.1.0   | AF Form 4141 — Individual's Record of Duties and Experience (Ground Environment) |
| `daf1206`            | 0.1.0   | DAF Form 1206 — Nomination for Award                                             |
| `daf4392`            | 0.1.0   | DAF Form 4392 — Pre-Departure Safety Briefing (Page 2)                           |
| `afmc_moa`           | 0.0.1   | DoD Memorandum of Agreement (DoDI 4000.19)                                       |
| `classic_resume`     | 0.0.1   | Classic single-page resume                                                       |
| `cyber_ribbon_chart` | 0.0.1   | 17X Cyber Operations Officer ribbon chart and career vector planner              |

## Install

```bash
npm install @airmark/quiver @quillmark/quiver @quillmark/wasm
```

This package ships the source-quiver assets (`Quiver.yaml` + `quills/`) and the
official [templates](#templates), and exposes no JavaScript API. Loading is `@quillmark/quiver`'s, rendering is
`@quillmark/wasm`'s.

## Usage

### Load from the installed directory (Node)

Resolve this package's `Quiver.yaml` from your own module — your dependencies are
reachable from you, not from the loader's install location — and hand its
directory to `fromDir`:

```ts
import { createRequire } from 'node:module';
import { dirname } from 'node:path';
import { Engine, init } from '@quillmark/wasm';
import { fromDir } from '@quillmark/quiver/node';

// `init` is the only door to `Document`: there is no static export to reach early.
const { Document } = await init();

const root = dirname(createRequire(import.meta.url).resolve('@airmark/quiver/Quiver.yaml'));
const quiver = await fromDir(root);
const engine = new Engine();

const doc = Document.fromMarkdown(`~~~
$quill: usaf_memo@0.3
$kind: main
memo_for: ["ORG/SYMBOL"]
memo_from: ["ORG/SYMBOL", "Organization Name", "123 Street Ave", "City ST 12345-6789"]
subject: Hello Quillmark
signature_block: ["FIRST M. LAST, Rank, USAF", "Duty Title"]
~~~

Body of the memo.`);

const quill = await quiver.getQuill(doc.quillRef);
const { artifacts } = await engine.render(quill, doc, { format: 'pdf' });
```

A quill from `getQuill` is borrowed: every caller asking for that ref gets the
same instance, so it is not yours to `free()`.

### Load over HTTP (browser)

A browser cannot read the source layout, so pack it at deploy time and serve the
output as static files:

```ts
import { build } from '@quillmark/quiver/node'; // build step
await build(root, './public/quivers/airmark');
```

```ts
import { Quiver } from '@quillmark/quiver'; // browser runtime
const quiver = await Quiver.fromBuiltUrl('/quivers/airmark/');
```

## Layout

This package is a [source quiver](https://www.npmjs.com/package/@quillmark/quiver)
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
templates/
  templates.json
  <file>.md
```

## Templates

`templates/` holds the official starter documents Tongue to Quill offers in its
template library. They sit beside the quiver rather than inside it: the quiver
loaders never read them, and a consumer reaches them as files, through
`@airmark/quiver/templates/templates.json` and the Markdown it names. Each entry
is `{ id, name, description, file, tags }`, and every listed template is live.

An entry's `id` is permanent. Tongue to Quill derives the template's row id and
its shareable short code from it, so renaming one retires the old template (its
stars and its short code with it) and publishes a new one. Removing an entry
retires it the same way.

`npm test` renders every template against this quiver after `quillkit test`, and
a warning fails it as an error does, so a quill change that breaks a template
fails here rather than on the app's build.

## Working on a quill

Two verbs, and they answer different questions.

Both verbs are [`quillkit`](https://www.npmjs.com/package/quillkit)'s, the quill
author's toolchain. It resolves `@quillmark/quiver` and `@quillmark/wasm` out of
this collection's own `node_modules`, so the versions pinned here are the format
the quiver is packed in and the wasm the gate renders through.

**Does it work?** `quillkit test` loads the collection with `fromDir`, compiles
every quill, and renders each one's seed: every field absent, rendering its
`default:` or its blank. It is the gate CI runs, so a validation failure
surfaces here rather than on a consumer's build:

```bash
npm install
npm test
```

The gate renders no answer, so a page with a long list or a wrapping value in
it is a design fixture's to exercise (`design/`), not the gate's.

**What is it like to use?** `npm run dev` is `quillkit studio`: it packs this
quiver, serves the studio client over it, and repacks on every save — pick a
quill, edit the seeded document or press **Fill examples** to write each
unanswered field's `example:` into it, watch it paint, read the diagnostics. The
client is quillkit's own, so there is nothing to install for it and nothing to
keep in step.

Reload to pick up a repack. Editing a quill into an invalid state is not a
failure of the loop: it packs, and the client says what is wrong with that quill
and where, while the others stay usable.

The two verbs answer to different authorities. `quillkit test` renders through
the wasm pinned here and is what CI blocks on; the client renders through the
wasm it was built against, and nothing at runtime reconciles the two. The gate
is authoritative, studio is advisory.

`npm run site` writes the arrangement a deploy serves into `site/` — the client
at the root, a built quiver at `quiver/` beneath it — without serving it. It
passes `--drafts`, so the `0.0.x` prototypes are packed beside the releases and
every deploy previews them as `npm run dev` does. CI
uploads that on every run, so a pull request — a fork's included — is reviewed
by downloading the artifact and serving the directory.

`main` is deployed to GitHub Pages by `.github/workflows/studio.yml`, which runs
that same command and keeps the deploy here: nothing outside this repository
holds `pages: write`.

`vercel.json` deploys the same layout to Vercel, where a pull request gets a
preview URL instead of an artifact to download. It carries the build, the output
directory and the one cache rule a host owes this layout — `assets/*` immutable,
which is the engine, and everything else already right by default. Importing the
repository is the rest of the setup. Both deploys run off `main` and neither
knows about the other.

## License

Apache-2.0, the quill packages under `quills/` included, except
`classic_resume`'s `ttq-classic-resume`, which is MIT. Two things a quill
carries are not the project's to license: the fonts its package bundles, which
keep their own upstream terms — see the `packages/` directory inside each quill
— and the DoD and DoW seals under `quills/*/*/assets/`, which are US
Government insignia and whose use is governed as such.
