#!/usr/bin/env bash
# Ensure optional ecosystem skills are discoverable under .cursor/skills/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
if [[ -f "$(pwd)/Makefile" ]] || [[ -d "$(pwd)/.git" ]]; then
  PROJECT_ROOT="$(pwd)"
fi

mkdir -p "$PROJECT_ROOT/.cursor/skills"

link_if_missing() {
  local name="$1"
  local target="$2"
  local link="$PROJECT_ROOT/.cursor/skills/$name"
  if [[ -e "$target" ]] && [[ ! -e "$link" ]]; then
    ln -sfn "$target" "$link"
    echo "    linked $name → $target"
  elif [[ -e "$link" ]]; then
    echo "    ok $name"
  else
    echo "    skip $name (not installed)"
  fi
}

echo "==> link-ecosystem-skills"
link_if_missing "caveman" "$PROJECT_ROOT/.agents/skills/caveman"
link_if_missing "design-taste-frontend" "$PROJECT_ROOT/.agents/skills/design-taste-frontend"

# Relative symlinks when under project .agents
if [[ -d "$PROJECT_ROOT/.agents/skills/caveman" ]]; then
  ln -sfn ../../.agents/skills/caveman "$PROJECT_ROOT/.cursor/skills/caveman" 2>/dev/null || true
fi
if [[ -d "$PROJECT_ROOT/.agents/skills/design-taste-frontend" ]]; then
  ln -sfn ../../.agents/skills/design-taste-frontend "$PROJECT_ROOT/.cursor/skills/design-taste-frontend" 2>/dev/null || true
fi

echo "==> done"
