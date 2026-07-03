# Docs Sync Discipline — regra global Hermes-style

**Escopo:** toda mudança na skill Lucy (comandos, scripts, protocolos, hooks) **e** mudanças no app que alterem comportamento visível ao usuário.

**Origem:** `/lucy aprenda` — 2026-07-03 — *documentar tudo que faz, buscar docs afetados, nunca entregar feature sem docs sincronizadas.*

**Não confundir com:** `/lucy docs` (geração de API/componentes) — este protocolo é **sincronização obrigatória** após editar, não geração sob demanda.

---

## Mandamento (P0 global)

> **Após qualquer mudança em comandos, scripts ou protocolos**, o agente **não encerra o turno** sem:

1. **Grep docs** por termos afetados (comando, script, flag, nome de protocolo)
2. **Atualizar** README, MANUAL, SKILL, `references/README.md`, CHANGELOG
3. **Bump patch** em `SKILL.md` (`version` no frontmatter + título H1)
4. **Registrar** em `references/learned/INDEX.md` (se veio de `/lucy aprenda`)

Equivalente operacional ao Hermes: **memória (CAPTURE) + documentação (sync) = handoff completo.**

---

## Quando dispara

| Mudança | Obrigatório |
|---------|-------------|
| Novo comando ou flag em `SKILL.md` | Sim — todos os docs user-facing |
| Novo/alterado script em `scripts/` | Sim — MANUAL, README, protocolo dono |
| Novo/alterado protocolo em `references/` | Sim — `references/README.md`, SKILL refs, cross-links |
| Hook em `hooks/` | Sim — init-protocol, second-brain, MANUAL |
| Só typo em comentário interno | Não |
| Mudança só no app do cliente | PLAN + INDEX do projeto + docs do app (ver § App) |

---

## Pipeline (ordem obrigatória)

### 1. Extrair termos de busca

Do diff ou da tarefa, listar 3–8 termos:

- Nome do comando (`refazer-frontend`, `aprenda`)
- Nome do script (`design-quiz-next.sh`)
- Nome do protocolo (`docs-sync-discipline`)
- Flags (`--escopo`, `--audit-only`)
- Versão anterior (para achar badges desatualizados)

### 2. Grep docs (skill pack)

```bash
cd /path/to/Loop-master   # ou .cursor/skills/lucy

rg -l 'TERM1|TERM2|loop-master' \
  README.md MANUAL.md SKILL.md CHANGELOG.md \
  references/ .cursor/skills/lucy 2>/dev/null || true
```

**Arquivos user-facing — checklist mínimo:**

| Arquivo | O que conferir |
|---------|----------------|
| `SKILL.md` | Tabela de comandos, refs, anti-padrões, `version` |
| `README.md` | Badge, seções de comandos, tabela refs, rodapé versão |
| `MANUAL.md` | Versão no header, seções por comando |
| `references/README.md` | Índice, versão atual |
| `references/getting-started.md` | Comandos essenciais |
| `CHANGELOG.md` | Entrada `[x.y.z]` com data |
| Protocolo dono | Cross-links, exemplos de uso |
| `references/update-protocol.md` | Se comando novo aparece no update |

### 3. Editar e alinhar

- Uma entrada **CHANGELOG** por release lógico (patch se só docs/regra; minor se comando novo).
- **Mesma versão** em: frontmatter `SKILL.md`, H1, badge README, MANUAL header, `references/README.md`.
- Links relativos entre protocolos — sem 404 internos.

### 4. Bump versão

| Tipo de mudança | Bump |
|-----------------|------|
| Regra/processo/docs sync | patch (`2.9.1` → `2.9.2`) |
| Comando novo | minor (`2.9.x` → `2.10.0`) |
| Breaking (remover comando, paths) | major — raro, ADR obrigatório |

```yaml
# SKILL.md frontmatter
version: "2.9.2"
```

### 5. Registrar aprendizado (se `/lucy aprenda`)

```bash
bash .cursor/skills/lucy/scripts/aprenda-capture.sh \
  --slug "docs-sync-discipline" \
  --summary "Grep docs + sync README/MANUAL/SKILL/CHANGELOG + bump patch obrigatório"
```

Atualizar `references/learned/INDEX.md` com linha na tabela.

### 6. Publicar

Commit no repo `loop-master`:

```bash
git add README.md MANUAL.md SKILL.md CHANGELOG.md references/
git commit -m "learn: docs-sync-discipline — sync user-facing docs on every change"
git push origin main
```

---

## Handoff — checklist antes de CAPTURE

Marcar **todos** quando houve mudança em comando/script/protocolo:

- [ ] `rg` executado com termos da mudança
- [ ] README + MANUAL + SKILL + `references/README` + CHANGELOG alinhados
- [ ] `version` bumpada em `SKILL.md` (e espelhos)
- [ ] `learned/INDEX.md` atualizado (se aprenda)
- [ ] `brain-sync capture --paths` inclui docs tocados

---

## § App (projeto cliente)

Quando a mudança é no **app** (não no skill pack):

| Ação | Onde |
|------|------|
| Status fase | `docs/LUCY-PLAN.md` |
| Emojis | `docs/LUCY-INDEX.md` |
| ADR significativo | `/lucy docs --adr` |
| Changelog produto | `CHANGELOG.md` do app (se existir) |
| Versão doc | `doc_versions[]` no progress JSON |

Mesma disciplina de **grep antes de encerrar** — buscar README, docs/, comentários de rota.

---

## Integração com outros protocolos

| Protocolo | Relação |
|-----------|---------|
| `second-brain-protocol.md` | CAPTURE lista `--paths` dos docs editados |
| `lucy-aprenda-protocol.md` | Passo 2 do pipeline aprenda **inclui** este protocolo |
| `autonomous-orchestrator-protocol.md` | Gate + handoff exigem docs sync |
| `docs-protocol.md` | Geração (`/lucy docs`); sync é **complementar** |

---

## Anti-padrões

- Entregar comando novo só em `SKILL.md` — README/MANUAL ficam em v2 antiga
- Bump de versão só no CHANGELOG, não no frontmatter
- `references/README.md` sem entrada do protocolo novo
- Encerrar turno com CAPTURE mas docs desatualizados
- Confundir capture de brain com publicação global — aprendizado de processo vai no skill pack + GitHub
