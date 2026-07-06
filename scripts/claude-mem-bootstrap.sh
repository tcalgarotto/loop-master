#!/usr/bin/env bash
# Idempotent claude-mem L2 bootstrap — NVIDIA NIM zero-config path
# Usage: LUCY_CLAUDE_MEM=1 bash scripts/claude-mem-bootstrap.sh [PROJECT_ROOT]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"
# shellcheck source=lib/install-idempotent.sh
source "$SCRIPT_DIR/lib/install-idempotent.sh"

SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(lucy_detect_project_root "${1:-$(pwd)}")"
MEM_DIR="${CLAUDE_MEM_HOME:-$HOME/.claude-mem}"
SETTINGS_SRC="$SKILL_ROOT/references/templates/claude-mem-settings.nvidia.json"
ENV_SRC="$SKILL_ROOT/references/templates/claude-mem-nvidia.env.example"

log() { echo "    $*"; }
warn() { echo "    WARN: $*" >&2; }

ensure_mem_dir() {
  mkdir -p "$MEM_DIR"
}

ensure_settings() {
  if [[ ! -f "$SETTINGS_SRC" ]]; then
    warn "template missing: $SETTINGS_SRC"
    return 1
  fi
  if [[ ! -f "$MEM_DIR/settings.json" ]]; then
    cp "$SETTINGS_SRC" "$MEM_DIR/settings.json"
    log "created ~/.claude-mem/settings.json (NVIDIA NIM)"
    return 0
  fi
  if ! grep -q 'integrate.api.nvidia.com' "$MEM_DIR/settings.json" 2>/dev/null; then
    cp "$SETTINGS_SRC" "$MEM_DIR/settings.json"
    log "refreshed ~/.claude-mem/settings.json from template"
  else
    log "ok settings.json (NVIDIA NIM)"
  fi
}

# Read nvapi key from either var — never echo value
read_nvapi_key() {
  local env_file="$1" key=""
  if [[ -f "$env_file" ]]; then
    if grep -q '^CLAUDE_MEM_OPENROUTER_API_KEY=nvapi-' "$env_file" 2>/dev/null; then
      key=$(grep '^CLAUDE_MEM_OPENROUTER_API_KEY=' "$env_file" | head -1 | cut -d= -f2-)
    elif grep -q '^OPENROUTER_API_KEY=nvapi-' "$env_file" 2>/dev/null; then
      key=$(grep '^OPENROUTER_API_KEY=' "$env_file" | head -1 | cut -d= -f2-)
    fi
  fi
  if [[ -n "$key" && "$key" != "nvapi-REPLACE_ME" ]]; then
    printf '%s' "$key"
  fi
}

set_env_var() {
  local env_file="$1" var="$2" value="$3"
  if grep -q "^${var}=" "$env_file" 2>/dev/null; then
    # shellcheck disable=SC2016
    sed -i "s|^${var}=.*|${var}=${value}|" "$env_file"
  else
    printf '%s=%s\n' "$var" "$value" >> "$env_file"
  fi
}

ensure_nvidia_env() {
  local env_file="$MEM_DIR/.env"
  if [[ ! -f "$env_file" ]]; then
    cp "$ENV_SRC" "$env_file"
    chmod 600 "$env_file"
    log "created ~/.claude-mem/.env from template — paste nvapi- key once"
    return 0
  fi
  chmod 600 "$env_file"
  local nv_key
  nv_key=$(read_nvapi_key "$env_file" || true)
  if [[ -z "$nv_key" ]]; then
    warn "paste nvapi- key in ~/.claude-mem/.env (build.nvidia.com → Profile → API Keys)"
    return 0
  fi
  if ! grep -q '^CLAUDE_MEM_OPENROUTER_API_KEY=nvapi-' "$env_file" 2>/dev/null; then
    set_env_var "$env_file" "CLAUDE_MEM_OPENROUTER_API_KEY" "$nv_key"
    log "synced CLAUDE_MEM_OPENROUTER_API_KEY alias"
  fi
  if ! grep -q '^OPENROUTER_API_KEY=nvapi-' "$env_file" 2>/dev/null; then
    set_env_var "$env_file" "OPENROUTER_API_KEY" "$nv_key"
    log "synced OPENROUTER_API_KEY alias (worker provider gate)"
  fi
  log "ok ~/.claude-mem/.env (both NVIDIA vars present)"
}

