#!/usr/bin/env bash
# Migrate project artifacts: loop-master → lucy (no data loss)
# Usage: migrate-loop-master-to-lucy.sh [--dry-run] [--project PATH]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"

DRY_RUN=false
PROJECT_ROOT="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    -h|--help)
      cat <<'HELP'
Usage: migrate-loop-master-to-lucy.sh [--dry-run] [--project PATH]

Renames loop-master project artifacts to lucy naming without deleting data.
Creates a timestamped backup under .cursor/lucy-migration-backup-* before changes.

Mappings:
  .cursor/loop-master-progress.json     → .cursor/lucy-progress.json
  .cursor/loop-master-progress.*.json   → .cursor/lucy-progress.*.json
  .cursor/loop-master-brain/            → .cursor/lucy-brain/
  docs/LOOP-MASTER-PLAN.md              → docs/LUCY-PLAN.md
  docs/LOOP-MASTER-INDEX.md             → docs/LUCY-INDEX.md
  .cursor/hooks/loop-master/            → .cursor/hooks/lucy/
  .cursor/skills/loop-master            → .cursor/skills/lucy (symlink retarget)
HELP
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

PROJECT_ROOT="$(lucy_detect_project_root "$PROJECT_ROOT")"
BACKUP_DIR="$PROJECT_ROOT/.cursor/lucy-migration-backup-$(date +%Y%m%d%H%M%S)"

mv_if_exists() {
  local src="$1" dst="$2"
  [[ -e "$src" ]] || return 0
  if [[ -e "$dst" ]]; then
    echo "    skip (target exists): $dst"
    return 0
  fi
  echo "    $src → $dst"
  if $DRY_RUN; then return 0; fi
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$BACKUP_DIR/$(basename "$src").bak" 2>/dev/null || cp -a "$src" "$BACKUP_DIR/"
  mv "$src" "$dst"
}

patch_json_paths() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  echo "    patch JSON: $file"
  $DRY_RUN && return 0
  local tmp
  tmp=$(mktemp)
  sed -e 's|loop-master-progress\.json|lucy-progress.json|g' \
      -e 's|loop-master-brain|lucy-brain|g' \
      -e 's|LOOP-MASTER-PLAN\.md|LUCY-PLAN.md|g' \
      -e 's|LOOP-MASTER-INDEX\.md|LUCY-INDEX.md|g' \
      -e 's|/loop-master|/lucy|g' \
      -e 's|loop-master init|lucy init|g' \
      -e 's|loop-master-tick|lucy-tick|g' \
      -e 's|skills/loop-master|skills/lucy|g' \
      -e 's|hooks/loop-master|hooks/lucy|g' \
      "$file" > "$tmp" && mv "$tmp" "$file"
}

patch_text_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  echo "    patch text: $file"
  $DRY_RUN && return 0
  local tmp
  tmp=$(mktemp)
  sed -e 's|loop-master-progress\.json|lucy-progress.json|g' \
      -e 's|loop-master-brain|lucy-brain|g' \
      -e 's|LOOP-MASTER-PLAN\.md|LUCY-PLAN.md|g' \
      -e 's|LOOP-MASTER-INDEX\.md|LUCY-INDEX.md|g' \
      -e 's|\.cursor/skills/loop-master|.cursor/skills/lucy|g' \
      -e 's|\.cursor/hooks/loop-master|.cursor/hooks/lucy|g' \
      -e 's|Loop Master|Lucy|g' \
      -e 's|loop-master init|lucy init|g' \
      -e 's|/loop-master|/lucy|g' \
      "$file" > "$tmp" && mv "$tmp" "$file"
}

merge_hooks_json() {
  local hooks_json="$PROJECT_ROOT/.cursor/hooks.json"
  [[ -f "$hooks_json" ]] || return 0
  echo "    patch hooks.json"
  $DRY_RUN && return 0
  python3 << PY
import json
from pathlib import Path
p = Path("$hooks_json")
data = json.loads(p.read_text())
hooks = data.get("hooks", {})
for event, entries in list(hooks.items()):
    for e in entries:
        cmd = e.get("command", "")
        if "loop-master" in cmd:
            e["command"] = cmd.replace("loop-master", "lucy")
p.write_text(json.dumps(data, indent=2) + "\n")
PY
}

retarget_skill_symlink() {
  local old="$PROJECT_ROOT/.cursor/skills/loop-master"
  local new="$PROJECT_ROOT/.cursor/skills/lucy"
  [[ -e "$old" ]] || return 0
  if [[ -e "$new" && ! -L "$new" ]]; then
    echo "    WARN: $new exists and is not a symlink — manual merge needed"
    return 0
  fi
  local target
  target=$(readlink -f "$old" 2>/dev/null || echo "")
  [[ -z "$target" && -d "$old" ]] && target="$old"
  echo "    retarget skill symlink: loop-master → lucy"
  if $DRY_RUN; then return 0; fi
  if [[ -n "$target" && ! -e "$new" ]]; then
    ln -sfn "$target" "$new"
  fi
  rm -rf "$old"
  lucy_install_loop_master_alias "$SCRIPT_DIR/.." "$PROJECT_ROOT"
}

echo "==> migrate loop-master → lucy"
echo "    project: $PROJECT_ROOT"
$DRY_RUN && echo "    mode: DRY RUN (no writes)"

if ! lucy_legacy_paths_present "$PROJECT_ROOT"; then
  echo "    No legacy loop-master artifacts found — nothing to migrate."
  exit 0
fi

if ! $DRY_RUN; then
  mkdir -p "$BACKUP_DIR"
  echo "    backup: $BACKUP_DIR"
fi

for f in "$PROJECT_ROOT/.cursor"/loop-master-progress*.json; do
  [[ -e "$f" ]] || continue
  base=$(basename "$f")
  new_name=${base/loop-master-progress/lucy-progress}
  mv_if_exists "$f" "$PROJECT_ROOT/.cursor/$new_name"
done

mv_if_exists "$PROJECT_ROOT/.cursor/loop-master-brain" "$PROJECT_ROOT/.cursor/lucy-brain"
mv_if_exists "$PROJECT_ROOT/docs/LOOP-MASTER-PLAN.md" "$PROJECT_ROOT/docs/LUCY-PLAN.md"
mv_if_exists "$PROJECT_ROOT/docs/LOOP-MASTER-INDEX.md" "$PROJECT_ROOT/docs/LUCY-INDEX.md"
mv_if_exists "$PROJECT_ROOT/.cursor/hooks/loop-master" "$PROJECT_ROOT/.cursor/hooks/lucy"

retarget_skill_symlink
merge_hooks_json

for f in "$PROJECT_ROOT/.cursor"/lucy-progress*.json; do
  [[ -f "$f" ]] && patch_json_paths "$f"
done

patch_text_file "$PROJECT_ROOT/docs/LUCY-PLAN.md"
patch_text_file "$PROJECT_ROOT/docs/LUCY-INDEX.md"
if [[ -f "$PROJECT_ROOT/.cursor/lucy-brain/INDEX.md" ]]; then
  patch_text_file "$PROJECT_ROOT/.cursor/lucy-brain/INDEX.md"
fi
patch_text_file "$PROJECT_ROOT/DESIGN_SYSTEM.md"

echo ""
echo "==> Migration complete."
$DRY_RUN || echo "    Backup: $BACKUP_DIR"
echo "    Next: /lucy update  (or /lucy to continue loop)"
