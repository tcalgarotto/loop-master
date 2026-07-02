# `/loop-master init` — Protocolo de bootstrap

Comando de entrada para configurar loop-master em projeto novo ou existente.
O orchestrator executa **nesta ordem** quando o usuário invoca `/loop-master init`.

## Trigger

```
/loop-master init
/loop-master init <objetivo em uma linha>
/loop-master init --goal "Import module UI 100%" --plan docs/MY-PLAN.md
```

## Fase 0 — Pré-voo

1. Confirmar raiz do projeto (git repo ou diretório com código).
2. Verificar `.gitignore` inclui `.env`, `.cursor/loop-master-progress.json` **não** deve ser ignorado.
3. Verificar Agent Skills habilitado no Cursor (Settings → Rules → Agent Skills).

## Fase 1 — Quiz de contexto (AskQuestion)

Usar ferramenta **AskQuestion** para fechar ambiguidades. Mínimo 3 perguntas; máximo 6.

### Perguntas obrigatórias

| ID | Pergunta | Opções |
|----|----------|--------|
| `q_goal` | Qual o objetivo north-star deste loop? | Texto livre via "Other" ou opções do projeto |
| `q_scope` | Escopo principal? | Backend / Frontend / Full-stack / Infra / Docs-only |
| `q_delivery` | Barra de entrega? | MVP funcional / Production-ready 100% / Go-live |
| `q_design` | Superfície visual? | Sim — product CRM / Sim — marketing / Não |
| `q_loop_mode` | Agendamento? | **Dinâmico chain (padrão)** / Fixo (ex. 4m) / Manual |
| `q_skills` | Skills opcionais para instalar? | Multi: impeccable, ui-ux-pro-max, taste-skill, caveman, claude-mem |

### Persistir respostas

Gravar em `.cursor/loop-master-progress.json`:

```json
"quiz_answers": {
  "goal": "...",
  "scope": "fullstack",
  "delivery_bar": "production_100",
  "design_surface": "product_crm",
  "loop_mode": "fixed",
  "loop_interval_seconds": 240,
  "skills_requested": ["impeccable", "ui-ux-pro-max"]
}
```

## Fase 2 — Instalar skill pack e dependências opcionais

Executar `scripts/init.sh`:

| Modo | Comportamento |
|------|---------------|
| `init.sh` (sem flags) | Instala **impeccable** + **ui-ux-pro-max** se ausentes |
| `--skills a,b,c` | Instala apenas as listadas |
| `--skip-skills` | Só loop-master + JSON + plano |

**Não vêm embutidas:** taste-skill, caveman, claude-mem, motion, scripts de segurança.
**Nativas Cursor (sem install):** security-review, bugbot, ci-investigator.

Após install, registrar paths em `skills_installed[]` no JSON.

## Fase 3 — Artefatos de projeto

| Arquivo | Ação |
|---------|------|
| `.cursor/loop-master-progress.json` | Criar do schema; `minor_cycle.step = "discover"` |
| `docs/LOOP-MASTER-PLAN.md` | Criar se ausente — fases + gates |
| `PRODUCT.md` | Criar stub se ausente e escopo FE |
| `DESIGN.md` | Criar stub se ausente e design_surface ≠ none |
| `.impeccable/config.json` | Se impeccable instalado — defaults |
| `design-system/MASTER.md` | Se ui-ux-pro-max — gerar via search.py |

### Sentinel

Gerar ID único: `AGENT_LOOP_TICK_<PROJECT>_<HASH4>`
Exemplo: `AGENT_LOOP_TICK_MYAPP_A3F2`

Registrar em JSON: `loop_sentinel`, `loop_interval_seconds`, `loop_status: "pending_arm"`

## Fase 4 — Plano master

1. Ler `plan_doc` existente OU criar fases S0…Sn com:
   - `name`, `acceptance_criteria[]`, `pct: 0`, `status: pending`
2. Primeira fase → `status: in_progress`, `current_phase` aponta para ela
3. `delivery_contract`:

```json
"delivery_contract": {
  "status": "in_progress",
  "target_pct": 100,
  "acceptance_summary": "<do quiz q_goal>",
  "blocked_on_human": false
}
```

## Fase 5 — Armar loop (se quiz escolheu agendamento)

Se `loop_mode` ≠ `manual`:

```
/loop <intervalo> <objetivo> — skill loop-master, sentinel <SENTINEL>
```

Atualizar `loop_status: "running"`. Executar **primeiro tick imediato** (discover → plan). Ao fim do tick: `arm-dynamic-loop.sh` (chain 45s — padrão).

## Fase 6 — Confirmar ao usuário

Resumo em 5–8 linhas:
- Objetivo, fase atual, sentinel, skills instaladas
- Próximo step minor
- Como parar: "pare o loop" / matar sentinel

## Init em projeto com JSON existente

Se `.cursor/loop-master-progress.json` já existe:
- **Não** apagar — perguntar via AskQuestion: Continuar / Reset fases / Novo objetivo
- Reset preserva `tick_count` histórico em `archive_ticks` se implementado

## Flags

| Flag | Efeito |
|------|--------|
| `--skip-quiz` | Usar defaults; só para CI/script |
| `--skip-skills` | Não instalar deps opcionais |
| `--goal "..."` | Pré-preenche q_goal |
| `--plan path` | Pré-define plan_doc |
| `--interval 4m` | Pré-define loop fixo |
| `--preserve-context` | Não recriar JSON (usado por `update.sh`) |
| `--update-mode` | Alias de `--preserve-context` |
| `--progress-file` | Caminho do JSON (ex. `.cursor/loop-master-progress.skill-pack.json`) |

## Dois loops no mesmo repositório

Ver `multi-project-protocol.md`. **Nunca** substituir o JSON do app ao init da skill pack.

## Relação com `/loop-master update`

`update` chama `init.sh --preserve-context` após git pull. Ver `update-protocol.md`.
