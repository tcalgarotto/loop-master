# Prompt inicial — `/lucy init` (zero-config v2.4)

**Uma linha basta.** O agente roda bootstrap + quiz + loop sozinho.

---

## Comando único (copiar no Cursor Agent)

```
/lucy init
```

O orchestrator deve:

1. Rodar `bash .cursor/skills/lucy/scripts/init.sh` **sem perguntar**
2. Iniciar quiz Round 1 (AskQuestion) — 7 rodadas total; Round 3 guia cadastro MCP
3. Criar fases, INDEX, armar loop dinâmico, tick 1

---

## Com objetivo pré-definido

```
/lucy init — objetivo: Premium UI 100% production-ready
```

---

## Continuar trabalho

```
/lucy
```

Ou ler `next_prompt` do JSON e executar.

---

## Segundo loop no mesmo repo

```
/lucy init — progress-file: .cursor/lucy-progress.<NOME>.json
```

---

## Docs

- [getting-started.md](getting-started.md)
- [quiz-protocol.md](quiz-protocol.md) — 7 rodadas
- [mcp-integrations-setup-guide.md](mcp-integrations-setup-guide.md) — cadastro MCP
- [design-skills-routing-table.md](design-skills-routing-table.md)
