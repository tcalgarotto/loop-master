# Changelog — Lucy (loop-master)

## [2.9.34] — 2026-07-06

### knowledge-agent L2b + arquitetura de memória (`/lucy aprenda`)

- **`references/learned/l2-knowledge-agent-protocol.md`** — workflow 3 camadas: search (HYDRATE) vs corpus Q&A (retrospectiva); árvore de decisão; corpora HubFU sugeridos
- **`references/memory-architecture.md`** — mapa L0–L3 Lucy + L4/L5 comunidade; Vector DB custom vs Chroma claude-mem; skills plugin (knowledge-agent, weekly-digests, timeline-report)
- **`second-brain-protocol.md`** — HYDRATE: recall complexo → knowledge-agent ou search
- **`agent-routing-table.md`** — row knowledge-agent + discover step retrospectiva
- **`SKILL.md`** — v2.9.34; refs memory-architecture + l2-knowledge-agent

## [2.9.33] — 2026-07-06

### NVIDIA API keys — uma por usuário (`/lucy aprenda`)

- **`references/learned/nvidia-api-keys-per-user.md`** — política global: key pessoal, sem compartilhamento, workflow guide-only (build.nvidia.com)
- **`references/credentials-policy.md`** — política de credenciais do skill pack; cross-link `no-env-credentials`
- **`claude-mem-zero-config-playbook.md`**, **`claude-mem-nvidia-setup.md`**, **`mcp-integrations-setup-guide.md`**, **`claude-mem-mcp-operational-playbook.md`** — seção segurança per-user; anti-padrões (não pedir key no chat)

## [2.9.32] — 2026-07-06

### claude-mem zero-config (`/lucy aprenda`)

- **`scripts/claude-mem-bootstrap.sh`** — idempotente: settings NVIDIA, `.env` com ambas vars (`CLAUDE_MEM_OPENROUTER_API_KEY` + `OPENROUTER_API_KEY`), alias auto a partir de key existente, worker start, doctor, contagens SQLite/Chroma
- **`references/learned/claude-mem-zero-config-playbook.md`** — guia owner 3 passos (key → `LUCY_CLAUDE_MEM=1` → bootstrap)
- **`init.sh`** — chama bootstrap automaticamente quando `LUCY_CLAUDE_MEM=1`
- **`claude-mem-nvidia-setup.md`**, **`mcp-integrations-setup-guide.md`**, **`mcp-setup-guide.sh`** — caminho zero-config + bootstrap

## [2.9.31] — 2026-07-05

### Migrations + recreate backend proativos (`/lucy aprenda`)

- **`references/learned/proactive-migration-backend-restart.md`** — owner authorization: `alembic upgrade head` + `docker compose up -d --force-recreate backend` executados proativamente quando schema/backend muda; verify health + smoke obrigatórios; downgrade/drop/recreate de banco continuam exigindo confirmação
- **`learned/proactive-orchestration-mandate.md`** — nota "não são exceção": migration + backend restart
- **`learned/INDEX.md`** — entrada `proactive-migration-backend-restart`

## [2.9.30] — 2026-07-05

### Mandato de orquestração proativa (`/lucy aprenda`)

- **`references/learned/proactive-orchestration-mandate.md`** — owner authorization: agente MUST ativar skills/MCPs quando protocolo indica; checklist pré-ação; anti-padrões "Posso usar X?"; exceções destructive/credentials/deploy
- **`learned/autonomous-routing-contract.md`** — § Mandato proativo v2.9.30+: semi-auto → MUST activate; sem router em código permanece honesto
- **`autonomous-orchestrator-protocol.md`** — mandamento #8 ativação proativa
- **`premium-tool-orchestration.md`** — preamble mandato proativo
- **`SKILL.md`** — tick § Durante: orquestração proativa + anti-padrão pedir permissão

## [2.9.29] — 2026-07-05

### Contrato de roteamento autônomo (`/lucy aprenda`)

- **`references/learned/autonomous-routing-contract.md`** — matriz honesta: HYDRATE/rules/quality_gates automáticos; slash commands e MCP opt-in; GSAP semi-auto; gaps conhecidos
- **`premium-tool-orchestration.md`** — § automático vs comando + cross-link

## [2.9.28] — 2026-07-05

### claude-mem MCP — playbook operacional (`/lucy aprenda`)

- **`references/learned/claude-mem-mcp-operational-playbook.md`** — 4 camadas de status, workflow 3-layer search→timeline→get_observations, NVIDIA NIM default `meta/llama-3.3-70b-instruct`
- **`claude-mem-nvidia-setup.md`**, **`mcp-integrations-setup-guide.md`**, **`second-brain-protocol.md`** — cross-links + verificação agente
- **`scripts/mcp-setup-status.sh`** — detecta worker via `npx claude-mem` (fix false negative)

