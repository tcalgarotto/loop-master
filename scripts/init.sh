#!/usr/bin/env bash
# loop-master v2 — project bootstrap installer
# Usage: ./scripts/init.sh [--skills impeccable,ui-ux-pro-max] [--skip-skills]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$SKILL_ROOT/../../.." 2>/dev/null && pwd || pwd)"

# If run from ~/.cursor/skills/loop-master, project root is cwd
if [[ -f "$(pwd)/package.json" ]] || [[ -f "$(pwd)/Makefile" ]] || [[ -d "$(pwd)/.git" ]]; then
  PROJECT_ROOT="$(pwd)"
fi

SKILLS_CSV=""
SKIP_SKILLS=false
PRESERVE_CONTEXT=false
GOAL=""
PLAN_DOC=""
PROGRESS_FILE="${LOOP_MASTER_PROGRESS_FILE:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills) SKILLS_CSV="$2"; shift 2 ;;
    --skip-skills) SKIP_SKILLS=true; shift ;;
    --preserve-context|--update-mode) PRESERVE_CONTEXT=true; shift ;;
    --goal) GOAL="$2"; shift 2 ;;
    --plan) PLAN_DOC="$2"; shift 2 ;;
    --progress-file) PROGRESS_FILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: init.sh [--skills a,b,c] [--skip-skills] [--goal \"...\"] [--plan docs/PLAN.md] [--progress-file path]"
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

echo "==> loop-master init"
echo "    Project: $PROJECT_ROOT"
echo "    Skill pack: $SKILL_ROOT"

mkdir -p "$PROJECT_ROOT/.cursor"
mkdir -p "$PROJECT_ROOT/docs"

# Link or copy loop-master into project .cursor/skills if not already there
if [[ "$SKILL_ROOT" != *"/.cursor/skills/loop-master"* ]] && [[ "$SKILL_ROOT" != *"/.agents/skills/loop-master"* ]]; then
  mkdir -p "$PROJECT_ROOT/.cursor/skills"
  if [[ ! -e "$PROJECT_ROOT/.cursor/skills/loop-master" ]]; then
    ln -sf "$SKILL_ROOT" "$PROJECT_ROOT/.cursor/skills/loop-master" 2>/dev/null || \
      cp -r "$SKILL_ROOT" "$PROJECT_ROOT/.cursor/skills/loop-master"
    echo "    Linked loop-master → .cursor/skills/loop-master"
  fi
fi

# Optional skills
install_skill() {
  local name="$1"
  if $SKIP_SKILLS; then return 0; fi
  case "$name" in
    impeccable)
      if [[ ! -f "$PROJECT_ROOT/.cursor/skills/impeccable/SKILL.md" ]]; then
        echo "    Installing impeccable..."
        (cd "$PROJECT_ROOT" && npx --yes impeccable install --providers=cursor --scope=project 2>/dev/null) || \
          echo "    WARN: impeccable install failed — run manually: npx impeccable install"
      fi
      ;;
    ui-ux-pro-max)
      if [[ ! -f "$PROJECT_ROOT/.cursor/skills/ui-ux-pro-max/SKILL.md" ]]; then
        echo "    Installing ui-ux-pro-max..."
        (cd "$PROJECT_ROOT" && npx --yes ui-ux-pro-max-cli init --ai cursor 2>/dev/null) || \
          echo "    WARN: uipro init failed — run: npx ui-ux-pro-max-cli init --ai cursor"
      fi
      ;;
    taste-skill)
      if ! command -v npx &>/dev/null; then return 0; fi
      echo "    Installing taste-skill (design-taste-frontend)..."
      npx --yes skills add https://github.com/Leonxlnx/taste-skill --skill "design-taste-frontend" 2>/dev/null || \
        echo "    WARN: taste-skill install failed"
      ;;
    caveman)
      echo "    Installing caveman (cursor)..."
      curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh 2>/dev/null | bash -s -- --only cursor 2>/dev/null || \
        echo "    WARN: caveman install failed"
      ;;
    claude-mem)
      echo "    Installing claude-mem..."
      (cd "$PROJECT_ROOT" && npx --yes claude-mem install 2>/dev/null) || \
        echo "    WARN: claude-mem install failed"
      ;;
    motion)
      if [[ -f "$PROJECT_ROOT/frontend/package.json" ]]; then
        echo "    Adding motion to frontend..."
        (cd "$PROJECT_ROOT/frontend" && npm install motion 2>/dev/null) || true
      fi
      ;;
  esac
}

