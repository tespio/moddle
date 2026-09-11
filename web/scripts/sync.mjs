import { mkdir, readFile, writeFile, readdir, copyFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const webRoot = path.resolve(here, '..');
const repoRoot = path.resolve(webRoot, '..');

const dataOut = path.join(webRoot, 'src', 'data');
const docsOut = path.join(webRoot, 'src', 'content', 'docs');

await mkdir(dataOut, { recursive: true });
await mkdir(docsOut, { recursive: true });

// 1. Single source of truth -> site data
await copyFile(
  path.join(repoRoot, 'data', 'models.json'),
  path.join(dataOut, 'models.json')
);

// 2. Docs -> content collection, with a title frontmatter and the leading H1 stripped
const docsSrc = path.join(repoRoot, 'docs');
const files = (await readdir(docsSrc)).filter((f) => f.endsWith('.md'));

for (const file of files) {
  const raw = await readFile(path.join(docsSrc, file), 'utf8');
  const match = raw.match(/^#\s+(.+?)\s*$/m);
  const title = match ? match[1].trim() : file.replace(/\.md$/, '');
  const body = match ? raw.replace(/^#\s+.+?(\r?\n)/, '') : raw;
  const out = `---\ntitle: ${JSON.stringify(title)}\n---\n\n${body}`;
  await writeFile(path.join(docsOut, file), out, 'utf8');
}

console.log(`sync: copied models.json and ${files.length} docs`);
