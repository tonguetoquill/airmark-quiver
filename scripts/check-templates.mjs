// Every template in templates/templates.json names a file that exists, every
// file is named once, and each renders against this quiver with no warning.

import { readFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve } from "node:path";

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const templatesDir = join(repoRoot, "templates");
const manifest = JSON.parse(readFileSync(join(templatesDir, "templates.json"), "utf8"));

const failures = [];
const fail = (id, message) => failures.push(`${id}: ${message}`);

const ids = new Set();
const files = new Set();
for (const entry of manifest) {
  const id = entry.id ?? "(no id)";
  for (const key of ["id", "name", "description", "file"]) {
    if (typeof entry[key] !== "string" || entry[key] === "") fail(id, `\`${key}\` is not a non-empty string`);
  }
  if (!Array.isArray(entry.tags) || entry.tags.some((t) => typeof t !== "string")) {
    fail(id, "`tags` is not an array of strings");
  }
  if (ids.has(entry.id)) fail(id, "id is not unique");
  if (files.has(entry.file)) fail(id, `\`${entry.file}\` is named by another entry`);
  ids.add(entry.id);
  files.add(entry.file);
}
for (const file of readdirSync(templatesDir)) {
  if (file.endsWith(".md") && !files.has(file)) fail(file, "no manifest entry names it");
}

const { Document } = await init();
const quiver = await fromDir(repoRoot);
const engine = new Engine();

for (const entry of manifest) {
  let doc;
  try {
    doc = Document.fromMarkdown(readFileSync(join(templatesDir, entry.file), "utf8"));
    if (!doc.quillRef) {
      fail(entry.id, "names no `$quill`");
      continue;
    }
    const quill = await quiver.getQuill(doc.quillRef);
    const result = await engine.render(quill, doc, { format: "pdf" });
    for (const w of result.warnings ?? []) fail(entry.id, `${w.code}: ${w.message}`);
    if (!result.warnings?.length) console.log(`✓ ${entry.id} (${doc.quillRef})`);
  } catch (error) {
    fail(entry.id, error?.message ?? String(error));
  } finally {
    doc?.free();
  }
}

if (failures.length) {
  for (const f of failures) console.error(`✗ ${f}`);
  process.exit(1);
}
console.log(`${manifest.length} templates render against this quiver`);
