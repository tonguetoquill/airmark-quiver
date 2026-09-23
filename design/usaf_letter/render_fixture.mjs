// render_fixture.mjs — render a usaf_letter fixture to PDF through the real
// engine (@quillmark/wasm + @quillmark/quiver), the pipeline `quillkit test`
// uses. With no fixture, renders the blueprint the schema seeds.
//
// Usage: node design/usaf_letter/render_fixture.mjs [fixture.md] <output.pdf>
//
// Run it from the repo root so that `@quillmark/*` resolve from node_modules.

import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, "../..");

const args = process.argv.slice(2);
if (args.length === 0) {
  console.error("Usage: node design/usaf_letter/render_fixture.mjs [fixture.md] <output.pdf>");
  process.exit(1);
}
const [fixturePath, outputPath] = args.length === 1 ? [null, args[0]] : args;

const { Document } = await init();

const quiver = await fromDir(repoRoot);
const engine = new Engine();
const quill = await quiver.getQuill("usaf_letter@0.1.0");

const doc = fixturePath
  ? Document.fromMarkdown(readFileSync(resolve(fixturePath), "utf8"))
  : Document.fromMarkdown(quill.blueprint);

let result;
try {
  result = await engine.render(quill, doc);
} finally {
  doc.free();
}

for (const d of result.warnings ?? []) console.warn(`warning: ${d.message}`);

const artifact = result.artifacts[0];
const bytes = artifact.bytes ?? artifact.data;
writeFileSync(resolve(outputPath), Buffer.from(bytes));
console.log(`wrote ${outputPath} (${bytes.length} bytes)`);
