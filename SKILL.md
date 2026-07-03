---
name: loop-master
description: >-
  Zero-config autonomous orchestrator with Second Brain memory: learns project and
  dev on every interaction via brain-sync + claude-mem. Full skill install on init,
  6-round quiz, dynamic AGI workflows, design routing. Commands: /loop-master init, update, tick.
version: "2.5.0"
---
# Loop Master v2.5.0 — orquestrador + segundo cérebro

**Second Brain:** `references/second-brain-protocol.md`  
**Doc mestre:** `references/autonomous-orchestrator-protocol.md`  
**Init:** `references/init-protocol.md` · **Quiz:** `references/quiz-protocol.md`

---

## Second Brain — memória viva (NOVO v2.5)

A cada `/loop-master` (tick ou chat):

1. **HYDRATE** — `brain-sync.sh hydrate` + claude-mem search
2. **TRABALHAR** — com contexto acumulado
3. **CAPTURE** — `brain-sync.sh capture` + claude-mem observation_add

Armazena: perfil dev, decisões de arquitetura, log de interações, consciência crescente.
Diretório: `.cursor/loop-master-brain/`

**Nunca encerrar turno sem CAPTURE.**

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
1. **Second Brain HYDRATE** — `brain-sync.sh hydrate` + claude-mem search
2. L1 JSON + `next_prompt` + L0 dev-profile + project-mind
3. INDEX sync emojis
4. Scan `skills_installed[]`

### Durante (minor step)
`discover → plan → implement → verify → audit → fix ↺ → gate`

Design: rotear via `design-skills-routing-table.md` (Claude Design–style)

### Depois (handoff)
1. JSON + INDEX + **brain-sync capture** + claude-mem observation_add
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

## Memória (4 camadas)

| Camada | Obrigatório |
|--------|-------------|
| L0 Brain | `.cursor/loop-master-brain/` — **toda interação** |
| L1 JSON | progress handoff |
| L2 claude-mem | MCP search + observation_add |
| L3 PLAN/INDEX | docs humanos |

Ver `references/second-brain-protocol.md` + `memory-protocol.md`

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
- `references/second-brain-protocol.md`
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
