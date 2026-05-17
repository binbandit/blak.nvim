import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const scriptsDir = dirname(fileURLToPath(import.meta.url));
const docsDir = resolve(scriptsDir, "..");
const splashPath = resolve(docsDir, "src/data/splash.json");
const pngPath = resolve(docsDir, "public/social-card.png");

const CARD_WIDTH = 1200;
const CARD_HEIGHT = 630;
const FRAME_INDEX = 0;

const splash = JSON.parse(await readFile(splashPath, "utf8"));
const rows = splash.frames[FRAME_INDEX];
const colors = splash.colors[FRAME_INDEX] ?? [];

if (!rows || rows.length === 0) {
  throw new Error(`No splash frame found at index ${FRAME_INDEX}`);
}

function escapeXml(value) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function renderSegment(chars, fill, opacity = 1) {
  if (chars.length === 0) return "";
  const attrs = [`fill="${fill}"`];
  if (opacity !== 1) attrs.push(`fill-opacity="${opacity}"`);
  return `<tspan ${attrs.join(" ")}>${escapeXml(chars.join(""))}</tspan>`;
}

function renderRow(line, spans) {
  const chars = Array.from(line);
  const parts = [];
  let cursor = 0;

  for (const [start, end, fill] of spans) {
    if (start > cursor) {
      parts.push(renderSegment(chars.slice(cursor, start), "#000000", 0));
    }
    parts.push(renderSegment(chars.slice(start, end), fill));
    cursor = end;
  }

  if (cursor < chars.length) {
    parts.push(renderSegment(chars.slice(cursor), "#000000", 0));
  }

  return parts.join("");
}

const splashLines = rows
  .map((line, index) => {
    const y = 96 + index * 28;
    return `<text class="braille" x="600" y="${y}" text-anchor="middle">${renderRow(line, colors[index] ?? [])}</text>`;
  })
  .join("\n");

const svg = `<svg width="${CARD_WIDTH}" height="${CARD_HEIGHT}" viewBox="0 0 ${CARD_WIDTH} ${CARD_HEIGHT}" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="title desc">
  <title id="title">blak.nvim social card</title>
  <desc id="desc">The blak.nvim ASCII black-hole splash with the project name and tagline.</desc>
  <defs>
    <style>
      .sans {
        font-family: ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
      }
      .mono {
        font-family: ui-monospace, "SFMono-Regular", Menlo, Monaco, Consolas, "Liberation Mono", monospace;
      }
      .braille {
        font-family: "JetBrains Mono", ui-monospace, "SFMono-Regular", Menlo, Monaco, Consolas, "Liberation Mono", monospace;
        font-size: 31px;
        font-weight: 500;
        dominant-baseline: alphabetic;
        font-variant-ligatures: none;
        font-feature-settings: "calt" off, "liga" off;
      }
    </style>
  </defs>

  <rect width="1200" height="630" fill="#000000"/>
  <rect x="1" y="1" width="1198" height="628" rx="34" fill="none" stroke="#161616" stroke-width="2"/>

  ${splashLines}

  <text class="sans" x="600" y="514" fill="#ffffff" font-size="76" font-weight="800" text-anchor="middle">blak.nvim</text>
  <text class="sans" x="600" y="566" fill="#e8e8e8" font-size="30" font-weight="600" text-anchor="middle">Everything useful. Nothing escapes.</text>
  <text class="mono" x="600" y="607" fill="#5e5e5e" font-size="20" font-weight="500" text-anchor="middle">getblak.dev</text>
</svg>
`;

await sharp(Buffer.from(svg)).png().toFile(pngPath);

console.log("Rendered public/social-card.png from the ASCII splash.");
