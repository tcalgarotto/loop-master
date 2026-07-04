#!/usr/bin/env bash
# Lucy v2.8 — full project bootstrap (zero-config default)
# Usage: ./scripts/init.sh [--skip-skills] [--skills a,b,c] [--preserve-context]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"
# shellcheck source=lib/install-idempotent.sh
source "$SCRIPT_DIR/lib/install-idempotent.sh"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(lucy_detect_project_root "$(pwd)")"

# Full ecosystem — installed by default unless --skip-skills or custom --skills
DEFAULT_SKILLS="impeccable,ui-ux-pro-max,taste-skill,caveman,motion,nextjs-premium-stack,visual-gate,firecrawl-cli"
SKILLS_CSV=""
SKIP_SKILLS=false
PRESERVE_CONTEXT=false
UPDATE_MODE=false
GOAL=""
PLAN_DOC=""
PROGRESS_FILE="${LUCY_PROGRESS_FILE:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills) SKILLS_CSV="$2"; shift 2 ;;
    --skip-skills) SKIP_SKILLS=true; shift ;;
    --full) shift ;; # legacy alias — full is now default
    --preserve-context) PRESERVE_CONTEXT=true; shift ;;
    --update-mode) PRESERVE_CONTEXT=true; UPDATE_MODE=true; shift ;;
    --goal) GOAL="$2"; shift 2 ;;
    --plan) PLAN_DOC="$2"; shift 2 ;;
    --progress-file) PROGRESS_FILE="$2"; shift 2 ;;
    -h|--help)
      cat <<'HELP'
Usage: init.sh [options]

Default (zero-config): install full skill ecosystem + symlinks + INDEX stub.
  claude-mem (L2): opt-in — set LUCY_CLAUDE_MEM=1 before init to install/start.

Options:
  --skills a,b,c     Install only listed skills (overrides default full set)
  --skip-skills      Skip all optional skill installs
  --preserve-context Keep existing progress JSON (used by update.sh)
  --update-mode      Preserve context + incremental deps (skip what is installed)
  --goal "..."       Pre-fill north-star goal
  --plan path        Pre-fill plan_doc path
  --progress-file    Custom progress JSON path
HELP
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

echo "==> lucy init (v2.4 full bootstrap)"
echo "    Project: $PROJECT_ROOT"
echo "    Skill pack: $SKILL_ROOT"

mkdir -p "$PROJECT_ROOT/.cursor"
mkdir -p "$PROJECT_ROOT/docs"

# Link lucy skill pack into project .cursor/skills
if [[ "$SKILL_ROOT" != *"/.cursor/skills/lucy"* ]] && [[ "$SKILL_ROOT" != *"/.agents/skills/lucy"* ]]; then
  mkdir -p "$PROJECT_ROOT/.cursor/skills"
  if [[ ! -e "$PROJECT_ROOT/.cursor/skills/lucy" ]]; then
    ln -sf "$SKILL_ROOT" "$PROJECT_ROOT/.cursor/skills/lucy" 2>/dev/null || \
      cp -r "$SKILL_ROOT" "$PROJECT_ROOT/.cursor/skills/lucy"
    echo "    Linked skill pack → .cursor/skills/lucy"
  fi
elif [[ -d "$PROJECT_ROOT/.agents/skills/lucy" ]] && [[ ! -e "$PROJECT_ROOT/.cursor/skills/lucy" ]]; then
  mkdir -p "$PROJECT_ROOT/.cursor/skills"
  ln -sfn ../../.agents/skills/lucy "$PROJECT_ROOT/.cursor/skills/lucy" 2>/dev/null || true
  echo "    Linked .agents/skills/lucy → .cursor/skills/lucy"
fi

# Single canonical skill: /lucy only (remove legacy aliases if present)
lucy_cleanup_skill_duplicates "$PROJECT_ROOT/.cursor/skills"
lucy_cleanup_skill_duplicates "$HOME/.cursor/skills"

