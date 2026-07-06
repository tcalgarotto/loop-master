# Memory architecture — L0–L3 (Lucy) + L4/L5 (comunidade)

**Versão:** v2.9.34+  
**Público:** agente Lucy + owners técnicos

> Resumo owner PT-BR: `.lucy/memory-architecture-hubfu.md` (no projeto HubFU)  
> Protocolos: `second-brain-protocol.md` · `memory-protocol.md` · `learned/l2-knowledge-agent-protocol.md`

---

## Mapa geral

```
┌─────────────────────────────────────────────────────────────────┐
│ L5 — Org / cross-project (comunidade)         [Lucy: não usa]   │
├─────────────────────────────────────────────────────────────────┤
│ L4 — Product / team memory (Vector DB, graphs)  [Lucy: opcional]│
├─────────────────────────────────────────────────────────────────┤
│ L3 — Human docs (PLAN, INDEX, brain/INDEX)    [Lucy: sim]     │
├─────────────────────────────────────────────────────────────────┤
│ L2 — Semantic (claude-mem MCP)                [Lucy: opt-in]  │
│      ├─ search 3-layer (HYDRATE)                                │
│      └─ knowledge-agent (corpus Q&A)                            │
├─────────────────────────────────────────────────────────────────┤
│ L1 — Handoff JSON (lucy-progress.json)        [Lucy: sim]     │
├─────────────────────────────────────────────────────────────────┤
│ L0 — Brain local (.cursor/lucy-brain/)        [Lucy: sim]     │
└─────────────────────────────────────────────────────────────────┘
```

---

## L0 — Brain local (obrigatório)

| Item | Valor |
|------|-------|
| **Storage** | `.cursor/lucy-brain/` |
| **Conteúdo** | dev-profile, project-mind, interaction-log, rules P0 |
| **Scripts** | `brain-sync.sh hydrate|capture` |
| **Hooks** | `sessionStart` / `stop` → L0 only |
| **Escopo** | Este projeto, esta máquina |

**Papel:** memória estruturada de baixa latência; fonte para ticks e regras imutáveis (`/lucy regra`).

---

## L1 — Handoff JSON (obrigatório)

| Item | Valor |
|------|-------|
| **Storage** | `.cursor/lucy-progress.json` |
| **Conteúdo** | tick, fases, `next_prompt`, `memory_refs[]` |
| **Regra** | Single-writer — uma sessão orquestradora |

**Papel:** continuidade entre ticks e sessões sem depender de chat history.

---

## L2 — claude-mem semantic (opt-in)

| Item | Valor |
|------|-------|
| **Flag** | `LUCY_CLAUDE_MEM=1` |
| **Worker** | `npx claude-mem start` → `:37700` |
| **Índice interno** | SQLite + **Chroma embutido** (zero-config) |
| **MCP** | `plugin-claude-mem-mcp-search` |

### L2a — Search 3-layer (HYDRATE padrão)

`search` → `timeline` → `get_observations` — ver `claude-mem-mcp-operational-playbook.md`.

### L2b — Knowledge-agent (v2.9.34+)

`build_corpus` → `prime_corpus` → `query_corpus` — ver `learned/l2-knowledge-agent-protocol.md`.

### Skills claude-mem plugin (complementares)

| Skill | Papel | Lucy usa? |
|-------|-------|-----------|
| `mem-search` | Busca manual cross-session | Via MCP `search` no HYDRATE |
| `knowledge-agent` | Corpora conversacionais | **Sim** — protocolo L2b |
| `weekly-digests` | Digest semanal do repo | Opcional — owner sob demanda |
| `timeline-report` | Narrativa journey do projeto | Opcional — retrospectivas |
| `how-it-works` | Explica injeção de memória | Referência |

---

## L3 — Human-readable (obrigatório)

| Item | Valor |
|------|-------|
| **Storage** | `docs/LUCY-PLAN.md`, `docs/LUCY-INDEX.md`, `.lucy/*`, `brain/INDEX.md` |
| **Papel** | Owner lê sem abrir JSON; ADRs e handoffs |

---

## L4 — Product / team layer (comunidade — Lucy NÃO usa por padrão)

Camada para **memória do produto em runtime** (usuários finais, tenants, equipe), separada da memória de **desenvolvimento do agente**.

### Candidatos na comunidade (2026)

