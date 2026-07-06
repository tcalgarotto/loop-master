# Agent routing table — especialista por domínio (v2)

Orchestrator usa esta tabela para escolher `subagent_type` + skills.  
Invocar via ferramenta **Task**; múltiplos Tasks na **mesma mensagem** quando paralelo for seguro.

**Skills externas:** ver `skill-ecosystem-map.md` e `design-stack-protocol.md`.

## Tabela principal

| Domínio / trigger | subagent_type | readonly | Skills complementares | Escopo típico |
|-------------------|---------------|----------|----------------------|---------------|
| Quiz / contexto | orchestrator | — | AskQuestion, quiz-protocol | `quiz_answers` |
| Explorar codebase, mapear APIs | `explore` | true | claude-mem search | `backend/`, `frontend/` |
| Recall cross-session / expertise acumulada | orchestrator | — | claude-mem knowledge-agent (`query_corpus`) ou search 3-layer | decisões passadas, padrões |
| Implementar feature, fix bug | `generalPurpose` | false | loop-master | arquivos da task |
| UI product novo | `generalPurpose` | false | impeccable craft, ui-ux-pro-max | `frontend/src/**` |
| UI refino | `generalPurpose` | false | impeccable layout/typeset | superfície única |
| Landing / anti-slop | `generalPurpose` | false | taste-skill, motion | marketing pages |
| Rodar pytest, docker, migrations | `shell` | false | — | comandos, CI local |
| Review lógica / bugs | `bugbot` | true | review-bugbot | diff da fase |
| Review segurança | `security-review` | true | review-security | auth, tenant, webhooks |
| Review UX design | orchestrator | true | impeccable critique | FE paths |
| CI falhando no PR | `ci-investigator` | true | — | check específico |
| Arquitetura / design API | `ai-architect` | true | — | antes de implement grande |
| Deploy / cloud / pipelines | `deployment-expert` | true | deployments-cicd | infra, preview |
| Performance, bundle, CWV | `performance-optimizer` | true | impeccable optimize | frontend perf |
| PR merge-ready | — | — | babysit | após fase com PR |
| Integração / import E2E | `generalPurpose` + `explore` | mixed | loop-master | paths da integração |
| Competitive intel `@url` | `explore` | true | firecrawl, `browser-ai-scrape-protocol.md` | scrape + screenshot → `.lucy/browser/` |
| HTML preview gate (landing mock) | orchestrator | — | `html-preview-section-gate.sh`, `html-preview-interactive-mocks-protocol.md` | `preview/*.html` |
| Multitenancy / RLS | `security-review` + `generalPurpose` | mixed | — | `tenant`, `rls`, `organization_id` |
| Pagamentos (gateway externo) | `generalPurpose` | false | payments-best-practices | `billing`, `payments` |
| Red team / pentest | `shell` | false | security-audit-protocol | `scripts/security/**` |
| Handoff compress | orchestrator | — | caveman-compress | JSON summaries |

## Roteamento por `minor_cycle.step`

### `discover`

| Se precisar… | Spawn / ferramenta |
|--------------|-------------------|
| Contexto incompleto | **AskQuestion** (quiz-protocol.md) |
| Mapear área desconhecida | 1× `explore` readonly |
| Histórico cross-session (tick imediato) | claude-mem `search` → timeline → get_observations |
| Retrospectiva / "o que decidimos sobre X?" | claude-mem knowledge-agent — `build_corpus` → `prime_corpus` → `query_corpus` (L2 ativo) |
| Design system inexistente | ui-ux-pro-max `search.py --design-system` |

### `plan`

| Se precisar… | Spawn |
|--------------|-------|
| Mapear código desconhecido | 1× `explore` (thoroughness: medium) |
| Validar arquitetura da fase | 1× `ai-architect` readonly |
| Plano já claro no master doc | 0 subagents — orchestrator só |
| UX antes de codar (FE) | impeccable `shape` (orchestrator lê skill) |
| Design tokens | ui-ux-pro-max persist MASTER.md |

