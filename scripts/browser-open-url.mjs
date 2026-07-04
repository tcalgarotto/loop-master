#!/usr/bin/env node
/**
 * Lucy — Playwright headless URL capture (VPS-safe fallback for cursor-ide-browser MCP).
 * Usage: browser-open-url.mjs --url https://... [--out path.png] [--wait-ms 3000] [--json]
 */
import { createRequire } from "node:module";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { mkdir } from "node:fs/promises";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = process.cwd();
const pkgCandidates = [
  path.join(repoRoot, "frontend", "package.json"),
  path.join(repoRoot, "package.json"),
];
const pkgJson = pkgCandidates.find((p) => {
  try {
    return require("node:fs").existsSync(p);
  } catch {
    return false;
  }
});
if (!pkgJson) {
  console.error("ERROR: no package.json in project root or frontend/");
  process.exit(1);
}

const require = createRequire(pkgJson);
const { chromium } = require("playwright");

function parseArgs(argv) {
  const out = { url: "", out: "", waitMs: 3000, json: false };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--url") out.url = argv[++i] ?? "";
    else if (a === "--out") out.out = argv[++i] ?? "";
    else if (a === "--wait-ms") out.waitMs = Number(argv[++i] ?? 3000);
    else if (a === "--json") out.json = true;
    else if (a === "-h" || a === "--help") {
      console.log("Usage: browser-open-url.mjs --url URL [--out file.png] [--wait-ms N] [--json]");
      process.exit(0);
    }
  }
  if (!out.url) {
    console.error("Missing --url");
    process.exit(1);
  }
  if (!out.out) {
    const slug = out.url.replace(/[^a-zA-Z0-9]+/g, "-").slice(0, 60);
    out.out = `.lucy/browser/${slug}-${Date.now()}.png`;
  }
  return out;
}

const args = parseArgs(process.argv);
await mkdir(path.dirname(path.resolve(args.out)), { recursive: true });

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
let title = "";
let finalUrl = args.url;
try {
  await page.goto(args.url, { waitUntil: "domcontentloaded", timeout: 60_000 });
  await page.waitForTimeout(args.waitMs);
  title = await page.title();
  finalUrl = page.url();
  await page.screenshot({ path: args.out, fullPage: true });
} finally {
  await browser.close();
}

const result = { ok: true, url: args.url, finalUrl, title, screenshot: path.resolve(args.out) };
if (args.json) console.log(JSON.stringify(result, null, 2));
else {
  console.log(`screenshot: ${result.screenshot}`);
  console.log(`title: ${title}`);
  console.log(`finalUrl: ${finalUrl}`);
}
