#!/usr/bin/env bash
# Ensure Playwright headless is installed; emit browser routing for agents (VPS-safe).
# Usage: ensure-headless-browser.sh [--project PATH] [--json] [--quiet]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"
# shellcheck source=lib/install-idempotent.sh
source "$SCRIPT_DIR/lib/install-idempotent.sh"

PROJECT_ROOT="$(lucy_detect_project_root "$(pwd)")"
AS_JSON=false
QUIET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$(lucy_detect_project_root "${2:-$(pwd)}")"; shift 2 ;;
    --json) AS_JSON=true; shift ;;
    --quiet) QUIET=true; shift ;;
    -h|--help)
      cat <<'HELP'
Usage: ensure-headless-browser.sh [--project PATH] [--json] [--quiet]

Installs @playwright/test + chromium if missing (Next.js / frontend/).
Writes .lucy/headless-browser-ready.json with primary browser route for agents.

On VPS/Remote SSH: primary=playwright (never cursor-ide-browser MCP).
HELP
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

log() { $QUIET || echo "$@"; }

CURSOR_MCPS="$(lucy_cursor_mcps_dir "$PROJECT_ROOT")"
TOOLS_DIR="$CURSOR_MCPS/cursor-ide-browser/tools"
CURSOR_TOOLS=0
CURSOR_MCP_OK=false
if [[ -d "$TOOLS_DIR" ]]; then
  CURSOR_TOOLS=$(find "$TOOLS_DIR" -maxdepth 1 -name 'browser_*.json' 2>/dev/null | wc -l | tr -d ' ')
  [[ "${CURSOR_TOOLS:-0}" -ge 10 ]] && CURSOR_MCP_OK=true
fi

REMOTE_VPS=false
[[ -z "${DISPLAY:-}" ]] && REMOTE_VPS=true
[[ -d "${HOME}/.cursor-server" ]] && REMOTE_VPS=true

log "==> ensure headless browser ($PROJECT_ROOT)"
lucy_ensure_playwright "$PROJECT_ROOT" false

PLAYWRIGHT_OK=false
lucy_playwright_ready "$PROJECT_ROOT" && PLAYWRIGHT_OK=true

PRIMARY="playwright"
if $CURSOR_MCP_OK && ! $REMOTE_VPS; then
  PRIMARY="cursor-mcp"
fi

mkdir -p "$PROJECT_ROOT/.lucy/browser"
MARKER="$PROJECT_ROOT/.lucy/headless-browser-ready.json"

export ROOT="$PROJECT_ROOT" MARKER="$MARKER" PRIMARY="$PRIMARY"
export CURSOR_MCP_OK="$CURSOR_MCP_OK" CURSOR_TOOLS="$CURSOR_TOOLS" REMOTE_VPS="$REMOTE_VPS"
export PLAYWRIGHT_OK="$PLAYWRIGHT_OK" AS_JSON="$AS_JSON"

python3 <<'PY'
import json, os
from datetime import datetime, timezone
marker = os.environ["MARKER"]
out = {
    "ready": os.environ["PLAYWRIGHT_OK"] == "true",
    "checked_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "primary": os.environ["PRIMARY"],
    "cursor_mcp_available": os.environ["CURSOR_MCP_OK"] == "true",
    "cursor_browser_tools_count": int(os.environ["CURSOR_TOOLS"] or 0),
    "remote_vps": os.environ["REMOTE_VPS"] == "true",
    "playwright_ready": os.environ["PLAYWRIGHT_OK"] == "true",
    "agent_rule": (
        "Use Playwright shell scripts — do NOT CallMcpTool browser_* on VPS/Remote SSH."
        if os.environ["PRIMARY"] == "playwright"
        else "Cursor Browser MCP available — CallMcpTool OK in parent agent."
    ),
    "commands": {
        "ensure": "bash .cursor/skills/lucy/scripts/ensure-headless-browser.sh --project .",
        "open_url": "bash .cursor/skills/lucy/scripts/browser-open-url.mjs --url URL --out .lucy/browser/capture.png",
        "visual_gate": "bash .cursor/skills/lucy/scripts/visual-gate-capture.sh --base-url http://127.0.0.1:3000",
        "status": "bash .cursor/skills/lucy/scripts/mcp-setup-status.sh --json",
    },
}
with open(marker, "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
    f.write("\n")
if os.environ.get("AS_JSON") == "true":
    print(json.dumps(out, ensure_ascii=False, indent=2))
PY

if $AS_JSON; then
  :
else
  log "    primary: $PRIMARY"
  log "    playwright_ready: $PLAYWRIGHT_OK"
  log "    cursor_mcp_available: $CURSOR_MCP_OK (tools=$CURSOR_TOOLS)"
  log "    remote_vps: $REMOTE_VPS"
  log "    marker: $MARKER"
fi

$PLAYWRIGHT_OK || exit 1
