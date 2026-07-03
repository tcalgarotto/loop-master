#!/usr/bin/env bash
# Capture immutable project rule from /lucy regra
# Usage: regra-capture.sh --slug NAME --summary "..." [--body-file path] [--body "markdown"] [--versionar] [--project PATH]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"

SLUG=""
SUMMARY=""
BODY=""
BODY_FILE=""
VERSIONAR=false
PROJECT_ROOT="$(pwd)"
LIST=false
REVOKE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug) SLUG="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    --body) BODY="$2"; shift 2 ;;
    --body-file) BODY_FILE="$2"; shift 2 ;;
    --versionar) VERSIONAR=true; shift ;;
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --list) LIST=true; shift ;;
    --revogar) REVOKE="$2"; shift 2 ;;
    -h|--help)
      cat <<'HELP'
Usage: regra-capture.sh --slug NAME --summary "..." [--body-file path] [--versionar]
       regra-capture.sh --list [--project PATH]
       regra-capture.sh --revogar SLUG [--project PATH]
HELP
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

PROJECT_ROOT="$(lucy_detect_project_root "$PROJECT_ROOT")"
BRAIN="$(lucy_brain_dir "$PROJECT_ROOT")"
RULES_DIR="$BRAIN/rules"
mkdir -p "$RULES_DIR"

INDEX="$RULES_DIR/INDEX.md"
if [[ ! -f "$INDEX" ]]; then
  cat > "$INDEX" <<'IDX'
# Regras imutáveis do projeto (`/lucy regra`)

**P0** — prevalecem sobre o skill pack global após `/lucy update`.

| Status | Slug | Resumo | Arquivo |
|--------|------|--------|---------|
IDX
fi

if $LIST; then
  echo "==> lucy regras ativas"
  for f in "$RULES_DIR"/*.md; do
    [[ -f "$f" && "$(basename "$f")" != "INDEX.md" ]] || continue
    if grep -q '^revoked: true' "$f" 2>/dev/null; then continue; fi
    echo "    $(basename "$f" .md)"
    head -20 "$f"
    echo ""
  done
  exit 0
fi

if [[ -n "$REVOKE" ]]; then
  RF="$RULES_DIR/$REVOKE.md"
  [[ -f "$RF" ]] || { echo "ERROR: rule not found: $REVOKE" >&2; exit 1; }
  if grep -q '^revoked: true' "$RF"; then
    echo "    already revoked: $REVOKE"
    exit 0
  fi
  sed -i 's/^revoked: false/revoked: true/' "$RF"
  echo "==> regra revogada: $REVOKE"
  exit 0
fi

[[ -n "$SLUG" && -n "$SUMMARY" ]] || {
  echo "ERROR: --slug and --summary required" >&2
  exit 1
}

if [[ -n "$BODY_FILE" && -f "$BODY_FILE" ]]; then
  BODY=$(cat "$BODY_FILE")
fi

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
DATE="${TS%T*}"
RULE_FILE="$RULES_DIR/$SLUG.md"

if [[ ! -f "$RULE_FILE" ]]; then
  cat > "$RULE_FILE" <<EOF
---
slug: $SLUG
priority: P0
immutable: true
created_at: $TS
source: /lucy regra
revoked: false
---

# $SUMMARY

$BODY
EOF
else
  echo "    WARN: rule exists — append revision note"
  {
    echo ""
    echo "## Revisão $TS"
    echo "$BODY"
  } >> "$RULE_FILE"
fi

printf '%s\n' "{\"ts\":\"$TS\",\"slug\":\"$SLUG\",\"summary\":$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$SUMMARY"),\"scope\":\"project-rule\"}" >> "$RULES_DIR/entries.jsonl"

if ! grep -q "| \`$SLUG\`" "$INDEX" 2>/dev/null; then
  echo "| ✅ | \`$SLUG\` | $SUMMARY | \`rules/$SLUG.md\` |" >> "$INDEX"
fi

if $VERSIONAR; then
  DOCS_DIR="$PROJECT_ROOT/docs/lucy-rules"
  mkdir -p "$DOCS_DIR"
  cp "$RULE_FILE" "$DOCS_DIR/$SLUG.md"
  echo "    mirrored → docs/lucy-rules/$SLUG.md (versionável no git do app)"
fi

echo "==> regra capture (project / immutable)"
echo "    slug: $SLUG"
echo "    file: $RULE_FILE"
echo "    survives: /lucy update, git pull skill pack"
