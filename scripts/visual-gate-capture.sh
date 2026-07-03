#!/usr/bin/env bash
# Capture desktop + mobile screenshots for visual gate (Playwright)
# Usage: visual-gate-capture.sh --base-url http://localhost:3000 [--tick N] [--project PATH]
#        [--escopo /,/crm] [--routes-file .lucy/frontend-inventory.json] [--capture-only]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"

PROJECT_ROOT="$(pwd)"
BASE_URL=""
TICK=""
ESCOPO=""
ROUTES_FILE=""
CAPTURE_ONLY=false
INCLUDE_DYNAMIC=false
WAIT_MS=1500

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --base-url) BASE_URL="$2"; shift 2 ;;
    --tick) TICK="$2"; shift 2 ;;
    --escopo) ESCOPO="$2"; shift 2 ;;
    --routes-file) ROUTES_FILE="$2"; shift 2 ;;
    --capture-only) CAPTURE_ONLY=true; shift ;;
    --include-dynamic) INCLUDE_DYNAMIC=true; shift ;;
    --wait-ms) WAIT_MS="$2"; shift 2 ;;
    -h|--help)
      cat <<'HELP'
Usage: visual-gate-capture.sh --base-url URL [options]

Options:
  --project PATH          Project root (default: cwd)
  --tick N                Output dir tick-N (default: from lucy-progress.json)
  --escopo /a,/b          Only these routes (default: all from inventory)
  --routes-file FILE      JSON from frontend-inventory.sh --json
  --capture-only          Skip progress JSON update
  --include-dynamic       Include routes with [param] (may 404)
  --wait-ms MS            Wait after navigation (default: 1500)

Requires: dev server running at --base-url, Node.js, @playwright/test
Install:  npm install -D @playwright/test && npx playwright install chromium

Output:   .lucy/visual-gates/tick-N/{manifest.json, *.png}
HELP
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

PROJECT_ROOT="$(lucy_detect_project_root "$PROJECT_ROOT")"
PROGRESS="$(lucy_progress_file "$PROJECT_ROOT")"

if [[ -z "$BASE_URL" ]]; then
  for port in 3000 3001 5173 8080; do
    if curl -sf -o /dev/null -m 2 "http://127.0.0.1:${port}/" 2>/dev/null; then
      BASE_URL="http://127.0.0.1:${port}"
      echo "==> auto-detected base URL: $BASE_URL"
      break
    fi
  done
fi

[[ -n "$BASE_URL" ]] || {
  echo "ERROR: --base-url required (or start dev server on :3000)" >&2
  exit 1
}

BASE_URL="${BASE_URL%/}"

if [[ -z "$TICK" && -f "$PROGRESS" ]]; then
  TICK=$(python3 -c "import json; d=json.load(open('$PROGRESS')); print(d.get('tick_count', 1))" 2>/dev/null || echo "1")
fi
TICK="${TICK:-1}"

OUT_DIR="$PROJECT_ROOT/.lucy/visual-gates/tick-${TICK}"
mkdir -p "$OUT_DIR"

# Inventory JSON
if [[ -z "$ROUTES_FILE" ]]; then
  ROUTES_FILE="$PROJECT_ROOT/.lucy/frontend-inventory.json"
fi
if [[ ! -f "$ROUTES_FILE" ]]; then
  echo "==> generating frontend inventory..."
  bash "$SCRIPT_DIR/frontend-inventory.sh" --project "$PROJECT_ROOT" --json --out "$ROUTES_FILE"
fi

# Ensure Playwright
if ! node -e "require.resolve('@playwright/test')" 2>/dev/null; then
  echo "ERROR: @playwright/test not installed. Run:" >&2
  echo "  npm install -D @playwright/test && npx playwright install chromium" >&2
  exit 1
fi

# Filter routes
ROUTES_JSON=$(python3 << PY
import json, sys
from pathlib import Path

inv = json.loads(Path("$ROUTES_FILE").read_text())
escopo = "$ESCOPO".strip()
include_dynamic = "$INCLUDE_DYNAMIC" == "true"

routes = []
for p in inv.get("pages", []):
    r = p.get("route", "/")
    if "[" in r and not include_dynamic:
        continue
    routes.append(r)

if escopo:
    wanted = {s.strip() for s in escopo.split(",") if s.strip()}
    filtered = []
    for r in routes:
        for w in wanted:
            if r == w or r.startswith(w.rstrip("/") + "/") or (w != "/" and r.startswith(w)):
                filtered.append(r)
                break
    routes = sorted(set(filtered)) if filtered else sorted(set(routes))
else:
    routes = sorted(set(routes))

if not routes:
    routes = ["/"]

print(json.dumps(routes))
PY
)

