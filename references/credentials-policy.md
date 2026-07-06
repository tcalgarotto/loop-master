# Política de credenciais — Lucy skill pack

**Versão Lucy:** v2.9.33+  
**Escopo:** orientação global para agentes Lucy em qualquer projeto.

---

## Regra geral

- **Nunca** `git add`, commit ou push de `.env`, `.env.*` (exceto `.env.example` com placeholders)
- **Nunca** imprimir secrets em chat, `lucy-progress.json`, brain files, commits ou PRs
- **Nunca** ler valores de `.env` para ecoar no contexto — só verificar presença/ausência com checks silenciosos

Projetos Hermes/HubFU: regra workspace em `.cursor/rules/no-env-credentials.mdc` e `docs/CREDENTIALS-GIT-POLICY.md` quando existir.

---

## NVIDIA `nvapi-` (per-user)

Política completa: **`references/learned/nvidia-api-keys-per-user.md`**

Resumo:

| ✅ Permitido | ❌ Proibido |
|-------------|------------|
| Guiar owner em build.nvidia.com | Pedir key no chat |
| Placeholders em templates | Key compartilhada entre usuários |
| `~/.claude-mem/.env` chmod 600 | `cat` / `grep` com output da key |
| Verificar `grep -q 'nvapi-'` sem echo | Commitar key em qualquer arquivo |

---

## Outras integrações (quiz MCP)

| Integração | Onde vive a key |
|------------|-----------------|
| Firecrawl | env / Cursor MCP settings |
| Stripe, Supabase, etc. | MCP plugin ou `.env` gitignored |
| LaunchDarkly | env — nunca em frontend público |

Ver: `mcp-integrations-setup-guide.md`

---

## Exceção: owner fornece valor para aplicar

Owner pode ditar valor **explicitamente para aplicação local** em `.env` — agente aplica sem commitar. Mesmo assim: **não repetir** o valor no chat depois de aplicado.
