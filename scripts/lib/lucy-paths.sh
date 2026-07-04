#!/usr/bin/env bash
# Lucy — canonical paths (v2.8+). Legacy loop-master names resolve via fallbacks.
# Source from other scripts: source "$(dirname "$0")/lib/lucy-paths.sh"

lucy_detect_project_root() {
  local hint="${1:-$(pwd)}"
  if [[ -f "$hint/package.json" || -f "$hint/Makefile" || -d "$hint/.git" ]]; then
    echo "$hint"
    return 0
  fi
  local script_dir="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  script_dir="$(cd "$(dirname "$script_dir")" && pwd)"
  if [[ "$script_dir" == */scripts ]]; then
    echo "$(cd "$script_dir/../.." && pwd)"
    return 0
  fi
  echo "$hint"
}

lucy_progress_file() {
  local root="$1"
  local override="${LUCY_PROGRESS_FILE:-${LOOP_MASTER_PROGRESS_FILE:-}}"
  if [[ -n "$override" ]]; then
    [[ "$override" == /* ]] && echo "$override" || echo "$root/$override"
    return 0
  fi
  if [[ -f "$root/.cursor/lucy-progress.json" ]]; then
    echo "$root/.cursor/lucy-progress.json"
  elif [[ -f "$root/.cursor/loop-master-progress.json" ]]; then
    echo "$root/.cursor/loop-master-progress.json"
  else
    echo "$root/.cursor/lucy-progress.json"
  fi
}

lucy_brain_dir() {
  local root="$1"
  if [[ -d "$root/.cursor/lucy-brain" ]]; then
    echo "$root/.cursor/lucy-brain"
  elif [[ -d "$root/.cursor/loop-master-brain" ]]; then
    echo "$root/.cursor/loop-master-brain"
  else
    echo "$root/.cursor/lucy-brain"
  fi
}

lucy_plan_doc() {
  local root="$1"
  if [[ -f "$root/docs/LUCY-PLAN.md" ]]; then
    echo "$root/docs/LUCY-PLAN.md"
  elif [[ -f "$root/docs/LOOP-MASTER-PLAN.md" ]]; then
    echo "$root/docs/LOOP-MASTER-PLAN.md"
  else
    echo "$root/docs/LUCY-PLAN.md"
  fi
}

lucy_index_doc() {
  local root="$1"
  if [[ -f "$root/docs/LUCY-INDEX.md" ]]; then
    echo "$root/docs/LUCY-INDEX.md"
  elif [[ -f "$root/docs/LOOP-MASTER-INDEX.md" ]]; then
    echo "$root/docs/LOOP-MASTER-INDEX.md"
  else
    echo "$root/docs/LUCY-INDEX.md"
  fi
}

lucy_find_brain_sync() {
  local root="$1"
  local p
  for p in \
    "$root/.cursor/skills/lucy/scripts/brain-sync.sh" \
    "$root/.agents/skills/lucy/scripts/brain-sync.sh" \
    "$root/.cursor/skills/loop-master/scripts/brain-sync.sh" \
    "$root/.agents/skills/loop-master/scripts/brain-sync.sh"; do
    [[ -x "$p" ]] && { echo "$p"; return 0; }
  done
  return 1
}

lucy_find_init_script() {
  local root="$1"
  local p
  for p in \
    "$root/.cursor/skills/lucy/scripts/init.sh" \
    "$root/.agents/skills/lucy/scripts/init.sh" \
    "$root/.cursor/skills/loop-master/scripts/init.sh" \
    "$root/.agents/skills/loop-master/scripts/init.sh"; do
    [[ -x "$p" ]] && { echo "$p"; return 0; }
  done
  return 1
}

lucy_cursor_project_id() {
  local root="$1"
  echo "${root#/}" | tr '/' '-'
}

lucy_cursor_mcps_dir() {
  local root="$1"
  echo "${HOME}/.cursor/projects/$(lucy_cursor_project_id "$root")/mcps"
}

lucy_legacy_paths_present() {
  local root="$1"
  [[ -f "$root/.cursor/loop-master-progress.json" ]] && return 0
  [[ -d "$root/.cursor/loop-master-brain" ]] && return 0
  [[ -f "$root/docs/LOOP-MASTER-PLAN.md" ]] && return 0
  [[ -f "$root/docs/LOOP-MASTER-INDEX.md" ]] && return 0
  [[ -d "$root/.cursor/hooks/loop-master" ]] && return 0
  # Full legacy skill pack only (not thin alias folder)
  if [[ -L "$root/.cursor/skills/loop-master" ]]; then return 0; fi
  if [[ -d "$root/.cursor/skills/loop-master/scripts" ]]; then return 0; fi
  return 1
}

# Remove duplicate / legacy skill entries (loop-master alias, lucy-pack folder)
lucy_cleanup_skill_duplicates() {
  local skills_dir="${1:-}"
  [[ -n "$skills_dir" && -d "$skills_dir" ]] || return 0

  local lm="$skills_dir/loop-master"
  if [[ -d "$lm" && ! -L "$lm" && ! -d "$lm/scripts" && -f "$lm/SKILL.md" ]]; then
    local count
    count=$(find "$lm" -mindepth 1 -maxdepth 1 | wc -l)
    if [[ "$count" -le 2 ]]; then
      rm -rf "$lm"
      echo "    Removed legacy /loop-master alias skill"
    fi
  fi

  local pack="$skills_dir/lucy-pack"
  local lucy="$skills_dir/lucy"
  if [[ -d "$pack" ]]; then
    if [[ -L "$lucy" ]]; then
      rm -f "$lucy"
      if [[ ! -e "$lucy" ]]; then
        mv "$pack" "$lucy"
        echo "    Normalized lucy-pack → lucy (single skill install)"
      fi
    elif [[ ! -e "$lucy" ]]; then
      mv "$pack" "$lucy"
      echo "    Renamed lucy-pack → lucy"
    else
      rm -rf "$pack"
      echo "    Removed duplicate lucy-pack folder"
    fi
  fi
}
