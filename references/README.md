# Referências — Loop Master

Índice da documentação técnica da skill.

## Começar

| Doc | Para quem |
|-----|-----------|
| [../MANUAL.md](../MANUAL.md) | **Manual completo de uso** |
| [getting-started.md](getting-started.md) | Guia rápido 5 min |
| [setup-prompt.md](setup-prompt.md) | Prompts copiáveis |

## Init & configuração

| Doc | Conteúdo |
|-----|----------|
| [init-protocol.md](init-protocol.md) | Fluxo `/lucy init` zero-config |
| [quiz-protocol.md](quiz-protocol.md) | Quiz 6 rodadas |
| [update-protocol.md](update-protocol.md) | `/lucy update` |
| [multi-project-protocol.md](multi-project-protocol.md) | Vários loops no mesmo repo |

## Autonomia & loop

| Doc | Conteúdo |
|-----|----------|
| [autonomous-orchestrator-protocol.md](autonomous-orchestrator-protocol.md) | 7 mandamentos, re-arm, AGI workflows |
| [orchestrator-protocol.md](orchestrator-protocol.md) | Paralelismo, workers |
| [agent-routing-table.md](agent-routing-table.md) | Subagents Cursor |
| [prompt-template.md](prompt-template.md) | Templates next_prompt |

## Memória

| Doc | Conteúdo |
|-----|----------|
| [second-brain-protocol.md](second-brain-protocol.md) | Second Brain L0 + hooks |
| [memory-protocol.md](memory-protocol.md) | L1/L2/L3 camadas |
| [context-schema.json](context-schema.json) | Schema progress JSON |

## Design

| Doc | Conteúdo |
|-----|----------|
| [design-skills-routing-table.md](design-skills-routing-table.md) | Mapa skills design |
| [design-stack-protocol.md](design-stack-protocol.md) | Pipeline Impeccable × UI |
| [impeccable-routing-table.md](impeccable-routing-table.md) | Comandos Impeccable |
| [skill-ecosystem-map.md](skill-ecosystem-map.md) | Todas as skills |
| [skills-you-can-use.md](skills-you-can-use.md) | Resumo para usuário |

## Qualidade & segurança

| Doc | Conteúdo |
|-----|----------|
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
