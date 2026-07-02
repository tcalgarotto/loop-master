# Quiz Protocol — 6 rodadas (formulário multi-etapas)

O `/loop-master init` usa **AskQuestion** em **6 rodadas sequenciais**.
Cada rodada é **uma interação completa** (várias perguntas com opções + sugestões).
**Não implementar** até `quiz_complete: true` no JSON.

## Regra de ouro

1. **Antes do quiz:** rodar `bash .cursor/skills/loop-master/scripts/init.sh` **sem perguntar** (bootstrap completo).
2. **Durante init:** uma rodada por turno; persistir `quiz_answers.round_N` após cada rodada.
3. **Após Round 6:** criar fases, atualizar INDEX/plan, armar loop dinâmico, tick 1.

---

## Round 1 — Produto & North Star

**Objetivo:** entender o que entregar e a barra de qualidade.

| ID | Pergunta | Opções (sugestões) |
|----|----------|-------------------|
| `r1_goal` | Qual o objetivo north-star deste loop? | "Entregar MVP funcional" / "Production-ready 100%" / "Go-live com deploy" / Other (texto livre) |
| `r1_users` | Quem usa o produto? | "Equipe interna" / "Clientes B2B" / "Consumidor final" / "Devs/API" / Other |
| `r1_delivery` | Barra de entrega? | **Production-ready 100% (Recommended)** / MVP funcional / Go-live imediato |
| `r1_success` | Como sabemos que terminou? | Sugestões baseadas no repo (ex.: "UI premium", "API estável", "E2E verde") + Other |

Persistir: `quiz_answers.round_1`

---

## Round 2 — Escopo técnico

**Objetivo:** mapear stack e superfícies de código.

| ID | Pergunta | Opções |
|----|----------|--------|
| `r2_scope` | Escopo principal? | Backend / **Frontend (Recommended se repo tem frontend/)** / Full-stack / Infra / Docs-only |
| `r2_stack` | Stack detectada — confirmar? | Opções inferidas de `package.json`, `pyproject.toml`, `Makefile` + "Outro" |
| `r2_integrations` | Integrações críticas? | Multi: API externa, DB, auth, pagamentos, CRM, nenhuma, Other |
| `r2_constraints` | Restrições técnicas? | Multi: não quebrar prod, manter compat API, zero downtime, sem migrations, Other |

Persistir: `quiz_answers.round_2`

---

## Round 3 — Design & UX

**Objetivo:** rotear pipeline design (Claude Design–style).

| ID | Pergunta | Opções |
|----|----------|--------|
| `r3_surface` | Superfície visual? | **Product app — CRM/dashboard (Recommended)** / Marketing/landing / Nenhuma (BE only) |
| `r3_register` | Register visual? | Product restrained / Marketing expressivo / Seguir DESIGN.md existente |
| `r3_priority_pages` | Páginas prioritárias? | Multi: inferir de `frontend/src/app/**/page.tsx` + Other |
| `r3_design_skills` | Skills design a usar? | Multi (pré-marcar instaladas): impeccable, ui-ux-pro-max, taste-skill, design, design-system, ui-styling, brand, banner-design, slides, motion |

Ver roteamento: `references/design-skills-routing-table.md`

Persistir: `quiz_answers.round_3`

---

## Round 4 — Qualidade, segurança & gates

**Objetivo:** definir autocorreção e audit.

| ID | Pergunta | Opções |
|----|----------|--------|
| `r4_gate` | Gate por fase? | **100% + zero critical/high (Recommended)** / MVP happy-path / Medium com waiver |
| `r4_tests` | Verificação obrigatória? | Multi: pytest, npm test, build, lint, e2e playwright, impeccable detect |
| `r4_security` | Audit de segurança? | **Sim — security-review + bugbot (Recommended)** / Só bugbot / Pular neste projeto |
| `r4_docs` | Docs versionados? | Sim — plan + INDEX + COMPLETE / Só plan / Mínimo |

Persistir: `quiz_answers.round_4`

---

## Round 5 — Autonomia & loop dinâmico

**Objetivo:** configurar AGI-style continuous loop.

| ID | Pergunta | Opções |
|----|----------|--------|
| `r5_mode` | Modo de loop? | **Dinâmico chain — re-arm ao fim de cada tick (Recommended)** / Fixo (ex. 4m) / Manual |
| `r5_interval` | Fallback seconds (dinâmico)? | 45s (Recommended) / 90s / 240s |
| `r5_memory` | Memória claude-mem? | **Sim — sync a cada sessão (Recommended)** / Só JSON L1 |
| `r5_parallel` | Workers paralelos? | **Até 4 workers + 2 verifiers (Recommended)** / Conservador (2+1) / Sequencial |
| `r5_stop` | Quando parar? | **Só em 100% ou "pare o loop" (Recommended)** / Pausar após fase atual |

Persistir: `quiz_answers.round_5` + atualizar `loop_arm.mode`, `loop_interval_seconds`

---

## Round 6 — Kickoff contextual (por onde começar)

**Objetivo:** primeira fase, arquivos, blockers.

| ID | Pergunta | Opções |
|----|----------|--------|
| `r6_start_phase` | Por onde começar? | Sugestões do repo: fase com maior gap, P0 audit, página mais visível, Other |
| `r6_first_tasks` | 1–3 tasks do primeiro tick? | Sugestões concretas (paths + skill_hint) |
| `r6_read_first` | Arquivos para ler antes? | Multi: inferir de git status, plan existente, docs abertos |
| `r6_blockers` | Blockers humanos conhecidos? | Multi: credenciais, deploy, decisão produto, nenhum, Other |
| `r6_confirm` | Confirmar init completo? | **Sim — criar fases + armar loop + tick 1 (Recommended)** / Revisar quiz |

Após confirmar:
- `quiz_complete: true`, `quiz_round: 6`
- Gerar `phases{}` + `docs/LOOP-MASTER-PLAN.md`
- Atualizar `docs/LOOP-MASTER-INDEX.md` (✅/⏳/🔮/👤)
- `loop_status: running` + `arm-dynamic-loop.sh`
- Tick 1: `discover` → `plan` (ou `implement` se escopo cristalino)

Persistir: `quiz_answers.round_6`

---

## Formato JSON consolidado

```json
{
  "quiz_round": 3,
  "quiz_complete": false,
  "quiz_answers": {
    "round_1": { "goal": "...", "delivery": "production_100" },
    "round_2": { "scope": "fullstack", "stack": ["nextjs", "fastapi"] },
    "round_3": { "surface": "product_app", "design_skills": ["impeccable", "ui-ux-pro-max"] },
    "round_4": { "gate": "strict" },
    "round_5": { "loop_mode": "dynamic", "interval": 45 },
    "round_6": { "start_phase": "phase-1", "first_tasks": ["..."] }
  }
}
```

---

## Quando repetir quiz (fora do init)

| Situação | Rodadas |
|----------|---------|
| `discover` + `quiz_answers` incompleto | Completar rodadas faltantes |
| Mudança de objetivo | Round 1 + 6 |
| Gate bloqueado por produto | 1 pergunta Round 4 ou 6 |
| Tick com handoff completo | **Não** quiz |

## Anti-padrões

- Pular bootstrap shell antes do quiz
- Todas as 6 rodadas num único turno (fatiga + respostas rasas)
- Implementar sem Round 6 confirmado
- Perguntas já respondidas no JSON
