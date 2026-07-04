#!/usr/bin/env bash
# Seed cursor-ide-browser tool descriptors when Cursor has not materialized tools/ yet.
# Does NOT enable the MCP runtime — owner still toggles Browser in Settings → Tools & MCPs.
# Usage: cursor-browser-seed-tools.sh [--project PATH] [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"

PROJECT_ROOT="$(lucy_detect_project_root "$(pwd)")"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$(lucy_detect_project_root "${2:-$(pwd)}")"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) shift ;;
  esac
done

TARGET_DIR="$(lucy_cursor_mcps_dir "$PROJECT_ROOT")/cursor-ide-browser/tools"
SOURCE_CANDIDATES=()

for d in "$HOME/.cursor/projects"/*/mcps/cursor-ide-browser/tools; do
  [[ -d "$d" ]] || continue
  count=$(find "$d" -maxdepth 1 -name 'browser_*.json' 2>/dev/null | wc -l | tr -d ' ')
  [[ "${count:-0}" -ge 10 ]] || continue
  [[ "$(readlink -f "$d" 2>/dev/null || echo "$d")" == "$(readlink -f "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")" ]] && continue
  SOURCE_CANDIDATES+=("$d")
done

if [[ -f "$TARGET_DIR/browser_navigate.json" ]]; then
  echo "OK: cursor-ide-browser tools already present ($TARGET_DIR)"
  exit 0
fi

if [[ ${#SOURCE_CANDIDATES[@]} -eq 0 ]]; then
  echo "SKIP: no source project with cursor-ide-browser tools to seed from"
  echo "Owner: enable Browser in Cursor → Settings → Tools & MCPs → Reload Window"
  exit 1
fi

SOURCE="${SOURCE_CANDIDATES[0]}"
echo "Seed cursor-ide-browser tools"
echo "  from: $SOURCE"
echo "  to:   $TARGET_DIR"

if [[ "$DRY_RUN" == true ]]; then
  echo "(dry-run — no copy)"
  exit 0
fi

mkdir -p "$(dirname "$TARGET_DIR")"
cp -a "$SOURCE" "$(dirname "$TARGET_DIR")/"
count=$(find "$TARGET_DIR" -maxdepth 1 -name 'browser_*.json' 2>/dev/null | wc -l | tr -d ' ')
echo "OK: seeded $count browser tool descriptors"
echo "Next: Cursor → Settings → Tools & MCPs → Browser ON → Reload Window"
