# VPS / Remote SSH — Playwright headless é o browser padrão

**Origem:** `/lucy aprenda` 2026-07-04 — HubFU VPS; agentes falhavam com `CallMcpTool` → `browser_*` = Tool not found.

---

## Regra P0 (memória permanente)

| Ambiente | Browser correto | Proibido |
|----------|-----------------|----------|
| VPS, Remote SSH, Cloud Agent, sem `DISPLAY` | **Playwright headless** via shell | `browser_navigate`, `browser_tabs`, `browser_cdp` |
| Cursor Desktop local + `tools/` ≥ 10 JSONs | Cursor Browser MCP | — |
| Subagent (`Task`) | Playwright no **agente pai** ou shell | Qualquer MCP browser no subagent |

**Sintoma falso positivo:** `cursor-ide-browser` aparece na lista MCP do projeto, mas lease retorna `toolCount: 0`. Metadata ≠ runtime.

**Nunca** copiar `tools/*.json` de outro workspace — gera `mcp_disk_discovery_freshness_mismatch` sem habilitar handlers.

---

## Bootstrap obrigatório (antes de qualquer task com browser)

```bash
bash .cursor/skills/lucy/scripts/ensure-headless-browser.sh --project .
```

Saída: `.lucy/headless-browser-ready.json` com `primary: "playwright"` e comandos prontos.

---

## Comandos canônicos (VPS)

```bash
# URL externa (profiler share, pricing concorrente, etc.)
bash .cursor/skills/lucy/scripts/browser-open-url.mjs --url 'https://...' --out .lucy/browser/capture.png

# App local (dev server up)
bash .cursor/skills/lucy/scripts/visual-gate-capture.sh --base-url http://127.0.0.1:3000

# Red team / segurança
make security-browser HUBFU_URL=https://example.com
```

Projeto pode ter wrapper em `scripts/browser/open-url.mjs` — preferir o do skill pack se ausente.

---

## Detecção

```bash
bash .cursor/skills/lucy/scripts/mcp-setup-status.sh --json
# → browser_primary, headless_browser_ready, cursor_browser_tools_count
```

---

## Referências

- `premium-tool-orchestration.md` — R2
- `browser-ai-scrape-protocol.md` — árvore de decisão
- `mcp-integrations-setup-guide.md` — § cursor-browser vs § visual-gate
- `visual-gate-protocol.md`