install_skill() {
  local name="$1"
  if $SKIP_SKILLS; then return 0; fi
  if $UPDATE_MODE && lucy_skill_present "$PROJECT_ROOT" "$name"; then
    echo "    ok $name (skip — already installed)"
    return 0
  fi
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
      if ! lucy_claude_mem_enabled; then
        echo "    skip claude-mem (opt-in — set LUCY_CLAUDE_MEM=1 to enable L2 memory)"
        return 0
      fi
      if lucy_skill_present "$PROJECT_ROOT" "claude-mem"; then
        echo "    ok claude-mem (skip install)"
      else
        echo "    Installing claude-mem..."
        (cd "$PROJECT_ROOT" && npx --yes claude-mem install 2>/dev/null) || \
          echo "    WARN: claude-mem install failed — run: npx claude-mem install"
      fi
      if lucy_claude_mem_worker_running; then
        echo "    ok claude-mem worker (running)"
      elif command -v npx &>/dev/null; then
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
    nextjs-premium-stack)
      # Auto-install premium UI stack when Next.js project detected
      local PKG_JSON=""
      if [[ -f "$PROJECT_ROOT/package.json" ]]; then PKG_JSON="$PROJECT_ROOT/package.json"
      elif [[ -f "$PROJECT_ROOT/frontend/package.json" ]]; then PKG_JSON="$PROJECT_ROOT/frontend/package.json"
      fi
      if [[ -z "$PKG_JSON" ]]; then echo "    skip nextjs-premium-stack (no package.json)"; return 0; fi
      local PKG_DIR="$(dirname "$PKG_JSON")"
      local IS_NEXT=false
      grep -q '"next"' "$PKG_JSON" 2>/dev/null && IS_NEXT=true
      [[ -d "$PROJECT_ROOT/app" || -d "$PROJECT_ROOT/src/app" ]] && IS_NEXT=true
      if ! $IS_NEXT; then echo "    skip nextjs-premium-stack (not a Next.js project)"; return 0; fi
      echo "    Detected Next.js — installing premium UI stack..."
      # shadcn/ui
      if ! grep -q '"@radix-ui/react" \|shadcn' "$PKG_JSON" 2>/dev/null && \
         [[ ! -f "$PKG_DIR/components.json" ]]; then
        echo "      shadcn/ui (non-interactive)..."
        (cd "$PKG_DIR" && NEXT_PUBLIC_SKIP_AUTO_DETECT=true npx shadcn@latest init \
          --defaults --style default --base-color zinc --yes 2>/dev/null) || \
          echo "      WARN: shadcn init skipped (run manually: npx shadcn@latest init)"
      else
        echo "      ok shadcn/ui"
      fi
      # framer-motion
      if ! grep -q '"framer-motion"' "$PKG_JSON" 2>/dev/null; then
        echo "      framer-motion..."
        (cd "$PKG_DIR" && npm install framer-motion 2>/dev/null) || true
      else
        echo "      ok framer-motion"
      fi
      # tremor (gráficos)
      if ! grep -q '@tremor/react' "$PKG_JSON" 2>/dev/null; then
        echo "      @tremor/react (gráficos)..."
        (cd "$PKG_DIR" && npm install @tremor/react 2>/dev/null) || true
      else
        echo "      ok @tremor/react"
      fi
      # TanStack Query
      if ! grep -q '@tanstack/react-query' "$PKG_JSON" 2>/dev/null; then
        echo "      @tanstack/react-query..."
        (cd "$PKG_DIR" && npm install @tanstack/react-query 2>/dev/null) || true
      else
        echo "      ok @tanstack/react-query"
      fi
      # lucide-react
      if ! grep -q 'lucide-react' "$PKG_JSON" 2>/dev/null; then
        echo "      lucide-react..."
        (cd "$PKG_DIR" && npm install lucide-react 2>/dev/null) || true
      else
        echo "      ok lucide-react"
      fi
      echo "    Premium UI stack ready. See: .cursor/skills/lucy/references/premium-ui-stack.md"
      ;;
    visual-gate)
      lucy_ensure_playwright "$PROJECT_ROOT" "$UPDATE_MODE"
      bash "$SCRIPT_DIR/ensure-headless-browser.sh" --project "$PROJECT_ROOT" --quiet 2>/dev/null || true
      ;;
    firecrawl-cli)
      lucy_ensure_firecrawl "$PROJECT_ROOT" "$UPDATE_MODE"
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
  if lucy_brain_initialized "$PROJECT_ROOT"; then
    echo "    ok brain (skip init)"
  else
    bash "$SCRIPT_DIR/brain-sync.sh" init || true
  fi
fi

# Cursor hooks — sessionStart hydrate + stop capture (Option B)
if [[ -x "$SCRIPT_DIR/install-hooks.sh" ]]; then
  if $UPDATE_MODE && lucy_hooks_up_to_date "$SKILL_ROOT" "$PROJECT_ROOT"; then
    echo "    ok hooks (skip — up to date)"
  else
    bash "$SCRIPT_DIR/install-hooks.sh" || true
  fi
fi

