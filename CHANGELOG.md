# Changelog — Lucy (loop-master)

## [2.9.12] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`html-preview-interactive-mocks-protocol.md`** — anti-padrões JS preview: TDZ/`reduced`, paginação marketplace 9/página, logo fallback chain, hero/tab P0 regression checklist, feature kanban minmax
- HubFU `preview/hubfu-landing-premium.html` **v8**: hero nav + tabs fix, marketplace search/filter/pagination, carousel 90s, logos simple-icons v13
- **`scripts/build-hubfu-integrations-data.py`** — slugs pagseguro, n8n, googleshopping→google; mercadolibre sem ícone

---

## [2.9.11] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`integration-cards-patterns.md`** — 3 modelos canônicos (carousel pills, marketplace sidebar, grid denso) com logos reais
- **`html-preview-interactive-mocks-protocol.md`** — carousel ≥8 integrações, contraste dark P0, QA screenshot por seção
- **`scripts/html-preview-section-gate.sh`** — Playwright full-page + seções para HTML preview
- **`visual-gate-protocol.md`** — extensão HTML-first
- HubFU `preview/hubfu-landing-premium.html` v6: carousel integrações, contraste estoque hero, kanban sem clip

---

## [2.9.10] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`html-preview-interactive-mocks-protocol.md`** — mocks HTML com interatividade real, motion equilibrado, grid integrações, barras exponenciais, kanban funcional
- HubFU `preview/hubfu-landing-premium.html` v5 implementa o protocolo
- Cross-links: `html-first-design-protocol.md`, `premium-tool-orchestration.md`, `lucy-aprenda-protocol.md`

---

## [2.9.9] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **Quiz 7 rodadas** — Round 3 dedicado a MCP/integrações: detecta gaps, sugere cadastro, guia setup
- **`mcp-integrations-setup-guide.md`** — guia canônico Penpot, HTML-first, visual-gate, Firecrawl, claude-mem
- **`scripts/mcp-setup-status.sh`** — scan local sem expor secrets
- **`scripts/mcp-setup-guide.sh`** — passos guiados por integração
- `quiz-protocol.md` · `init-protocol.md` · `SKILL.md` atualizados

---

## [2.9.8] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`design-editable-hybrid-protocol.md`** — Caminho C: iterar HTML em `preview/` até aprovação → Penpot MCP (tokens/DS) → port Next → Puck opcional
- **`scripts/penpot-mcp-configure.sh`** — configura Cursor MCP a partir de `~/.config/penpot/mcp-token` (sem secrets no repo)
- `premium-tool-orchestration.md` · `html-first-design-protocol.md` · `SKILL.md` cross-links

---

## [2.9.7] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`html-first-design-protocol.md`** — prototipar landing em `preview/*.html` antes de Next; loop de edição live com owner
- **`scripts/html-preview-serve.sh`** — servidor local porta 8765 para iterar HTML
- **Biblioteca canônica de referências:** shadcn/ui, Atlassian Design, Figma Community, Material 3
- `premium-tool-orchestration.md` R3 HTML-first · `lucy-nova-pagina-protocol.md` Fase 1.5 · `design-system-intake.md` links

---

## [2.9.6] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`premium-tool-orchestration.md`** — regras P0: usar taste+impeccable+GSAP+browser no momento certo
- **`design-system-intake.md`** — protocolo quando owner taga design systems
- **Landing premium:** motion obrigatório + visual-gate na URL final; anti “Carregando flags…” SSR
- **`firecrawl-cli` no init** — auto se `FIRECRAWL_API_KEY`; Playwright já default
- `quality_gates`: `premium_tool_orchestration`, `landing_requires_motion`, `landing_visual_gate_production`

---

## [2.9.5] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`references/browser-ai-scrape-protocol.md`** — pipeline 3 passos: browser → screenshot + markdown → LLM/vision
- Roteamento: Playwright (app), Firecrawl scrape/map/Browser Sandbox, Browserbase, Bright Data, Obscura, Crawl4AI
- `competitive-intelligence.md` — fallback URLs + `.lucy/browser/` obrigatório screenshot em `@url`

