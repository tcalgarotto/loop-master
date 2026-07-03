#!/usr/bin/env bash
# Arm dynamic loop — chain next tick when current completes (default for loop-master)
# Usage: arm-dynamic-loop.sh [--progress-file path] [--seconds N] [--sentinel NAME]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
[[ -d "$PROJECT_ROOT/.git" ]] || PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

PROGRESS="${LOOP_MASTER_PROGRESS_FILE:-$PROJECT_ROOT/.cursor/loop-master-progress.json}"
SENTINEL_CLI=""
SECONDS_WAIT=45

while [[ $# -gt 0 ]]; do
  case "$1" in
    --progress-file) PROGRESS="$2"; shift 2 ;;
    --seconds) SECONDS_WAIT="$2"; shift 2 ;;
    --sentinel) SENTINEL_CLI="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: arm-dynamic-loop.sh [--progress-file path] [--seconds 45] [--sentinel AGENT_LOOP_WAKE_...]"
      exit 0
      ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

[[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"

if [[ ! -f "$PROGRESS" ]]; then
  echo "ERROR: progress file not found: $PROGRESS" >&2
  exit 1
fi

if ! command -v python3 &>/dev/null || ! command -v jq &>/dev/null; then
  echo "ERROR: python3 and jq required" >&2
  exit 1
fi

META=$(python3 << PY
import json
p = "$PROGRESS"
cli = "$SENTINEL_CLI"
with open(p) as f:
    d = json.load(f)
out = {
    "prompt": d.get("next_prompt", "/loop-master — skill loop-master"),
    "sentinel": cli or d.get("loop_sentinel") or d.get("loop_arm", {}).get("sentinel") or "AGENT_LOOP_WAKE_LOOPMASTER",
    "status": d.get("loop_status", "running"),
}
print(json.dumps(out))
PY
)

PROMPT_JSON=$(echo "$META" | jq -r '.prompt')
SENTINEL_JSON=$(echo "$META" | jq -r '.sentinel')
STATUS=$(echo "$META" | jq -r '.status')

if [[ "$STATUS" == "stopped" ]]; then
  echo "==> loop_status=stopped — not arming"
  exit 0
fi

PID_FILE="$PROJECT_ROOT/.cursor/.loop-arm-${SENTINEL_JSON}.pid"
if [[ -f "$PID_FILE" ]]; then
  old_pid=$(cat "$PID_FILE" 2>/dev/null || true)
  if [[ -n "$old_pid" ]]; then
    kill "$old_pid" 2>/dev/null || true
  fi
fi
sleep 0.3

LOG="${TMPDIR:-/tmp}/loopmaster-arm-${SENTINEL_JSON}.log"
PROMPT_ESC=$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$PROMPT_JSON")

nohup bash -c "sleep $SECONDS_WAIT; echo '${SENTINEL_JSON}' \"{\\\"prompt\\\":${PROMPT_ESC},\\\"chain\\\":true}\"" >> "$LOG" 2>&1 &
NEW_PID=$!
echo "$NEW_PID" > "$PID_FILE"

python3 << PY
import json
from datetime import datetime, timezone
p = "$PROGRESS"
sentinel = $(echo "$META" | jq -c '.sentinel')
with open(p) as f:
    d = json.load(f)
arm = d.setdefault("loop_arm", {})
arm.update({
    "last_armed_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "mode": "dynamic",
    "chain_on_complete": True,
    "sentinel": sentinel,
    "pid": $NEW_PID,
    "next_wake_seconds": $SECONDS_WAIT,
})
d["loop_status"] = "running"
d["loop_sentinel"] = sentinel
with open(p, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

echo "==> arm-dynamic-loop"
echo "    progress: $PROGRESS"
echo "    sentinel: $SENTINEL_JSON"
echo "    chain in: ${SECONDS_WAIT}s (PID $NEW_PID)"
echo "    log: $LOG"
