#!/usr/bin/env bash
# Idempotent install helpers — skip when already present (update/init fast path)
# Source: source "$SCRIPT_DIR/lib/install-idempotent.sh"

lucy_pkg_json() {
  local root="$1"
  if [[ -f "$root/package.json" ]]; then echo "$root/package.json"
  elif [[ -f "$root/frontend/package.json" ]]; then echo "$root/frontend/package.json"
  else echo ""; fi
}

lucy_pkg_dir() {
  local pj
  pj=$(lucy_pkg_json "$1")
  [[ -n "$pj" ]] && dirname "$pj" || echo ""
}

lucy_is_nextjs() {
  local root="$1"
  local pj
  pj=$(lucy_pkg_json "$root")
  [[ -n "$pj" ]] && grep -q '"next"' "$pj" 2>/dev/null && return 0
  [[ -d "$root/app" || -d "$root/src/app" ]] && return 0
  return 1
}

lucy_skill_present() {
  local root="$1" name="$2"
  case "$name" in
    impeccable) [[ -f "$root/.cursor/skills/impeccable/SKILL.md" ]] ;;
    ui-ux-pro-max) [[ -f "$root/.cursor/skills/ui-ux-pro-max/SKILL.md" ]] ;;
    taste-skill)
      [[ -f "$root/.cursor/skills/design-taste-frontend/SKILL.md" ]] || \
        [[ -f "$root/.agents/skills/design-taste-frontend/SKILL.md" ]]
      ;;
    caveman)
      [[ -f "$root/.cursor/skills/caveman/SKILL.md" ]] || \
        [[ -f "$root/.agents/skills/caveman/SKILL.md" ]]
      ;;
    claude-mem)
      [[ -d "$root/.cursor/plugins/claude-mem" ]] || \
        [[ -d "$HOME/.claude/plugins/marketplaces/thedotmack" ]] || \
        command -v claude-mem &>/dev/null
      ;;
    motion)
      local pj; pj=$(lucy_pkg_json "$root")
      [[ -n "$pj" ]] && grep -q '"motion"' "$pj" 2>/dev/null
      ;;
    nextjs-premium-stack)
      lucy_is_nextjs "$root" && \
        { [[ -f "$(lucy_pkg_dir "$root")/components.json" ]] || \
           grep -q 'lucide-react' "$(lucy_pkg_json "$root")" 2>/dev/null; }
      ;;
    visual-gate)
      lucy_playwright_ready "$root"
      ;;
    firecrawl-cli)
      command -v firecrawl &>/dev/null || [[ -f "$root/.lucy/firecrawl-ready" ]]
      ;;
    *) return 1 ;;
  esac
}

lucy_playwright_in_pkg() {
  local root="$1" pj
  pj=$(lucy_pkg_json "$root")
  [[ -n "$pj" ]] && grep -q '@playwright/test' "$pj" 2>/dev/null
}

lucy_playwright_chromium_cached() {
  [[ -d "${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}" ]] && \
    compgen -G "${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}/chromium-*" &>/dev/null
}

lucy_playwright_ready() {
  local root="$1"
  lucy_playwright_in_pkg "$root" && lucy_playwright_chromium_cached
}

lucy_claude_mem_worker_running() {
  if command -v npx &>/dev/null; then
    npx --yes claude-mem status 2>/dev/null | grep -qiE 'running|active|ok' && return 0
  fi
  pgrep -f 'claude-mem' &>/dev/null
}

lucy_brain_initialized() {
  local root="$1"
  local brain
  brain=$(lucy_brain_dir "$root" 2>/dev/null || echo "$root/.cursor/lucy-brain")
  [[ -f "$brain/STATE.json" ]]
}

lucy_hooks_up_to_date() {
  local skill_root="$1" project_root="$2"
  local src="$skill_root/hooks" dst="$project_root/.cursor/hooks/lucy"
  [[ -f "$dst/brain-hydrate.sh" && -f "$dst/brain-capture.sh" ]] || return 1
  for f in brain-hydrate.sh brain-capture.sh; do
    [[ -f "$src/$f" && -f "$dst/$f" ]] || return 1
    local a b
    a=$(md5sum "$src/$f" 2>/dev/null | awk '{print $1}')
    b=$(md5sum "$dst/$f" 2>/dev/null | awk '{print $1}')
    [[ "$a" == "$b" ]] || return 1
  done
  return 0
}

lucy_ensure_playwright() {
  local root="$1" incremental="${2:-false}"
  local pkg_dir pj

  if ! lucy_is_nextjs "$root"; then
    echo "    skip visual-gate/playwright (not Next.js)"
    return 0
  fi

  if $incremental && lucy_playwright_ready "$root"; then
    echo "    ok visual-gate (playwright + chromium)"
    return 0
  fi

  pkg_dir=$(lucy_pkg_dir "$root")
  pj=$(lucy_pkg_json "$root")
  [[ -n "$pkg_dir" ]] || { echo "    skip visual-gate (no package.json)"; return 0; }

  if ! lucy_playwright_in_pkg "$root"; then
    echo "    Installing @playwright/test (visual-gate)..."
    (cd "$pkg_dir" && npm install -D @playwright/test 2>/dev/null) || \
      echo "    WARN: playwright npm install failed"
  else
    echo "    ok @playwright/test"
  fi

  if ! lucy_playwright_chromium_cached; then
    echo "    Installing Playwright chromium (one-time)..."
    (cd "$pkg_dir" && npx --yes playwright install chromium 2>/dev/null) || \
      echo "    WARN: playwright install chromium failed"
  else
    echo "    ok playwright chromium cache"
  fi

  mkdir -p "$root/.lucy"
  date -u +%Y-%m-%dT%H:%M:%SZ > "$root/.lucy/visual-gate-ready"
}

lucy_ensure_firecrawl() {
  local root="$1" incremental="${2:-false}"

  if command -v firecrawl &>/dev/null; then
    echo "    ok firecrawl-cli ($(firecrawl --version 2>/dev/null | head -1 || echo installed))"
    mkdir -p "$root/.lucy"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$root/.lucy/firecrawl-ready"
    return 0
  fi

  if [[ -z "${FIRECRAWL_API_KEY:-}" ]]; then
    echo "    skip firecrawl-cli (set FIRECRAWL_API_KEY in env to auto-install)"
    return 0
  fi

  if $incremental && [[ -f "$root/.lucy/firecrawl-ready" ]]; then
    echo "    ok firecrawl-cli (marker)"
    return 0
  fi

  echo "    Configuring firecrawl-cli (browser scrape for @url)..."
  (cd "$root" && npx -y firecrawl-cli@latest init --all --browser 2>/dev/null) || \
    echo "    WARN: firecrawl-cli init failed — set FIRECRAWL_API_KEY and run: npx firecrawl-cli init --all --browser"
  mkdir -p "$root/.lucy"
  date -u +%Y-%m-%dT%H:%M:%SZ > "$root/.lucy/firecrawl-ready"
}

lucy_patch_quality_gates() {
  local progress="$1"
  command -v jq &>/dev/null && [[ -f "$progress" ]] || return 0
  local tmp
  tmp=$(mktemp)
  jq '
    .quality_gates = (
      (.quality_gates // {}) +
      {
        "visual_gate_auto": true,
        "visual_gate_on_fe_phase": true,
        "require_vision_before_gate": true,
        "premium_tool_orchestration": true,
        "landing_requires_motion": true,
        "landing_visual_gate_production": true
      }
    )
  ' "$progress" > "$tmp" && mv "$tmp" "$progress"
}
