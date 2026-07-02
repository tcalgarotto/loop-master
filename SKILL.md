---
name: loop-master
description: >-
  Fully autonomous orchestrator until 100% delivery: phased plan, self-correcting
  implement/audit/fix loops, parallel workers, skill ecosystem routing, quiz,
  live memory, auto re-arm next tick. Commands: /loop-master init, update, tick.
version: "2.3.1"
---
# Loop Master v2.3.1 — orquestrador autônomo completo

**Nada foi removido** ao generalizar nomes de projeto. Ciclos de autocorreção,
fan-out paralelo, audit adversarial, invocação autônoma de skills e **re-arm
automático** do próximo tick permanecem **obrigatórios**.

**Doc mestre de autonomia:** `references/autonomous-orchestrator-protocol.md`

**Referências:**
- `references/skill-ecosystem-map.md` — quando invocar cada skill
- `references/autonomous-orchestrator-protocol.md` — 7 mandamentos + re-arm
- `references/update-protocol.md` — `/loop-master update`
- `references/init-protocol.md` — `/loop-master init`
- `references/quiz-protocol.md` — AskQuestion
- `references/memory-protocol.md` — memória viva L1/L2
- `references/design-stack-protocol.md` — pipeline design
- `references/security-audit-protocol.md` — red team
- `references/orchestrator-protocol.md` — paralelismo
- `references/agent-routing-table.md` — subagents
- `references/multi-project-protocol.md` — loops paralelos / progress files
- `references/getting-started.md` — guia amigável (instalação, primeiros passos)
- `references/setup-prompt.md` — prompt inicial copiável
- `references/impeccable-routing-table.md` — Impeccable

---

## Progress file (multi-projeto)

| Contexto | Arquivo |
|----------|---------|
| Padrão (app) | `.cursor/loop-master-progress.json` |
| Skill pack / meta | `.cursor/loop-master-progress.skill-pack.json` |
| Override | `LOOP_MASTER_PROGRESS_FILE` ou `--progress-file` no init/update |

**Hidratação:** ler o JSON indicado no chat ou o campo `progress_file` do JSON.
Ver `references/multi-project-protocol.md`. **Nunca** sobrescrever o JSON do app ao evoluir a skill no mesmo repo.

**Prompt inicial:** `references/setup-prompt.md`

---

## Comandos

| Comando | Ação |
|---------|------|
| `/loop-master init` | Quiz + deps + JSON + plano + armar loop |
| `/loop-master update` | `git pull` skill pack + re-init **sem apagar** contexto |
| `/loop-master` | **Um tick autônomo** — ver fluxo abaixo |
| `/loop <intervalo> … skill loop-master` | Agendamento (skill `loop`) |
| `pare o loop` | Stop sentinel + `loop_status: stopped` |

CLI: `scripts/init.sh`, `scripts/update.sh`, `scripts/arm-dynamic-loop.sh`

### Loop dinâmico (padrão)

Ao fim de **cada** tick: atualizar JSON → `arm-dynamic-loop.sh` (chain 45s). Próximo tick inicia quando o atual termina. Dizer **"pare o loop"** para parar.

---

## Modo autônomo — o que o orchestrator faz TODO tick

### Antes do tick (hidratação obrigatória)

1. Ler o progress JSON do loop ativo (`progress_file` ou `.cursor/loop-master-progress.json`) **inteiro**
2. Ler `next_prompt` do tick anterior
3. Ler `archive_summaries[]` (últimos ticks)
4. Ler `plan_doc` + `context_files`
5. **Scan** `skills_installed[]` — paths em `.cursor/skills/`
6. claude-mem search se instalado

### Durante o tick (um minor step)

| Step | Autonomia |
|------|-----------|
| `discover` | AskQuestion se contexto incompleto; explore |
| `plan` | Fases + tasks com `skill_hint` |
| `implement` | Workers + skills (impeccable, ui-ux-pro-max, taste, motion…) |
| `verify` | Smoke pytest/lint/build |
| `audit` | security-review + bugbot + scripts `scripts/security/**` |
| `fix` | Autocorreção → **volta audit** (`iteration++`) |
| `gate` | 100% fase; docs versionados; próxima fase |

**Ciclo autocorreção:** `implement → verify → audit → fix ↺ → gate`  
**Nunca** gate com critical/high abertos. **Nunca** parar antes de `overall_pct === 100`.

### Depois do tick (handoff obrigatório)

1. Atualizar JSON: `tick_count++`, `last_audit`, `next_actions`
2. **`next_prompt`** — prompt completo para tick N+1 (template em autonomous-orchestrator-protocol.md)
3. `archive_summaries[]` push resumo
4. `doc_versions[]` se docs alterados
5. Sincronizar `plan_doc` com % da fase
6. **Re-arm loop** se `< 100%` e `loop_status: running` — **padrão dinâmico:** `arm-dynamic-loop.sh` (chain ~45s após fim do tick)

---

## Invocação autônoma de skills

Orchestrator resolve por tabela — **sem pedir permissão** se skill instalada:

| Domínio | Skill / subagent | Step |
|---------|------------------|------|
| Agendamento | `loop` | fim do tick |
| UI product | impeccable (1–2 cmds) | implement…gate |
| Design system | ui-ux-pro-max | discover, plan |
| Anti-slop / landing | taste-skill | implement |
| Motion | motion/react | implement |
| Memória | claude-mem | discover, hydrate |
| Handoff compacto | caveman | persist |
| Segurança código | security-review | audit |
| Bugs | bugbot | audit |
| Red team | `scripts/security/*` do projeto | audit, gate |

Árvore completa: `skill-ecosystem-map.md`

---

## Contrato 100%

- `overall_pct === 100`
- `delivery_contract.status === "complete"`
- Toda fase `pct === 100`, `gate === passed`
- Zero critical/high abertos (ou waived)

Enquanto incompleto: **re-arm automático** — não encerrar turno sem próximo wake.

---

## `/loop-master init`

1. AskQuestion — objetivo, escopo, design, loop, skills
2. `scripts/init.sh`
3. JSON + `docs/LOOP-MASTER-PLAN.md` + `delivery_contract`
4. Armar `/loop`
5. Tick: discover → plan

Persistir `quiz_answers`. Ver `init-protocol.md`.

---

## `/loop-master update`

1. Backup `loop-master-progress.json`
2. `git pull` no skill pack (ou submodule update)
3. `scripts/init.sh --preserve-context` — **não apaga** ticks/fases/quiz
4. Re-scan `skills_installed`
5. Continuar com `next_prompt` existente

Ver `update-protocol.md` + `scripts/update.sh`.

---

## Ecossistema (instalação)

| Skill | Init padrão? |
|-------|--------------|
| loop-master | sim (este pacote) |
| impeccable, ui-ux-pro-max | sim se ausentes |
| taste, caveman, claude-mem, motion | `--skills` ou quiz |
| security-review, bugbot | nativos Cursor |

Impeccable: FE only, max 1–2 cmds/tick, **qualquer** product UI (dashboard, inbox, settings…).

---

## Instalação

```bash
git clone <repo> ~/.cursor/skills/loop-master
cd your-project && ~/.cursor/skills/loop-master/scripts/init.sh
/loop-master init
```

---

## Anti-padrões

- Parar loop antes de 100% sem pedido explícito
- Terminar turno **sem** `next_prompt` e **sem** re-arm
- Pular audit/fix após implement
- Assumir skill instalada sem scan
- Apagar JSON no update
- Secrets no progress JSON
