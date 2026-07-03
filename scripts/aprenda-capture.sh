#!/usr/bin/env bash
# Log global learning from /lucy aprenda (skill pack repo)
# Usage: aprenda-capture.sh --slug NAME --summary "one line"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"

SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SLUG=""
SUMMARY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug) SLUG="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: aprenda-capture.sh --slug NAME --summary \"text\""
      echo "       Writes to skill pack references/learned/ (global, for GitHub publish)"
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$SLUG" && -n "$SUMMARY" ]] || {
  echo "ERROR: --slug and --summary required" >&2
  exit 1
}

LEARNED_DIR="$SKILL_ROOT/references/learned"
mkdir -p "$LEARNED_DIR"

INDEX="$LEARNED_DIR/INDEX.md"
if [[ ! -f "$INDEX" ]]; then
  cat > "$INDEX" <<'IDX'
# Lucy — aprendizados globais (`/lucy aprenda`)

Publicados no GitHub — todos os usuários recebem no `git pull`.

| Data | Slug | Resumo |
|------|------|--------|
IDX
fi

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
DATE="${TS%T*}"
ENTRY="$LEARNED_DIR/entries.jsonl"

printf '%s\n' "{\"ts\":\"$TS\",\"slug\":\"$SLUG\",\"summary\":$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$SUMMARY"),\"scope\":\"global\"}" >> "$ENTRY"

if ! grep -q "| \`$SLUG\`" "$INDEX" 2>/dev/null && ! grep -q "| $SLUG |" "$INDEX" 2>/dev/null; then
  echo "| $DATE | \`$SLUG\` | $SUMMARY |" >> "$INDEX"
fi

echo "==> aprenda capture (global / skill pack)"
echo "    slug: $SLUG"
echo "    path: $LEARNED_DIR"
echo "    next: commit + push loop-master repo"