### `implement` / `execute`

| Se precisar… | Spawn |
|--------------|-------|
| Backend + frontend independentes | 2× `generalPurpose` paralelo |
| Só backend | 1× `generalPurpose` |
| Só comandos (migrate, seed) | 1× `shell` |
| Página FE nova | 1× `generalPurpose` + impeccable craft (skill_hint) |
| Animação | generalPurpose + motion/react + impeccable animate |
| Feature grande 1 área | 1× `generalPurpose` (não fan-out prematuro) |

### `verify`

| Spawn | Quando |
|-------|--------|
| `shell` | pytest/lint/build smoke pós-implement |
| `npx impeccable detect <path>` | FE alterado neste tick |

### `audit`

| Sempre | Spawn paralelo (escopos distintos) |
|--------|--------------------------------------|
| Diff com auth/integrations | `security-review` |
| Diff com lógica de negócio | `bugbot` |
| CI vermelho | `ci-investigator` |
| Credenciais | orchestrator: `git diff` + grep (sem subagent) |
| UX pré-gate (FE) | impeccable `critique` |
| Design anti-patterns | impeccable detect CLI + ui-ux-pro-max checklist |
| Red team / probe projeto | `shell` — ver `security-audit-protocol.md` |
| Scanner externo (gate deploy) | `shell` — script/API do projeto |

### `fix`

| Regra | Spawn |
|-------|-------|
| 1 finding, 1 arquivo | 1× `generalPurpose` serial |
| N findings, N arquivos sem overlap | até 4× `generalPurpose` paralelo |
| Finding só de teste | 1× `shell` rodar pytest |
| Finding UX/layout | generalPurpose + impeccable (1 cmd) |
| Output truncado | taste-skill full-output-enforcement |

### `gate`

| Spawn | Quando |
|-------|--------|
| `shell` | suite de regressão da fase |
| impeccable `polish` + `optimize` | FE com gate design |
| 0 | se testes + design checks já passaram no audit |

## Prompt mínimo para spawn (template)

```text
loop-master worker — task <task_id> — phase <phase_id> — step <step>

Read: .cursor/lucy-progress.json (phase + task only)
Scope ONLY: <files_scope glob list>
Do NOT touch: <excluded paths>
Acceptance: <1-3 bullets from acceptance_criteria>

Conventions: match repo style; minimal diff.

Return structured JSON per orchestrator-protocol.md (status, files_touched, summary, findings, tests_run, blockers).
```

## Prompt verifier (template)

```text
loop-master verifier — adversarial — phase <phase_id>

Repository: <abs path>
Diff: branch changes | unscoped: <paths from parallel_runs>
Focus: <security|logic|ci>

Return: findings array with id, severity, category, file, note.
Do not fix — report only.
```

Para `bugbot` / `security-review`, usar o prompt shape das skills `review-bugbot` e `review-security`.

## Rotas rápidas (padrões comuns)

| Área | Worker | Verifier |
|------|--------|----------|
| `**/auth/**`, `**/middleware/**` | generalPurpose | security-review |
| `**/routers/**` (API) | generalPurpose | security-review + bugbot |
| `frontend/**` (UI) | generalPurpose + impeccable | bugbot |
| `**/billing/**`, `**/payments/**` | generalPurpose | security-review |
| `docs/*.md` only | orchestrator | — |

Detalhe segurança: `security-audit-protocol.md`

## Anti-padrões de roteamento

- Parent encerra com "subagent completed" — **obrigatório** sintetizar em `learned/multi-subagent-handoff-synthesis.md`
- `explore` + `generalPurpose` no **mesmo arquivo** em paralelo.
- Dois `generalPurpose` escrevendo o **mesmo arquivo**.
- `bugbot` como implementer (é readonly).
- Fan-out de 10 agents num tick (usar batches de 4).
- Subagent sem `task_id` no prompt (perde rastreio no JSON).
