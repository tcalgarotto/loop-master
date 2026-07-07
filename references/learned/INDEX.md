# Lucy — aprendizados globais (`/lucy aprenda` only)

Publicados no GitHub (`loop-master`) — **todos** recebem no `/lucy update`.  
Regras **por projeto** → `/lucy regra` → `.cursor/lucy-brain/rules/` (não listadas aqui).

| Data | Slug | Resumo | Protocolo canônico |
|------|------|--------|-------------------|
| 2026-07-07 | `hubfu-design-system-v19` | HubFU DS v1.9: workflow canvas Attio (pan/zoom/drag), hubfu-motion.js, shadcn specimens, integrações v2; HTML-first → port obrigatório | `design-system/hubfu/INDEX.md`, `learned/hubfu-design-system-v19.md`, `html-first-design-protocol.md` |
| 2026-07-07 | `lucy-runtime-gitignore` | `.lucy/` = runtime efêmero (gates, caches, captures); skill pack público ≠ runtime; nunca commitar `.lucy/` | `learned/lucy-runtime-gitignore.md`, `.gitignore`, `second-brain-protocol.md` |
| 2026-07-06 | `multi-subagent-handoff-synthesis` | Parent MUST sintetizar 5 seções após workers (per-agent, estado, owner items, agent-next, checklist); proibido "subagent completed" | `learned/multi-subagent-handoff-synthesis.md`, `owner-handoff-qa-protocol.md`, `autonomous-orchestrator-protocol.md` |
| 2026-07-06 | `l2-knowledge-agent` | L2b: build_corpus→prime→query vs search 3-layer; quando retrospectiva; corpora focados; L4 Vector DB ≠ claude-mem | `learned/l2-knowledge-agent-protocol.md`, `memory-architecture.md`, `second-brain-protocol.md` |
| 2026-07-06 | `nvidia-api-keys-per-user` | Key NVIDIA pessoal por usuário; agente guia build.nvidia.com; proibido pedir/ecoar `nvapi-` no chat; storage só `~/.claude-mem/.env` ou `.env` gitignored | `learned/nvidia-api-keys-per-user.md`, `credentials-policy.md`, `claude-mem-zero-config-playbook.md` |
| 2026-07-06 | `claude-mem-zero-config` | L2 zero-config: 3 passos owner, bootstrap idempotente, alias NVIDIA .env, init auto-call | `learned/claude-mem-zero-config-playbook.md`, `claude-mem-nvidia-setup.md`, `scripts/claude-mem-bootstrap.sh` |
| 2026-07-05 | `proactive-migration-backend-restart` | Owner authorization: migration (`alembic upgrade head`) + recreate backend são proativos e obrigatórios quando schema/backend muda; verify health + smoke; downgrade/drop continuam exigindo confirmação | `learned/proactive-migration-backend-restart.md`, `learned/proactive-orchestration-mandate.md` |
| 2026-07-05 | `proactive-orchestration-mandate` | Owner authorization: agente MUST ativar skills/MCPs quando protocolo indica; proibido "Posso usar X?"; exceções destructive/credentials/deploy | `learned/proactive-orchestration-mandate.md`, `autonomous-routing-contract.md`, `autonomous-orchestrator-protocol.md` |
| 2026-07-05 | `autonomous-routing-contract` | Matriz honesta: HYDRATE/tabelas/quality_gates automáticos; slash commands e MCP opt-in; v2.9.30+ mandato proativo MUST activate | `learned/autonomous-routing-contract.md`, `premium-tool-orchestration.md` |
| 2026-07-05 | `claude-mem-mcp-operational-playbook` | MCP plugin search 3-layer; worker :37700 + NVIDIA NIM backend; status 4 camadas; fix mcp-setup-status npx | `learned/claude-mem-mcp-operational-playbook.md`, `claude-mem-nvidia-setup.md`, `mcp-integrations-setup-guide.md` |
| 2026-07-05 | `gsap-plugin-orchestration` | GSAP Cursor plugin (8 skills, não MCP): routing gsap-react/scrolltrigger/timeline, pirâmide html→GSAP→Framer, register brand/product, matchMedia a11y | `learned/gsap-plugin-orchestration.md`, `gsap-premium-protocol.md`, `design-skills-routing-table.md` |
| 2026-07-05 | `case-study-neo-mirai` | Case study #001 Neo Mirai: craft pipeline visualize→shape→craft→ship; visual DNA warm paper; INDEX case-studies para sugestões brand | `case-studies/neo-mirai-impeccable.md`, `case-studies/INDEX.md`, `design-system-intake.md`, `premium-tool-orchestration.md` |
| 2026-07-05 | `premium-motion-patterns` | Motion premium: scroll storytelling, pin+scrub vídeo, sandwich stack, morphism tasteful, hero editorial; suggest brand / restrain product | `premium-motion-scroll-protocol.md`, `gsap-premium-protocol.md`, `premium-tool-orchestration.md` |
| 2026-07-05 | `vps-live-mode-owner-guide` | Owner pede Live Mode no VPS: Lucy guia tunnel SSH / Cursor Ports / Desktop local — nunca só "não funciona"; checklist + portas HubFU | `learned/impeccable-live-mode.md`, `learned/vps-live-mode-owner-guide.md`, `impeccable-lucy-integration.md` |
| 2026-07-05 | `impeccable-live-eight-pillars` | 8 pilares impeccable.style + guia Live Mode (pick→3 variantes→accept→source); VPS fallback; bootstrap HubFU PRODUCT/DESIGN | `learned/impeccable-eight-pillars.md`, `learned/impeccable-live-mode.md`, `learned/impeccable-lucy-integration.md` |
| 2026-07-05 | `impeccable-lucy-brain` | Catálogo 23 cmds + 45 regras detector + integração explícita Lucy→impeccable em ticks/refazer/nova-pagina/visual-gate | `learned/impeccable-capabilities-map.md`, `learned/impeccable-lucy-integration.md`, `impeccable-routing-table.md` |
| 2026-07-05 | `design-visual-html-defaults` | Discussão design → HTML preview com seletor variantes; default 2 light + 2 dark; ler page.tsx alvo; persistir decisão owner | `design-visual-html-protocol.md`, `html-first-design-protocol.md` |
| 2026-07-05 | `owner-handoff-qa-rounds` | Ao atingir teto/paused_owner: quiz por rodadas (Concluído/Adiar/Ajuda/N/A), contexto da sessão como fonte, persistir owner_qa, continuar até 100% | `references/owner-handoff-qa-protocol.md`, `autonomous-orchestrator-protocol.md` |
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
