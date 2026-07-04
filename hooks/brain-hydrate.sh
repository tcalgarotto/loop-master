#!/usr/bin/env bash
# Lucy hook — sessionStart: hydrate Second Brain + headless browser routing
set -euo pipefail

input=$(cat)
PROJECT_ROOT="${CURSOR_PROJECT_DIR:-${PWD}}"

find_brain_sync() {
  local p
  for p in \
    "$PROJECT_ROOT/.cursor/skills/lucy/scripts/brain-sync.sh" \
    "$PROJECT_ROOT/.agents/skills/lucy/scripts/brain-sync.sh" \
    "$PROJECT_ROOT/.cursor/skills/loop-master/scripts/brain-sync.sh" \
    "$PROJECT_ROOT/.agents/skills/loop-master/scripts/brain-sync.sh"; do
    [[ -x "$p" ]] && { echo "$p"; return 0; }
  done
  return 1
}

find_ensure_browser() {
  local p
  for p in \
    "$PROJECT_ROOT/.cursor/skills/lucy/scripts/ensure-headless-browser.sh" \
    "$PROJECT_ROOT/.agents/skills/lucy/scripts/ensure-headless-browser.sh"; do
    [[ -x "$p" ]] && { echo "$p"; return 0; }
  done
  find "$PROJECT_ROOT" -path '*/lucy/scripts/ensure-headless-browser.sh' -executable 2>/dev/null | head -1
}

BRAIN_SYNC=$(find_brain_sync) || exit 0

cd "$PROJECT_ROOT"
TMP=$(mktemp)
if ! "$BRAIN_SYNC" hydrate > "$TMP" 2>/dev/null; then
  rm -f "$TMP"
  exit 0
fi

ENSURE_BROWSER="$(find_ensure_browser || true)"
MCP_NOTE=""
if [[ -n "$ENSURE_BROWSER" ]]; then
  "$ENSURE_BROWSER" --project "$PROJECT_ROOT" --quiet 2>/dev/null || true
fi
if [[ -f "$PROJECT_ROOT/.lucy/headless-browser-ready.json" ]]; then
  MCP_NOTE=$'\n\n[BROWSER] Read .lucy/headless-browser-ready.json — use Playwright (browser-open-url.mjs, visual-gate-capture.sh). NEVER CallMcpTool browser_* when primary=playwright.'
fi

export PROJECT_ROOT BRAIN_TMP="$TMP" MCP_NOTE="$MCP_NOTE"
python3 << 'PY'
import json, os, pathlib
tmp = os.environ["BRAIN_TMP"]
body = pathlib.Path(tmp).read_text(encoding="utf-8", errors="replace")[:8000]
mcp = os.environ.get("MCP_NOTE", "")
primary = "playwright" if "primary=playwright" in mcp or "headless-browser-ready" in mcp else "unknown"
out = {
    "env": {"LUCY_BRAIN": "active", "BROWSER_PRIMARY": primary},
    "additional_context": (
        "[Lucy — Second Brain hydrated]\n"
        "Memory protocol: .cursor/skills/lucy/references/second-brain-protocol.md\n"
        "Browser VPS: references/learned/vps-headless-browser-default.md\n\n"
        + body
        + mcp
    ),
}
print(json.dumps(out, ensure_ascii=False))
PY

rm -f "$TMP"
exit 0
