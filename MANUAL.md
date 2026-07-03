# Manual — Loop Master

Guia completo de uso da skill loop-master no Cursor Agent.

**Versão:** 2.5.1 · **Repo:** https://github.com/tcalgarotto/loop-master

---

## 1. O que é

Loop Master transforma o Cursor Agent em um **orquestrador autônomo** com **segundo cérebro**:

- Planeja em fases até **100% de entrega**
- Instala skills de design, memória e qualidade
- Loop dinâmico encadeado (tick → tick)
- Memória viva do projeto e do dev a **cada sessão Agent**

---

## 2. Pré-requisitos

| Requisito | Como verificar |
|-----------|----------------|
| Cursor com **Agent Skills** ON | Settings → Rules → Agent Skills |
| Git + Node.js + jq | `node -v`, `jq --version` |
| Projeto com código | repo git ou app |

---

## 3. Instalação (primeira vez)

### 3.1 Clone da skill

```bash
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/loop-master
cd seu-projeto
ln -sf ~/.cursor/skills/loop-master .cursor/skills/loop-master   # opcional
```

### 3.2 Um comando no Cursor Agent

```
/loop-master init
```

Isso executa **automaticamente**:

1. `init.sh` — instala impeccable, ui-ux-pro-max, taste, caveman, claude-mem, motion
2. `brain-sync.sh init` — cria `.cursor/loop-master-brain/`
3. `install-hooks.sh` — registra hooks Cursor (memória em todo chat Agent)
4. Quiz em **6 rodadas** (AskQuestion)
5. Plano + INDEX + armamento do loop dinâmico

**Não precisa** rodar scripts manualmente após o clone.

### 3.3 Verificar

```bash
bash .cursor/skills/loop-master/scripts/verify-pack.sh    # → PASSED
bash .cursor/skills/loop-master/scripts/brain-sync.sh status
cat .cursor/hooks.json   # deve listar loop-master hooks
```

Reinicie o Cursor se os hooks não aparecerem em Settings → Hooks.

---

## 4. Comandos

| Comando | Quando usar |
|---------|-------------|
| `/loop-master init` | Projeto novo ou reconfigurar |
| `/loop-master` | Executar **um tick** de trabalho |
| `/loop-master update` | Atualizar skill sem perder progresso |
| `pare o loop` | Parar loop automático |

---

## 5. Second Brain — memória viva

### Onde fica

```
.cursor/loop-master-brain/
├── STATE.json           # consciência (0–100%)
├── dev-profile.json     # preferências do dev
├── project-mind.json    # decisões de arquitetura
├── interaction-log.jsonl
└── INDEX.md             # ✅ ⏳ 🔮 👤
```

### Ciclo automático (hooks — Opção B)

| Evento Cursor | Hook | Ação |
|---------------|------|------|
| Nova sessão Agent | `sessionStart` | Hidrata memória → injeta contexto |
| Fim do turno Agent | `stop` | Captura resumo da sessão |

Hooks instalados em `.cursor/hooks/loop-master/` via `install-hooks.sh`.

### Ciclo manual (cada `/loop-master`)

1. **HYDRATE** — `brain-sync.sh hydrate` + claude-mem search
2. **TRABALHAR** — implement / audit / fix
3. **CAPTURE** — `brain-sync.sh capture` + claude-mem observation_add

Detalhe: [references/second-brain-protocol.md](references/second-brain-protocol.md)

---

## 6. Quiz — 6 rodadas

| # | Tema |
|---|------|
| 1 | Produto & North Star |
| 2 | Escopo técnico |
| 3 | Design & UX |
| 4 | Qualidade & gates |
| 5 | Autonomia & loop |
| 6 | Kickoff — por onde começar |

Detalhe: [references/quiz-protocol.md](references/quiz-protocol.md)

---

## 7. Loop autônomo

Após init, cada tick:

```
discover → plan → implement → verify → audit → fix ↺ → gate
```

Ao fim: `arm-dynamic-loop.sh` re-arma o próximo tick em ~45s até `overall_pct === 100`.

Detalhe: [references/autonomous-orchestrator-protocol.md](references/autonomous-orchestrator-protocol.md)

---

## 8. Design — skills roteadas

O orchestrator escolhe automaticamente:

impeccable · ui-ux-pro-max · taste-skill · design · design-system · ui-styling · brand · slides · motion

Detalhe: [references/design-skills-routing-table.md](references/design-skills-routing-table.md)

---

## 9. Arquivos do projeto

| Arquivo | Função |
|---------|--------|
| `.cursor/loop-master-progress.json` | Estado do loop (L1) |
| `docs/LOOP-MASTER-PLAN.md` | Fases e gates |
| `docs/LOOP-MASTER-INDEX.md` | Índice operacional |
| `.cursor/hooks.json` | Hooks Cursor (brain) |

---

## 10. Atualizar a skill

```bash
bash ~/.cursor/skills/loop-master/scripts/update.sh
```

Ou no Agent: `/loop-master update`

---

## 11. Parar o loop

Digite no chat:

```
pare o loop
```

Ou: `loop_status: stopped` no JSON.

---

## 12. Troubleshooting

| Problema | Solução |
|----------|---------|
| Hooks não carregam | Reiniciar Cursor; conferir `.cursor/hooks.json` |
| claude-mem inativo | `npx claude-mem start` |
| verify-pack FAILED | Rodar do root do projeto; ver mensagem |
| Brain vazio | Rodar `/loop-master init` ou `brain-sync.sh init` |
| Skills não instaladas | `init.sh` de novo ou `--skills ...` |

---

## 13. Referência técnica

Índice completo: [references/README.md](references/README.md)

---

## 14. Licença

MIT — ver [LICENSE](LICENSE)
