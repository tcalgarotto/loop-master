#!/usr/bin/env bash
# Scan local MCP integrations and Lucy toolchain — no secrets printed.
# Usage: mcp-setup-status.sh [--json] [--project PATH]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"
# shellcheck source=lib/install-idempotent.sh
source "$SCRIPT_DIR/lib/install-idempotent.sh"

PROJECT_ROOT="$(lucy_detect_project_root "$(pwd)")"
AS_JSON=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) AS_JSON=true; shift ;;
    --project) PROJECT_ROOT="$(lucy_detect_project_root "${2:-$(pwd)}")"; shift 2 ;;
    *) shift ;;
  esac
done

MCP_JSON="${CURSOR_MCP_JSON:-$HOME/.cursor/mcp.json}"
PENPOT_TOKEN="${PENPOT_MCP_TOKEN_FILE:-$HOME/.config/penpot/mcp-token}"

has_mcp_server() {
  local name="$1"
  [[ -f "$MCP_JSON" ]] && python3 -c "
import json, sys
p='$MCP_JSON'
n='$name'
try:
  d=json.load(open(p))
  sys.exit(0 if n in d.get('mcpServers',{}) else 1)
except Exception:
  sys.exit(1)
" 2>/dev/null
}

has_file_nonempty() {
  [[ -f "$1" ]] && [[ -s "$1" ]]
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# --- checks ---
PENPOT_OK=false
PENPOT_MCP_OK=false
if has_file_nonempty "$PENPOT_TOKEN"; then PENPOT_OK=true; fi
if has_mcp_server "penpot"; then PENPOT_MCP_OK=true; fi

FIRECRAWL_OK=false
[[ -n "${FIRECRAWL_API_KEY:-}" ]] && FIRECRAWL_OK=true

PLAYWRIGHT_OK=false
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  if [[ -d "$PROJECT_ROOT/node_modules/@playwright/test" ]] || [[ -d "$PROJECT_ROOT/node_modules/playwright" ]]; then
    PLAYWRIGHT_OK=true
  fi
fi
has_cmd npx && npx playwright --version >/dev/null 2>&1 && PLAYWRIGHT_OK=true

VISUAL_GATE_SCRIPT=false
[[ -x "$SCRIPT_DIR/visual-gate-capture.sh" ]] && VISUAL_GATE_SCRIPT=true

CLAUDE_MEM_OK=false
if has_cmd claude-mem; then
  claude-mem status 2>/dev/null | grep -qi running && CLAUDE_MEM_OK=true || true
fi

HTML_PREVIEW_OK=false
[[ -x "$SCRIPT_DIR/html-preview-serve.sh" ]] && HTML_PREVIEW_OK=true

CURSOR_BROWSER_OK=false
CURSOR_BROWSER_TOOLS=0
CURSOR_MCPS_DIR="$(lucy_cursor_mcps_dir "$PROJECT_ROOT")"
CURSOR_BROWSER_TOOLS_DIR="$CURSOR_MCPS_DIR/cursor-ide-browser/tools"
if [[ -d "$CURSOR_BROWSER_TOOLS_DIR" ]]; then
  CURSOR_BROWSER_TOOLS=$(find "$CURSOR_BROWSER_TOOLS_DIR" -maxdepth 1 -name 'browser_*.json' 2>/dev/null | wc -l | tr -d ' ')
  [[ "${CURSOR_BROWSER_TOOLS:-0}" -ge 10 ]] && CURSOR_BROWSER_OK=true
fi

REMOTE_VPS=false
[[ -z "${DISPLAY:-}" ]] && REMOTE_VPS=true
[[ -d "${HOME}/.cursor-server" ]] && REMOTE_VPS=true

HEADLESS_BROWSER_OK=false
if lucy_playwright_ready "$PROJECT_ROOT" 2>/dev/null; then
  HEADLESS_BROWSER_OK=true
elif [[ -f "$PROJECT_ROOT/.lucy/headless-browser-ready.json" ]]; then
  python3 -c "import json; d=json.load(open('$PROJECT_ROOT/.lucy/headless-browser-ready.json')); exit(0 if d.get('playwright_ready') else 1)" 2>/dev/null && HEADLESS_BROWSER_OK=true || true
fi

BROWSER_PRIMARY="playwright"
if [[ "$CURSOR_BROWSER_OK" == true && "$REMOTE_VPS" == false ]]; then
  BROWSER_PRIMARY="cursor-mcp"
fi

NEXTJS=false
[[ -f "$PROJECT_ROOT/package.json" ]] && grep -q '"next"' "$PROJECT_ROOT/package.json" 2>/dev/null && NEXTJS=true

# Cursor plugin MCPs (optional — read mcp.json only)
MCP_SERVERS=()
if [[ -f "$MCP_JSON" ]]; then
  mapfile -t MCP_SERVERS < <(python3 -c "
import json
try:
  for k in json.load(open('$MCP_JSON')).get('mcpServers',{}):
    print(k)
except Exception:
  pass
" 2>/dev/null || true)
fi

export AS_JSON="$AS_JSON" PROJECT_ROOT PENPOT_OK PENPOT_MCP_OK FIRECRAWL_OK PLAYWRIGHT_OK
export VISUAL_GATE_SCRIPT CLAUDE_MEM_OK HTML_PREVIEW_OK NEXTJS
export CURSOR_BROWSER_OK CURSOR_BROWSER_TOOLS CURSOR_MCPS_DIR MCP_JSON
export REMOTE_VPS HEADLESS_BROWSER_OK BROWSER_PRIMARY
python3 <<'PY'
import json, os

def item(slug, label, ok, guide, priority="recommended"):
    return {
        "slug": slug,
        "label": label,
        "configured": bool(ok),
        "guide_section": guide,
        "priority": priority,
    }

checks = [
    item("headless-browser", "Playwright headless (VPS default)", os.environ.get("HEADLESS_BROWSER_OK") == "true", "visual-gate", "recommended"),
    item("cursor-browser", "Cursor Browser MCP (só Desktop local)", os.environ.get("CURSOR_BROWSER_OK") == "true", "cursor-browser", "optional"),
    item("penpot", "Penpot MCP (design editável)", os.environ.get("PENPOT_MCP_OK") == "true", "penpot"),
    item("html-first", "HTML preview local (preview/)", os.environ.get("HTML_PREVIEW_OK") == "true", "html-first", "recommended"),
    item("visual-gate", "Visual gate (Playwright)", os.environ.get("PLAYWRIGHT_OK") == "true", "visual-gate"),
    item("firecrawl", "Firecrawl (scrape concorrentes)", os.environ.get("FIRECRAWL_OK") == "true", "firecrawl", "optional"),
    item("claude-mem", "claude-mem (segundo cérebro L2)", os.environ.get("CLAUDE_MEM_OK") == "true", "claude-mem"),
]

missing = [c for c in checks if not c["configured"]]
configured = [c for c in checks if c["configured"]]

out = {
    "project_root": os.environ.get("PROJECT_ROOT", ""),
    "nextjs_detected": os.environ.get("NEXTJS") == "true",
    "cursor_mcps_dir": os.environ.get("CURSOR_MCPS_DIR", ""),
    "cursor_browser_tools_count": int(os.environ.get("CURSOR_BROWSER_TOOLS", "0") or 0),
    "remote_vps": os.environ.get("REMOTE_VPS") == "true",
    "browser_primary": os.environ.get("BROWSER_PRIMARY", "playwright"),
    "headless_browser_ready": os.environ.get("HEADLESS_BROWSER_OK") == "true",
    "mcp_servers": [],
    "integrations": checks,
    "missing_count": len(missing),
    "missing_slugs": [c["slug"] for c in missing],
    "quiz_hint": (
        "Rodada 3: priorize cadastrar " + ", ".join(c["label"] for c in missing[:3])
        if missing else "Todas as integrações core detectadas."
    ),
}

mcp_json = os.environ.get("MCP_JSON", "")
if mcp_json and os.path.isfile(mcp_json):
    try:
        out["mcp_servers"] = list(json.load(open(mcp_json)).get("mcpServers", {}).keys())
    except Exception:
        pass

if os.environ.get("AS_JSON") == "true":
    print(json.dumps(out, ensure_ascii=False, indent=2))
else:
    print("MCP & integrações Lucy — status")
    print("=" * 50)
    for c in checks:
        mark = "OK" if c["configured"] else "FALTA"
        print(f"  [{mark}] {c['label']}  → guia: §{c['guide_section']}")
    if out["mcp_servers"]:
        print(f"\nCursor mcp.json: {', '.join(out['mcp_servers'])}")
    print(f"\n{out['quiz_hint']}")
    print("\nGuia: references/mcp-integrations-setup-guide.md")
    print("Config Penpot: bash scripts/penpot-mcp-configure.sh")
PY
