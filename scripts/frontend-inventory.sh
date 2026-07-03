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
    slop_patterns = [
        (r"gradient-to-", "gradient"),
        (r"\b(purple|violet|blue)-(4|5|6)00\b", "generic_color"),
        (r"shadow-(lg|xl|2xl)", "heavy_shadow"),
        (r"Welcome to|Get started|Lorem ipsum", "generic_copy"),
        (r"rounded-(2xl|3xl)", "rounded_spam"),
    ]
    slop_hits = [name for pat, name in slop_patterns if re.search(pat, text, re.I)]
    return {
        "lines": text.count("\n") + 1,
        "use_client": text.lstrip().startswith('"use client"') or "'use client'" in text[:200],
        "has_motion": "framer-motion" in text or "from \"motion\"" in text,
        "has_gsap": "gsap" in text,
        "transition_tailwind": bool(re.search(r"transition(-[a-z]+)?", text)),
        "imports_shadcn": "/ui/" in text or "@/components/ui" in text,
        "slop_signals": slop_hits,
        "slop_score": len(slop_hits),
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

# Nav links heuristic — scan components for href="/..."
nav_text = ""
for comp_dir in [project / "src" / "components", project / "components", project / "frontend" / "src" / "components"]:
    if comp_dir.is_dir():
        for f in comp_dir.rglob("*.tsx"):
            try:
                nav_text += f.read_text(encoding="utf-8", errors="replace") + "\n"
            except OSError:
                pass
nav_routes = set(re.findall(r'href=["\'](/[^"\']*)["\']', nav_text))
nav_routes |= set(re.findall(r'pathname:\s*["\'](/[^"\']*)["\']', nav_text))

for x in inventory["pages"]:
    route = x["route"]
    x["orphan"] = route not in nav_routes and route not in ("/", "/login", "/signup")
    if route in nav_routes:
        x["nav_linked"] = True

# Duplicate heuristic — same last segment or high slop + similar lines
from collections import defaultdict
by_segment = defaultdict(list)
for x in inventory["pages"]:
    seg = x["route"].rstrip("/").split("/")[-1] or "root"
    by_segment[seg].append(x["route"])

duplicates = []
for seg, routes in by_segment.items():
    if len(routes) > 1 and seg not in ("page", "index", ""):
        duplicates.append({"segment": seg, "routes": routes})

orphans = [x["route"] for x in inventory["pages"] if x.get("orphan")]
high_slop = sorted(
    [x for x in inventory["pages"] if x.get("slop_score", 0) >= 2],
    key=lambda x: -x.get("slop_score", 0),
)

inventory["issues"] = {
    "duplicate_route_groups": duplicates,
    "orphan_routes": orphans,
    "high_slop_routes": [{"route": x["route"], "signals": x.get("slop_signals", [])} for x in high_slop[:20]],
    "nav_routes_found": sorted(nav_routes)[:40],
}

inventory["summary"] = {
    "client_pages": client_pages,
    "server_pages": len(pages) - client_pages,
    "motion_pages": sum(1 for x in inventory["pages"] if x.get("has_motion")),
    "gsap_pages": sum(1 for x in inventory["pages"] if x.get("has_gsap")),
    "orphan_count": len(orphans),
    "duplicate_groups": len(duplicates),
    "high_slop_count": len(high_slop),
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
        f"Órfãs: **{inventory['summary']['orphan_count']}** | Grupos duplicados: **{inventory['summary']['duplicate_groups']}** | Alto slop: **{inventory['summary']['high_slop_count']}**",
        "",
        "## Issues (design focus — não mover URLs)",
        "",
    ]
    if duplicates:
        lines.append("### Rotas possivelmente duplicadas (mesmo segmento)")
        for d in duplicates:
            lines.append(f"- `{d['segment']}`: {', '.join('`'+r+'`' for r in d['routes'])}")
        lines.append("")
    if orphans:
        lines.append("### Órfãs (sem link na nav/sidebar)")
        for r in orphans[:25]:
            lines.append(f"- `{r}`")
        lines.append("")
    if high_slop:
        lines.append("### Alto sinal AI slop")
        for x in high_slop[:15]:
            lines.append(f"- `{x['route']}` — {', '.join(x.get('slop_signals', []))}")
        lines.append("")
    lines += [
        "## Pages (read order for /lucy refazer-frontend)",
        "",
        "| Route | File | Slop | Órfã | Client |",
        "|-------|------|------|------|--------|",
    ]
    for x in inventory["pages"]:
        lines.append(
            f"| `{x['route']}` | `{x['path']}` | {x.get('slop_score', 0)} | "
            f"{'yes' if x.get('orphan') else 'no'} | "
            f"{'yes' if x.get('use_client') else 'no'} |"
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
