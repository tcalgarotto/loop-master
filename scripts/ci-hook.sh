#!/usr/bin/env bash
# ci-hook.sh — Dispara tick Lucy automaticamente em eventos de CI/Git
# Uso: bash scripts/ci-hook.sh [evento]
# Eventos: pr-opened, pr-merged, ci-failed, ci-passed, push-main

set -euo pipefail

SKILL_ROOT="${SKILL_ROOT:-$(dirname "$0")/..}"
PROGRESS_FILE="${PROGRESS_FILE:-.cursor/lucy-progress.json}"
HOOK_LOG=".lucy/ci-hook.log"
SENTINEL_PREFIX="LUCY_CI_WAKE"

# Garantir diretório de log
mkdir -p .lucy

log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" | tee -a "$HOOK_LOG"; }

# ──────────────────────────────────────────────
# Detecção de evento
# ──────────────────────────────────────────────
EVENT="${1:-auto}"

detect_event() {
  # GitHub Actions
  if [[ -n "${GITHUB_EVENT_NAME:-}" ]]; then
    echo "$GITHUB_EVENT_NAME"
    return
  fi
  # GitLab CI
  if [[ -n "${CI_PIPELINE_SOURCE:-}" ]]; then
    echo "gitlab-$CI_PIPELINE_SOURCE"
    return
  fi
  # Local git hook
  echo "$EVENT"
}

DETECTED_EVENT=$(detect_event)
log "Evento detectado: $DETECTED_EVENT"

# ──────────────────────────────────────────────
# Verificar se loop está armado
# ──────────────────────────────────────────────
if [[ ! -f "$PROGRESS_FILE" ]]; then
  log "SKIP: $PROGRESS_FILE não encontrado — /lucy init primeiro"
  exit 0
fi

LOOP_STATUS=$(python3 -c "import json,sys; d=json.load(open('$PROGRESS_FILE')); print(d.get('loop_status','stopped'))" 2>/dev/null || echo "stopped")

if [[ "$LOOP_STATUS" == "stopped" || "$LOOP_STATUS" == "complete" ]]; then
  log "SKIP: loop_status=$LOOP_STATUS — nada a fazer"
  exit 0
fi

# ──────────────────────────────────────────────
# Construir next_prompt baseado no evento
# ──────────────────────────────────────────────
build_prompt() {
  local event="$1"
  local base_prompt
  base_prompt=$(python3 -c "
import json
d = json.load(open('$PROGRESS_FILE'))
print(d.get('next_prompt', '/lucy'))
" 2>/dev/null || echo "/lucy")

  case "$event" in
    "pull_request"|"pr-opened")
      echo "$base_prompt

CI Hook: PR aberto. Verificar se há findings de audit pendentes antes do merge.
Prioridade: rodar /lucy audit se minor_cycle.step != gate."
      ;;
    "push"|"push-main"|"merge")
      echo "$base_prompt

CI Hook: Push para branch principal detectado. Continuar loop de onde parou."
      ;;
    "workflow_run"|"ci-failed")
      echo "$base_prompt

CI Hook: CI falhou. Investigar com ci-investigator, corrigir e re-auditar.
Prioridade máxima: resolver falha de CI antes de qualquer nova feature."
      ;;
    "ci-passed")
      echo "$base_prompt

CI Hook: CI passou. Avançar para próximo minor step."
      ;;
    *)
      echo "$base_prompt"
      ;;
  esac
}

NEXT_PROMPT=$(build_prompt "$DETECTED_EVENT")

# ──────────────────────────────────────────────
# Emitir sentinel (acorda o agente Lucy)
# ──────────────────────────────────────────────
SENTINEL="${SENTINEL_PREFIX}_$(echo "$DETECTED_EVENT" | tr '[:lower:]-' '[:upper:]_')"
PAYLOAD=$(python3 -c "import json; print(json.dumps({'prompt': '''$NEXT_PROMPT''', 'chain': True, 'ci_event': '$DETECTED_EVENT'}))" 2>/dev/null || echo '{}')

log "Emitindo sentinel: $SENTINEL"
echo "$SENTINEL $PAYLOAD"

# Registrar no progress JSON
python3 - <<PYEOF
import json, datetime

try:
    with open('$PROGRESS_FILE', 'r') as f:
        data = json.load(f)
except:
    data = {}

data.setdefault('ci_hooks', [])
data['ci_hooks'].append({
    'event': '$DETECTED_EVENT',
    'sentinel': '$SENTINEL',
    'fired_at': datetime.datetime.utcnow().isoformat() + 'Z'
})
# Manter só os últimos 20
data['ci_hooks'] = data['ci_hooks'][-20:]

with open('$PROGRESS_FILE', 'w') as f:
    json.dump(data, f, indent=2)

print('Progress atualizado com ci_hook event')
PYEOF

log "CI hook concluído — sentinel emitido"
