# Referências — Lucy

Índice da documentação técnica da skill. **Versão atual:** v2.9.1 — ver [CHANGELOG.md](../CHANGELOG.md).

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
| [quiz-protocol.md](quiz-protocol.md) | Quiz 6 rodadas (init) |
| [update-protocol.md](update-protocol.md) | `/lucy update` |
| [multi-project-protocol.md](multi-project-protocol.md) | Vários loops no mesmo repo |

## Frontend & design

| Doc | Conteúdo |
|-----|----------|
| [lucy-refazer-frontend-protocol.md](lucy-refazer-frontend-protocol.md) | `/lucy refazer-frontend` — audit + quiz design |
| [lucy-nova-pagina-protocol.md](lucy-nova-pagina-protocol.md) | `/lucy nova-pagina` — landing e app |
| [premium-ui-stack.md](premium-ui-stack.md) | Stack Next.js + paletas |
| [html-native-light-protocol.md](html-native-light-protocol.md) | UI leve, view-transition, HTMX |
| [gsap-premium-protocol.md](gsap-premium-protocol.md) | GSAP timelines, ScrollTrigger |
| [ux-design-intelligence.md](ux-design-intelligence.md) | 15 Laws of UX |
| [design-skills-routing-table.md](design-skills-routing-table.md) | Mapa skills design |
| [design-stack-protocol.md](design-stack-protocol.md) | Pipeline Impeccable × UI |
| [template-gallery.md](template-gallery.md) | Layouts prontos |
| [impeccable-routing-table.md](impeccable-routing-table.md) | Comandos Impeccable |
| [skill-ecosystem-map.md](skill-ecosystem-map.md) | Todas as skills |
| [skills-you-can-use.md](skills-you-can-use.md) | Resumo para usuário |

## Aprendizado

| Doc | Conteúdo |
|-----|----------|
| [lucy-aprenda-protocol.md](lucy-aprenda-protocol.md) | `/lucy aprenda` — global → GitHub |
| [lucy-regra-protocol.md](lucy-regra-protocol.md) | `/lucy regra` — projeto P0 |
| [learned/INDEX.md](learned/INDEX.md) | Catálogo aprendizados globais |

## Autonomia & loop

| Doc | Conteúdo |
|-----|----------|
| [autonomous-orchestrator-protocol.md](autonomous-orchestrator-protocol.md) | 7 mandamentos, re-arm |
| [orchestrator-protocol.md](orchestrator-protocol.md) | Paralelismo, workers |
| [agent-routing-table.md](agent-routing-table.md) | Subagents Cursor |
| [prompt-template.md](prompt-template.md) | Templates next_prompt |
| [competitive-intelligence.md](competitive-intelligence.md) | `/lucy @url`, analise, build |

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