ensure_project_l2_flag() {
  local env_file="$PROJECT_ROOT/.env"
  [[ -f "$env_file" ]] || return 0
  if grep -qE '^LUCY_CLAUDE_MEM=1' "$env_file" 2>/dev/null; then
    log "ok project .env LUCY_CLAUDE_MEM=1"
    return 0
  fi
  if grep -qE '^#?[[:space:]]*LUCY_CLAUDE_MEM=' "$env_file" 2>/dev/null; then
    sed -i 's/^[#[:space:]]*LUCY_CLAUDE_MEM=.*/LUCY_CLAUDE_MEM=1/' "$env_file"
  else
    cat >> "$env_file" <<'EOF'

# Lucy L2 — claude-mem semantic memory (opt-in, non-secret)
LUCY_CLAUDE_MEM=1
EOF
  fi
  log "added LUCY_CLAUDE_MEM=1 to project .env"
}

install_and_start_worker() {
  if ! lucy_claude_mem_enabled; then
    log "skip worker (LUCY_CLAUDE_MEM not set — export LUCY_CLAUDE_MEM=1)"
    return 0
  fi
  if ! lucy_skill_present "$PROJECT_ROOT" "claude-mem"; then
    log "Installing claude-mem..."
    (cd "$PROJECT_ROOT" && npx --yes claude-mem install 2>/dev/null) || \
      warn "claude-mem install failed — run: npx claude-mem install"
  else
    log "ok claude-mem plugin"
  fi
  if lucy_claude_mem_worker_running; then
    log "ok claude-mem worker (running)"
    return 0
  fi
  log "Starting claude-mem worker..."
  (cd "$PROJECT_ROOT" && npx --yes claude-mem start 2>/dev/null) || \
    warn "claude-mem start failed — run: npx claude-mem start"
}

verify_stack() {
  local ok=true
  if command -v npx &>/dev/null; then
    if npx --yes claude-mem status 2>/dev/null | grep -qi 'running'; then
      log "verify: worker running (:37700)"
    else
      warn "worker not running — npx claude-mem start"
      ok=false
    fi
    if npx --yes claude-mem doctor 2>/dev/null | grep -qi 'All required checks passed'; then
      log "verify: doctor OK"
    else
      warn "doctor degraded — check ~/.claude-mem/.env keys"
      ok=false
    fi
  fi
  if [[ -f "$MEM_DIR/.env" ]] && grep -q '^OPENROUTER_API_KEY=nvapi-' "$MEM_DIR/.env" && \
     grep -q '^CLAUDE_MEM_OPENROUTER_API_KEY=nvapi-' "$MEM_DIR/.env"; then
    log "verify: NVIDIA .env both vars"
  else
    warn "NVIDIA key missing in ~/.claude-mem/.env"
    ok=false
  fi
  $ok
}

print_memory_counts() {
  command -v python3 &>/dev/null || return 0
  python3 - "$MEM_DIR" <<'PY' 2>/dev/null || true
import sqlite3, sys, os
mem = sys.argv[1]
main = os.path.join(mem, "claude-mem.db")
chroma = os.path.join(mem, "chroma", "chroma.sqlite3")
if os.path.isfile(main):
    c = sqlite3.connect(main)
    obs = c.execute("SELECT COUNT(*) FROM observations").fetchone()[0]
    c.close()
    print(f"    memory: SQLite observations={obs}", end="")
if os.path.isfile(chroma):
    c = sqlite3.connect(chroma)
    emb = c.execute("SELECT COUNT(*) FROM embeddings").fetchone()[0]
    c.close()
    print(f", Chroma embeddings={emb}")
elif os.path.isfile(main):
    print()
PY
}

main() {
  echo "==> claude-mem bootstrap (NVIDIA zero-config)"
  ensure_mem_dir
  ensure_settings
  ensure_nvidia_env
  ensure_project_l2_flag
  install_and_start_worker
  print_memory_counts
  if verify_stack; then
    echo "==> claude-mem bootstrap OK"
    echo "    Next: Cursor → Settings → Tools & MCPs → claude-mem ON"
    echo "    Guide: references/learned/claude-mem-zero-config-playbook.md"
  else
    echo "==> claude-mem bootstrap partial — see WARN above"
    exit 1
  fi
}

main "$@"