| Padrão | Exemplos | Quando faz sentido |
|--------|----------|-------------------|
| **Vector DB dedicado** | pgvector, Qdrant, Pinecone, Chroma self-hosted | RAG multi-tenant no app |
| **Episodic memory graphs** | Zep (Graphiti), Mem0g | Fatos com validade temporal, "o que era verdade em março?" |
| **Team shared KB** | Notion API, Confluence, wiki indexada | Conhecimento institucional fora do git |
| **RAG sobre repo** | codebase index (Cursor, Sourcegraph) | Perguntas sobre código — overlap com `explore` |
| **Cursor rules como memória** | `.cursor/rules/`, `lucy-brain/rules/` | **Lucy já usa** via L0 rules P0 |
| **NotebookLM corpus** | `notebooklm-mcp` | Research docs externos, não dev memory |

### Vector DB custom vs Chroma do claude-mem

| | claude-mem (L2) | Vector DB custom (L4) |
|--|-----------------|----------------------|
| **Quem** | Agente dev no Cursor | App HubFU / usuários finais |
| **Dados** | Observações de sessão dev | Docs produto, tickets, NCM, histórico cliente |
| **Config** | Zero-config (`npx claude-mem`) | Infra própria + embeddings |
| **Multi-tenant** | Por máquina/projeto local | Por `company_id` no Postgres |
| **Lucy** | **Usa** (opt-in) | **Não usa** — camada produto futura |

### Sketch de config HubFU (L4 produto — hipotético)

```env
# Memória AI do produto — NÃO confundir com L2 dev
VECTOR_DB_URL=postgresql://user:pass@db:5432/hubfu_vectors
VECTOR_DB_PROVIDER=pgvector
EMBEDDING_MODEL=nvidia/nv-embedqa-e5-v5
EMBEDDING_API_BASE=https://integrate.api.nvidia.com/v1
VECTOR_COLLECTION_PREFIX=hubfu_tenant_
```

**Por que separar:** L2 grava *como o time desenvolveu*; L4 gravaria *o que o CRM sabe sobre cada cliente/empresa*. Misturar os dois gera vazamento de contexto e custo de embedding desnecessário no dev loop.

---

## L5 — Org / cross-project (comunidade — Lucy NÃO usa)

| Padrão | Exemplos | Status Lucy |
|--------|----------|-------------|
| Long-term user preference models | Perfil inferido cross-repo | Não — só `dev-profile.json` local |
| Cross-project org memory | Memória empresa em todos repos | Não — cada projeto tem brain |
| Fine-tuned project embeddings | Modelo custom por codebase | Não — over-engineering para skill pack |
| Letta/MemGPT stateful agents | Agente com memória como runtime | Arquitetura diferente do Lucy |

**Honestidade:** L5 é pesquisa/produto maduro (Zep Cloud, Mem0 platform). Lucy resolve 90% com L0–L3 + L2 opt-in. Adicionar L4/L5 sem necessidade clara viola o mandato anti-over-engineering.

---

## Matriz HubFU / Lucy hoje

| Capacidade | Camada | Status |
|------------|--------|--------|
| Regras P0 projeto | L0 rules | ✅ |
| Handoff ticks | L1 JSON | ✅ |
| Busca semântica dev | L2 search | ⏳ opt-in (`LUCY_CLAUDE_MEM=1`) |
| Expertise compilada | L2 knowledge-agent | ✅ v2.9.34 (protocolo) |
| PLAN/INDEX/.lucy | L3 | ✅ |
| Assistente IA tenant no CRM | L4 pgvector | 🔮 futuro produto |
| Memória org cross-repo | L5 | 🔮 não planejado |

---

## Próximos passos opcionais (sem over-engineering)

| Prioridade | Ação | Esforço |
|------------|------|---------|
| P0 | Habilitar L2 + corpora focados (`hubfu-fiscal`, `hubfu-erp`) | Baixo |
| P1 | `weekly-digests` / `timeline-report` em marcos de release | Baixo |
| P2 | NotebookLM para docs fiscais externos (TEC, CONFAZ) | Médio |
| P3 | L4 pgvector no backend HubFU para assistente tenant | Alto — produto |
| — | Zep/Mem0 no dev loop | **Não recomendado** — overlap com claude-mem |

---

## Referências cruzadas

- `second-brain-protocol.md` — ciclo HYDRATE/CAPTURE
- `memory-protocol.md` — regras L1 concorrência
- `learned/claude-mem-zero-config-playbook.md` — habilitar L2
- `learned/l2-knowledge-agent-protocol.md` — L2b workflow
- `mcp-integrations-setup-guide.md` — cadastro MCP