---

## [2.9.4] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **Visual gate automático** em `/lucy init` e `/lucy update` — `quality_gates` no JSON (default on)
- **`init.sh --update-mode` incremental** — instala só o que falta (skills, claude-mem, playwright, hooks, brain)
- **`scripts/lib/install-idempotent.sh`** — helpers de checagem
- Update reporta `git: already up to date` quando não há commits novos

---

## [2.9.3] — 2026-07-03

### Aprendizado global (`/lucy aprenda`) — Visual gate

- **`/lucy visual-gate`** — Playwright captura desktop + mobile por rota
- **`scripts/visual-gate-capture.sh`** — grava `.lucy/visual-gates/tick-N/`
- **`references/visual-gate-protocol.md`** — checklist vision V1–V8 (ux-design-intelligence)
- `last_visual_audit` no progress JSON + `audit-checklist.md` §9
- Gate FE bloqueado sem análise visual de PNGs no Cursor

---

## [2.9.2] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`references/docs-sync-discipline.md`** — regra P0: após mudança em comando/script/protocolo → grep docs → sync README/MANUAL/SKILL/references/README/CHANGELOG → bump patch → `learned/INDEX`
- Integrado em `SKILL.md` (handoff + anti-padrão), `lucy-aprenda-protocol.md`, `autonomous-orchestrator-protocol.md`

---

## [2.9.1] — 2026-07-03

### Documentação

- `README.md`, `MANUAL.md`, `getting-started.md`, `references/README.md` sincronizados com v2.9.1

### `/lucy refazer-frontend` — design premium (sem mudar rotas)

- Foco em **design only**: impeccable critique → craft → polish; **URLs preservadas**
- Inventário detecta **AI slop**, rotas **órfãs** e **duplicadas**
- **Quiz de design** em 4 rodadas (`design-quiz-next.sh`, IDs `d1_*`–`d4_*`)
- Escopo: **todo o frontend** ou **só rotas mencionadas** (`--escopo`)

---

## [2.9.0] — 2026-07-03

### Novos comandos frontend

- **`/lucy refazer-frontend`** — inventário page-by-page + refactor com skills mapeadas
- **`/lucy nova-pagina`** — landing ou página app do zero (`--tipo landing|app`)
- Script `frontend-inventory.sh`

---

## [2.8.5] — 2026-07-03

### Dois escopos de aprendizado

- **`/lucy aprenda`** — evolução **global** → GitHub (todos recebem no update)
- **`/lucy regra`** — regras **P0 imutáveis** do projeto (`.cursor/lucy-brain/rules/`)

---

## [2.8.4] — 2026-07-03

- Protocolo **GSAP premium** (timelines, ScrollTrigger, stagger)
- Comando **`/lucy aprenda`** + `aprenda-capture.sh`

---

## [2.8.3] — 2026-07-03

- `html-native-light-protocol`: **View Transitions**, `animation-timeline: view()`, scroll scrub

---

## [2.8.2] — 2026-07-03

- Comando único **`/lucy`** (remove alias `/loop-master` e pasta `lucy-pack`)
- `html-native-light-protocol`: dialog/`command`, Popover, HTMX parcial

---

## [2.8.1] — 2026-07-03

- Fix migração `loop-master` → `lucy` (fallbacks corrompidos na 2.8.0)

---

## [2.8.0] — 2026-07-03

### Rebrand Lucy

- `loop-master` → **Lucy** (`lucy-progress.json`, `lucy-brain/`, hooks `lucy/`)
- `migrate-loop-master-to-lucy.sh` + `lucy-paths.sh`
- README e hero `assets/lucy-hero-18x9-4k.png`

---

[2.9.6]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.6
[2.9.5]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.5
[2.9.4]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.4
[2.9.3]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.3
[2.9.2]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.2
[2.9.1]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.1
