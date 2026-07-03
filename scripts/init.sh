#!/usr/bin/env bash
# loop-master v2.4 — full project bootstrap (zero-config default)
# Usage: ./scripts/init.sh [--skip-skills] [--skills a,b,c] [--preserve-context]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$SKILL_ROOT/../../.." 2>/dev/null && pwd || pwd)"

if [[ -f "$(pwd)/package.json" ]] || [[ -f "$(pwd)/Makefile" ]] || [[ -d "$(pwd)/.git" ]]; then
  PROJECT_ROOT="$(pwd)"
fi

# Full ecosystem — installed by default unless --skip-skills or custom --skills
DEFAULT_SKILLS="impeccable,ui-ux-pro-max,taste-skill,caveman,claude-mem,motion"
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
    --full) shift ;; # legacy alias — full is now default
    --preserve-context|--update-mode) PRESERVE_CONTEXT=true; shift ;;
    --goal) GOAL="$2"; shift 2 ;;
    --plan) PLAN_DOC="$2"; shift 2 ;;
    --progress-file) PROGRESS_FILE="$2"; shift 2 ;;
    -h|--help)
      cat <<'HELP'
Usage: init.sh [options]

Default (zero-config): install full skill ecosystem + claude-mem + symlinks + INDEX stub.

Options:
  --skills a,b,c     Install only listed skills (overrides default full set)
  --skip-skills      Skip all optional skill installs
  --preserve-context Keep existing progress JSON (used by update.sh)
  --goal "..."       Pre-fill north-star goal
  --plan path        Pre-fill plan_doc path
  --progress-file    Custom progress JSON path
HELP
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

echo "==> loop-master init (v2.4 full bootstrap)"
echo "    Project: $PROJECT_ROOT"
echo "    Skill pack: $SKILL_ROOT"

mkdir -p "$PROJECT_ROOT/.cursor"
mkdir -p "$PROJECT_ROOT/docs"

# Link loop-master into project .cursor/skills if running from global clone
if [[ "$SKILL_ROOT" != *"/.cursor/skills/loop-master"* ]] && [[ "$SKILL_ROOT" != *"/.agents/skills/loop-master"* ]]; then
  mkdir -p "$PROJECT_ROOT/.cursor/skills"
  if [[ ! -e "$PROJECT_ROOT/.cursor/skills/loop-master" ]]; then
    ln -sf "$SKILL_ROOT" "$PROJECT_ROOT/.cursor/skills/loop-master" 2>/dev/null || \
      cp -r "$SKILL_ROOT" "$PROJECT_ROOT/.cursor/skills/loop-master"
    echo "    Linked loop-master → .cursor/skills/loop-master"
  fi
elif [[ -d "$PROJECT_ROOT/.agents/skills/loop-master" ]] && [[ ! -e "$PROJECT_ROOT/.cursor/skills/loop-master" ]]; then
  mkdir -p "$PROJECT_ROOT/.cursor/skills"
  ln -sfn ../../.agents/skills/loop-master "$PROJECT_ROOT/.cursor/skills/loop-master" 2>/dev/null || true
  echo "    Linked .agents/skills/loop-master → .cursor/skills/loop-master"
fi