PROGRESS="${PROGRESS_FILE:-$(lucy_progress_file "$PROJECT_ROOT")}"
[[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"
INDEX_DOC="$(lucy_index_doc "$PROJECT_ROOT")"

if [[ ! -f "$PROGRESS" ]] && ! $PRESERVE_CONTEXT; then
  SENTINEL="AGENT_LOOP_TICK_$(basename "$PROJECT_ROOT" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9_')_$(date +%s | tail -c 5)"
  TARGET="${GOAL:-Define goal via /lucy init quiz (Round 1)}"
  PLAN="${PLAN_DOC:-docs/LUCY-PLAN.md}"
  rel_pf="${PROGRESS#$PROJECT_ROOT/}"
  cat > "$PROGRESS" <<EOF
{
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tick_count": 0,
  "overall_pct": 0,
  "skill_pack_version": "2.4.0",
  "progress_file": "$rel_pf",
  "index_doc": "docs/LUCY-INDEX.md",
  "brain_dir": ".cursor/lucy-brain",
  "brain_sync": { "last_capture_at": null, "interaction_count": 0, "consciousness_level": 0 },
  "skills_installed": [],
  "quiz_round": 0,
  "quiz_complete": false,
  "memory_sync": { "claude_mem": "pending", "last_sync_at": null },
  "quality_gates": {
    "visual_gate_auto": true,
    "visual_gate_on_fe_phase": true,
    "require_vision_before_gate": true,
    "premium_tool_orchestration": true,
    "landing_requires_motion": true,
    "landing_visual_gate_production": true
  },
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
      "name": "First phase — define in quiz Round 6 + LUCY-PLAN.md",
      "status": "pending",
      "pct": 0,
      "acceptance_criteria": ["Complete /lucy init quiz (6 rounds)"]
    }
  },
  "minor_cycle": {
    "phase_id": "phase-1",
    "step": "discover",
    "iteration": 1,
    "gate": "pending",
    "tasks": []
  },
  "last_iteration": { "agent_summary": "Full bootstrap ran. Awaiting /lucy init quiz (6 rounds)." },
  "next_actions": ["Complete quiz Round 1 (produto)", "Run verify-pack.sh", "Arm dynamic loop after quiz"],
  "context_files": ["docs/LUCY-PLAN.md", "docs/LUCY-INDEX.md", ".cursor/lucy-brain/INDEX.md"],
  "human_blockers": [],
  "archive_summaries": []
}
EOF
  echo "    Created $PROGRESS"
elif $PRESERVE_CONTEXT && [[ -f "$PROGRESS" ]]; then
  echo "    Preserving existing progress JSON (update/preserve mode)"
fi

PLAN_PATH="$(lucy_plan_doc "$PROJECT_ROOT")"
if [[ ! -f "$PLAN_PATH" ]] && ! $PRESERVE_CONTEXT; then
  cat > "$PLAN_PATH" <<'EOF'
# Lucy Plan

> Gerado por `lucy init`. Fases definidas após quiz (Round 6).

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
# Lucy Index

Legenda: ✅ OK | ⏳ Pendente | 🔮 Futuro | 👤 Human

| Artefato | Status | Path | Notas |
|----------|--------|------|-------|
| Progress JSON | ⏳ | `.cursor/lucy-progress.json` | Handoff L1 entre ticks |
| Master Plan | ⏳ | `docs/LUCY-PLAN.md` | Fases e gates |
| Product brief | 🔮 | `PRODUCT.md` | Se escopo FE |
| Design brief | 🔮 | `DESIGN.md` | Se design_surface ≠ none |
| claude-mem L2 | 🔮 | opt-in (`LUCY_CLAUDE_MEM=1`) | Memória semântica cross-session — opcional |
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

# DESIGN_SYSTEM.md stub — padrões premium para CRM/ERP/IA
if ! $PRESERVE_CONTEXT && [[ ! -f "$PROJECT_ROOT/DESIGN_SYSTEM.md" ]]; then
  # Detect Next.js
  IS_NEXT=false
  [[ -f "$PROJECT_ROOT/package.json" ]] && grep -q '"next"' "$PROJECT_ROOT/package.json" 2>/dev/null && IS_NEXT=true
  [[ -d "$PROJECT_ROOT/app" || -d "$PROJECT_ROOT/src/app" ]] && IS_NEXT=true
  if $IS_NEXT; then
    cat > "$PROJECT_ROOT/DESIGN_SYSTEM.md" <<'EOF'
# Design System — Padrão Premium

> Gerado por Lucy. Seguir estritamente.
> Stack: Next.js + Tailwind + shadcn/ui + Framer Motion + Tremor + TanStack Query
> Referência completa: `.cursor/skills/lucy/references/premium-ui-stack.md`

## Paleta

- Fundo página: `bg-zinc-50` | `bg-zinc-100`
- Cards: `bg-white rounded-xl shadow-sm`
- Sidebar escura: `bg-zinc-950`
- Sidebar expansível: `bg-zinc-50`
- Texto principal: `text-zinc-900`
- Texto secundário: `text-zinc-500`
- PROIBIDO: azul puro, verde saturado, bordas coloridas

