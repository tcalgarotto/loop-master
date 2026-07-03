#!/usr/bin/env bash
# Log learning capture from /lucy aprenda
# Usage: aprenda-capture.sh --slug NAME --summary "one line" [--project PATH]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"

SLUG=""
SUMMARY=""
PROJECT_ROOT="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug) SLUG="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: aprenda-capture.sh --slug NAME --summary \"text\" [--project PATH]"
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$SLUG" && -n "$SUMMARY" ]] || {
  echo "ERROR: --slug and --summary required" >&2
  exit 1
}

PROJECT_ROOT="$(lucy_detect_project_root "$PROJECT_ROOT")"
BRAIN="$(lucy_brain_dir "$PROJECT_ROOT")"
LEARNED_DIR="$BRAIN/learned"
mkdir -p "$LEARNED_DIR"

# Project-local index (survives /lucy update)
INDEX="$LEARNED_DIR/INDEX.md"
if [[ ! -f "$INDEX" ]]; then
  cat > "$INDEX" <<'IDX'
# Aprendizados do projeto (`/lucy aprenda`)

Conhecimento local — **não é apagado** por `git pull` no skill pack.

| Data | Slug | Resumo |
|------|------|--------|
IDX
fi

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
DATE="${TS%T*}"
ENTRY="$LEARNED_DIR/entries.jsonl"

printf '%s\n' "{\"ts\":\"$TS\",\"slug\":\"$SLUG\",\"summary\":$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$SUMMARY")}" >> "$ENTRY"

# Append to project INDEX if slug not already listed
if ! grep -q "| \`$SLUG\`" "$INDEX" 2>/dev/null && ! grep -q "| $SLUG |" "$INDEX" 2>/dev/null; then
  echo "| $DATE | \`$SLUG\` | $SUMMARY |" >> "$INDEX"
fi

echo "==> aprenda capture"
echo "    slug: $SLUG"
echo "    brain: $ENTRY"
echo "    summary: $SUMMARY"
