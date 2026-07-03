#!/usr/bin/env bash
# Ensure ecosystem skills are discoverable under .cursor/skills/
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

# .agents → .cursor relative symlinks
for skill in caveman design-taste-frontend design design-system ui-styling brand banner-design slides; do
  if [[ -d "$PROJECT_ROOT/.agents/skills/$skill" ]]; then
    ln -sfn "../../.agents/skills/$skill" "$PROJECT_ROOT/.cursor/skills/$skill" 2>/dev/null || true
    echo "    ok $skill (.agents symlink)"
  fi
done

link_if_missing "caveman" "$PROJECT_ROOT/.agents/skills/caveman"
link_if_missing "design-taste-frontend" "$PROJECT_ROOT/.agents/skills/design-taste-frontend"
link_if_missing "design" "$PROJECT_ROOT/.agents/skills/design"
link_if_missing "design-system" "$PROJECT_ROOT/.agents/skills/design-system"
link_if_missing "ui-styling" "$PROJECT_ROOT/.agents/skills/ui-styling"
link_if_missing "brand" "$PROJECT_ROOT/.agents/skills/brand"
link_if_missing "banner-design" "$PROJECT_ROOT/.agents/skills/banner-design"
link_if_missing "slides" "$PROJECT_ROOT/.agents/skills/slides"

echo "==> done"
