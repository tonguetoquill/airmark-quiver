// render_fixture.mjs — render a MOA fixture markdown file to PDF using the
// real quillmark engine (@quillmark/wasm + @quillmark/quiver), the same
// pipeline `npx quiver test`/`preview` use.
//
// Usage: node render_fixture.mjs <fixture.md> <output.pdf> [quiverDir]
//
// quiverDir defaults to this repo's root. Pass an alternate directory (a
// symlink farm containing only quills/MOAs/0.1.0) to work around unrelated
// non-canonical version directories elsewhere under quills/ that would
// otherwise abort Quiver.fromDir's repo-wide scan.

import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

import { Quillmark, Document } from "@quillmark/wasm";
import { Quiver } from "@quillmark/quiver/node";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, "../../../..");

const [, , fixturePath, outputPath, quiverDirArg] = process.argv;
if (!fixturePath || !outputPath) {
  console.error("Usage: node render_fixture.mjs <fixture.md> <output.pdf> [quiverDir]");
  process.exit(1);
}

const quiverDir = quiverDirArg ? resolve(quiverDirArg) : repoRoot;

const engine = new Quillmark();
const quiver = await Quiver.fromDir(quiverDir);
const quill = await quiver.getQuill("MOAs@0.1.0", { engine });

const markdown = readFileSync(resolve(fixturePath), "utf8");
const doc = Document.fromMarkdown(markdown);
const result = quill.render(doc, { format: "pdf" });

const artifact = result.artifacts[0];
const bytes = artifact.bytes ?? artifact.data;
writeFileSync(resolve(outputPath), Buffer.from(bytes));
console.log(`wrote ${outputPath} (${bytes.length} bytes, ${result.artifacts.length} artifact(s))`);
