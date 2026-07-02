---
name: loop-master
description: >-
  Zero-config autonomous orchestrator until 100% delivery: full skill ecosystem install
  on init, 6-round quiz, phased plan, self-correcting loops, dynamic AGI workflows,
  design director routing, claude-mem sync, auto re-arm. Commands: /loop-master init, update, tick.
version: "2.4.0"
---
# Loop Master v2.4.0 — orquestrador autônomo zero-config

**Doc mestre:** `references/autonomous-orchestrator-protocol.md`  
**Init zero-config:** `references/init-protocol.md`  
**Quiz 6 rodadas:** `references/quiz-protocol.md`  
**Design routing:** `references/design-skills-routing-table.md`

---

## `/loop-master init` — zero-config

**Ordem obrigatória — sem pedir permissão:**

1. **Shell automático** (silencioso):
   ```bash
   bash .cursor/skills/loop-master/scripts/init.sh
   ```
   Instala: impeccable, ui-ux-pro-max, taste-skill, caveman, claude-mem (+ start), motion, symlinks, JSON, PLAN, INDEX.

2. **Quiz 6 rodadas** (AskQuestion, uma rodada por turno) — ver `quiz-protocol.md`

3. **Plano + memória + armar loop** — fases, INDEX (✅⏳🔮👤), `arm-dynamic-loop.sh`, tick 1

4. **`next_prompt`** armado para tick seguinte

**Usuário só digita:** `/loop-master init`

---

## Progress file

| Contexto | Arquivo |
|----------|---------|
| App | `.cursor/loop-master-progress.json` |
| Skill pack | `.cursor/loop-master-progress.skill-pack.json` |
| Index | `docs/LOOP-MASTER-INDEX.md` |

Campos novos v2.4: `quiz_round`, `quiz_complete`, `index_doc`, `memory_sync`

---

## Comandos

| Comando | Ação |
|---------|------|
| `/loop-master init` | Bootstrap shell + quiz 6 rodadas + plano + arm loop |
| `/loop-master update` | git pull + re-init preservando contexto |
| `/loop-master` | Um tick autônomo |
| `pare o loop` | Stop + `loop_status: stopped` |

---

## Modo autônomo — cada tick

### Antes (hidratação)
1. L1 JSON inteiro + `next_prompt`
2. claude-mem search (L2) + capture ao fim
3. `docs/LOOP-MASTER-INDEX.md` — sync emojis
4. Scan `skills_installed[]`

### Durante (minor step)
`discover → plan → implement → verify → audit → fix ↺ → gate`

Design: rotear via `design-skills-routing-table.md` (Claude Design–style)

### Depois (handoff)
1. JSON + INDEX + claude-mem capture
2. `next_prompt` completo
3. **Re-arm:** `arm-dynamic-loop.sh --seconds 45` se `< 100%`

---

## Skills — init instala tudo (padrão)

| Skill | Init v2.4 |
|-------|-----------|
| loop-master | sim |
| impeccable, ui-ux-pro-max | sim |
| taste-skill, caveman, claude-mem, motion | sim |
| design, design-system, ui-styling, brand, slides, banner-design | symlink se presentes |
| security-review, bugbot | nativos Cursor |

---

## Memória (3 camadas)

| Camada | Obrigatório |
|--------|-------------|
| L1 JSON | sim |
| L2 claude-mem | sim (init + sync cada sessão) |
| L3 PLAN + INDEX | sim (emojis ✅⏳🔮👤) |

Ver `references/memory-protocol.md`

---

## Dynamic workflows

Self-pacing loop: re-arm chain 45s, branching audit→fix, parallel workers, event watchers opcionais.
Ver seção "Dynamic workflows" em `autonomous-orchestrator-protocol.md`.

---

## Contrato 100%

- `overall_pct === 100`
- `delivery_contract.status === "complete"`
- Zero critical/high abertos

Enquanto incompleto: re-arm automático obrigatório.

---

## Referências

- `references/skill-ecosystem-map.md`
- `references/init-protocol.md`
- `references/quiz-protocol.md`
- `references/design-skills-routing-table.md`
- `references/memory-protocol.md`
- `references/getting-started.md`
- `references/setup-prompt.md`

---

## Anti-padrões

- Pedir permissão antes de rodar init.sh
- Pular quiz ou implementar antes de Round 6
- Terminar tick sem next_prompt + re-arm
- Ignorar INDEX / claude-mem sync
- Secrets no progress JSON
