# Loop Master v2.5.1

> **Zero-config autonomous orchestrator** with **Second Brain** memory for Cursor Agent.

📖 **[Manual completo (PT)](MANUAL.md)** · [Guia rápido](references/getting-started.md) · [Referências](references/README.md)

---

## Quick start

```bash
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/loop-master
cd seu-projeto
```

No Cursor Agent:

```
/loop-master init
```

---

## O que faz

| Feature | Descrição |
|---------|-----------|
| **Zero-config init** | Instala todas skills + brain + hooks |
| **Quiz 6 rodadas** | Formulário multi-etapas |
| **Second Brain** | Memória dev + projeto a cada interação |
| **Cursor hooks** | `sessionStart` hydrate + `stop` capture |
| **Dynamic loop** | Re-arm 45s até 100% |
| **Design director** | Roteia 10+ skills de design |

---

## Comandos

| Comando | Ação |
|---------|------|
| `/loop-master init` | Bootstrap + quiz + hooks + arm loop |
| `/loop-master` | Um tick autônomo |
| `/loop-master update` | Atualizar sem perder progresso |
| `pare o loop` | Parar |

---

## Scripts

| Script | Função |
|--------|--------|
| `init.sh` | Bootstrap completo |
| `brain-sync.sh` | Second Brain hydrate/capture |
| `install-hooks.sh` | Hooks Cursor (Opção B) |
| `arm-dynamic-loop.sh` | Chain next tick |
| `verify-pack.sh` | Smoke test |

---

## Versão

**2.5.2** — quiz-next.sh enforces 6-round AskQuestion (fixes legacy flat quiz).

MIT License
