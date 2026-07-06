# NVIDIA API keys — uma por usuário (segurança L2)

**Origem:** `/lucy aprenda` — 2026-07-06  
**Versão Lucy:** v2.9.33+  
**Papel:** política global — chaves `nvapi-` são **pessoais**, nunca compartilhadas nem ecoadas pelo agente.

> Complementa: `claude-mem-zero-config-playbook.md` · `claude-mem-nvidia-setup.md` · `mcp-integrations-setup-guide.md` · `references/credentials-policy.md`

---

## Princípio

| Regra | Detalhe |
|-------|---------|
| **Uma key por usuário** | Cada pessoa gera a sua em [build.nvidia.com](https://build.nvidia.com) |
| **Sem key compartilhada** | Proibido "key do time" no repo, VPS compartilhada ou chat |
| **Guia only** | Agente **orienta** passos; **nunca** pede a key no chat |
| **Zero echo** | Não ler `.env` / `~/.claude-mem/.env` para o contexto; não `cat`, `grep` com output |

---

## Onde a key pode existir

| Local | Uso | Commit? |
|-------|-----|---------|
| `~/.claude-mem/.env` (chmod 600) | claude-mem L2 — `CLAUDE_MEM_OPENROUTER_API_KEY` + `OPENROUTER_API_KEY` (mesmo valor) | ❌ Nunca |
| `.env` do projeto (gitignored) | `NVIDIA_API_KEY` para relatórios NIM no app — **opcional**, owner cola manualmente | ❌ Nunca |
| Templates / `.env.example` | `nvapi-REPLACE_ME`, `nvapi-your-key-here`, `nvapi-...` | ✅ Só placeholders |

**Nunca** colocar `nvapi-` real no `.env` versionado, `lucy-progress.json`, brain files ou docs do skill pack.

---

## Workflow agente (guide-only)

Quando L2 ou NIM precisam de key e o owner ainda não configurou:

1. **Não pedir** "cole sua key aqui"
2. **Enviar** os 3 passos owner (abaixo)
3. **Sugerir** verificação sem vazar valor:
   ```bash
   test -f ~/.claude-mem/.env && grep -q 'nvapi-' ~/.claude-mem/.env && echo "NVIDIA key configured (value hidden)"
   ```
4. **Rodar** `claude-mem-bootstrap.sh` só depois que o owner confirmou que colou localmente

### 3 passos owner (self-service)

1. Abrir [build.nvidia.com](https://build.nvidia.com) → login/cadastro  
2. **Profile → API Keys → Generate Personal Key** (`nvapi-…`)  
3. Colar **uma vez** em `~/.claude-mem/.env` (chmod 600) — ou no `.env` do projeto se for `NVIDIA_API_KEY` do app; **fora do chat e do git**

Depois: `LUCY_CLAUDE_MEM=1` no `.env` do projeto + `claude-mem-bootstrap.sh` (ver zero-config playbook).

---

## Anti-padrões

- Compartilhar key entre devs, máquinas ou agentes
- Agente executar `cat ~/.claude-mem/.env` ou `grep nvapi-` com output no chat
- Commitar key em regra P0, ADR, CHANGELOG ou transcript
- Assumir que a key da VPS do owner serve para outro usuário
- Placeholder realista demais (`nvapi-abc123def456...`) em fixtures — usar `REPLACE_ME`

---

## Auditoria (agente)

Antes de handoff ou `/lucy aprenda` sobre NVIDIA:

```bash
# Deve retornar só templates — zero keys reais (20+ chars após nvapi-)
rg 'nvapi-[A-Za-z0-9]{20,}' . --glob '!.env' --glob '!~/.claude-mem/**' || echo "OK: no real keys in repo"
```

Contar ocorrências em transcripts/brain — **reportar contagem**, nunca imprimir matches.

---

## Política de credenciais

Ver `references/credentials-policy.md` — alinhado a `.cursor/rules/no-env-credentials.mdc` nos projetos Hermes/HubFU.