install_skill() {
  local name="$1"
  if $SKIP_SKILLS; then return 0; fi
  case "$name" in
    impeccable)
      if [[ ! -f "$PROJECT_ROOT/.cursor/skills/impeccable/SKILL.md" ]]; then
        echo "    Installing impeccable..."
        (cd "$PROJECT_ROOT" && npx --yes impeccable install --providers=cursor --scope=project 2>/dev/null) || \
          echo "    WARN: impeccable install failed — run: npx impeccable install"
      else
        echo "    ok impeccable"
      fi
      ;;
    ui-ux-pro-max)
      if [[ ! -f "$PROJECT_ROOT/.cursor/skills/ui-ux-pro-max/SKILL.md" ]]; then
        echo "    Installing ui-ux-pro-max..."
        (cd "$PROJECT_ROOT" && npx --yes ui-ux-pro-max-cli init --ai cursor 2>/dev/null) || \
          echo "    WARN: uipro init failed — run: npx ui-ux-pro-max-cli init --ai cursor"
      else
        echo "    ok ui-ux-pro-max"
      fi
      ;;
    taste-skill)
      if [[ ! -f "$PROJECT_ROOT/.cursor/skills/design-taste-frontend/SKILL.md" ]] && \
         [[ ! -f "$PROJECT_ROOT/.agents/skills/design-taste-frontend/SKILL.md" ]]; then
        echo "    Installing taste-skill (design-taste-frontend)..."
        (cd "$PROJECT_ROOT" && npx --yes skills add https://github.com/Leonxlnx/taste-skill --skill "design-taste-frontend" 2>/dev/null) || \
          echo "    WARN: taste-skill install failed"
      else
        echo "    ok taste-skill"
      fi
      ;;
    caveman)
      if [[ ! -f "$PROJECT_ROOT/.cursor/skills/caveman/SKILL.md" ]] && \
         [[ ! -f "$PROJECT_ROOT/.agents/skills/caveman/SKILL.md" ]]; then
        echo "    Installing caveman..."
        curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh 2>/dev/null | bash -s -- --only cursor 2>/dev/null || \
          echo "    WARN: caveman install failed"
      else
        echo "    ok caveman"
      fi
      ;;
    claude-mem)
      echo "    Installing claude-mem..."
      (cd "$PROJECT_ROOT" && npx --yes claude-mem install 2>/dev/null) || \
        echo "    WARN: claude-mem install failed — run: npx claude-mem install"
      if command -v npx &>/dev/null; then
        echo "    Starting claude-mem worker..."
        (cd "$PROJECT_ROOT" && npx --yes claude-mem start 2>/dev/null) || \
          echo "    WARN: claude-mem start failed — run: npx claude-mem start"
      fi
      ;;
    motion)
      if [[ -f "$PROJECT_ROOT/frontend/package.json" ]]; then
        if ! grep -q '"motion"' "$PROJECT_ROOT/frontend/package.json" 2>/dev/null; then
          echo "    Adding motion to frontend..."
          (cd "$PROJECT_ROOT/frontend" && npm install motion 2>/dev/null) || true
        else
          echo "    ok motion (frontend)"
        fi
      elif [[ -f "$PROJECT_ROOT/package.json" ]]; then
        if ! grep -q '"motion"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
          echo "    Adding motion to project..."
          (cd "$PROJECT_ROOT" && npm install motion 2>/dev/null) || true
        else
          echo "    ok motion"
        fi
      else
        echo "    skip motion (no package.json)"
      fi
      ;;
  esac
}

if [[ -n "$SKILLS_CSV" ]]; then
  IFS=',' read -ra SKILL_ARR <<< "$SKILLS_CSV"
  for s in "${SKILL_ARR[@]}"; do install_skill "$(echo "$s" | tr -d ' ')"; done
else
  IFS=',' read -ra SKILL_ARR <<< "$DEFAULT_SKILLS"
  for s in "${SKILL_ARR[@]}"; do install_skill "$s"; done
fi

# Symlinks for ecosystem skills
if [[ -x "$SCRIPT_DIR/link-ecosystem-skills.sh" ]]; then
  bash "$SCRIPT_DIR/link-ecosystem-skills.sh" || true
fi

# Second Brain (L0) — local memory directory
if [[ -x "$SCRIPT_DIR/brain-sync.sh" ]]; then
  bash "$SCRIPT_DIR/brain-sync.sh" init || true
fi

