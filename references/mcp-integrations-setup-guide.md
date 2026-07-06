# MCP & Integrações — guia de cadastro (memória da skill)

**Origem:** `/lucy aprenda` — 2026-07-03  
**Papel:** o quiz (Round 3) e o agente usam este guia para **sugerir**, **detectar gaps** e **guiar o owner** passo a passo.

> Complementa: `design-editable-hybrid-protocol.md` · `quiz-protocol.md` · `premium-tool-orchestration.md`

---

## Mandamento (P0)

> No `/lucy init`, **Round 3** roda `mcp-setup-status.sh`, mostra o que falta e oferece **guiar o cadastro agora** antes de continuar o quiz.

Scripts:

| Script | Uso |
|--------|-----|
| `scripts/mcp-setup-status.sh --json` | Detectar o que está configurado (incl. **Cursor Browser** nativo) |
| `scripts/mcp-setup-guide.sh` | Próximos passos para itens faltando |
| `scripts/cursor-browser-seed-tools.sh` | Seed descriptors `tools/` se Cursor não materializou |
| `scripts/penpot-mcp-configure.sh` | Aplicar token Penpot no Cursor |

---

## Round 3 do quiz — fluxo do agente

1. `bash scripts/mcp-setup-status.sh --json`
2. Apresentar ao owner o resumo (OK / FALTA) em 3–5 linhas
3. **AskQuestion** com IDs `r3m_*` (ver `quiz-protocol.md`)
4. Se `r3m_guidance` = **Guiar setup agora (Recommended)**:
   - Para cada slug em `missing_slugs`: `mcp-setup-guide.sh --slug <slug>`
   - Executar passos que não exigem secret do owner (init, playwright install)
   - Pedir ao owner só o que for secret (token Penpot, API keys)
   - Re-rodar `mcp-setup-status.sh` e confirmar progresso
5. Persistir `quiz_answers.round_3` + `mcp_setup_status` snapshot no progress JSON
6. Só então avançar para Round 4 (Design)

---

## § penpot — Design editável (Caminho C)

**Quando sugerir:** superfície visual (landing/app), design system, Caminho C híbrido.

