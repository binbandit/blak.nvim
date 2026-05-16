import { chmod, copyFile, mkdir, stat } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptsDir = dirname(fileURLToPath(import.meta.url));
const docsDir = resolve(scriptsDir, "..");
const repoDir = resolve(docsDir, "..");
const source = resolve(repoDir, "install.sh");
const publicDir = resolve(docsDir, "public");
const targets = [resolve(publicDir, "install.sh"), resolve(publicDir, "install")];

const sourceStat = await stat(source);
if (!sourceStat.isFile()) {
  throw new Error(`Expected installer at ${source}`);
}

await mkdir(publicDir, { recursive: true });

for (const target of targets) {
  await copyFile(source, target);
  await chmod(target, 0o644);
}

console.log("Synced installer to docs public assets.");
