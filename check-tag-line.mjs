// Renders the usaf_memo tag line plain, italic, bold, and mixed, and reports
// whether each differs from plain. Italic matching plain is the bug.
//   node check-tag-line.mjs [--png]
import { writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { Engine } from '@quillmark/wasm';
import { fromDir } from '@quillmark/quiver/node';

const png = process.argv.includes('--png');
const quiver = await fromDir(import.meta.dirname);
const quill = await quiver.getQuill('usaf_memo@0.3');
const engine = new Engine();

const cases = {
	plain: 'Aim High',
	italic: '*Aim High*',
	bold: '**Aim High**',
	mixed: 'Aim *High* and **Low**'
};

const digests = {};
for (const [name, tag_line] of Object.entries(cases)) {
	const doc = quill.parse(`~~~
$quill: usaf_memo@0.3
$kind: main
memo_for: ["ORG/SYMBOL"]
memo_from: ["ORG/SYMBOL", "Organization Name", "123 Street Ave", "City ST 12345-6789"]
subject: Tag Line Emphasis
tag_line: "${tag_line}"
signature_block: ["FIRST M. LAST, Rank, USAF", "Duty Title"]
~~~

Body of the memo.`);
	const { artifacts } = await engine.render(quill, doc, png ? { format: 'png', ppi: 150 } : { format: 'svg' });
	const bytes = Buffer.from(artifacts[0].bytes);
	digests[name] = createHash('sha256').update(bytes).digest('hex').slice(0, 12);
	if (png) writeFileSync(`tag-line-${name}.png`, bytes);
}

for (const [name, digest] of Object.entries(digests)) {
	const verdict = name === 'plain' ? '' : digests[name] === digests.plain ? '  ← identical to plain' : '  ← distinct';
	console.log(`${name.padEnd(7)} ${digest}${verdict}`);
}
process.exitCode = ['italic', 'bold', 'mixed'].every((k) => digests[k] !== digests.plain) ? 0 : 1;
