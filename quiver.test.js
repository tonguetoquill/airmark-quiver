import { Quillmark, Document } from '@quillmark/wasm';
import { runQuiverTests } from '@quillmark/quiver/testing';

const engine = new Quillmark();

runQuiverTests(import.meta.url, engine, Document);
