#!/usr/bin/env bash
# Print guided next steps for missing MCP integrations (no secrets).
# Usage: mcp-setup-guide.sh [--slug penpot|firecrawl|visual-gate|html-first|claude-mem|cursor-browser|all]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SLUG="all"
[[ "${1:-}" == "--slug" ]] && SLUG="${2:-all}"
[[ -n "${1:-}" && "${1:-}" != "--slug" ]] && SLUG="$1"

GUIDE="$SCRIPT_DIR/../references/mcp-integrations-setup-guide.md"
STATUS_JSON="$("$SCRIPT_DIR/mcp-setup-status.sh" --json 2>/dev/null || echo '{}')"

export SLUG GUIDE STATUS_JSON
python3 <<'PY'
import json, os

slug = os.environ.get("SLUG", "all")
guide_path = os.environ.get("GUIDE", "")
raw = os.environ.get("STATUS_JSON", "{}")
try:
    status = json.loads(raw)
except json.JSONDecodeError:
    status = {}

missing = {c["slug"]: c for c in status.get("integrations", []) if not c.get("configured")}

steps = {
    "cursor-browser": [
        "1. Cursor → Settings → Tools & MCPs → ativar **Browser** (cursor-ide-browser) — toggle verde",
        "2. Command Palette → 'Browser: Open' (abrir painel uma vez para inicializar)",
        "3. Developer: Reload Window (Command Palette → 'Developer: Reload Window')",
        "4. Confirmar ~/.cursor/projects/<workspace>/mcps/cursor-ide-browser/tools/ com ~16 JSON (browser_navigate, browser_tabs, …)",
        "5. Agente testa: browser_tabs action=list",
        "Fallback headless: bash scripts/visual-gate-capture.sh (Playwright — já no init Next.js)",
        "Ver: premium-tool-orchestration.md R2 · mcp-integrations-setup-guide.md §cursor-browser",
    ],
    "penpot": [
        "1. Penpot → Settings → Integrations → Enable MCP → Generate key",
        "2. Salvar token em ~/.config/penpot/mcp-token (chmod 600)",
        "3. bash scripts/penpot-mcp-configure.sh",
        "4. Reiniciar Cursor → Tools & MCPs → Penpot verde",
        "5. Abrir arquivo Penpot → menu → MCP enabled + connected",
        "Ver também: design-editable-hybrid-protocol.md",
    ],
    "firecrawl": [
        "1. Obter API key em firecrawl.dev",
        "2. export FIRECRAWL_API_KEY=... no profile ou env do Cursor",
        "3. npx firecrawl-cli init --browser",
        "4. /lucy update para init incremental",
    ],
    "visual-gate": [
        "1. No projeto Next: npm i -D @playwright/test && npx playwright install chromium",
        "2. bash .cursor/skills/lucy/scripts/init.sh",
        "3. bash scripts/visual-gate-capture.sh --base-url http://127.0.0.1:3000",
    ],
    "html-first": [
        "1. Criar preview/<slug>.html no projeto",
        "2. bash scripts/html-preview-serve.sh",
        "3. Iterar até owner aprovar → port Next",
        "Ver: html-first-design-protocol.md",
    ],
    "claude-mem": [
        "1. build.nvidia.com → API key (nvapi-...) → ~/.claude-mem/.env (chmod 600)",
        "2. Copiar references/templates/claude-mem-settings.nvidia.json → ~/.claude-mem/settings.json",
        "3. export LUCY_CLAUDE_MEM=1",
        "4. LUCY_CLAUDE_MEM=1 bash .cursor/skills/lucy/scripts/init.sh",
        "5. npx claude-mem status && Cursor → Tools & MCPs → claude-mem ON",
        "Ver: references/claude-mem-nvidia-setup.md (multi-sessão + troubleshooting)",
    ],
}

targets = list(missing.keys()) if slug == "all" else ([slug] if slug in steps else [])

if not targets:
    if slug == "all" and not missing:
        print("Todas as integrações core estão configuradas.")
    elif slug not in steps:
        print("Slug desconhecido:", slug, "| Opções:", ", ".join(steps))
    else:
        print(slug + ": já configurado ou não aplicável.")
    raise SystemExit(0)

print("Guia canônico:", guide_path, "\n")
for s in targets:
    print("===", s, "===")
    for line in steps.get(s, []):
        print(line)
    print()
PY
