import { Quillmark, Document } from '@quillmark/wasm';
import { renderQuiverSamples } from '@quillmark/quiver/preview';

const results = await renderQuiverSamples(import.meta.url, {
  engine: new Quillmark(),
  Document,
});

// `renderQuiverSamples` never throws — surface failures as a non-zero exit
// so CI fails when a quill stops rendering.
if (results.some((r) => r.status === 'failed')) {
  process.exitCode = 1;
}
