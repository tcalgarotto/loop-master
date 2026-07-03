# Prompt template — loop master v2.5.2

## 1. `/loop-master init`

```
/loop-master init
```

Agente executa **nesta ordem** (não inverter):

1. `bash .cursor/skills/loop-master/scripts/init.sh` — silencioso
2. `bash .cursor/skills/loop-master/scripts/quiz-next.sh` — ler rodada atual
3. **AskQuestion** só com IDs da rodada (ex. Round 1: r1_goal, r1_users, r1_delivery, r1_success)
4. Persistir `quiz_answers.round_N`, `quiz_round++`
5. Repetir 2–4 até Round 6 → `quiz_complete: true`
6. Fases + INDEX + `arm-dynamic-loop.sh` + tick 1

**Proibido:** quiz legado flat (goal+scope+design+loop+skills num turno).

## 2. Tick recorrente

```
/loop-master

1. brain-sync.sh hydrate + claude-mem search
2. Ler loop-master-progress.json + next_prompt
3. Um minor step (discover→plan→implement→verify→audit→fix→gate)
4. brain-sync.sh capture + observation_add
5. Re-arm se < 100%
```

## 3. Encerramento 100%

```
overall_pct === 100 → LOOP-MASTER-COMPLETE.md → loop_status: stopped
```
