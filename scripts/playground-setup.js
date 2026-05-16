#!/usr/bin/env node
// Clones quillmark-editor into .playground/ and wires it to this local quiver.
import { execSync } from 'child_process';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { dirname, resolve, join } from 'path';
import { fileURLToPath } from 'url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const playgroundDir = join(root, '.playground', 'quillmark-editor');
const editorRepo = 'https://github.com/nibsbin/quillmark-editor';

function run(cmd, cwd = root) {
  execSync(cmd, { cwd, stdio: 'inherit' });
}

if (!existsSync(playgroundDir)) {
  console.log('Cloning quillmark-editor into .playground/...');
  run(`git clone ${editorRepo} ${playgroundDir}`);
} else {
  console.log('Playground found — pulling latest changes...');
  run('git pull', playgroundDir);
}

// Point @airmark/quiver at this local checkout so package-quills.js uses local files.
const pkgPath = join(playgroundDir, 'package.json');
const pkg = JSON.parse(readFileSync(pkgPath, 'utf8'));
const localRef = `file:${root}`;

// Update @airmark/quiver in whichever dep bucket it lives in (dev or prod).
// Adding it to a second bucket causes npm to treat it as a conflicting override.
if (pkg.devDependencies?.['@airmark/quiver']) {
  pkg.devDependencies['@airmark/quiver'] = localRef;
} else {
  pkg.dependencies ??= {};
  pkg.dependencies['@airmark/quiver'] = localRef;
}

writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + '\n');
console.log(`Linked @airmark/quiver → ${localRef}`);

console.log('Installing editor dependencies...');
run('npm install', playgroundDir);

console.log('Building initial quill artifacts...');
run('node scripts/package-quills.js', playgroundDir);

console.log('\nPlayground ready. Run: npm run playground:dev');
