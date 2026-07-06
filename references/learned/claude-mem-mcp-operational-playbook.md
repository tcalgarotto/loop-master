# claude-mem MCP — playbook operacional (aprendido via `/lucy aprenda`)

**Origem:** owner · 2026-07-05 · Hermes VPS — worker `:37700` + MCP `plugin-claude-mem-mcp-search` autenticado  
**Versão Lucy:** v2.9.28+  
**Papel:** agente usa L2 sem adivinhar — verificar, buscar, extrair valor do índice semântico.

> Complementa: `claude-mem-nvidia-setup.md` · `second-brain-protocol.md` · `mcp-integrations-setup-guide.md`

---

## Qual MCP é este?

| Sinal | Significa |
|-------|-----------|
| Owner diz "memória", "L2", "claude-mem", "basically in memory" | **claude-mem** (plugin Cursor `plugin-claude-mem-mcp-search`) |
| `build.nvidia.com` / `nvapi-` | **Backend LLM** do worker claude-mem (NVIDIA NIM) — **não** é um MCP separado |
| Worker `:37700` | Daemon local SQLite + Chroma — alimenta o MCP search |

**Não confundir** com notebooklm-mcp (research Google) nem cursor-ide-browser (visual QA).

---

## Status em 4 camadas (checklist agente)

Rodar **antes** de assumir "claude-mem não funciona":

```bash
# 1. Worker
npx claude-mem status          # Worker is running · Port 37700

# 2. Provider NVIDIA (secrets fora do repo)
test -f ~/.claude-mem/settings.json && echo settings OK
test -f ~/.claude-mem/.env && grep -q 'nvapi-' ~/.claude-mem/.env && echo key present || echo key MISSING

# 3. Lucy opt-in
echo "LUCY_CLAUDE_MEM=${LUCY_CLAUDE_MEM:-unset}"

# 4. MCP Cursor (descriptors)
ls ~/.cursor/projects/*/mcps/plugin-claude-mem-mcp-search/tools/search.json
bash .cursor/skills/lucy/scripts/mcp-setup-status.sh --json | jq '.integrations[] | select(.slug=="claude-mem")'
```

| Camada | Configurado quando… | Sintoma se falta |
|--------|---------------------|------------------|
| Worker | `npx claude-mem status` → running | MCP search vazio ou erro de conexão |
| NVIDIA `.env` | `~/.claude-mem/.env` com `nvapi-` em **ambas** `CLAUDE_MEM_OPENROUTER_API_KEY` + `OPENROUTER_API_KEY` | Worker cai no Claude SDK; observações não indexam via NIM |
| `LUCY_CLAUDE_MEM=1` | export no profile ou sessão | Lucy não chama MCP em HYDRATE/CAPTURE |
| MCP plugin | `plugin-claude-mem-mcp-search/tools/` presente | Agente não vê tools `search`, `observation_add` |

**Parcial comum (2026-07-05 Hermes):** worker + MCP + settings OK; **falta `.env` NVIDIA** e `LUCY_CLAUDE_MEM=1`.

---

## Workflow MCP — 3 camadas (obrigatório)

O tool `__IMPORTANT` do plugin exige **economia de tokens**:

```
1. search(query)           → índice com IDs (~50–100 tokens/resultado)
2. timeline(anchor=ID)     → contexto ao redor do hit interessante
3. get_observations([IDs]) → detalhe completo SÓ dos IDs filtrados
```

**Nunca** pular para `get_observations` sem filtrar via `search` primeiro.

### HYDRATE (início de tick)

```
search(query="<projeto> <tópico ativo>", limit=5)
→ se hit relevante: timeline(anchor=<ID>)
→ get_observations([<IDs>]) só se precisar do texto completo
```

### CAPTURE (fim de tick)

```
observation_add(...)   # decisão, finding, bloqueio
brain-sync.sh capture  # L0 — sempre, independente de L2
```

---

## NVIDIA NIM — modelo recomendado

Provider: `openrouter` apontando para `https://integrate.api.nvidia.com/v1`.

| Model ID | Quando usar |
|----------|-------------|
| **`meta/llama-3.3-70b-instruct`** | **Default** — extração de observações; melhor equilíbrio qualidade/latência/custo no NIM |
| `mistralai/mistral-small-24b-instruct-2501` | VPS RAM apertada (~11 GB); indexação mais leve |
| `nvidia/llama-3.1-nemotron-70b-instruct` | Reasoning pesado — **evitar** para indexação contínua (lento) |

Key: [build.nvidia.com](https://build.nvidia.com) → Profile → API Keys → `nvapi-...` → `~/.claude-mem/.env` (chmod 600). **Uma key por usuário** — ver `nvidia-api-keys-per-user.md`.

Templates: `references/templates/claude-mem-settings.nvidia.json`, `claude-mem-nvidia.env.example`.

---

## Setup owner — gaps típicos

**Preferir zero-config:** `references/learned/claude-mem-zero-config-playbook.md` + `scripts/claude-mem-bootstrap.sh`.

```bash
# Caminho curto (recomendado)
LUCY_CLAUDE_MEM=1 bash .cursor/skills/lucy/scripts/claude-mem-bootstrap.sh
```

Cursor → Settings → Tools & MCPs → **claude-mem** verde.

Teste agente: `search(query="nome-do-projeto")` deve retornar índice com IDs.

---

## Anti-padrões

- Tratar `build.nvidia.com` como MCP separado
- Assumir `mcp-setup-status.sh` claude-mem=false quando worker roda via `npx` (corrigido v2.9.28)
- Buscar memória sem `search` primeiro
- Colocar `nvapi-` no `.env` do app ou git
- Pedir key NVIDIA no chat ou ecoar valor de `.env`
- Compartilhar key entre usuários/máquinas
- Três sessões editando `lucy-progress.json` (L1 single-writer)

---

## Comandos

| Comando | Ação |
|---------|------|
| `npx claude-mem status` | Worker health |
| `bash scripts/mcp-setup-status.sh --json` | Snapshot integrações |
| `bash scripts/mcp-setup-guide.sh --slug claude-mem` | Guia resumido |
| MCP `search` | HYDRATE L2 |
| MCP `observation_add` | CAPTURE L2 |
| MCP `build_corpus` → `prime_corpus` → `query_corpus` | L2b knowledge-agent — retrospectiva (v2.9.34+) |

Ver `learned/l2-knowledge-agent-protocol.md` · `memory-architecture.md`.
