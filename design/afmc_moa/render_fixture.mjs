// render_fixture.mjs — render an MOA fixture markdown file to PDF using the
// real quillmark engine (@quillmark/wasm + @quillmark/quiver), the same
// pipeline `npx quillkit test` uses.
//
// Usage: node design/afmc_moa/render_fixture.mjs <fixture.md> <output.pdf>
//
// Run it from the repo root so that `@quillmark/*` resolve from node_modules.

import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, "../..");

const [, , fixturePath, outputPath] = process.argv;
if (!fixturePath || !outputPath) {
  console.error("Usage: node design/afmc_moa/render_fixture.mjs <fixture.md> <output.pdf>");
  process.exit(1);
}

// `init()` is the only door to `Document`: there is no static export.
const { Document } = await init();

const quiver = await fromDir(repoRoot);
const engine = new Engine();
const quill = await quiver.getQuill("afmc_moa@0.0.1");

const doc = Document.fromMarkdown(readFileSync(resolve(fixturePath), "utf8"));
let result;
try {
  result = await engine.render(quill, doc);
} finally {
  doc.free();
}

const artifact = result.artifacts[0];
const bytes = artifact.bytes ?? artifact.data;
writeFileSync(resolve(outputPath), Buffer.from(bytes));
console.log(`wrote ${outputPath} (${bytes.length} bytes, ${result.artifacts.length} artifact(s))`);
