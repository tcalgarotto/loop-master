# Referências — Lucy

Índice da documentação técnica da skill. **Versão atual:** v2.9.29 — ver [CHANGELOG.md](../CHANGELOG.md).

## Começar

| Doc | Para quem |
|-----|-----------|
| [../MANUAL.md](../MANUAL.md) | **Manual completo de uso** |
| [getting-started.md](getting-started.md) | Guia rápido |
| [setup-prompt.md](setup-prompt.md) | Prompts copiáveis |

## Init & configuração

| Doc | Conteúdo |
|-----|----------|
| [init-protocol.md](init-protocol.md) | Fluxo `/lucy init` zero-config |
| [quiz-protocol.md](quiz-protocol.md) | Quiz 7 rodadas (init; Round 3 = MCP) |
| [mcp-integrations-setup-guide.md](mcp-integrations-setup-guide.md) | **Guia cadastro MCP** — quiz + agente |
| [claude-mem-nvidia-setup.md](claude-mem-nvidia-setup.md) | **L2 claude-mem** — NVIDIA NIM + multi-sessão |
| [learned/claude-mem-mcp-operational-playbook.md](learned/claude-mem-mcp-operational-playbook.md) | **MCP claude-mem** — workflow 3-layer + checklist status |
| [update-protocol.md](update-protocol.md) | `/lucy update` |
| [multi-project-protocol.md](multi-project-protocol.md) | Vários loops no mesmo repo |

## Frontend & design

