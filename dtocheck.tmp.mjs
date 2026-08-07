// The DTO axis, both ways: a subject stored as a plain string by the old 0.2.0
// quill, opened against `type: string` and against `type: richtext` + inline.
import { writeFileSync } from 'node:fs';
import { Engine, init } from '@quillmark/wasm';
import { fromDir } from '@quillmark/quiver/node';

await init();
const engine = new Engine();
const SUBJECT = 'Cost * Benefit Analysis *DRAFT*';
const md = `~~~
$quill: usaf_memo@0.2.0
$kind: main
memo_for: ["ORG/SYMBOL"]
subject: ${JSON.stringify(SUBJECT)}
signature_block: ["FIRST M. LAST, Rank, USAF", "Duty Title"]
~~~

Body.`;

const restOf = (doc) => JSON.stringify(
	JSON.parse(doc.toJson()).main.payload.items.find((i) => i.key === 'subject')?.value
);

for (const [label, dir, png] of [
	['type: string  ', process.cwd(), process.argv[2]],
	['type: richtext', process.argv[3], process.argv[4]]
]) {
	const quill = await (await fromDir(dir)).getQuill('usaf_memo');
	const doc = quill.parse(md);
	const carried = doc.warnings.filter((d) => d.code?.startsWith('conform::')).length;
	console.log(`\n${label}`);
	console.log(`  conform diagnostics : ${carried}`);
	console.log(`  rests in the DTO as : ${restOf(doc)}`);
	console.log(`  reader.get          : ${JSON.stringify(quill.reader(doc).get('subject'))}`);

	// What an editor writes back, which is what the next DTO holds.
	const edited = quill.parse(md);
	const w = quill.writer(edited);
	for (const verb of ['set', 'reviseField']) {
		try {
			w[verb]('subject', 'Cost * Benefit Analysis *FINAL*');
			console.log(`  after ${verb}()${' '.repeat(13 - verb.length)}: ${restOf(edited)}`);
		} catch (err) {
			console.log(`  after ${verb}()${' '.repeat(13 - verb.length)}: throws — ${err.message}`);
		}
	}
	const { artifacts } = await engine.render(quill, doc, { format: 'png' });
	writeFileSync(png, artifacts[0].bytes);
	doc.free();
	edited.free();
}
