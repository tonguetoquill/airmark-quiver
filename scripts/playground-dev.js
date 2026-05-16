#!/usr/bin/env node
// Starts the quillmark-editor dev server and rebuilds quill artifacts on quills/ changes.
import { spawn, execSync } from 'child_process';
import { existsSync, watch } from 'fs';
import { dirname, resolve, join } from 'path';
import { fileURLToPath } from 'url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const playgroundDir = join(root, '.playground', 'quillmark-editor');
const quillsDir = join(root, 'quills');

if (!existsSync(playgroundDir)) {
  console.error('Playground not set up. Run: npm run playground:setup');
  process.exit(1);
}

function rebuildQuills() {
  console.log('\n[quiver] Rebuilding quill artifacts...');
  try {
    execSync('node scripts/package-quills.js', { cwd: playgroundDir, stdio: 'inherit' });
    console.log('[quiver] Done.');
  } catch {
    console.error('[quiver] Rebuild failed — check output above.');
  }
}

// Debounce rapid file-system events (e.g. saving multiple files at once).
let rebuildTimer;
function scheduleRebuild() {
  clearTimeout(rebuildTimer);
  rebuildTimer = setTimeout(rebuildQuills, 150);
}

console.log(`Watching ${quillsDir} for changes...`);
watch(quillsDir, { recursive: true }, (_, filename) => {
  if (filename) {
    console.log(`[quiver] Changed: ${filename}`);
    scheduleRebuild();
  }
});

console.log('Starting quillmark-editor dev server...\n');
const devServer = spawn('npm', ['run', 'dev'], {
  cwd: playgroundDir,
  stdio: 'inherit',
  shell: true,
});

devServer.on('close', (code) => process.exit(code ?? 0));

process.on('SIGINT', () => {
  devServer.kill('SIGINT');
  process.exit(0);
});
