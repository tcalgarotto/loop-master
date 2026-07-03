import fs from 'fs';
import path from 'path';
import { pathToFileURL } from 'url';

const gateDeps = process.env.GATE_DEPS;
if (!gateDeps) {
  console.error('GATE_DEPS env required');
  process.exit(1);
}
const { chromium } = await import(pathToFileURL(path.join(gateDeps, 'node_modules/playwright/index.mjs')).href);

const url = process.env.BASE_URL;
const out = process.env.OUT;
const sections = ['top', 'plataforma', 'integrations', 'produto', 'precos', 'cta'];

if (!url || !out) {
  console.error('BASE_URL and OUT env required');
  process.exit(1);
}

fs.mkdirSync(out, { recursive: true });

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
await page.goto(url, { waitUntil: 'load', timeout: 60000 });
// Force visible state (GSAP .reveal hides off-screen content until scroll)
await page.addStyleTag({ content: '.reveal { opacity: 1 !important; transform: none !important; }' });
await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
await page.waitForTimeout(400);
await page.evaluate(() => window.scrollTo(0, 0));
await page.waitForTimeout(200);
await page.screenshot({ path: path.join(out, 'full-desktop.png'), fullPage: true });

for (const id of sections) {
  const el = await page.$(`#${id}`);
  if (el) {
    await el.scrollIntoViewIfNeeded();
    await page.waitForTimeout(300);
    await el.screenshot({ path: path.join(out, `section-${id}.png`) });
  }
}

await page.setViewportSize({ width: 390, height: 844 });
await page.goto(url, { waitUntil: 'load' });
await page.screenshot({ path: path.join(out, 'full-mobile.png'), fullPage: true });

await browser.close();

const manifest = { url, sections, captured_at: new Date().toISOString(), out };
fs.writeFileSync(path.join(out, 'manifest.json'), JSON.stringify(manifest, null, 2));
console.log('OK: captures →', out);
