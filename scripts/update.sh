#!/usr/bin/env bash
# Lucy — update skill pack preserving project context
# Usage: ./scripts/update.sh [--restart-loop] [--skills a,b,c]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(lucy_detect_project_root "$(pwd)")"

PROGRESS="$(lucy_progress_file "$PROJECT_ROOT")"
RESTART_LOOP=false
SKILLS_CSV=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --restart-loop) RESTART_LOOP=true; shift ;;
    --skills) SKILLS_CSV="$2"; shift 2 ;;
    --progress-file) PROGRESS="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: update.sh [--restart-loop] [--skills a,b,c] [--progress-file path]"
      exit 0
      ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

echo "==> lucy update (preserve context)"
echo "    Project: $PROJECT_ROOT"
echo "    Skill pack: $SKILL_ROOT"

[[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"

# Migrate legacy loop-master artifacts before update (no data loss)
if lucy_legacy_paths_present "$PROJECT_ROOT"; then
  echo "    Legacy loop-master paths detected — running migration..."
  bash "$SCRIPT_DIR/migrate-loop-master-to-lucy.sh" --project "$PROJECT_ROOT"
  PROGRESS="$(lucy_progress_file "$PROJECT_ROOT")"
  [[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"
fi

# 1. Backup progress JSON
if [[ -f "$PROGRESS" ]]; then
  BAK="$PROJECT_ROOT/.cursor/lucy-progress.json.bak.$(date +%Y%m%d%H%M%S)"
  cp "$PROGRESS" "$BAK"
  echo "    Backed up progress → $BAK"
else
  echo "    WARN: No progress JSON — run init first"
fi

# 2. Git pull skill pack
OLD_VER=""
if [[ -f "$SKILL_ROOT/SKILL.md" ]]; then
  OLD_VER=$(grep -E '^version:' "$SKILL_ROOT/SKILL.md" | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "?")
fi

if [[ -d "$SKILL_ROOT/.git" ]]; then
  echo "    git pull in $SKILL_ROOT"
  BEFORE_HEAD=$(cd "$SKILL_ROOT" && git rev-parse HEAD 2>/dev/null || echo "")
  (cd "$SKILL_ROOT" && git pull --ff-only) || {
    echo "    WARN: git pull failed — continuing with local files"
  }
  AFTER_HEAD=$(cd "$SKILL_ROOT" && git rev-parse HEAD 2>/dev/null || echo "")
  if [[ -n "$BEFORE_HEAD" && "$BEFORE_HEAD" == "$AFTER_HEAD" ]]; then
    echo "    git: already up to date (no new commits)"
  fi
elif [[ -f "$PROJECT_ROOT/.gitmodules" ]] && grep -qE 'loop-master|skills/lucy' "$PROJECT_ROOT/.gitmodules" 2>/dev/null; then
  echo "    git submodule update --remote"
  (cd "$PROJECT_ROOT" && git submodule update --remote --merge .agents/skills/lucy 2>/dev/null) || true
else
  echo "    NOTE: skill pack not a git repo — manual copy required for updates"
fi

NEW_VER=$(grep -E '^version:' "$SKILL_ROOT/SKILL.md" | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "?")
echo "    Skill pack: $OLD_VER → $NEW_VER"

# 3. Re-run init preserving context (incremental — skip installed deps)
INIT_ARGS=(--preserve-context --update-mode --progress-file "$PROGRESS")
echo "    Init mode: incremental (install only missing deps)"
if [[ -n "$SKILLS_CSV" ]]; then
  INIT_ARGS+=(--skills "$SKILLS_CSV")
elif [[ -f "$PROGRESS" ]] && command -v jq &>/dev/null; then
  INSTALLED=$(jq -r '.skills_installed | join(",")' "$PROGRESS" 2>/dev/null || echo "")
  if [[ -n "$INSTALLED" && "$INSTALLED" != "null" ]]; then
    INIT_ARGS+=(--skills "$INSTALLED")
  fi
fi

bash "$SCRIPT_DIR/init.sh" "${INIT_ARGS[@]}"

# Remove legacy skill duplicates (/loop-master alias, lucy-pack)
lucy_cleanup_skill_duplicates "$PROJECT_ROOT/.cursor/skills"
lucy_cleanup_skill_duplicates "$HOME/.cursor/skills"

# 4. Patch version into JSON
if [[ -f "$PROGRESS" ]] && command -v jq &>/dev/null; then
  tmp=$(mktemp)
  jq --arg v "$NEW_VER" --arg t "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '.skill_pack_version = $v | .skill_pack_updated_at = $t' "$PROGRESS" > "$tmp" && mv "$tmp" "$PROGRESS"
  echo "    Updated skill_pack_version in progress JSON"
fi

if $RESTART_LOOP; then
  echo "    --restart-loop: re-arm /loop in Cursor with next_prompt from JSON"
fi

echo ""
echo "==> Update complete. Context preserved."
echo "    Brain + rules/ (.cursor/lucy-brain/) untouched by update."
echo "    Run /lucy to continue, or read next_prompt in progress JSON."
echo ""
