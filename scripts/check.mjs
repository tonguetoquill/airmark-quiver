// What `quillkit check` passes and this gate does not:
// - a quill version that declares no example, its fields' `example:` and its
//   kinds' `body.example`;
// - an example that renders with a warning;
// - templates/templates.json naming no publisher, an entry missing a field,
//   a repeated id or file, a template file no entry names, and a template that
//   fails to render or renders with a warning.
// A `typst::pdf_ua` warning does not fail: the render exports a tagged PDF that
// makes no PDF/UA-1 claim.

import { readFileSync, readdirSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const templatesDir = join(repoRoot, "templates");

const failures = [];
const fail = (what, message) => failures.push(`${what}: ${message}`);

const { Document } = await init();
const quiver = await fromDir(repoRoot);
const engine = new Engine();

async function renderClean(what, quill, doc) {
  const result = await engine.render(quill, doc, { format: "pdf" });
  const warnings = [...(doc.warnings ?? []), ...(result.warnings ?? [])].filter(
    (w) => w.code !== "typst::pdf_ua",
  );
  for (const w of warnings) fail(what, `${w.code}${w.path ? ` at ${w.path}` : ""}: ${w.message}`);
  if (!warnings.length) console.log(`✓ ${what}`);
}

let examples = 0;
for (const name of quiver.quillNames()) {
  for (const version of quiver.versionsOf(name)) {
    const ref = `${name}@${version}`;
    let doc;
    try {
      const quill = await quiver.getQuill(ref);
      doc = quill.exampleDocument();
      if (!doc) {
        fail(ref, "declares no example");
        continue;
      }
      examples++;
      await renderClean(`${ref} example`, quill, doc);
    } catch (error) {
      fail(ref, error?.message ?? String(error));
    } finally {
      doc?.free();
    }
  }
}

const { publisher, templates: manifest } = JSON.parse(
  readFileSync(join(templatesDir, "templates.json"), "utf8"),
);
if (typeof publisher !== "string" || publisher.trim() === "") {
  fail("templates.json", "`publisher` is not a non-empty string");
}
if (!Array.isArray(manifest)) {
  fail("templates.json", "`templates` is not an array");
} else {
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

  for (const entry of manifest) {
    let doc;
    try {
      doc = Document.parse(readFileSync(join(templatesDir, entry.file), "utf8"));
      if (!doc.quillRef) {
        fail(entry.id, "names no `$quill`");
        continue;
      }
      const quill = await quiver.getQuill(doc.quillRef);
      await renderClean(`${entry.id} (${doc.quillRef})`, quill, doc);
    } catch (error) {
      fail(entry.id, error?.message ?? String(error));
    } finally {
      doc?.free();
    }
  }
}

if (failures.length) {
  for (const f of failures) console.error(`✗ ${f}`);
  process.exit(1);
}
console.log(`${examples} examples and ${manifest.length} templates render against this quiver`);
