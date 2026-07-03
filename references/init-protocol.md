# `/lucy init` — Protocolo zero-config v2.5.2

Quando o usuário invoca `/lucy init`, o orchestrator executa **nesta ordem exata**.
**Sem rodeios. Sem pedir permissão para rodar scripts.**

---

## Fase 0 — Bootstrap automático (shell, silencioso)

**Imediatamente**, antes de qualquer AskQuestion:

```bash
bash .cursor/skills/lucy/scripts/init.sh
```

Isso instala e configura **tudo**:

| Componente | Ação |
|------------|------|
| impeccable | `npx impeccable install` se ausente |
| ui-ux-pro-max | `uipro init --ai cursor` se ausente |
| taste-skill | `npx skills add … design-taste-frontend` |
| caveman | installer curl |
| claude-mem | install + **start worker** (skip se já instalado/rodando) |
| motion | npm install no frontend |
| **visual-gate** | Playwright + chromium se Next.js (**skip se já ok**) |
| **firecrawl-cli** | Se `FIRECRAWL_API_KEY` → `npx firecrawl-cli init --browser` |
| Symlinks | `link-ecosystem-skills.sh` |
| JSON L1 | `.cursor/lucy-progress.json` |
| Plan stub | `docs/LUCY-PLAN.md` |
| Index | `docs/LUCY-INDEX.md` (✅⏳🔮👤) |
| Second Brain | `brain-sync.sh init` → `.cursor/lucy-brain/` |
| **Cursor hooks** | `install-hooks.sh` → sessionStart + stop |
| PRODUCT.md | stub se FE |

**Não** perguntar ao usuário nesta fase. Reportar resumo em 3 linhas após concluir.

Se script falhar parcialmente: registrar WARN em `human_blockers[]`, continuar quiz.

---

## Fase 1–7 — Quiz (AskQuestion, uma rodada por turno)

**Antes de cada rodada**, executar:

```bash
bash .cursor/skills/lucy/scripts/quiz-next.sh
```

Usar **somente** os question IDs impressos. **Não** improvisar perguntas legadas.

Seguir `references/quiz-protocol.md`:

| Turno | Rodada | Tema |
|-------|--------|------|
| 1 | Round 1 | Produto & North Star |
| 2 | Round 2 | Escopo técnico |
| 3 | Round 3 | **MCP & integrações** (+ guia cadastro) |
| 4 | Round 4 | Design & UX |
| 5 | Round 5 | Qualidade & gates |
| 6 | Round 6 | Autonomia & loop |
| 7 | Round 7 | Kickoff contextual |

**Round 3:** rodar `mcp-setup-status.sh` + `mcp-integrations-setup-guide.md` se owner pedir guiar setup.

Após cada rodada:
- Persistir `quiz_answers.round_N` + incrementar `quiz_round`
- Round 3: persistir também `mcp_setup_status`
- Atualizar `docs/LUCY-INDEX.md`

---

## Fase 8 — Plano + memória + armar loop

Quando `quiz_complete: true`:

1. **Fases** — criar `phases{}` + tabela em `docs/LUCY-PLAN.md`
2. **Memória L2** — claude-mem capture: objetivo, fases, quiz summary
3. **INDEX** — marcar ✅ skills instaladas, ⏳ fase atual, 👤 blockers
4. **Delivery contract** — `acceptance_summary` do Round 1
5. **Armar loop dinâmico:**

```bash
bash .cursor/skills/lucy/scripts/arm-dynamic-loop.sh \
  --progress-file .cursor/lucy-progress.json \
  --seconds 45
```

6. **Tick 1 imediato** — `discover` → `plan` (ou `implement` se Round 7 definiu tasks claras)
7. **`next_prompt`** + re-arm ao fim do tick

---

## Prompt armado (gerado ao fim do init)

Gravar em JSON campo `next_prompt`:

```text
/lucy tick #1 — skill lucy

Context: .cursor/lucy-progress.json (quiz_complete=true)
Plan: docs/LUCY-PLAN.md
Index: docs/LUCY-INDEX.md
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
/lucy init
/lucy init --goal "Premium UI 100%"
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
