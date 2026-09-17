// render_fixture.mjs — render a cyber_ribbon_chart fixture through the real
// engine (@quillmark/wasm + @quillmark/quiver), the pipeline `quillkit test`
// uses. With no fixture, renders the blueprint the schema seeds.
//
// Usage: node design/cyber_ribbon_chart/render_fixture.mjs [fixture.md] <out.pdf|out.png>
//
// Run it from the repo root so that `@quillmark/*` resolve from node_modules.

import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, extname, resolve } from "node:path";

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, "../..");

const args = process.argv.slice(2);
if (args.length === 0) {
  console.error("Usage: node design/cyber_ribbon_chart/render_fixture.mjs [fixture.md] <out.pdf|out.png>");
  process.exit(1);
}
const [fixturePath, outputPath] = args.length === 1 ? [null, args[0]] : args;

const { Document } = await init();

const quiver = await fromDir(repoRoot);
const engine = new Engine();
const quill = await quiver.getQuill("cyber_ribbon_chart@0.0.1");

const doc = fixturePath
  ? Document.fromMarkdown(readFileSync(resolve(fixturePath), "utf8"))
  : Document.fromMarkdown(quill.blueprint);

const format = extname(outputPath) === ".png" ? "png" : "pdf";

let result;
try {
  result = await engine.render(quill, doc, { format });
} finally {
  doc.free();
}

for (const d of result.warnings ?? []) console.warn(`warning: ${d.message}`);

if (result.artifacts.length !== 1) {
  console.warn(`warning: ${result.artifacts.length} pages — the chart is meant to be one`);
}

const artifact = result.artifacts[0];
const bytes = artifact.bytes ?? artifact.data;
writeFileSync(resolve(outputPath), Buffer.from(bytes));
console.log(`wrote ${outputPath} (${bytes.length} bytes)`);
