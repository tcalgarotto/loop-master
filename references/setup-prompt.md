# Prompt inicial — `/loop-master init` (zero-config v2.4)

**Uma linha basta.** O agente roda bootstrap + quiz + loop sozinho.

---

## Comando único (copiar no Cursor Agent)

```
/loop-master init
```

O orchestrator deve:

1. Rodar `bash .cursor/skills/loop-master/scripts/init.sh` **sem perguntar**
2. Iniciar quiz Round 1 (AskQuestion) — 6 rodadas total
3. Criar fases, INDEX, armar loop dinâmico, tick 1

---

## Com objetivo pré-definido

```
/loop-master init — objetivo: Premium UI 100% production-ready
```

---

## Continuar trabalho

```
/loop-master
```

Ou ler `next_prompt` do JSON e executar.

---

## Segundo loop no mesmo repo

```
/loop-master init — progress-file: .cursor/loop-master-progress.<NOME>.json
```

---

## Docs

- [getting-started.md](getting-started.md)
- [quiz-protocol.md](quiz-protocol.md) — 6 rodadas
- [design-skills-routing-table.md](design-skills-routing-table.md)