PROGRESS="${PROGRESS_FILE:-$PROJECT_ROOT/.cursor/loop-master-progress.json}"
[[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"
INDEX_DOC="$PROJECT_ROOT/docs/LOOP-MASTER-INDEX.md"

if [[ ! -f "$PROGRESS" ]] && ! $PRESERVE_CONTEXT; then
  SENTINEL="AGENT_LOOP_TICK_$(basename "$PROJECT_ROOT" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9_')_$(date +%s | tail -c 5)"
  TARGET="${GOAL:-Define goal via /loop-master init quiz (Round 1)}"
  PLAN="${PLAN_DOC:-docs/LOOP-MASTER-PLAN.md}"
  rel_pf="${PROGRESS#$PROJECT_ROOT/}"
  cat > "$PROGRESS" <<EOF
{
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tick_count": 0,
  "overall_pct": 0,
  "skill_pack_version": "2.4.0",
  "progress_file": "$rel_pf",
  "index_doc": "docs/LOOP-MASTER-INDEX.md",
  "brain_dir": ".cursor/loop-master-brain",
  "brain_sync": { "last_capture_at": null, "interaction_count": 0, "consciousness_level": 0 },
  "skills_installed": [],
  "quiz_round": 0,
  "quiz_complete": false,
  "memory_sync": { "claude_mem": "pending", "last_sync_at": null },
  "current_phase": "phase-1",
  "target": "$TARGET",
  "plan_doc": "$PLAN",
  "loop_sentinel": "$SENTINEL",
  "loop_interval_seconds": 45,
  "loop_status": "pending_arm",
  "loop_arm": { "mode": "dynamic", "chain_on_complete": true, "next_wake_seconds": 45 },
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
      "name": "First phase — define in quiz Round 6 + LOOP-MASTER-PLAN.md",
      "status": "pending",
      "pct": 0,
      "acceptance_criteria": ["Complete /loop-master init quiz (6 rounds)"]
    }
  },
  "minor_cycle": {
    "phase_id": "phase-1",
    "step": "discover",
    "iteration": 1,
    "gate": "pending",
    "tasks": []
  },
  "last_iteration": { "agent_summary": "Full bootstrap ran. Awaiting /loop-master init quiz (6 rounds)." },
  "next_actions": ["Complete quiz Round 1 (produto)", "Run verify-pack.sh", "Arm dynamic loop after quiz"],
  "context_files": ["docs/LOOP-MASTER-PLAN.md", "docs/LOOP-MASTER-INDEX.md", ".cursor/loop-master-brain/INDEX.md"],
  "human_blockers": [],
  "archive_summaries": []
}
EOF
  echo "    Created $PROGRESS"
elif $PRESERVE_CONTEXT && [[ -f "$PROGRESS" ]]; then
  echo "    Preserving existing progress JSON (update/preserve mode)"
fi

PLAN_PATH="$PROJECT_ROOT/docs/LOOP-MASTER-PLAN.md"
if [[ ! -f "$PLAN_PATH" ]] && ! $PRESERVE_CONTEXT; then
  cat > "$PLAN_PATH" <<'EOF'
# Loop Master Plan

> Gerado por `loop-master init`. Fases definidas após quiz (Round 6).

## North star

_Definir via quiz Round 1._

## Fases

| ID | Nome | % | Status | Critérios |
|----|------|---|--------|-----------|
| phase-1 | Primeira entrega | 0 | ⏳ Pendente | A definir no quiz |

## Gates

- Cada fase: 100% + audit sem critical/high abertos
- Entrega final: `overall_pct === 100` + `delivery_contract.complete`

## Design pipeline

ui-ux-pro-max → impeccable shape/craft → taste (marketing) → motion → critique → polish
EOF
  echo "    Created $PLAN_PATH"
fi

if [[ ! -f "$INDEX_DOC" ]] && ! $PRESERVE_CONTEXT; then
  cat > "$INDEX_DOC" <<'EOF'
# Loop Master Index

Legenda: ✅ OK | ⏳ Pendente | 🔮 Futuro | 👤 Human

