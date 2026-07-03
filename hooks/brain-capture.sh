#!/usr/bin/env bash
# loop-master hook — stop: capture session summary into Second Brain
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

status="unknown"
loop_count=0
transcript=""
if command -v jq &>/dev/null; then
  status=$(echo "$input" | jq -r '.status // "unknown"')
  loop_count=$(echo "$input" | jq -r '.loop_count // 0')
  transcript=$(echo "$input" | jq -r '.transcript_path // empty')
fi

summary="Agent turn ended status=${status} loop_count=${loop_count}"
if [[ -n "$transcript" && -f "$transcript" ]]; then
  tail_snip=$(tail -n 30 "$transcript" 2>/dev/null | tr '\n' ' ' | head -c 600)
  [[ -n "$tail_snip" ]] && summary="${summary}. tail: ${tail_snip}"
fi

cd "$PROJECT_ROOT"
"$BRAIN_SYNC" capture --kind chat --summary "$summary" >/dev/null 2>&1 || true

# No followup_message — capture only, do not re-trigger agent
exit 0
