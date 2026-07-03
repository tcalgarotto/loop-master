# `/loop-master init` — Protocolo zero-config v2.5.1

Quando o usuário invoca `/loop-master init`, o orchestrator executa **nesta ordem exata**.
**Sem rodeios. Sem pedir permissão para rodar scripts.**

---

## Fase 0 — Bootstrap automático (shell, silencioso)

**Imediatamente**, antes de qualquer AskQuestion:

```bash
bash .cursor/skills/loop-master/scripts/init.sh
```

Isso instala e configura **tudo**:

| Componente | Ação |
|------------|------|
| impeccable | `npx impeccable install` se ausente |
| ui-ux-pro-max | `uipro init --ai cursor` se ausente |
| taste-skill | `npx skills add … design-taste-frontend` |
| caveman | installer curl |
| claude-mem | install + **start worker** |
| motion | npm install no frontend |
| Symlinks | `link-ecosystem-skills.sh` |
| JSON L1 | `.cursor/loop-master-progress.json` |
| Plan stub | `docs/LOOP-MASTER-PLAN.md` |
| Index | `docs/LOOP-MASTER-INDEX.md` (✅⏳🔮👤) |
| Second Brain | `brain-sync.sh init` → `.cursor/loop-master-brain/` |
| **Cursor hooks** | `install-hooks.sh` → sessionStart + stop |
| PRODUCT.md | stub se FE |

**Não** perguntar ao usuário nesta fase. Reportar resumo em 3 linhas após concluir.

Se script falhar parcialmente: registrar WARN em `human_blockers[]`, continuar quiz.

---

## Fase 1–6 — Quiz (AskQuestion, uma rodada por turno)

Seguir `references/quiz-protocol.md`:

| Turno | Rodada | Tema |
|-------|--------|------|
| 1 | Round 1 | Produto & North Star |
| 2 | Round 2 | Escopo técnico |
| 3 | Round 3 | Design & UX |
| 4 | Round 4 | Qualidade & gates |
| 5 | Round 5 | Autonomia & loop |
| 6 | Round 6 | Kickoff contextual |

Após cada rodada:
- Persistir `quiz_answers.round_N` + incrementar `quiz_round`
- Atualizar `docs/LOOP-MASTER-INDEX.md`

---

## Fase 7 — Plano + memória + armar loop

Quando `quiz_complete: true`:

1. **Fases** — criar `phases{}` + tabela em `docs/LOOP-MASTER-PLAN.md`
2. **Memória L2** — claude-mem capture: objetivo, fases, quiz summary
3. **INDEX** — marcar ✅ skills instaladas, ⏳ fase atual, 👤 blockers
4. **Delivery contract** — `acceptance_summary` do Round 1
5. **Armar loop dinâmico:**

```bash
bash .cursor/skills/loop-master/scripts/arm-dynamic-loop.sh \
  --progress-file .cursor/loop-master-progress.json \
  --seconds 45
```

6. **Tick 1 imediato** — `discover` → `plan` (ou `implement` se Round 6 definiu tasks claras)
7. **`next_prompt`** + re-arm ao fim do tick

---

## Prompt armado (gerado ao fim do init)

Gravar em JSON campo `next_prompt`:

```text
/loop-master tick #1 — skill loop-master

Context: .cursor/loop-master-progress.json (quiz_complete=true)
Plan: docs/LOOP-MASTER-PLAN.md
Index: docs/LOOP-MASTER-INDEX.md
Phase: <current_phase> at 0%
Memory: claude-mem search + L1 hydrate

Execute ONE minor step. Dynamic loop armed (45s chain).
Design: route via design-skills-routing-table.md
Gate: zero critical/high before advance.

Do NOT stop until overall_pct === 100 unless user says stop.
```

---

## Entrada do usuário

```
/loop-master init
/loop-master init --goal "Premium UI 100%"
```

Flags CLI (via agente rodando init.sh):

| Flag | Efeito |
|------|--------|
| `--skip-quiz` | CI only — defaults |
| `--skip-skills` | Só JSON + plano |
| `--preserve-context` | update.sh |
| `--progress-file` | multi-projeto |

---

## Init com JSON existente

Se progress JSON já existe → AskQuestion:
- **Continuar** (preservar ticks)
- **Reset fases** (manter archive)
- **Novo objetivo** (re-quiz Round 1 + 6)

---

## Checklist pós-init

- [ ] `verify-pack.sh` → PASSED
- [ ] `skills_installed` não vazio
- [ ] `memory_sync.claude_mem` = installed ou running
- [ ] `loop_status` = running
- [ ] INDEX com emojis atualizados
- [ ] Agent Skills ON (Settings)
