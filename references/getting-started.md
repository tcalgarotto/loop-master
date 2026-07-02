# Guia rápido — Loop Master v2.4

> **Zero-config:** digite `/loop-master init` — o resto é automático.

## O que é?

Orquestrador autônomo para Cursor Agent:
- Instala **todas** as skills no init
- Quiz em **6 rodadas** (formulário multi-etapas)
- Loop dinâmico encadeado (AGI-style)
- Design director com mapa completo de skills
- Memória claude-mem + JSON + INDEX com emojis

---

## Pré-requisitos

1. Cursor com **Agent Skills** ON
2. Git + Node.js + jq

---

## Instalação (2 passos)

### 1. Clone

```bash
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/loop-master
cd seu-projeto
```

### 2. Init no Cursor

```
/loop-master init
```

Isso roda bootstrap completo + quiz. **Não precisa** rodar scripts manualmente.

---

## Quiz — 6 rodadas

| Rodada | Tema |
|--------|------|
| 1 | Produto & North Star |
| 2 | Escopo técnico |
| 3 | Design & UX |
| 4 | Qualidade & gates |
| 5 | Autonomia & loop |
| 6 | Kickoff — por onde começar |

Detalhe: [quiz-protocol.md](quiz-protocol.md)

---

## Comandos

| Comando | Uso |
|---------|-----|
| `/loop-master init` | Bootstrap + quiz + arm loop |
| `/loop-master` | Um tick |
| `/loop-master update` | Atualizar pack |
| `pare o loop` | Parar |

---

## Memória & INDEX

| Artefato | Função |
|----------|--------|
| `.cursor/loop-master-progress.json` | Handoff L1 |
| claude-mem | Memória L2 cross-session |
| `docs/LOOP-MASTER-PLAN.md` | Fases |
| `docs/LOOP-MASTER-INDEX.md` | Status ✅ ⏳ 🔮 👤 |

---

## Design skills

Mapa completo: [design-skills-routing-table.md](design-skills-routing-table.md)

impeccable · ui-ux-pro-max · taste-skill · design · design-system · ui-styling · brand · slides · banner-design · motion

---

## Verificar

```bash
bash .cursor/skills/loop-master/scripts/verify-pack.sh
```

Deve retornar **PASSED**.