CAPTURE_SCRIPT="$OUT_DIR/_capture.mjs"
cat > "$CAPTURE_SCRIPT" << 'MJS'
import { chromium, devices } from '@playwright/test';
import fs from 'fs';
import path from 'path';

const baseUrl = process.env.VG_BASE_URL;
const outDir = process.env.VG_OUT_DIR;
const routes = JSON.parse(process.env.VG_ROUTES);
const waitMs = parseInt(process.env.VG_WAIT_MS || '1500', 10);

function slug(route) {
  return route.replace(/^\//, '').replace(/\//g, '__') || 'root';
}

const viewports = [
  { name: 'desktop', width: 1440, height: 900 },
  { name: 'mobile', ...devices['iPhone 13'].viewport, isMobile: true },
];

const results = [];

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ ignoreHTTPSErrors: true });

for (const route of routes) {
  const entry = { route, screenshots: {}, errors: [] };
  for (const vp of viewports) {
    const page = await context.newPage();
    await page.setViewportSize({ width: vp.width, height: vp.height });
    const url = baseUrl + (route === '/' ? '' : route);
    const file = path.join(outDir, `${slug(route)}__${vp.name}.png`);
    try {
      const resp = await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
      await page.waitForTimeout(waitMs);
      await page.screenshot({ path: file, fullPage: true });
      entry.screenshots[vp.name] = path.relative(process.env.VG_PROJECT_ROOT, file);
      entry.http_status = resp ? resp.status() : null;
    } catch (e) {
      entry.errors.push({ viewport: vp.name, error: String(e.message || e) });
    } finally {
      await page.close();
    }
  }
  results.push(entry);
}

await browser.close();

const manifest = {
  captured_at: new Date().toISOString(),
  base_url: baseUrl,
  tick: process.env.VG_TICK,
  routes: results,
  viewports: viewports.map((v) => v.name),
};

fs.writeFileSync(path.join(outDir, 'manifest.json'), JSON.stringify(manifest, null, 2));
console.log(JSON.stringify(manifest, null, 2));
MJS

echo "==> visual gate capture"
echo "    tick: $TICK"
echo "    out:  $OUT_DIR"
echo "    routes: $(echo "$ROUTES_JSON" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))')"

export VG_BASE_URL="$BASE_URL"
export VG_OUT_DIR="$OUT_DIR"
export VG_ROUTES="$ROUTES_JSON"
export VG_TICK="$TICK"
export VG_WAIT_MS="$WAIT_MS"
export VG_PROJECT_ROOT="$PROJECT_ROOT"

MANIFEST=$(node "$CAPTURE_SCRIPT")
rm -f "$CAPTURE_SCRIPT"

# Relative manifest path for agent
REL_MANIFEST=".lucy/visual-gates/tick-${TICK}/manifest.json"

if [[ "$CAPTURE_ONLY" != "true" && -f "$PROGRESS" ]]; then
  python3 << PY
import json
from datetime import datetime, timezone
from pathlib import Path

progress = Path("$PROGRESS")
data = json.loads(progress.read_text())
manifest = json.loads(Path("$OUT_DIR/manifest.json").read_text())

phase_id = data.get("current_phase", "")
routes_audit = []
for r in manifest.get("routes", []):
    routes_audit.append({
        "route": r["route"],
        "screenshots": r.get("screenshots", {}),
        "scores": {},
        "findings": [],
        "passed": None,
        "errors": r.get("errors", []),
    })

data["last_visual_audit"] = {
    "at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "tick": int("$TICK"),
    "phase_id": phase_id,
    "capture_dir": f".lucy/visual-gates/tick-{int('$TICK')}",
    "manifest": "$REL_MANIFEST",
    "base_url": "$BASE_URL",
    "routes": routes_audit,
    "gate_passed": False,
    "waived": [],
    "status": "captured_pending_vision",
    "agent_notes": "Run vision checklist per visual-gate-protocol.md; attach PNGs in Cursor.",
}
progress.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print("    updated →", progress)
PY
fi

echo "==> manifest → $REL_MANIFEST"
echo "    Next: agent reads PNGs + scores checklist → set last_visual_audit.gate_passed"
