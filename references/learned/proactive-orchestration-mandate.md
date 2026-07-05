# Mandato de orquestração proativa — owner authorization

**Origem:** `/lucy aprenda` — 2026-07-05  
**Versão Lucy:** v2.9.30+  
**Autorização do owner (paráfrase):** Lucy deve ser um **orquestrador autônomo** sobre todas as suas capacidades. Se o agente determina que um MCP ou skill deve ser usado, **deve ativá-lo automaticamente** — não esperar o usuário pedir. Usuários frequentemente não conhecem o poder completo da Lucy e sub-utilizam ferramentas.

---

## Distinção crítica

| Conceito | O que significa |
|----------|-----------------|
| **Sem router em código** | Não existe middleware que dispare skills/MCPs sozinho — tabelas são contrato para o LLM |
| **Agente É o orquestrador** | O modelo **deve** ler tabelas, escolher ferramenta e **executar** sem pedir permissão |
| **Slash commands** | `/lucy init`, `/lucy @url`, `/lucy aprenda` = workflows explícitos de entrada |
| **Dentro de qualquer tick ou chat** | Auto-seleção de skills/MCPs é **obrigatória** quando protocolo indica |

**Anti-confusão:** "não há router executável" ≠ "espere o owner mandar". A camada de enforcement é **disciplina do agente**, reforçada por este mandato.

---

## Mandamento P0

> **Se a tabela ou protocolo indica ferramenta X → usar X sem pedir permissão.**

Declarar em **1 linha** o que foi ativado e por quê; em seguida **executar**.

---

## Checklist pré-ação (obrigatório)

Antes de implementar, auditar ou responder:

1. **Scan routing tables** — `agent-routing-table.md`, `design-skills-routing-table.md`, `premium-tool-orchestration.md`
2. **Pick skill/MCP** — match superfície × step × register (brand/product)
3. **Declarar** — uma linha: *"Ativando gsap-scrolltrigger — landing brand com scroll storytelling"*
4. **Executar** — ler `SKILL.md` da skill escolhida; `CallMcpTool` se MCP cadastrado e protocolo manda
5. **Limites soft** — máx 2 skills design / 2 GSAP plugin por tick (inalterado)

---

## Anti-padrões — PROIBIDO quando protocolo manda

| Frase proibida | Fazer em vez disso |
|----------------|-------------------|
| "Posso usar GSAP?" | Ler `gsap-plugin-orchestration.md` → ativar skill adequada |
| "Quer que eu rode visual-gate?" | Rodar se `quality_gates.visual_gate_on_fe_phase` ou fase FE |
| "Devo consultar impeccable?" | Ler skill + executar sub-comando indicado na tabela |
| "O MCP claude-mem está disponível?" | Se `LUCY_CLAUDE_MEM=1` + MCP verde → `search` no HYDRATE |
| "Prefere Firecrawl ou Playwright?" | Seguir `premium-tool-orchestration.md` R2 por contexto |

**Exceção:** sugestões de motion brand (R4b) podem propor padrões — mas **implementação** após match não exige "quer que eu?".

---

## Exceções — ainda confirmar com owner

| Ação | Por quê |
|------|---------|
| Operações destrutivas | `git push --force`, drop table, delete em massa |
| Credenciais / secrets | Nunca colar; pedir status, não valor |
| Deploy produção | Confirmar ambiente e rollback |
| `git push` | Confirmar se owner não pediu só commit local |
| MCP não cadastrado | Não adivinhar tokens; guiar setup (Round 3) |

---

## MCP — regra de ativação

```
Protocolo indica MCP?
├─ MCP cadastrado + schema legível → CallMcpTool (sem perguntar)
├─ MCP opt-in não habilitado (claude-mem, Penpot) → seguir setup guide; não fingir que rodou
└─ cursor-ide-browser em VPS → NÃO tentar; Playwright fallback (vps-headless-browser-default.md)
```

Ver: `mcp-integrations-setup-guide.md`, `learned/claude-mem-mcp-operational-playbook.md`

---

## Skills — regra de ativação

| Gatilho | Ação |
|---------|------|
| Tabela design match | Ler `SKILL.md` **antes** de codar |
| GSAP em Next/React | Auto-load `gsap-react` per `learned/gsap-plugin-orchestration.md` |
| GSAP scroll brand | Auto-load `gsap-scrolltrigger` + `premium-motion-scroll-protocol.md` |
| FE alterado no verify | `npx impeccable detect` — não opcional |
| Subagent indicado | Task tool com prompt mínimo de `agent-routing-table.md` |

**Plugin GSAP:** 8 skills Cursor — **não** MCP. Auto-load quando routing table + register casam.

---

## Integração com contrato honesto

Este mandato **não remove** limitações documentadas em `autonomous-routing-contract.md`:

- VPS: Browser MCP inoperante — Playwright é fallback P0
- MCP opcionais exigem setup prévio
- Aprendizado global deste turno entra no tick seguinte após HYDRATE
- Enforcement continua sendo disciplina do agente, não código

O que muda (v2.9.30+): de **semi-automático** ("o agente deve…") para **mandatório** ("o agente MUST activate").

---

## Cross-links

- `learned/autonomous-routing-contract.md` — § Mandato proativo
- `autonomous-orchestrator-protocol.md` — mandamento #8
- `premium-tool-orchestration.md` — preamble mandato proativo
- `design-skills-routing-table.md` — superfície → skill
- `agent-routing-table.md` — subagentes
- `learned/gsap-plugin-orchestration.md` — GSAP plugin auto-load
