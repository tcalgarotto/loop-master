#!/usr/bin/env bash
# loop-master hook — sessionStart: hydrate Second Brain into agent context
set -euo pipefail

input=$(cat)
PROJECT_ROOT="${CURSOR_PROJECT_DIR:-${PWD}}"

find_brain_sync() {
  local p
  for p in \
    "$PROJECT_ROOT/.cursor/skills/loop-master/scripts/brain-sync.sh" \
    "$PROJECT_ROOT/.agents/skills/loop-master/scripts/brain-sync.sh"; do
    [[ -x "$p" ]] && { echo "$p"; return 0; }
  done
  return 1
}

BRAIN_SYNC=$(find_brain_sync) || exit 0

cd "$PROJECT_ROOT"
TMP=$(mktemp)
if ! "$BRAIN_SYNC" hydrate > "$TMP" 2>/dev/null; then
  rm -f "$TMP"
  exit 0
fi

export PROJECT_ROOT BRAIN_TMP="$TMP"
python3 << 'PY'
import json, os, pathlib
tmp = os.environ["BRAIN_TMP"]
body = pathlib.Path(tmp).read_text(encoding="utf-8", errors="replace")[:8000]
out = {
    "env": {"LOOP_MASTER_BRAIN": "active"},
    "additional_context": (
        "[Loop Master — Second Brain hydrated]\n"
        "Memory protocol: .cursor/skills/loop-master/references/second-brain-protocol.md\n\n"
        + body
    ),
}
print(json.dumps(out, ensure_ascii=False))
PY

rm -f "$TMP"
exit 0