| Doc | Conteúdo |
|-----|----------|
| [lucy-refazer-frontend-protocol.md](lucy-refazer-frontend-protocol.md) | `/lucy refazer-frontend` — audit + quiz design |
| [lucy-nova-pagina-protocol.md](lucy-nova-pagina-protocol.md) | `/lucy nova-pagina` — landing e app |
| [visual-gate-protocol.md](visual-gate-protocol.md) | `/lucy visual-gate` — Playwright + vision QA |
| [premium-ui-stack.md](premium-ui-stack.md) | Stack Next.js + paletas |
| [html-native-light-protocol.md](html-native-light-protocol.md) | UI leve, view-transition, HTMX |
| [optimistic-inline-edit-protocol.md](optimistic-inline-edit-protocol.md) | **Planilhas densas** — useOptimistic, Server Actions, HubfuSheet |
| [design-system/hubfu/INDEX.md](design-system/hubfu/INDEX.md) | **HubFU DS** — tokens, EditableTable, catálogo HTML |
| [html-first-design-protocol.md](html-first-design-protocol.md) | **HTML-first** — preview local antes de Next |
| [html-preview-interactive-mocks-protocol.md](html-preview-interactive-mocks-protocol.md) | **Mocks interativos** — espelho do produto SaaS |
| [integration-cards-patterns.md](integration-cards-patterns.md) | **3 modelos** — carousel, marketplace sidebar, grid denso |
| [design-editable-hybrid-protocol.md](design-editable-hybrid-protocol.md) | **Caminho C** — HTML loop + Penpot MCP + port Next |
| [gsap-premium-protocol.md](gsap-premium-protocol.md) | GSAP timelines, ScrollTrigger |
| [learned/gsap-plugin-orchestration.md](learned/gsap-plugin-orchestration.md) | **GSAP Cursor plugin** — 8 skills, routing (não MCP) |
| [learned/autonomous-routing-contract.md](learned/autonomous-routing-contract.md) | **Automático vs comando** — skills, MCP, plugin, gaps |
| [premium-motion-scroll-protocol.md](premium-motion-scroll-protocol.md) | **Scroll storytelling** — pin/scrub, sandwich, imagery, morphism |
| [ux-design-intelligence.md](ux-design-intelligence.md) | 15 Laws of UX |
| [design-skills-routing-table.md](design-skills-routing-table.md) | Mapa skills design |
| [design-stack-protocol.md](design-stack-protocol.md) | Pipeline Impeccable × UI |
| [template-gallery.md](template-gallery.md) | Layouts prontos |
| [case-studies/INDEX.md](case-studies/INDEX.md) | **Estudos de caso** owner-provided — sugestões brand (#001 Neo Mirai) |
| [design-system-intake.md](design-system-intake.md) | Intake design systems + case study refs |
| [impeccable-routing-table.md](impeccable-routing-table.md) | 15 cmds Impeccable no minor cycle |
| [learned/impeccable-capabilities-map.md](learned/impeccable-capabilities-map.md) | **Catálogo completo** — 23 cmds, register, detector 45 regras, live/CLI |
| [learned/impeccable-eight-pillars.md](learned/impeccable-eight-pillars.md) | **8 pilares** impeccable.style × routing Lucy |
| [learned/impeccable-live-mode.md](learned/impeccable-live-mode.md) | **Live Mode beta** — pick→variantes→accept; guia VPS tunnel/Ports |
| [learned/vps-live-mode-owner-guide.md](learned/vps-live-mode-owner-guide.md) | **Live Mode VPS** — checklist owner (SSH tunnel, Forwarded Ports) |
| [learned/impeccable-lucy-integration.md](learned/impeccable-lucy-integration.md) | **Routing Lucy** — ticks, refazer-frontend, nova-pagina, visual-gate |
| [skill-ecosystem-map.md](skill-ecosystem-map.md) | Todas as skills |
| [skills-you-can-use.md](skills-you-can-use.md) | Resumo para usuário |

## Aprendizado

| Doc | Conteúdo |
|-----|----------|
| [lucy-aprenda-protocol.md](lucy-aprenda-protocol.md) | `/lucy aprenda` — global → GitHub |
| [lucy-regra-protocol.md](lucy-regra-protocol.md) | `/lucy regra` — projeto P0 |
| [learned/INDEX.md](learned/INDEX.md) | Catálogo aprendizados globais |
| [docs-sync-discipline.md](docs-sync-discipline.md) | **Sync obrigatória** após mudança (Hermes-style) |

## Autonomia & loop

| Doc | Conteúdo |
|-----|----------|
| [autonomous-orchestrator-protocol.md](autonomous-orchestrator-protocol.md) | 7 mandamentos, re-arm |
| [orchestrator-protocol.md](orchestrator-protocol.md) | Paralelismo, workers |
| [agent-routing-table.md](agent-routing-table.md) | Subagents Cursor |
| [prompt-template.md](prompt-template.md) | Templates next_prompt |
| [competitive-intelligence.md](competitive-intelligence.md) | `/lucy @url`, analise, build |
| [browser-ai-scrape-protocol.md](browser-ai-scrape-protocol.md) | Headless scrape + screenshots para IA |
| [premium-tool-orchestration.md](premium-tool-orchestration.md) | Orquestração P0 — ferramenta por momento |
| [design-system-intake.md](design-system-intake.md) | Referências de design do owner |

## Memória

| Doc | Conteúdo |
|-----|----------|
| [second-brain-protocol.md](second-brain-protocol.md) | Second Brain L0 + hooks |
| [memory-protocol.md](memory-protocol.md) | L1/L2/L3 camadas |
| [context-schema.json](context-schema.json) | Schema progress JSON |

## Qualidade & entrega

| Doc | Conteúdo |
|-----|----------|
| [test-protocol.md](test-protocol.md) | `/lucy test` |
| [perf-protocol.md](perf-protocol.md) | `/lucy perf` |
| [deploy-protocol.md](deploy-protocol.md) | `/lucy deploy` |
| [i18n-protocol.md](i18n-protocol.md) | `/lucy i18n` |
| [docs-protocol.md](docs-protocol.md) | `/lucy docs` |
| [docs-sync-discipline.md](docs-sync-discipline.md) | Sync docs após editar (P0 global) |
| [audit-checklist.md](audit-checklist.md) | Checklist audit |
| [security-audit-protocol.md](security-audit-protocol.md) | Red team |

## Distribuição

| Doc | Conteúdo |
|-----|----------|
| [distribution.md](distribution.md) | Monorepo vs standalone |
| [git-publish-checklist.md](git-publish-checklist.md) | Publicar no GitHub |

## Hooks (Cursor)

| Arquivo | Evento |
|---------|--------|
| `../hooks/brain-hydrate.sh` | `sessionStart` |
| `../hooks/brain-capture.sh` | `stop` |
| `../hooks/hooks.template.json` | Template |
| `../scripts/install-hooks.sh` | Instalador |
| `../scripts/frontend-inventory.sh` | Inventário pages (refazer-frontend) |
| `../scripts/design-quiz-next.sh` | Quiz design 4 rodadas |
| `../scripts/html-preview-serve.sh` | Servidor local HTML preview (:8765) |
| `../scripts/html-preview-section-gate.sh` | Screenshots Playwright por seção (HTML gate) |
| `../scripts/build-hubfu-integrations-data.py` | Catálogo integrações HubFU → preview JS |
