# claude-mem zero-config — guia owner (3 passos)

**Origem:** `/lucy aprenda` — 2026-07-06  
**Versão Lucy:** v2.9.32+  
**Papel:** um caminho só para L2 semântico — qualquer usuário, qualquer máquina.

> Complementa: `claude-mem-nvidia-setup.md` · `claude-mem-mcp-operational-playbook.md` · `mcp-integrations-setup-guide.md`

---

## O que você ganha

| Camada | O quê | Obrigatório? |
|--------|-------|--------------|
| L0 | `.cursor/lucy-brain/` — regras, perfil, ADRs | Sim (sempre) |
| L1 | `lucy-progress.json` — handoff entre ticks | Sim |
| **L2** | claude-mem — busca semântica cross-session | **Opt-in** (`LUCY_CLAUDE_MEM=1`) |

L2 vale quando roda **2+ chats Cursor** no mesmo projeto e quer recall (“o que decidimos sobre auth?”) sem reler JSON inteiro.

---

## 3 passos (owner)

### 1. Key NVIDIA — uma por usuário (não compartilhar)

> **Segurança (v2.9.33+):** cada pessoa gera **sua própria** key; agente só guia — nunca pede a key no chat. Ver `nvidia-api-keys-per-user.md`.

1. [build.nvidia.com](https://build.nvidia.com) → Profile → API Keys → Generate Personal Key (`nvapi-...`)
2. Cole **uma vez** em `~/.claude-mem/.env` (chmod 600) — **só localmente**, fora do repo e do chat

O bootstrap copia o template e sincroniza **as duas** variáveis com o mesmo valor:

```bash
CLAUDE_MEM_OPENROUTER_API_KEY=nvapi-...
OPENROUTER_API_KEY=nvapi-...   # obrigatório — worker só ativa NIM com esta var
```

**Nunca** commitar a key no repo do app. **Nunca** compartilhar key entre usuários ou máquinas.

### 2. Habilitar L2 no projeto

Uma linha no `.env` do projeto (não é secret):

```bash
LUCY_CLAUDE_MEM=1
```

### 3. Bootstrap ou init

```bash
# Caminho direto (recomendado)
LUCY_CLAUDE_MEM=1 bash .cursor/skills/lucy/scripts/claude-mem-bootstrap.sh

# Ou init incremental (chama bootstrap automaticamente quando LUCY_CLAUDE_MEM=1)
LUCY_CLAUDE_MEM=1 bash .cursor/skills/lucy/scripts/init.sh --update-mode incremental
```

Depois: **Cursor → Settings → Tools & MCPs → claude-mem** verde.

---

## Checklist agente (4 camadas)

Rodar antes de assumir “claude-mem não funciona”:

```bash
npx claude-mem status                                    # Worker is running · :37700
test -f ~/.claude-mem/.env && grep -q 'nvapi-' ~/.claude-mem/.env && echo key OK
grep -q '^LUCY_CLAUDE_MEM=1' .env && echo L2 opt-in OK
bash .cursor/skills/lucy/scripts/mcp-setup-status.sh --json | jq '.integrations[] | select(.slug=="claude-mem")'
LUCY_CLAUDE_MEM=1 bash .cursor/skills/lucy/scripts/claude-mem-bootstrap.sh  # idempotente
```

| Camada | OK quando… |
|--------|------------|
| Worker | `npx claude-mem status` → running |
| NVIDIA `.env` | Ambas vars `nvapi-` em `~/.claude-mem/.env` |
| Lucy opt-in | `LUCY_CLAUDE_MEM=1` no `.env` do projeto |
| MCP plugin | `plugin-claude-mem-mcp-search/tools/search.json` presente |

---

## Modelo default

Provider `openrouter` → `https://integrate.api.nvidia.com/v1`

| Model ID | Uso |
|----------|-----|
| **`meta/llama-3.3-70b-instruct`** | **Default** — indexação L2 |
| `mistralai/mistral-small-24b-instruct-2501` | VPS RAM apertada |

Template: `references/templates/claude-mem-settings.nvidia.json`

---

## Workflow MCP (obrigatório)

```
search(query) → timeline(anchor=ID) → get_observations([IDs])
```

Nunca pular `search` e ir direto para `get_observations`.

**HYDRATE:** `brain-sync.sh hydrate` + MCP `search`  
**CAPTURE:** `brain-sync.sh capture` + MCP `observation_add`

---

## Chroma vs SQLite

Contagens típicas após bootstrap:

- **SQLite** `observations` — fonte de verdade (ex.: 300+)
- **Chroma** `embeddings` — índice vetorial (pode ficar alguns registros atrás até o worker indexar)

Se Chroma estiver muito atrás do SQLite:

```bash
npx claude-mem stop && npx claude-mem start
# aguardar ~1 min; recontar com bootstrap (mostra contagens)
```

O arquivo `~/.claude-mem/chroma-sync-state.json` rastreia versões do plugin — **não** use `observations: 0` ali como fonte de verdade; conte via SQLite/Chroma sqlite.

---

## Troubleshooting rápido

| Sintoma | Ação |
|---------|------|
| `Claude executable not found` nos logs | Falta `OPENROUTER_API_KEY=` — rodar bootstrap |
| Agente não busca L2 | MCP claude-mem OFF no Cursor |
| `LUCY_CLAUDE_MEM` unset | Adicionar ao `.env` do projeto |
| Worker parado | `npx claude-mem start` ou bootstrap |

---

## Comandos

| Comando | Ação |
|---------|------|
| `claude-mem-bootstrap.sh` | Setup idempotente (settings + .env + worker + verify) |
| `LUCY_CLAUDE_MEM=1 init.sh` | Init full + bootstrap automático |
| `npx claude-mem status` | Health worker |
| `mcp-setup-guide.sh --slug claude-mem` | Guia resumido |