if [[ -n "$SKILLS_CSV" ]]; then
  IFS=',' read -ra SKILL_ARR <<< "$SKILLS_CSV"
  for s in "${SKILL_ARR[@]}"; do install_skill "$(echo "$s" | tr -d ' ')"; done
else
  install_skill impeccable
  install_skill ui-ux-pro-max
fi

# Progress JSON stub if missing (skip create when preserving context on update)
PROGRESS="${PROGRESS_FILE:-$PROJECT_ROOT/.cursor/loop-master-progress.json}"
# Relative progress paths → under project root
[[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"
if [[ ! -f "$PROGRESS" ]] && ! $PRESERVE_CONTEXT; then
  SENTINEL="AGENT_LOOP_TICK_$(basename "$PROJECT_ROOT" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9_')_$(date +%s | tail -c 5)"
  TARGET="${GOAL:-Define goal via /loop-master init in Cursor}"
  PLAN="${PLAN_DOC:-docs/LOOP-MASTER-PLAN.md}"
  rel_pf="${PROGRESS#$PROJECT_ROOT/}"
  cat > "$PROGRESS" <<EOF
{
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tick_count": 0,
  "overall_pct": 0,
  "skill_pack_version": "2.3.0",
  "progress_file": "$rel_pf",
  "skills_installed": [],
  "current_phase": "phase-1",
  "target": "$TARGET",
  "plan_doc": "$PLAN",
  "loop_sentinel": "$SENTINEL",
  "loop_interval_seconds": 240,
  "loop_status": "pending_arm",
  "quiz_answers": {},
  "delivery_contract": {
    "status": "in_progress",
    "target_pct": 100,
    "acceptance_summary": "$TARGET",
    "phases_required": ["phase-1"],
    "completed_phases": [],
    "blocked_on_human": false
  },
  "phases": {
    "phase-1": {
      "name": "First phase — define in LOOP-MASTER-PLAN.md",
      "status": "in_progress",
      "pct": 0,
      "acceptance_criteria": ["Complete via /loop-master init quiz"]
    }
  },
  "minor_cycle": {
    "phase_id": "phase-1",
    "step": "discover",
    "iteration": 1,
    "gate": "pending",
    "tasks": []
  },
  "last_iteration": { "agent_summary": "Init script created JSON stub. Run /loop-master init in Cursor for quiz + phases." },
  "next_actions": ["Run /loop-master init in Cursor Agent", "Complete quiz (AskQuestion)", "Define phases in docs/LOOP-MASTER-PLAN.md"],
  "context_files": ["docs/LOOP-MASTER-PLAN.md"],
  "human_blockers": []
}
EOF
  echo "    Created $PROGRESS"
elif $PRESERVE_CONTEXT && [[ -f "$PROGRESS" ]]; then
  echo "    Preserving existing progress JSON (update/preserve mode)"
fi

# LOOP-MASTER-PLAN stub (only if missing)
PLAN_PATH="$PROJECT_ROOT/docs/LOOP-MASTER-PLAN.md"
if [[ ! -f "$PLAN_PATH" ]] && ! $PRESERVE_CONTEXT; then
  cat > "$PLAN_PATH" <<'EOF'
# Loop Master Plan

> Gerado por `loop-master init`. Edite fases e critérios de aceite.

## North star

_Definir via quiz `/loop-master init`._

## Fases

| ID | Nome | % | Status | Critérios de aceite |
|----|------|---|--------|---------------------|
| phase-1 | Primeira entrega | 0 | in_progress | A definir |

## Gates

- Cada fase: 100% + audit sem critical/high abertos
- Entrega final: `overall_pct === 100` + `delivery_contract.complete`

## Skills design (se FE)

- ui-ux-pro-max → design-system/MASTER.md
- impeccable → shape → craft → critique → polish
- motion → animate step only
EOF
  echo "    Created $PLAN_PATH"
fi

# PRODUCT.md stub (only on fresh init)
if ! $PRESERVE_CONTEXT && [[ ! -f "$PROJECT_ROOT/PRODUCT.md" ]] && [[ -d "$PROJECT_ROOT/frontend" || -d "$PROJECT_ROOT/src" ]]; then
  cat > "$PROJECT_ROOT/PRODUCT.md" <<'EOF'
# Product

- **Audience:** End users of this application (define in /loop-master init quiz)
- **Register:** Product UI — restrained, professional
- **Voice:** Clear, operational (match your locale)
EOF
  echo "    Created PRODUCT.md stub"
fi

# Scan and record installed skills in JSON
scan_skills() {
  local json='[]'
  local paths=(
    "impeccable:.cursor/skills/impeccable/SKILL.md"
    "ui-ux-pro-max:.cursor/skills/ui-ux-pro-max/SKILL.md"
    "taste-skill:.cursor/skills/design-taste-frontend/SKILL.md"
    "taste-skill:.agents/skills/design-taste-frontend/SKILL.md"
    "caveman:.cursor/skills/caveman/SKILL.md"
    "caveman:.agents/skills/caveman/SKILL.md"
    "claude-mem:.cursor/plugins/claude-mem"
    "claude-mem:/root/.claude/plugins/marketplaces/thedotmack"
  )
  local seen=()
  for entry in "${paths[@]}"; do
    local name="${entry%%:*}"
    local path="${entry#*:}"
    [[ " ${seen[*]} " == *" $name "* ]] && continue
    if [[ "$path" == /* ]]; then
      [[ -f "$path/SKILL.md" || -d "$path" ]] && { json=$(echo "$json" | jq -c ". + [\"$name\"]" 2>/dev/null || echo "$json"); seen+=("$name"); }
    elif [[ -f "$PROJECT_ROOT/$path" || -d "$PROJECT_ROOT/$path" ]]; then
      json=$(echo "$json" | jq -c ". + [\"$name\"]" 2>/dev/null || echo "$json")
      seen+=("$name")
    fi
  done
  if [[ -f "$PROJECT_ROOT/frontend/package.json" ]] && grep -q '"motion"' "$PROJECT_ROOT/frontend/package.json" 2>/dev/null; then
    json=$(echo "$json" | jq -c '. + ["motion"]' 2>/dev/null || echo "$json")
  fi
  echo "$json"
}

if command -v jq &>/dev/null && [[ -f "$PROGRESS" ]]; then
  SKILLS_JSON=$(scan_skills)
  PACK_VER=$(grep -E '^version:' "$SKILL_ROOT/SKILL.md" | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "2.3.0")
  tmp=$(mktemp)
  rel_progress="${PROGRESS#$PROJECT_ROOT/}"
  jq --argjson sk "$SKILLS_JSON" --arg v "$PACK_VER" --arg pf "$rel_progress" \
    '.skills_installed = $sk | .skill_pack_version = $v | .skills_inventory = $sk | .progress_file = $pf' "$PROGRESS" > "$tmp" && mv "$tmp" "$PROGRESS"
  echo "    skills_installed: $SKILLS_JSON"
  echo "    progress_file: $rel_progress"
fi

# Symlinks for optional skills under .cursor/skills/
if [[ -x "$SCRIPT_DIR/link-ecosystem-skills.sh" ]]; then
  bash "$SCRIPT_DIR/link-ecosystem-skills.sh" || true
fi

echo ""
echo "==> Done. Next steps in Cursor:"
echo "    1. /loop-master init   (quiz + arm loop)"
echo "    2. Enable Agent Skills in Cursor Settings"
echo "    3. Optional skills: --skills taste-skill,caveman,claude-mem,motion"
echo "    4. Security: add scripts/security/ in your project OR use security-review subagent"
echo ""
