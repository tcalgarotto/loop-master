#!/usr/bin/env bash
# Capture full-page + section scroll shots of HTML preview for vision QA.
# Usage: html-preview-section-gate.sh [--file preview/foo.html] [--base-url http://127.0.0.1:8765/foo.html]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FILE="${FILE:-$ROOT/preview/hubfu-landing-premium.html}"
BASE_URL="${BASE_URL:-}"
OUT="${OUT:-$ROOT/.lucy/html-preview-gates/$(date +%Y%m%d-%H%M%S)}"
GATE_DEPS="$ROOT/.lucy/html-preview-gate"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) FILE="$2"; shift 2 ;;
    --base-url) BASE_URL="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: html-preview-section-gate.sh [--file PATH] [--base-url URL]"
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

mkdir -p "$OUT"

if [[ -z "$BASE_URL" ]]; then
  BN="$(basename "$FILE")"
  BASE_URL="http://127.0.0.1:8765/$BN"
  echo "NOTE: start server: bash scripts/html-preview-serve.sh"
  echo "      url: $BASE_URL"
fi

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node required" >&2
  exit 1
fi

if [[ ! -d "$GATE_DEPS/node_modules/playwright" ]]; then
  echo "==> installing playwright (one-time, .lucy/html-preview-gate)..."
  mkdir -p "$GATE_DEPS"
  (cd "$GATE_DEPS" && npm init -y >/dev/null 2>&1 && npm install playwright@1.49.1 >/dev/null 2>&1)
  (cd "$GATE_DEPS" && npx playwright install chromium >/dev/null 2>&1) || true
fi

export BASE_URL OUT GATE_DEPS="$GATE_DEPS"
node "$SCRIPT_DIR/html-preview-section-gate.mjs"

echo "Review: contrast, clipping, empty panels, integration logos"
echo "Protocol: references/html-preview-interactive-mocks-protocol.md §7"
