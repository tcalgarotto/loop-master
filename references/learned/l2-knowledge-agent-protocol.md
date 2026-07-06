# L2 knowledge-agent — quando usar vs search bruto

**Origem:** `/lucy aprenda` — 2026-07-06  
**Versão Lucy:** v2.9.34+  
**MCP:** `plugin-claude-mem-mcp-search` — tools `build_corpus`, `prime_corpus`, `query_corpus`, `list_corpora`, `rebuild_corpus`, `reprime_corpus`

> Complementa: `claude-mem-mcp-operational-playbook.md` · `second-brain-protocol.md` · `memory-architecture.md`

---

## O que é

**Knowledge-agent** transforma observações filtradas do claude-mem em um **cérebro conversacional** (corpus + sessão primada). Em vez de o agente juntar manualmente hits de `search`, você compila expertise focada e faz perguntas em linguagem natural.

| Abordagem | Analogia | Melhor para |
|-----------|----------|-------------|
| **search → timeline → get_observations** | Índice + fichas | HYDRATE rápido, 1–5 hits, tick corrente |
| **knowledge-agent** | Especialista que leu tudo do tema | Padrões, decisões acumuladas, "o que aprendemos sobre X?" |

Ambos usam o **mesmo** worker claude-mem (L2). Knowledge-agent é camada **acima** do search — não substitui L0/L1.

---

## Workflow em 3 camadas (obrigatório entender)

### Camada A — Recall pontual (todo HYDRATE)

```
search(query="<projeto> <fase> <intenção>", limit=5)
→ timeline(anchor=ID)        # se hit relevante
→ get_observations([IDs])    # só IDs filtrados
```

**Use quando:** início de tick, contexto recente, 1 tópico ativo, economia de tokens.

### Camada B — Expertise compilada (sob demanda)

```
build_corpus(
  name="hubfu-fiscal",
  description="Decisões e descobertas fiscais HubFU",
  project="hermes-crm",
  types="decision,feature,discovery",
  concepts="fiscal,erp",
  limit=500
)
prime_corpus(name="hubfu-fiscal")
query_corpus(name="hubfu-fiscal", question="Quais decisões de ICMS/IPI já tomamos?")
```

**Use quando:**
- Owner pergunta "o que já decidimos sobre X?"
- Retomar área complexa (fiscal, ERP native, migração Kommo)
- Auditar padrões cross-session (não só último tick)
- Corpus focado (<500 obs) com follow-ups conversacionais

### Camada C — Manutenção

```
list_corpora                          # ver stats + priming status
rebuild_corpus(name="hubfu-fiscal")   # novas observações desde último build
reprime_corpus(name="hubfu-fiscal")   # reset sessão se drift
```

---

## Árvore de decisão (agente)

```
L2 ativo? (LUCY_CLAUDE_MEM=1 + worker + MCP)
  │
  ├─ NÃO → só L0 brain-sync + L1 JSON
  │
  └─ SIM
       │
       ├─ HYDRATE de tick / contexto imediato?
       │     └─ SIM → Camada A (search 3-layer)
       │
       └─ Pergunta ampla / retrospectiva / padrões?
             ├─ Corpus já existe e primed? → query_corpus
             └─ Não existe? → build_corpus → prime_corpus → query_corpus
```

**Regra:** nunca pular Camada A no HYDRATE só porque existe corpus — search é barato e traz o mais recente.

---

## Quando NÃO usar knowledge-agent

| Situação | Usar em vez |
|----------|-------------|
| 1–3 observações esperadas | `search` direto |
| Tick com escopo fechado | Camada A no HYDRATE |
| L2 desabilitado | L0 `.cursor/lucy-brain/` |
| Corpus "tudo do projeto" sem filtro | Refinar filtros — corpora amplos perdem foco |
| `prime_corpus` falha (worker sem LLM) | Camada A + documentar blocker |

---

## Filtros úteis para HubFU

| Corpus sugerido | Filtros |
|-----------------|---------|
| `hubfu-fiscal` | `project=hermes-crm`, `concepts=fiscal`, `types=decision,discovery` |
| `hubfu-erp-native` | `files=backend/app/erp/`, `types=feature,refactor` |
| `hubfu-design` | `concepts=design,impeccable`, `types=decision,change` |
| `hubfu-migrations` | `query="alembic migration"`, `types=change,bugfix` |

---

## Pré-requisitos e falhas comuns

| Check | Comando / sinal |
|-------|-----------------|
| Worker | `npx claude-mem status` → running `:37700` |
| MCP | `list_corpora` ou `search` retorna sem erro |
| LLM para prime/query | NVIDIA NIM em `~/.claude-mem/.env` **ou** `CLAUDE_CODE_PATH` no settings |
| Opt-in Lucy | `LUCY_CLAUDE_MEM=1` |

**Sintoma:** `build_corpus` OK, `prime_corpus` 500 "Claude executable not found" → backend LLM do worker não configurado. **Fallback:** Camada A (search) continua funcionando.

---

## Integração HYDRATE (second-brain)

Ordem no início de tick com L2 ativo:

1. `brain-sync.sh hydrate` (L0 — sempre)
2. Camada A: `search` + timeline se necessário
3. **Se** tarefa é retrospectiva/complexa **e** corpus relevante existe: `query_corpus` (não rebuild a cada tick)
4. Merge em `memory_refs[]` no progress JSON

---

## Integração CAPTURE

Knowledge-agent **não** substitui capture:

```
observation_add(...)      # alimenta futuros corpora
brain-sync.sh capture     # L0 — sempre
```

Rebuild de corpus é **manual ou sob demanda** — não a cada tick.

---

## Anti-padrões

- Rebuild corpus inteiro a cada HYDRATE (lento, caro)
- Ignorar search porque corpus existe (perde observações novas)
- Corpus sem `project` ou `types` — vira lixo semântico
- `get_observations` em massa sem filtrar via search
- Assumir knowledge-agent funciona sem verificar worker LLM
