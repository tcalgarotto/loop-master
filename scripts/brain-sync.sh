#!/usr/bin/env bash
# Lucy Second Brain — local memory + claude-mem sync
# Usage:
#   brain-sync.sh init
#   brain-sync.sh hydrate [--json]
#   brain-sync.sh capture --summary "..." [--paths a,b] [--decisions "..."] [--dev-note "..."] [--kind tick|chat|decision]
#   brain-sync.sh status
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"
PROJECT_ROOT="$(lucy_detect_project_root "$(pwd)")"

BRAIN_DIR="$(lucy_brain_dir "$PROJECT_ROOT")"
PROGRESS="$(lucy_progress_file "$PROJECT_ROOT")"
[[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"

STATE="$BRAIN_DIR/STATE.json"
DEV="$BRAIN_DIR/dev-profile.json"
MIND="$BRAIN_DIR/project-mind.json"
LOG="$BRAIN_DIR/interaction-log.jsonl"
INDEX="$BRAIN_DIR/INDEX.md"

now_iso() { date -u +%Y-%m-%dT%H:%M:%SZ; }

brain_init() {
  mkdir -p "$BRAIN_DIR"
  local proj_id
  proj_id=$(basename "$PROJECT_ROOT" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')

  if [[ ! -f "$STATE" ]]; then
    cat > "$STATE" <<EOF
{
  "version": "1.0",
  "project_id": "$proj_id",
  "created_at": "$(now_iso)",
  "updated_at": "$(now_iso)",
  "interaction_count": 0,
  "consciousness_level": 0,
  "last_hydrate_at": null,
  "last_capture_at": null,
  "topics_active": [],
  "open_threads": []
}
EOF
  fi

  if [[ ! -f "$DEV" ]]; then
    cat > "$DEV" <<'EOF'
{
  "dev_preferences": {},
  "communication_style": [],
  "learned_facts": [],
  "blockers_history": []
}
EOF
  fi

  if [[ ! -f "$MIND" ]]; then
    cat > "$MIND" <<'EOF'
{
  "architecture_decisions": [],
  "conventions": [],
  "domain_glossary": [],
  "phase_history": [],
  "key_paths": []
}
EOF
  fi

  touch "$LOG"

  if [[ ! -f "$INDEX" ]]; then
    cat > "$INDEX" <<'EOF'
# Lucy — Second Brain

Legenda: ✅ consolidado | ⏳ aprendendo | 🔮 inferido | 👤 confirmado pelo dev

| Camada | Status | Arquivo |
|--------|--------|---------|
| Estado vivo | ⏳ | `.cursor/lucy-brain/STATE.json` |
| Perfil dev | ⏳ | `.cursor/lucy-brain/dev-profile.json` |
| Mente projeto | ⏳ | `.cursor/lucy-brain/project-mind.json` |
| Log interações | ⏳ | `.cursor/lucy-brain/interaction-log.jsonl` |
| claude-mem L2 | ⏳ | MCP search + observation_add |

> Atualizado automaticamente a cada `/lucy` (hydrate → trabalho → capture).
EOF
  fi

  echo "==> brain init OK → $BRAIN_DIR"
}

brain_hydrate() {
  brain_init
  local as_json=false
  [[ "${1:-}" == "--json" ]] && as_json=true

  local tick=0 target="" phase="" pct=0
  if [[ -f "$PROGRESS" ]] && command -v jq &>/dev/null; then
    tick=$(jq -r '.tick_count // 0' "$PROGRESS" 2>/dev/null || echo 0)
    target=$(jq -r '.target // ""' "$PROGRESS" 2>/dev/null || echo "")
    phase=$(jq -r '.current_phase // ""' "$PROGRESS" 2>/dev/null || echo "")
    pct=$(jq -r '.overall_pct // 0' "$PROGRESS" 2>/dev/null || echo 0)
  fi

  if $as_json; then
    python3 << PY
import json, pathlib
root = pathlib.Path("$BRAIN_DIR")
out = {
  "hydrated_at": "$(now_iso)",
  "progress": {"tick": $tick, "target": """$target""", "phase": """$phase""", "pct": $pct},
  "state": json.loads((root/"STATE.json").read_text()) if (root/"STATE.json").exists() else {},
  "dev_profile": json.loads((root/"dev-profile.json").read_text()) if (root/"dev-profile.json").exists() else {},
  "project_mind": json.loads((root/"project-mind.json").read_text()) if (root/"project-mind.json").exists() else {},
  "recent_interactions": []
}
log = root/"interaction-log.jsonl"
if log.exists():
    lines = [l for l in log.read_text().strip().split("\n") if l.strip()][-5:]
    out["recent_interactions"] = [json.loads(l) for l in lines]
print(json.dumps(out, ensure_ascii=False, indent=2))
PY
    return 0
  fi

  echo "==> SECOND BRAIN HYDRATE"
  echo "    project: $(basename "$PROJECT_ROOT")"
  echo "    progress: tick=$tick phase=$phase pct=$pct%"
  echo "    target: $target"
  echo ""
  echo "--- project rules (P0 — imutáveis) ---"
  local rf
  shopt -s nullglob
  for rf in "$BRAIN_DIR/rules"/*.md; do
    [[ "$(basename "$rf")" == "INDEX.md" ]] && continue
    grep -q '^revoked: true' "$rf" 2>/dev/null && continue
    echo "  [P0] $(basename "$rf" .md):"
    sed -n '/^# /,$p' "$rf" | head -8
    echo ""
  done
  shopt -u nullglob
  [[ -d "$BRAIN_DIR/rules" ]] || echo "(nenhuma — use /lucy regra)"
  echo ""
  jq -r '.learned_facts[-5:][]? | "- [\(.confidence // "medium")] \(.fact)"' "$DEV" 2>/dev/null || echo "(vazio)"
  echo ""
  echo "--- project-mind (decisões recentes) ---"
  jq -r '.architecture_decisions[-5:][]? | "- \(.decision) (\(.at // ""))"' "$MIND" 2>/dev/null || echo "(vazio)"
  echo ""
  echo "--- últimas interações ---"
  tail -n 3 "$LOG" 2>/dev/null | while read -r line; do
    echo "$line" | jq -r '"[\(.at)] \(.kind): \(.summary)"' 2>/dev/null || echo "$line"
  done
  echo ""
  echo ">>> Agent: também chamar claude-mem MCP:"
  echo "    1. session_start_context(project=\"$(basename "$PROJECT_ROOT")\", platformSource=\"cursor\")"
  echo "    2. search(query=\"$target $phase\", limit=5, platformSource=\"cursor\")"
  echo "    3. timeline(anchor=<id>) se relevante"
}

brain_capture() {
  brain_init
  local summary="" paths="" decisions="" dev_note="" kind="interaction"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --summary) summary="$2"; shift 2 ;;
      --paths) paths="$2"; shift 2 ;;
      --decisions) decisions="$2"; shift 2 ;;
      --dev-note) dev_note="$2"; shift 2 ;;
      --kind) kind="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  [[ -z "$summary" ]] && { echo "ERROR: --summary required" >&2; exit 1; }

  local at count
  at=$(now_iso)
  count=$(jq -r '.interaction_count // 0' "$STATE" 2>/dev/null || echo 0)
  count=$((count + 1))
  local consciousness=$(( count > 100 ? 100 : count ))

  # Append interaction log
  python3 << PY
import json
entry = {
  "at": "$at",
  "kind": "$kind",
  "summary": """$summary""",
  "paths": [p.strip() for p in """$paths""".split(",") if p.strip()],
  "decisions": """$decisions""",
  "dev_note": """$dev_note"""
}
with open("$LOG", "a") as f:
    f.write(json.dumps(entry, ensure_ascii=False) + "\n")
PY

  # Update STATE
  tmp=$(mktemp)
  jq --arg at "$at" --argjson n "$count" --argjson c "$consciousness" \
    '.interaction_count = $n | .consciousness_level = $c | .updated_at = $at | .last_capture_at = $at' \
    "$STATE" > "$tmp" && mv "$tmp" "$STATE"

  # Append dev facts if dev-note provided
  if [[ -n "$dev_note" ]] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq --arg at "$at" --arg fact "$dev_note" \
      '.learned_facts += [{"at": $at, "fact": $fact, "confidence": "medium", "source": "capture"}]' \
      "$DEV" > "$tmp" && mv "$tmp" "$DEV"
  fi

  # Append architecture decisions
  if [[ -n "$decisions" ]] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq --arg at "$at" --arg d "$decisions" \
      '.architecture_decisions += [{"at": $at, "decision": $d, "status": "⏳"}]' \
      "$MIND" > "$tmp" && mv "$tmp" "$MIND"
  fi

  # Sync progress JSON brain fields if exists
  if [[ -f "$PROGRESS" ]] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq --arg at "$at" --argjson n "$count" \
      '.brain_sync = {"last_capture_at": $at, "interaction_count": $n, "consciousness_level": ($n | if . > 100 then 100 else . end)} | .memory_sync.last_sync_at = $at' \
      "$PROGRESS" > "$tmp" && mv "$tmp" "$PROGRESS"
  fi

  echo "==> brain capture OK (#$count)"
  echo "    summary: ${summary:0:120}..."
  echo ""
  echo ">>> Agent: também chamar claude-mem MCP observation_add:"
  echo "    content: compact narrative of this interaction"
  echo "    kind: lucy-$kind"
  echo "    metadata: {paths, phase, tick}"
}

brain_status() {
  brain_init
  echo "==> Second Brain Status"
  echo "    dir: $BRAIN_DIR"
  jq -r '"    interactions: \(.interaction_count) consciousness: \(.consciousness_level)%"' "$STATE" 2>/dev/null || true
  echo "    log lines: $(wc -l < "$LOG" 2>/dev/null || echo 0)"
  if [[ -f "$PROGRESS" ]]; then
    jq -r '.brain_sync // "    brain_sync: (not in progress JSON yet)"' "$PROGRESS" 2>/dev/null || true
  fi
}

cmd="${1:-status}"
shift || true
case "$cmd" in
  init) brain_init ;;
  hydrate) brain_hydrate "$@" ;;
  capture) brain_capture "$@" ;;
  status) brain_status ;;
  *)
    echo "Usage: brain-sync.sh {init|hydrate|capture|status}"
    exit 1
    ;;
esac
