#!/usr/bin/env bash
# Serve preview/ HTML for live browser iteration (HTML-first design loop)
# Usage: html-preview-serve.sh [DIR] [PORT]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIR="${1:-$ROOT/preview}"
PORT="${2:-8765}"

if [[ ! -d "$DIR" ]]; then
  mkdir -p "$DIR"
  echo "Created $DIR — add .html files and re-run"
fi

echo "==> Lucy HTML preview"
echo "    dir:  $DIR"
echo "    url:  http://127.0.0.1:$PORT/"
echo "    tip:  edit HTML in Cursor → refresh browser"
echo "    stop: Ctrl+C"
cd "$DIR"
exec python3 -m http.server "$PORT" --bind 127.0.0.1