| Artefato | Status | Path | Notas |
|----------|--------|------|-------|
| Progress JSON | ⏳ | `.cursor/loop-master-progress.json` | Handoff L1 entre ticks |
| Master Plan | ⏳ | `docs/LOOP-MASTER-PLAN.md` | Fases e gates |
| Product brief | 🔮 | `PRODUCT.md` | Se escopo FE |
| Design brief | 🔮 | `DESIGN.md` | Se design_surface ≠ none |
| claude-mem | ⏳ | worker + MCP | Memória L2 cross-session |
| Skills ecosystem | ⏳ | `.cursor/skills/` | Scan a cada tick |
| Dynamic loop | 🔮 | `arm-dynamic-loop.sh` | Após quiz + tick 1 |

> Atualizar status a cada tick. Orchestrator mantém este índice sincronizado.
EOF
  echo "    Created $INDEX_DOC"
fi

if ! $PRESERVE_CONTEXT && [[ ! -f "$PROJECT_ROOT/PRODUCT.md" ]] && [[ -d "$PROJECT_ROOT/frontend" || -d "$PROJECT_ROOT/src" ]]; then
  cat > "$PROJECT_ROOT/PRODUCT.md" <<'EOF'
# Product

- **Audience:** End users (define in quiz Round 1)
- **Register:** Product UI — restrained, professional
- **Voice:** Clear, operational
EOF
  echo "    Created PRODUCT.md stub"
fi

scan_skills() {
  local json='[]'
  local paths=(
    "impeccable:.cursor/skills/impeccable/SKILL.md"
    "ui-ux-pro-max:.cursor/skills/ui-ux-pro-max/SKILL.md"
    "taste-skill:.cursor/skills/design-taste-frontend/SKILL.md"
    "taste-skill:.agents/skills/design-taste-frontend/SKILL.md"
    "caveman:.cursor/skills/caveman/SKILL.md"
    "caveman:.agents/skills/caveman/SKILL.md"
    "design:.cursor/skills/design/SKILL.md"
    "design-system:.cursor/skills/design-system/SKILL.md"
    "ui-styling:.cursor/skills/ui-styling/SKILL.md"
    "brand:.cursor/skills/brand/SKILL.md"
    "banner-design:.cursor/skills/banner-design/SKILL.md"
    "slides:.cursor/skills/slides/SKILL.md"
    "claude-mem:.cursor/plugins/claude-mem"
    "claude-mem:/root/.claude/plugins/marketplaces/thedotmack"
  )
  local seen=()
  for entry in "${paths[@]}"; do
    local name="${entry%%:*}"
    local path="${entry#*:}"
    [[ " ${seen[*]} " == *" $name "* ]] && continue
    if [[ "$path" == /* ]]; then
      if [[ -f "$path/SKILL.md" || -d "$path" ]]; then
        json=$(echo "$json" | jq -c ". + [\"$name\"]" 2>/dev/null || echo "$json")
        seen+=("$name")
      fi
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
  PACK_VER=$(grep -E '^version:' "$SKILL_ROOT/SKILL.md" | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "2.4.0")
  MEM_STATUS="pending"
  if echo "$SKILLS_JSON" | jq -e 'index("claude-mem")' &>/dev/null; then MEM_STATUS="installed"; fi
  tmp=$(mktemp)
  rel_progress="${PROGRESS#$PROJECT_ROOT/}"
  jq --argjson sk "$SKILLS_JSON" --arg v "$PACK_VER" --arg pf "$rel_progress" --arg ms "$MEM_STATUS" \
    '.skills_installed = $sk | .skill_pack_version = $v | .skills_inventory = $sk | .progress_file = $pf | .memory_sync.claude_mem = $ms | .memory_sync.last_sync_at = now | .index_doc = "docs/LOOP-MASTER-INDEX.md"' \
    "$PROGRESS" > "$tmp" && mv "$tmp" "$PROGRESS"
  echo "    skills_installed: $SKILLS_JSON"
fi

echo ""
echo "==> Full bootstrap done. Next in Cursor Agent:"
echo "    /loop-master init"
echo "    (Agent runs quiz 6 rounds — no extra shell steps needed)"
echo ""