| Passo | Ação |
|-------|------|
| 1 | [penpot.app](https://penpot.app) → conta gratuita |
| 2 | Settings → Integrations → **Enable MCP** → Generate key |
| 3 | Token em `~/.config/penpot/mcp-token` (chmod 600) — **nunca no repo** |
| 4 | `bash scripts/penpot-mcp-configure.sh` |
| 5 | Reiniciar Cursor → Settings → Tools & MCPs → **penpot** verde |
| 6 | Abrir arquivo no Penpot → menu → MCP **enabled + connected** |

**Rotacionar token:** delete key no Penpot → nova key → atualizar `mcp-token` → `penpot-mcp-configure.sh` → restart Cursor.

**Teste:** "Qual arquivo está aberto no Penpot?"

Ver: `design-editable-hybrid-protocol.md`

---

## § html-first — Preview local antes de Next

**Quando sugerir:** landing nova, design incerto, owner quer ver no browser.

| Passo | Ação |
|-------|------|
| 1 | `preview/<projeto>-<pagina>.html` |
| 2 | `bash scripts/html-preview-serve.sh` → `http://127.0.0.1:8765` |
| 3 | Loop owner + agente até aprovação |
| 4 | Port Next só depois |

Ver: `html-first-design-protocol.md`

---

## § cursor-browser — Browser integrado Cursor (Desktop local only)

**Quando sugerir:** Cursor Desktop **local** (não Remote SSH/VPS). Complementa Playwright headless.

| Passo | Ação |
|-------|------|
| 1 | **Cursor → Settings → Tools & MCPs** → ativar **Browser** (`cursor-ide-browser`) |
| 2 | Command Palette → **Browser: Open** (inicializa painel uma vez) |
| 3 | **Developer: Reload Window** |
| 4 | Confirmar `~/.cursor/projects/<workspace>/mcps/cursor-ide-browser/tools/` (~16 JSON) |
| 5 | Agente: `browser_tabs` action=list |

**VPS / Remote SSH:** lease retorna `toolCount: 0` — **não usar** MCP browser. Rodar:

```bash
bash .cursor/skills/lucy/scripts/ensure-headless-browser.sh --project .
```

Ver: `references/learned/vps-headless-browser-default.md`

**Detectar:** `bash scripts/mcp-setup-status.sh --json` → `browser_primary`, `headless_browser_ready`.

**Seed de descriptors:** **não recomendado** — copiar `tools/` de outro workspace causa mismatch sem habilitar runtime.

**Fallback (sempre):** Playwright — `ensure-headless-browser.sh`, `browser-open-url.mjs`, `visual-gate-capture.sh`.

---

## § visual-gate — Playwright + vision QA

**Quando sugerir:** projeto Next.js, fases FE, landing em produção.

| Passo | Ação |
|-------|------|
| 1 | `bash .cursor/skills/lucy/scripts/init.sh` (instala Playwright se Next) |
| 2 | `npx playwright install chromium` |
| 3 | `bash scripts/visual-gate-capture.sh --base-url <URL>` |

Ver: `visual-gate-protocol.md`

---

## § firecrawl — Scrape e análise competitiva

**Quando sugerir:** `/lucy @url`, gap analysis, sites externos.

| Passo | Ação |
|-------|------|
| 1 | API key em [firecrawl.dev](https://firecrawl.dev) |
| 2 | `export FIRECRAWL_API_KEY=...` (profile ou Cursor env) |
| 3 | `npx firecrawl-cli init --browser` |
| 4 | `/lucy update` |

Fallback sem key: Playwright + `browser-ai-scrape-protocol.md`

---

## § claude-mem — Memória L2 (opt-in)

**Quando sugerir:** owner com 2+ sessões paralelas ou recall cross-session (Recommended se RAM OK).

**Padrão v2.9.14+:** desabilitado — L0 brain + L1 JSON bastam. Habilitar só com opt-in.

**Guia zero-config (3 passos):** `learned/claude-mem-zero-config-playbook.md`

**MCP Cursor:** plugin `plugin-claude-mem-mcp-search` (tools: `search`, `timeline`, `get_observations`, `observation_add`).  
**Backend LLM:** NVIDIA NIM via `build.nvidia.com` — **não** é MCP separado; key em `~/.claude-mem/.env`.

| Passo | Ação |
|-------|------|
| 1 | API key em [build.nvidia.com](https://build.nvidia.com) → colar **uma vez** em `~/.claude-mem/.env` (chmod 600) |
| 2 | `LUCY_CLAUDE_MEM=1` no `.env` do projeto |
| 3 | `LUCY_CLAUDE_MEM=1 bash .cursor/skills/lucy/scripts/claude-mem-bootstrap.sh` |
| 4 | Cursor → Settings → Tools & MCPs → **claude-mem** verde |
| 5 | Teste agente: MCP `search(query="projeto")` → índice com IDs |

*Alternativa:* `LUCY_CLAUDE_MEM=1 bash scripts/init.sh --update-mode incremental` (chama bootstrap automaticamente).

**Workflow MCP (3 camadas):** `search` → `timeline(anchor=ID)` → `get_observations([IDs])` — nunca pular filtro.

**Provider:** openrouter-compatible apontando para NVIDIA NIM (`integrate.api.nvidia.com/v1`) — **não** DeepSeek.

**Modelo default:** `meta/llama-3.3-70b-instruct` (ver `claude-mem-nvidia-setup.md` para alternativas VPS).

**Multi-sessão:** L2 = índice compartilhado (search); L1 `lucy-progress.json` = **single writer** — ver guia completo.

Ver: `claude-mem-nvidia-setup.md` · `learned/claude-mem-mcp-operational-playbook.md` · `second-brain-protocol.md` · `memory-protocol.md`

---

## MCPs opcionais (Cursor plugins)

Cadastrar em **Cursor → Settings → Tools & MCPs** conforme o projeto:

| MCP | Uso Lucy | Cadastro |
|-----|----------|----------|
| **Vercel** | deploy, previews | Plugin Cursor + login |
| **Supabase** | DB, auth | Plugin + project ref |
| **Stripe** | pagamentos | Plugin + API key |
| **Sentry** | erros prod | Plugin + DSN |
| **Linear** | issues | Plugin OAuth |
| **Notion** | docs/specs | Plugin workspace |
| **Figma** | intake only (não editar vivo) | Plugin — rate limit |

O quiz Round 3 lista os **core** (Cursor Browser, Penpot, HTML-first, visual-gate, Firecrawl, claude-mem). Plugins opcionais entram em `r3m_optional` (multi).

---

## Persistência no progress JSON

Após Round 3:

```json
{
  "quiz_answers": {
    "round_3": {
      "mcp_priority": ["penpot", "html-first", "visual-gate"],
      "guidance": "guide_now",
      "design_pipeline": "html_first_until_approved",
      "optional_mcps": ["vercel", "supabase"]
    }
  },
  "mcp_setup_status": {
    "captured_at": "ISO8601",
    "missing_slugs": ["firecrawl"],
    "configured_slugs": ["penpot", "html-first", "claude-mem"]
  }
}
```

---

## Anti-padrões

- Pular Round 3 quando há itens `FALTA` sem owner escolher "Depois"
- Colocar tokens/API keys no repo ou `lucy-progress.json`
- Prometer Figma MCP para edição em loop
- Avançar para implementação FE sem visual-gate configurado (se Next)

---

## Comandos

| Comando | Uso |
|---------|-----|
| `/lucy init` | Round 3 guia MCP |
| `/lucy update` | Re-scan integrações |
| `bash scripts/mcp-setup-status.sh` | Status manual (incl. Cursor Browser) |
| `bash scripts/mcp-setup-guide.sh --slug cursor-browser` | Guia Browser nativo |
| `bash scripts/cursor-browser-seed-tools.sh --project .` | Seed descriptors tools/ |
| `bash scripts/mcp-setup-guide.sh --slug penpot` | Guia Penpot |
