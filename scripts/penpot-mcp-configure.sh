#!/usr/bin/env bash
# Configure Penpot MCP in Cursor from a local token file (never commit token).
# Usage:
#   bash scripts/penpot-mcp-configure.sh              # reads ~/.config/penpot/mcp-token
#   PENPOT_MCP_TOKEN=xxx bash scripts/penpot-mcp-configure.sh
#   echo -n 'TOKEN' | bash scripts/penpot-mcp-configure.sh --stdin
set -euo pipefail

TOKEN_FILE="${PENPOT_MCP_TOKEN_FILE:-$HOME/.config/penpot/mcp-token}"
MCP_JSON="${CURSOR_MCP_JSON:-$HOME/.cursor/mcp.json}"
PENPOT_MCP_BASE="https://design.penpot.app/mcp/stream"

usage() {
  echo "Usage: penpot-mcp-configure.sh [--stdin]"
  echo "  Token source (first match): PENPOT_MCP_TOKEN env, --stdin, $TOKEN_FILE"
  exit 0
}

FROM_STDIN=false
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage
[[ "${1:-}" == "--stdin" ]] && FROM_STDIN=true

mkdir -p "$(dirname "$TOKEN_FILE")"
chmod 700 "$(dirname "$TOKEN_FILE")" 2>/dev/null || true

TOKEN=""
if [[ -n "${PENPOT_MCP_TOKEN:-}" ]]; then
  TOKEN="$PENPOT_MCP_TOKEN"
elif [[ "$FROM_STDIN" == true ]]; then
  IFS= read -r TOKEN || true
elif [[ -f "$TOKEN_FILE" ]]; then
  TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"
fi

TOKEN="${TOKEN#https://design.penpot.app/mcp/stream?userToken=}"
TOKEN="${TOKEN#userToken=}"

if [[ -z "$TOKEN" ]]; then
  echo "ERROR: No Penpot MCP token found." >&2
  echo "  Save token to: $TOKEN_FILE" >&2
  echo "  Or: PENPOT_MCP_TOKEN=... $0" >&2
  exit 1
fi

printf '%s' "$TOKEN" > "$TOKEN_FILE"
chmod 600 "$TOKEN_FILE"

mkdir -p "$(dirname "$MCP_JSON")"

python3 - "$MCP_JSON" "$PENPOT_MCP_BASE" "$TOKEN" <<'PY'
import json, pathlib, sys

mcp_path = pathlib.Path(sys.argv[1])
base_url = sys.argv[2]
token = sys.argv[3]
url = f"{base_url}?userToken={token}"

if mcp_path.exists():
    try:
        data = json.loads(mcp_path.read_text())
    except json.JSONDecodeError:
        data = {"mcpServers": {}}
else:
    data = {}

data.setdefault("mcpServers", {})["penpot"] = {"url": url}
mcp_path.write_text(json.dumps(data, indent=2) + "\n")
PY

echo "OK: Penpot MCP → $MCP_JSON (server: penpot)"
echo "OK: Token → $TOKEN_FILE (chmod 600)"
echo "Next: restart Cursor → Settings → Tools & MCPs → verify Penpot is green"
echo "Next: open Penpot file → enable MCP in file menu"
