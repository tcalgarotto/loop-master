# Prompt template — loop master v2

## 1. `/loop-master init` (primeira vez)

```
/loop-master init

Bootstrap loop-master v2:
1. Run AskQuestion quiz (init-protocol.md) — goal, scope, design, loop mode, skills
2. Run scripts/init.sh for selected skills
3. Create/update .cursor/loop-master-progress.json (context-schema.json)
4. Create docs/LOOP-MASTER-PLAN.md with measurable phases
5. delivery_contract.target_pct = 100
6. minor_cycle.step = discover → then plan after quiz
7. Arm /loop if user chose fixed/dynamic mode
8. Execute first tick

Do NOT deliver until overall_pct === 100.
```

### Init com objetivo

```
/loop-master init --goal "Frontend reimagine R2 — signup, CRM, clientes" --plan docs/FRONTEND-REIMAGINE-PHASED-PLAN.md
```

## 2. Comando `/loop` (agendamento)

### Fixo

```
/loop 4m <OBJETIVO> — skill loop-master, sentinel AGENT_LOOP_TICK_<NAME>.
Read .cursor/loop-master-progress.json.
One minor step per tick. Never advance phase without gate passed.
Update JSON every tick. Continue until overall_pct === 100.
```

### Dinâmico

```
/loop <OBJETIVO> — skill loop-master, dynamic schedule.
Wake on pytest failure or loop-master-progress.json change; fallback 30m.
Sentinel AGENT_LOOP_WAKE_<NAME>.
```

## 3. Tick recorrente (orchestrator)

```
loop-master orchestrator tick #<N>

Context: .cursor/loop-master-progress.json
Plan: <plan_doc>
Current: phase <ID> at <pct>%, minor step <step>, iteration <i>
Delivery: overall_pct <X>/100 — contract <status>

Duties:
1. Hydrate L1 JSON + claude-mem search if installed
2. If step=discover and quiz incomplete → AskQuestion (quiz-protocol.md)
3. Route per agent-routing-table.md + skill-ecosystem-map.md
4. Fan-out max 4 workers + 2 verifiers when files_scope disjoint
5. implement → verify smoke → audit → fix loop until gate_passed
6. Persist handoff: agent_summary, next_actions (max 5), delivery_contract
7. Re-arm loop if overall_pct < 100

Design FE: max 1-2 impeccable cmds/tick. ui-ux-pro-max for design-system.
Reply: phase %, step, findings open, next tick focus.
```

## 4. Payload JSON no sentinel (opcional)

```json
{
  "prompt": "loop-master tick: hydrate JSON, one minor step, persist, continue until 100%",
  "phase": "api-v2",
  "force_step": null
}
```

`force_step`: recovery only — `audit`, `fix`, `discover`.

## 5. Fan-out paralelo (exemplo)

| task_id | subagent_type | skill_hint | files_scope |
|---------|---------------|------------|-------------|
| t-api | generalPurpose | — | `backend/app/routers/users.py` |
| t-ui | generalPurpose | impeccable:craft | `frontend/src/app/dashboard/**` |
| t-test | shell | — | `backend/tests/test_users*.py` |

Audit tick (readonly paralelo):

| subagent_type | skill |
|---------------|-------|
| security-review | — |
| bugbot | — |
| orchestrator | impeccable:critique |

## 6. Encerramento 100%

```
loop-master FINALIZE

overall_pct === 100, delivery_contract.status === complete.
Write docs/LOOP-MASTER-COMPLETE.md.
Set loop_status: stopped. Kill sentinel PID.
```

## Checklist prompt perfeito

- [ ] Objetivo north-star
- [ ] JSON path + plan_doc
- [ ] Sentinel único
- [ ] Regra 100% — não parar antes
- [ ] Um minor step por tick
- [ ] Quiz se discover
- [ ] Paralelo só sem conflito
- [ ] Sem secrets no JSON
- [ ] Skills design se escopo FE