## [2.9.27] — 2026-07-05

### GSAP Cursor plugin — orquestração (`/lucy aprenda`)

- **`references/learned/gsap-plugin-orchestration.md`** — 8 skills oficiais (não MCP), árvore de decisão, register brand/product, pirâmide html→GSAP→Framer, anti-padrões
- **`gsap-premium-protocol.md`** — § plugin skills + auto-load gsap-react vs gsap-scrolltrigger
- **`premium-tool-orchestration.md`**, **`design-skills-routing-table.md`** — rows GSAP plugin + R1 scan
- **`learned/INDEX.md`** — entrada `gsap-plugin-orchestration`

## [2.9.26] — 2026-07-05

### Case studies — Neo Mirai #001 (`/lucy aprenda`)

- **`references/case-studies/neo-mirai-impeccable.md`** — estudo completo: visual DNA, section anatomy, craft pipeline, triggers, anti-patterns
- **`references/case-studies/INDEX.md`** — catálogo owner-provided (#001+) para sugestões brand
- **`references/learned/case-study-neo-mirai.md`** — log PT-BR
- **`design-system-intake.md`** — seção case study references
- **`premium-tool-orchestration.md`** — R5b: checar INDEX ao sugerir landing
- **`impeccable-lucy-integration.md`** — `/impeccable craft` 4 fases + Neo Mirai exemplar
- **`template-gallery.md`** — §10 Neo Mirai conference template

## [2.9.25] — 2026-07-05

### Premium motion & scroll storytelling (`/lucy aprenda`)

- **`references/premium-motion-scroll-protocol.md`** — mestre: art-directed imagery, scroll reveals, pin+scrub vídeo/canvas, sandwich stack, morphism tasteful, scroll storytelling 3 acts; register brand vs product
- **`references/learned/premium-motion-patterns.md`** — log PT-BR
- **`gsap-premium-protocol.md`** — cross-links pin/scrub/sandwich (sem duplicar receitas)
- **`premium-tool-orchestration.md`** — R4b: quando SUGERIR (brand) vs restringir (product)
- **`design-skills-routing-table.md`**, **`template-gallery.md`** — rotas + templates editorial hero, pin-scrub, sandwich

## [2.9.24] — 2026-07-05

### Live Mode no VPS — guia owner (`/lucy aprenda`)

- **`references/learned/impeccable-live-mode.md`** — § "Quando o owner pede Live Mode no VPS": árvore A/B/C/D, template de resposta Lucy, can vs cannot
- **`references/learned/vps-live-mode-owner-guide.md`** — playbook checklist (tunnel SSH, Cursor Ports, Desktop local, firewall)
- **`impeccable-lucy-integration.md`** — gatilhos de frase + routing P0 (nunca só "não funciona")
- **`premium-tool-orchestration.md`**, **`owner-handoff-qa-protocol.md`** — cross-links e `oh_r4_live_mode_vps`

## [2.9.23] — 2026-07-05

### Impeccable Live Mode + 8 pilares (`/lucy aprenda`)

- **`references/learned/impeccable-live-mode.md`** — guia PT-BR: pré-requisitos, poll loop, pick/variantes/accept/carbonize, frameworks, limitações, VPS vs Desktop
- **`references/learned/impeccable-eight-pillars.md`** — 8 capacidades impeccable.style com routing por tick/refazer/nova-pagina
- **`impeccable-lucy-integration.md`** — seção Live Mode + bootstrap PRODUCT/DESIGN HubFU
- **`premium-tool-orchestration.md`** — momento "iteração visual 1 elemento"

## [2.9.22] — 2026-07-05

### Impeccable no cérebro Lucy (`/lucy aprenda`)

- **`references/learned/impeccable-capabilities-map.md`** — catálogo completo: 23 comandos, register brand/product, 45 regras detector, live/CLI/extension, setup PRODUCT.md/DESIGN.md
- **`references/learned/impeccable-lucy-integration.md`** — routing explícito: ticks minor cycle, refazer-frontend, nova-pagina, visual-gate + checklist pré-gate
- Cross-links em `impeccable-routing-table.md`, `design-skills-routing-table.md`, `premium-tool-orchestration.md`, `references/README.md`

## [2.9.21] — 2026-07-05

### Design visual HTML — discussão → preview (`/lucy aprenda`)

- **`references/design-visual-html-protocol.md`** — owner rule global: ler `page.tsx`, HTML standalone com seletor de variantes; default **2 light + 2 dark**; persistir decisão + port CSS vars mínimo
- **`design-skills-routing-table.md`** — rotear paleta/tema/layout para HTML preview antes de impeccable no Next
- **`html-first-design-protocol.md`**, **`lucy-aprenda-protocol.md`**, **`learned/INDEX.md`** — slug `design-visual-html-defaults`
- Referência HubFU: `frontend/preview/inbox-theme-picker.html` (B light / C dark)

## [2.9.19] — 2026-07-04

### VPS headless browser default (`/lucy aprenda`)

- **`references/learned/vps-headless-browser-default.md`** — Playwright headless é browser padrão em VPS/Remote SSH; MCP `cursor-ide-browser` toolCount=0
- **`hooks/brain-hydrate.sh`** — sessionStart chama `ensure-headless-browser.sh` e injeta routing Playwright no contexto
- **`scripts/cursor-browser-seed-tools.sh`** — copia descriptors MCP de outro workspace quando `tools/` vazio
- **`scripts/ensure-headless-browser.sh`** — instala Playwright + chromium; grava `.lucy/headless-browser-ready.json`
- **`scripts/browser-open-url.mjs`** — screenshot URL externa (profiler share, etc.)
- **`mcp-setup-status.sh`** — `browser_primary`, `headless_browser_ready`, `remote_vps`
- **`premium-tool-orchestration.md` R2**, **`browser-ai-scrape-protocol.md`**, **`mcp-integrations-setup-guide.md`** — routing VPS-first

## [2.9.18] — 2026-07-04

### Edição inline otimista — planilhas densas (`/lucy aprenda`)

- **`references/optimistic-inline-edit-protocol.md`** — useOptimistic + Server Actions; HTMX alternativa; anti-padrões; prompt template
- **`references/design-system/hubfu/editable-table.md`** — spec HubfuSheet → EditableTable / InlineEditCell
- **`references/design-system/hubfu/snippets/optimistic-leads-table.tsx.example`** — snippet Next.js (comentários PT)
- **`preview/hubfu-sheet.js`** — save otimista: dot `row-syncing`, debounce 300ms, ~5% falha demo + toast rollback
- **`preview/hubfu-design-tokens.css`** — `.hubfu-toast`, `.row-syncing`
- HubFU `components.md` + `INDEX.md` v1.3; cross-link `html-native-light-protocol.md`

### Cursor Browser MCP — detecção Round 3 + seed tools

- **`mcp-setup-status.sh`** — slug `cursor-browser`: detecta `mcps/cursor-ide-browser/tools/` (~16 JSON)
- **`mcp-setup-guide.sh`** — guia passo a passo (Settings → Browser ON → Reload Window)
- **`cursor-browser-seed-tools.sh`** — copia descriptors de outro workspace se `tools/` vazio
- **`quiz-next.sh`**, **`quiz-protocol.md`** — Round 3 inclui Cursor Browser na prioridade
- **`mcp-integrations-setup-guide.md`**, **`premium-tool-orchestration.md`** — § cursor-browser (P0)

---

## [2.9.15] — 2026-07-03

### claude-mem L2 — NVIDIA build.nvidia.com + multi-sessão

- **`references/claude-mem-nvidia-setup.md`** — setup passo a passo: NVIDIA NIM via openrouter provider, `.env` secrets, opt-in `LUCY_CLAUDE_MEM=1`, MCP Cursor, troubleshooting, C62 vs VPS
- **Templates:** `references/templates/claude-mem-settings.nvidia.json`, `claude-mem-nvidia.env.example`
- **`mcp-integrations-setup-guide.md`** — § claude-mem atualizado (NVIDIA em vez de DeepSeek)
- **`second-brain-protocol.md`**, **`memory-protocol.md`** — regras multi-sessão paralela (single-writer L1, rótulos `[design]`/`[integration]`/`[security]`)
- **`scripts/mcp-setup-guide.sh`** — passos NVIDIA para slug claude-mem

---

## [2.9.14] — 2026-07-03

### claude-mem L2 opt-out por padrão

- **`init.sh`** — remove claude-mem do default skills; instala/start só com `LUCY_CLAUDE_MEM=1`
- **`brain-sync.sh`** — hints MCP L2 só quando opt-in + worker/MCP presente; skip silencioso
- **`install-idempotent.sh`** — helpers `lucy_claude_mem_enabled`, `lucy_claude_mem_active`
- **Docs:** `SKILL.md`, `second-brain-protocol.md`, `memory-protocol.md` — L2 opcional; L0+L1 suficientes
- **Aprendizado:** `references/learned/` — claude-mem optional

---

## [2.9.13] — 2026-07-03

### Aprendizado global (`/lucy aprenda`) + docs sync

- **`html-preview-interactive-mocks-protocol.md`** — kanban DnD nativo (drag cards, column drop targets, drag-over styling, GSAP snap on drop); section gate `waitUntil: load` (estável vs `networkidle`)
- HubFU `preview/hubfu-landing-premium.html` **v9**: feature kanbans CRM/ERP/finance com drag-drop funcional
- **Docs sync:** README, MANUAL, `references/README.md`, routing tables alinhados a v2.9.11–2.9.12 (integration cards, section gate, regressions v8)

---

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
