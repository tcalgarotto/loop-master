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

lucy_legacy_paths_present() {
  local root="$1"
  [[ -f "$root/.cursor/loop-master-progress.json" ]] && return 0
  [[ -d "$root/.cursor/loop-master-brain" ]] && return 0
  [[ -f "$root/docs/LOOP-MASTER-PLAN.md" ]] && return 0
  [[ -f "$root/docs/LOOP-MASTER-INDEX.md" ]] && return 0
  [[ -d "$root/.cursor/hooks/loop-master" ]] && return 0
  [[ -e "$root/.cursor/skills/loop-master" ]] && return 0
  return 1
}

# Install thin /loop-master slash-command alias (separate folder; canonical pack stays at lucy/)
lucy_install_loop_master_alias() {
  local skill_root="$1"
  local project_root="$2"
  local alias_src="$skill_root/alias/loop-master/SKILL.md"
  local alias_dst="$project_root/.cursor/skills/loop-master"
  [[ -f "$alias_src" ]] || return 0
  mkdir -p "$alias_dst"
  cp "$alias_src" "$alias_dst/SKILL.md"
  echo "    Installed /loop-master alias → $alias_dst/SKILL.md"
}
