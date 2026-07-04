# Lucy — aprendizados globais (`/lucy aprenda` only)

Publicados no GitHub (`loop-master`) — **todos** recebem no `/lucy update`.  
Regras **por projeto** → `/lucy regra` → `.cursor/lucy-brain/rules/` (não listadas aqui).

| Data | Slug | Resumo | Protocolo canônico |
|------|------|--------|-------------------|
| 2026-07-04 | `vps-headless-browser-default` | VPS/SSH: Playwright headless é browser padrão; MCP cursor-ide-browser toolCount=0; ensure-headless-browser.sh | `references/learned/vps-headless-browser-default.md`, `scripts/ensure-headless-browser.sh` |
| 2026-07-04 | `optimistic-inline-edit-v1` | useOptimistic + Server Actions + HubfuSheet save otimista; EditableTable/InlineEditCell spec | `optimistic-inline-edit-protocol.md`, `design-system/hubfu/editable-table.md` |
| 2026-07-04 | `firefox-profiler-multi-process-tracks` | Profiler captura TODOS os processos do navegador, não só a aba ativa; track de domínio desconhecido = provável aba irmã, não embed; checar PIDs + grep código antes de suspeitar de bug | `references/learned/firefox-profiler-multi-process-tracks.md` |
| 2026-07-03 | `react-list-keys-unique` | Footer/nav: key = scope+label, nunca só href; grep antes visual gate | `references/learned/react-list-keys-unique.md` |
| 2026-07-03 | `hubfu-pricing-landing-integrity` | Matriz pricing auditada vs produto; sem hints fake; CTAs uniformes; FAQ/footer premium | `references/learned/hubfu-pricing-landing-integrity.md` |
| 2026-07-03 | `claude-mem-nvidia-l2` | L2 claude-mem com NVIDIA NIM (build.nvidia.com); multi-sessão sem corromper L1; templates settings/.env | `claude-mem-nvidia-setup.md` |
| 2026-07-03 | `hubfu-docs-sync-v2913` | Audit docs-sync: README/MANUAL/routing alinhados v2.9.11–13; CHANGELOG v9 kanban DnD | `docs-sync-discipline.md` |
| 2026-07-03 | `html-preview-kanban-dnd-v9` | Kanban DnD nativo + GSAP snap; section gate waitUntil load | `html-preview-interactive-mocks-protocol.md` |
| 2026-07-03 | `integration-cards-patterns` | 3 modelos carousel/marketplace/grid; logos reais; build-hubfu script | `integration-cards-patterns.md` |
| 2026-07-03 | `html-preview-section-gate` | Playwright full-page + screenshots por seção para HTML preview | `visual-gate-protocol.md`, `html-preview-interactive-mocks-protocol.md` |
| 2026-07-03 | `html-preview-regressions-v8` | Anti-padrões JS: reduced TDZ, paginação 9/página, logo fallback chain, hero/tab P0 checklist | `html-preview-interactive-mocks-protocol.md` |
| 2026-07-03 | `html-interactive-mocks` | Mocks HTML reais: nav troca view, kanban funcional, integrações carousel, contraste dark, section gate | `html-preview-interactive-mocks-protocol.md` |
| 2026-07-03 | `mcp-quiz-setup-guide` | Quiz Round 3 MCP; mcp-setup-status/guide; guia cadastro integrações | `mcp-integrations-setup-guide.md` |
| 2026-07-03 | `design-editable-hybrid` | Caminho C: HTML até aprovar, Penpot MCP, port Next, Puck opcional | `design-editable-hybrid-protocol.md` |
| 2026-07-03 | `html-first-design` | HTML preview local antes de Next; shadcn/Atlassian/Figma/M3 como refs | `html-first-design-protocol.md` |
| 2026-07-03 | `premium-tool-orchestration` | P0: taste+GSAP+browser+Firecrawl por momento; landing com motion | `premium-tool-orchestration.md` |
| 2026-07-03 | `browser-ai-scrape` | Pipeline browser→screenshot+markdown→LLM/vision | `browser-ai-scrape-protocol.md` |
| 2026-07-04 | `visual-gate-auto-incremental-update` | Visual gate default on init/update; update só instala deps faltantes | `visual-gate-protocol.md`, `install-idempotent.sh` |
| 2026-07-03 | `visual-gate` | Playwright desktop+mobile + vision checklist V1–V8 antes do gate FE | `references/visual-gate-protocol.md` |
| 2026-07-03 | `docs-sync-discipline` | Grep docs + sync README/MANUAL/SKILL/CHANGELOG + bump patch após mudança | `references/docs-sync-discipline.md` |
| 2026-07-03 | `gsap-premium` | GSAP para timelines/ScrollTrigger/stagger; CSS só hover; sem `transition-*` com GSAP | `references/gsap-premium-protocol.md` |
| 2026-07-04 | `html-design-system-showcase` | Design systems HubFU (e futuros) devem shippar catálogo HTML visual (`preview/*-design-system.html`); markdown aponta pro HTML | `references/design-system/hubfu/INDEX.md`, `html-first-design-protocol.md` |
| 2026-07-03 | `hubfu-design-system-v1` | Tokens light/dark HubFU extraídos do preview v9; docs em `references/design-system/hubfu/`; toggle `data-theme` | `references/design-system/hubfu/INDEX.md` |
| 2026-07-03 | `html-native-view-scroll` | `@view-transition`, `animation-timeline: view()`, scrub | `references/html-native-light-protocol.md` |
| 2026-07-03 | `html-native-dialog-htmx` | `command`/`dialog`, Popover, HTMX parcial | `references/html-native-light-protocol.md` |
| 2026-07-03 | `claude-mem-optional-l2` | claude-mem L2 opt-out default; LUCY_CLAUDE_MEM=1 para habilitar; L0 brain + L1 JSON bastam |
