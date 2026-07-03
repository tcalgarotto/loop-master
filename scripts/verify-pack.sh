#!/usr/bin/env bash
# Smoke verification for Lucy skill pack (run before git publish)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(pwd)"
if [[ -f "$PROJECT_ROOT/Makefile" ]] || [[ -d "$PROJECT_ROOT/.git" ]]; then
  PROJECT_ROOT="$(pwd)"
fi

PROGRESS="${LUCY_PROGRESS_FILE:-$PROJECT_ROOT/.cursor/lucy-progress.json}"
FAIL=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; FAIL=1; }

echo "==> verify-pack (lucy)"
echo "    skill root: $SKILL_ROOT"
echo "    progress:   $PROGRESS"

# Required files
for f in SKILL.md README.md scripts/init.sh scripts/update.sh scripts/link-ecosystem-skills.sh \
  scripts/arm-dynamic-loop.sh \
  references/autonomous-orchestrator-protocol.md references/skill-ecosystem-map.md \
  references/init-protocol.md references/setup-prompt.md references/git-publish-checklist.md \
  references/getting-started.md references/skills-you-can-use.md references/quiz-protocol.md \
  references/design-skills-routing-table.md references/init-protocol.md \
  references/second-brain-protocol.md scripts/brain-sync.sh scripts/install-hooks.sh \
  scripts/quiz-next.sh scripts/mcp-setup-status.sh scripts/mcp-setup-guide.sh scripts/penpot-mcp-configure.sh \
  references/mcp-integrations-setup-guide.md \
  hooks/brain-hydrate.sh hooks/brain-capture.sh hooks/hooks.template.json MANUAL.md references/README.md; do
  [[ -f "$SKILL_ROOT/$f" ]] && pass "$f" || fail "missing $f"
done

# Shell syntax
bash -n "$SKILL_ROOT/scripts/init.sh" && pass "init.sh syntax" || fail "init.sh syntax"
bash -n "$SKILL_ROOT/scripts/update.sh" && pass "update.sh syntax" || fail "update.sh syntax"
bash -n "$SKILL_ROOT/scripts/link-ecosystem-skills.sh" && pass "link-ecosystem-skills.sh syntax" || fail "link syntax"
bash -n "$SKILL_ROOT/scripts/quiz-next.sh" && pass "quiz-next.sh syntax" || fail "quiz-next syntax"
bash -n "$SKILL_ROOT/scripts/mcp-setup-status.sh" && pass "mcp-setup-status.sh syntax" || fail "mcp-setup-status syntax"
bash -n "$SKILL_ROOT/scripts/mcp-setup-guide.sh" && pass "mcp-setup-guide.sh syntax" || fail "mcp-setup-guide syntax"
chmod +x "$SKILL_ROOT/scripts/mcp-setup-status.sh" "$SKILL_ROOT/scripts/mcp-setup-guide.sh" 2>/dev/null || true
bash -n "$SKILL_ROOT/scripts/brain-sync.sh" && pass "brain-sync.sh syntax" || fail "brain-sync syntax"
bash -n "$SKILL_ROOT/hooks/brain-hydrate.sh" && pass "brain-hydrate.sh syntax" || fail "brain-hydrate syntax"
bash -n "$SKILL_ROOT/hooks/brain-capture.sh" && pass "brain-capture.sh syntax" || fail "brain-capture syntax"
[[ -x "$SKILL_ROOT/hooks/brain-hydrate.sh" ]] || chmod +x "$SKILL_ROOT/hooks/"*.sh "$SKILL_ROOT/scripts/install-hooks.sh" 2>/dev/null || true

# Version in SKILL.md
VER=$(grep -E '^version:' "$SKILL_ROOT/SKILL.md" | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "")
[[ -n "$VER" ]] && pass "SKILL.md version=$VER" || fail "SKILL.md version missing"

# No project-specific names in distributable refs
if rg -qi 'hubfu|kommo' "$SKILL_ROOT/references" "$SKILL_ROOT/SKILL.md" "$SKILL_ROOT/README.md" 2>/dev/null; then
  fail "project-specific names in pack (HubFU/Kommo)"
else
  pass "generic naming (no HubFU/Kommo)"
fi

# Skills scan via init preserve (dry)
if [[ -f "$PROGRESS" ]] && command -v jq &>/dev/null; then
  INST=$(jq -r '.skills_installed | join(",")' "$PROGRESS" 2>/dev/null || echo "")
  [[ -n "$INST" && "$INST" != "null" ]] && pass "skills_installed: $INST" || fail "skills_installed empty in $PROGRESS"
else
  echo "  ~ progress JSON not found or jq missing — skip skills_installed check"
fi

# Ecosystem paths
[[ -f "$PROJECT_ROOT/.cursor/skills/impeccable/SKILL.md" || -L "$PROJECT_ROOT/.cursor/skills/impeccable" ]] && pass "impeccable" || echo "  ~ impeccable not in project (optional)"
[[ -f "$PROJECT_ROOT/.cursor/skills/ui-ux-pro-max/SKILL.md" ]] && pass "ui-ux-pro-max" || echo "  ~ ui-ux-pro-max not in project (optional)"

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "==> verify-pack PASSED"
  exit 0
else
  echo "==> verify-pack FAILED"
  exit 1
fi
