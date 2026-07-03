#!/usr/bin/env bash
# Install loop-master Cursor hooks into project .cursor/hooks.json (merge, no clobber)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(pwd)"
if [[ -f "$PROJECT_ROOT/Makefile" ]] || [[ -d "$PROJECT_ROOT/.git" ]]; then
  PROJECT_ROOT="$(pwd)"
elif [[ -d "$SKILL_ROOT/../../.." ]]; then
  PROJECT_ROOT="$(cd "$SKILL_ROOT/../../.." && pwd)"
fi

HOOKS_SRC="$SKILL_ROOT/hooks"
HOOKS_DST="$PROJECT_ROOT/.cursor/hooks/loop-master"
HOOKS_JSON="$PROJECT_ROOT/.cursor/hooks.json"
TEMPLATE="$HOOKS_SRC/hooks.template.json"

echo "==> install-hooks (loop-master)"
echo "    project: $PROJECT_ROOT"

mkdir -p "$HOOKS_DST" "$PROJECT_ROOT/.cursor"

for f in brain-hydrate.sh brain-capture.sh; do
  cp "$HOOKS_SRC/$f" "$HOOKS_DST/$f"
  chmod +x "$HOOKS_DST/$f"
  echo "    installed $HOOKS_DST/$f"
done

if ! command -v jq &>/dev/null; then
  echo "    WARN: jq missing — copying template to hooks.json (may overwrite)"
  cp "$TEMPLATE" "$HOOKS_JSON"
  echo "==> done (jq merge skipped)"
  exit 0
fi

if [[ -f "$HOOKS_JSON" ]]; then
  python3 << PY
import json
from pathlib import Path
proj = Path("$HOOKS_JSON")
lm = json.loads(Path("$TEMPLATE").read_text())
existing = json.loads(proj.read_text())
merged = {"version": existing.get("version", 1), "hooks": dict(existing.get("hooks", {}))}
for event, entries in lm.get("hooks", {}).items():
    cur = list(merged["hooks"].get(event, []))
    cmds = {e.get("command") for e in cur}
    for e in entries:
        if e.get("command") not in cmds:
            cur.append(e)
            cmds.add(e.get("command"))
    merged["hooks"][event] = cur
proj.write_text(json.dumps(merged, indent=2) + "\n")
print("    merged into", proj)
PY
else
  cp "$TEMPLATE" "$HOOKS_JSON"
  echo "    created $HOOKS_JSON"
fi

echo "==> hooks installed. Restart Cursor if hooks do not load."
echo "    Verify: Cursor Settings → Hooks"