## Espaçamento

- Regra 8px: `p-4`, `p-6`, `p-8`, `gap-4`
- Arredondamento: cards `rounded-xl`, modais `rounded-2xl`, botões `rounded-lg`
- Sombra: `shadow-sm` em cards, nunca `shadow-xl` em elementos internos

## Sidebar Dupla

- Mini (64px): `bg-zinc-950`, ícones `text-zinc-400` → `text-white` (ativo)
- Expansível (240px): `bg-zinc-50`, framer-motion spring
- Separadores: group labels `text-[10px] font-bold text-zinc-400 tracking-wider uppercase`
- Item ativo: `bg-zinc-200/50 rounded-lg`

## Badges

- Conectado: `bg-emerald-50 text-emerald-700`
- Erro: `bg-red-50 text-red-700`
- Warning: `bg-amber-50 text-amber-700`

## Ícones

- Biblioteca: lucide-react exclusivamente
- Tamanho: `size-4` (inline), `size-5` (sidebar/card)
- Cor: `text-zinc-500` padrão, `text-zinc-900` ativo

## Animações (Framer Motion)

```tsx
// Spring padrão
const spring = { type: "spring", stiffness: 400, damping: 30 }
// Fade-in de cards
initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.2 }}
// Sempre respeitar prefers-reduced-motion
```

## Gráficos

- Biblioteca: Tremor Raw (`@tremor/react`)
- Paleta: zinc/slate, sem cores saturadas
- Loading: shadcn Skeleton + framer-motion fade-in

## Dados

- Cache: TanStack Query (`@tanstack/react-query`)
- Proibido: `useEffect` + fetch manual para dados de server
- Server Actions para mutações
EOF
    echo "    Created DESIGN_SYSTEM.md (Next.js premium preset)"
  fi
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
  if lucy_is_nextjs "$PROJECT_ROOT" 2>/dev/null; then
    if lucy_playwright_in_pkg "$PROJECT_ROOT" 2>/dev/null || [[ -f "$PROJECT_ROOT/.lucy/visual-gate-ready" ]]; then
      json=$(echo "$json" | jq -c '. + ["visual-gate"]' 2>/dev/null || echo "$json")
    fi
  fi
  if command -v firecrawl &>/dev/null || [[ -f "$PROJECT_ROOT/.lucy/firecrawl-ready" ]]; then
    json=$(echo "$json" | jq -c '. + ["firecrawl-cli"]' 2>/dev/null || echo "$json")
  fi
  echo "$json"
}

if command -v jq &>/dev/null && [[ -f "$PROGRESS" ]]; then
  SKILLS_JSON=$(scan_skills)
  PACK_VER=$(grep -E '^version:' "$SKILL_ROOT/SKILL.md" | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "2.4.0")
  MEM_STATUS="disabled"
  if lucy_claude_mem_enabled; then
    MEM_STATUS="pending"
    if echo "$SKILLS_JSON" | jq -e 'index("claude-mem")' &>/dev/null; then MEM_STATUS="installed"; fi
    if lucy_claude_mem_worker_running; then MEM_STATUS="running"; fi
  fi
  tmp=$(mktemp)
  rel_progress="${PROGRESS#$PROJECT_ROOT/}"
  jq --argjson sk "$SKILLS_JSON" --arg v "$PACK_VER" --arg pf "$rel_progress" --arg ms "$MEM_STATUS" \
    '.skills_installed = $sk | .skill_pack_version = $v | .skills_inventory = $sk | .progress_file = $pf | .memory_sync.claude_mem = $ms | .memory_sync.last_sync_at = now | .index_doc = "docs/LUCY-INDEX.md" | .quality_gates = ((.quality_gates // {}) + {"visual_gate_auto": true, "visual_gate_on_fe_phase": true, "require_vision_before_gate": true, "premium_tool_orchestration": true, "landing_requires_motion": true, "landing_visual_gate_production": true})' \
    "$PROGRESS" > "$tmp" && mv "$tmp" "$PROGRESS"
  echo "    skills_installed: $SKILLS_JSON"
  echo "    quality_gates: visual_gate_auto=true (default)"
fi

echo ""
if lucy_is_nextjs "$PROJECT_ROOT" 2>/dev/null; then
  echo "==> Headless browser ready check"
  bash "$SCRIPT_DIR/ensure-headless-browser.sh" --project "$PROJECT_ROOT" 2>/dev/null || true
fi
echo "==> Full bootstrap done. Next in Cursor Agent:"
echo "    /lucy init"
echo "    (Agent runs quiz 6 rounds — no extra shell steps needed)"
echo ""
