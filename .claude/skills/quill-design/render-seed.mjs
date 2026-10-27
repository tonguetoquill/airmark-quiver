// Renders a quill's seeded document, the page a new document prints untouched, to seed-<n>.png in the working directory.
// Usage: node .claude/skills/quill-design/render-seed.mjs <name>@<major.minor>
import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";
import { writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

await init();
const quiver = await fromDir(resolve(dirname(fileURLToPath(import.meta.url)), "../../.."));
const quill = await quiver.getQuill(process.argv[2]);
const { artifacts, warnings } = await new Engine().render(quill, quill.seedDocument(), { format: "png" });
artifacts.forEach((page, i) => writeFileSync(`seed-${i + 1}.png`, page.bytes));
for (const w of warnings ?? []) console.warn(`${w.code}: ${w.message}`);
console.log(`${artifacts.length} page(s) written`);
