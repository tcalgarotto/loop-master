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
| `scripts/mcp-setup-status.sh --json` | Detectar o que está configurado |
| `scripts/mcp-setup-guide.sh` | Próximos passos para itens faltando |
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

## § claude-mem — Memória L2

**Quando sugerir:** sempre no init (Recommended).

| Passo | Ação |
|-------|------|
| 1 | `bash .cursor/skills/lucy/scripts/init.sh` |
| 2 | `claude-mem start` |
| 3 | `claude-mem status` |

Ver: `second-brain-protocol.md`

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

O quiz Round 3 lista os **core** (Penpot, HTML-first, visual-gate, Firecrawl, claude-mem). Plugins opcionais entram em `r3m_optional` (multi).

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
| `bash scripts/mcp-setup-status.sh` | Status manual |
| `bash scripts/mcp-setup-guide.sh --slug penpot` | Guia Penpot |
