#!/usr/bin/env bash
# Inventory frontend pages, layouts, CSS for /lucy refazer-frontend
# Usage: frontend-inventory.sh [--project PATH] [--json] [--out FILE]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"

PROJECT_ROOT="$(pwd)"
AS_JSON=false
OUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --json) AS_JSON=true; shift ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: frontend-inventory.sh [--project PATH] [--json] [--out .lucy/frontend-inventory.md]"
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

PROJECT_ROOT="$(lucy_detect_project_root "$PROJECT_ROOT")"

# Detect App Router root
APP_ROOT=""
for candidate in \
  "$PROJECT_ROOT/src/app" \
  "$PROJECT_ROOT/app" \
  "$PROJECT_ROOT/frontend/src/app" \
  "$PROJECT_ROOT/frontend/app"; do
  if [[ -d "$candidate" ]]; then
    APP_ROOT="$candidate"
    break
  fi
done

if [[ -z "$APP_ROOT" ]]; then
  echo "ERROR: No Next.js App Router found (app/ or src/app/)" >&2
  exit 1
fi

REL_APP="${APP_ROOT#$PROJECT_ROOT/}"
CSS_GLOB=( "$PROJECT_ROOT"/**/*.css )
shopt -s globstar nullglob 2>/dev/null || true

INV_OUT=$(python3 << PY
import json, os, re
from pathlib import Path

project = Path("$PROJECT_ROOT")
app_root = Path("$APP_ROOT")
rel_app = "$REL_APP"

def route_from(page: Path) -> str:
    rel = page.relative_to(app_root)
    parts = list(rel.parts)
    if parts and parts[-1] in ("page.tsx", "page.jsx"):
        parts = parts[:-1]
    route = "/" + "/".join(p for p in parts if not p.startswith("("))
    return route if route != "/" or not parts else "/"

def scan_file(path: Path) -> dict:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return {"error": "unreadable"}
    return {
        "lines": text.count("\n") + 1,
        "use_client": text.lstrip().startswith('"use client"') or "'use client'" in text[:200],
        "has_motion": "framer-motion" in text or "from \"motion\"" in text,
        "has_gsap": "gsap" in text,
        "transition_tailwind": bool(re.search(r"transition(-[a-z]+)?", text)),
        "imports_shadcn": "/ui/" in text or "@/components/ui" in text,
    }

pages = sorted(app_root.rglob("page.tsx")) + sorted(app_root.rglob("page.jsx"))
layouts = sorted(app_root.rglob("layout.tsx")) + sorted(app_root.rglob("layout.jsx"))
css_files = sorted(project.glob("**/*.css"))
# trim node_modules .next
css_files = [p for p in css_files if "node_modules" not in p.parts and ".next" not in p.parts]

inventory = {
    "project": str(project),
    "app_root": rel_app,
    "page_count": len(pages),
    "layout_count": len(layouts),
    "css_count": len(css_files),
    "pages": [],
    "layouts": [],
    "css": [],
}

for p in pages:
    meta = scan_file(p)
    inventory["pages"].append({
        "path": str(p.relative_to(project)),
        "route": route_from(p),
        **meta,
    })

for p in layouts:
    meta = scan_file(p)
    inventory["layouts"].append({
        "path": str(p.relative_to(project)),
        **meta,
    })

for p in css_files[:80]:
    try:
        lines = p.read_text(encoding="utf-8", errors="replace").count("\n") + 1
    except OSError:
        lines = 0
    inventory["css"].append({
        "path": str(p.relative_to(project)),
        "lines": lines,
        "globals": p.name == "globals.css",
    })

client_pages = sum(1 for x in inventory["pages"] if x.get("use_client"))
inventory["summary"] = {
    "client_pages": client_pages,
    "server_pages": len(pages) - client_pages,
    "motion_pages": sum(1 for x in inventory["pages"] if x.get("has_motion")),
    "gsap_pages": sum(1 for x in inventory["pages"] if x.get("has_gsap")),
}

as_json = "$AS_JSON" == "true"
if as_json:
    print(json.dumps(inventory, indent=2, ensure_ascii=False))
else:
    lines = [
        "# Frontend inventory",
        "",
        f"Project: `{project.name}`",
        f"App root: `{rel_app}`",
        f"Pages: **{len(pages)}** | Layouts: **{len(layouts)}** | CSS: **{len(css_files)}**",
        f"Client pages: **{client_pages}** | Server: **{len(pages) - client_pages}**",
        "",
        "## Pages (read order for /lucy refazer-frontend)",
        "",
        "| Route | File | Lines | Client | Motion | GSAP |",
        "|-------|------|-------|--------|--------|------|",
    ]
    for x in inventory["pages"]:
        lines.append(
            f"| `{x['route']}` | `{x['path']}` | {x.get('lines','?')} | "
            f"{'yes' if x.get('use_client') else 'no'} | "
            f"{'yes' if x.get('has_motion') else 'no'} | "
            f"{'yes' if x.get('has_gsap') else 'no'} |"
        )
    lines += ["", "## Layouts", ""]
    for x in inventory["layouts"]:
        lines.append(f"- `{x['path']}` ({x.get('lines','?')} lines, client={x.get('use_client')})")
    lines += ["", "## CSS files (sample)", ""]
    for x in inventory["css"][:30]:
        g = " (globals)" if x.get("globals") else ""
        lines.append(f"- `{x['path']}` — {x['lines']} lines{g}")
    print("\n".join(lines))
PY
)

if [[ -z "$OUT" ]]; then
  echo "$INV_OUT"
else
  mkdir -p "$(dirname "$OUT")"
  echo "$INV_OUT" > "$OUT"
  echo "==> frontend inventory"
  echo "    wrote → $OUT"
fi
