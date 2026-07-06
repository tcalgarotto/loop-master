# Contrato de roteamento autônomo — o que é automático vs comando

**Origem:** `/lucy aprenda` — 2026-07-05  
**Pergunta do owner:** *"Tudo que você aprendeu já está mapeado e útil sem precisar ser mandado?"*

**Resposta curta:** Lucy tem mapas, mandamentos P0 e hidratação automática em ticks — mas **não** existe um router em código que dispare skills/MCPs sozinho. O agente (LLM) **é** o orquestrador: **deve consultar** tabelas e **ativar** ferramentas sem pedir permissão quando o protocolo indica. Falhas de roteamento são gaps de disciplina do modelo, não de ausência de docs.

---

## Mandato proativo (owner v2.9.30+)

**Autorização do owner:** Lucy opera como orquestrador autônomo — se MCP ou skill deve ser usado, **ativar automaticamente**; usuários sub-utilizam ferramentas por desconhecimento.

| Antes (v2.9.29) | Depois (v2.9.30+) |
|-----------------|-------------------|
| Semi-automático: "o agente deve…" | **Mandatório:** "o agente MUST activate" |
| Risco de perguntar "Posso usar X?" | **Proibido** quando tabela/protocolo manda X |
| Slash commands = única forma de acionar tools | Slash = entrada de workflow; **dentro do tick/chat** = auto-seleção |

**Sem mudança na arquitetura:** continua sem middleware/router executável. A camada de enforcement é **disciplina do agente** + este mandato.

**Pipeline obrigatório:** scan tabelas → pick skill/MCP → declarar 1 linha → executar. Ver `learned/proactive-orchestration-mandate.md`.

**Ainda confirmar:** destructive ops, credentials, deploy prod, git push. **Ainda opt-in por comando:** `/lucy init`, `/lucy @url`, `/lucy aprenda`, etc.

---

## Três mecanismos distintos

| Mecanismo | O que é | Como dispara | Exemplo |
|-----------|---------|--------------|---------|
| **Skill pack (Lucy)** | Protocolos + tabelas em `references/` | Agente **lê** no HYDRATE/tick quando SKILL.md manda | `premium-tool-orchestration.md` R1 |
| **Cursor skill / plugin** | `SKILL.md` com `description` para auto-trigger | Cursor **sugere** skill ao modelo quando o pedido casa com a description | GSAP `gsap-scrolltrigger`, `impeccable` |
| **MCP** | Servidor externo + `CallMcpTool` | Agente **invoca** tool se MCP cadastrado **e** contexto pede | `claude-mem` search, Penpot |

**Não confundir:** GSAP Cursor plugin = **8 skills**, **não** MCP (`learned/gsap-plugin-orchestration.md`).

---

## Automático hoje (sem o owner repetir o comando)

| Gatilho | Comportamento | Onde está |
|---------|---------------|-----------|
| **`/lucy` (tick)** | HYDRATE → trabalhar → CAPTURE | `SKILL.md` § Second Brain |
| **Regras P0 do projeto** | Ler `.cursor/lucy-brain/rules/*.md` no HYDRATE | `second-brain-protocol.md` |
| **`brain-sync.sh`** | hydrate/capture L0 brain | `scripts/brain-sync.sh` |
| **Loop dinâmico** | Re-arm 45s se `< 100%` e QA owner ok | `autonomous-orchestrator-protocol.md` |
| **Fase FE + `quality_gates`** | visual-gate antes do gate (Playwright, não MCP browser em VPS) | `visual-gate-protocol.md`, JSON `quality_gates` |
| **Browser em VPS** | `ensure-headless-browser.sh` → Playwright como `primary` | `learned/vps-headless-browser-default.md` |
| **Design em tick** | Consultar `design-skills-routing-table.md` + `premium-tool-orchestration.md` | SKILL.md § Modo autônomo |
| **Subagentes** | Tabela `agent-routing-table.md` por domínio/step | Task tool |
| **Hooks Cursor** | Se `install-hooks.sh` rodou | `hooks/` |
| **Aprendizado global** | Disponível após `/lucy update` ou pull do `loop-master` | `lucy-aprenda-protocol.md` |

---

## Ainda exige comando explícito do owner

| Comando | Por quê não é automático |
|---------|--------------------------|
| `/lucy init` | Bootstrap one-shot: deps, quiz 7 rodadas, MCP Round 3 |
| `/lucy` | Tick autônomo — sem isso o loop não anda (salvo re-arm chain) |
| `/lucy @url`, `analise`, `build` | Análise competitiva é opt-in por URL |
| `/lucy refazer-frontend`, `nova-pagina` | Escopo e tipo de entrega precisam de intenção |
| `/lucy visual-gate` | Pode rodar auto em fase FE; comando manual para escopo/URL avulsa |
| `/lucy aprenda` | Evolução global do produto Lucy → GitHub |
| `/lucy regra` | Regra local imutável do projeto |
| `/lucy test`, `perf`, `deploy`, `i18n`, `docs` | Pipelines sob demanda |
| `/impeccable <cmd>` | Sub-comandos design — agente invoca, owner pode forçar |
| `/gsap-*` (plugin) | Atalho manual; auto só se description casar |

---

## Proativo mandatório (disciplina do agente — v2.9.30+)

Está **mapeado** nas tabelas; enforcement é o agente, não código. **Não perguntar** quando protocolo indica:

| Situação | O agente MUST… | Risco se pular ou pedir permissão |
|----------|----------------|-----------------------------------|
| Landing brand | Ativar taste + GSAP plugin + motion (R4/R4b) | Página "plana" |
| Product CRM | Ativar impeccable + shadcn; **sem** pin/scrub | Motion indevido |
| React + GSAP | Ler e aplicar `gsap-react` antes de codar | useEffect sem cleanup |
| Scroll storytelling | Ativar `gsap-scrolltrigger` + `premium-motion-scroll` | Só CSS estático |
| FE alterado | Rodar `npx impeccable detect` no verify | Slop no gate |
| Site externo | Firecrawl ou Playwright scrape (sem perguntar qual) | WebFetch em SPA falha |
| claude-mem L2 | `search` no HYDRATE se MCP verde | Memória cross-session perdida |
| claude-mem recall complexo | `build_corpus` → `prime_corpus` → `query_corpus` se retrospectiva | Perde padrões acumulados |
| MCP indicado + cadastrado | `CallMcpTool` direto | Sub-utilização de capacidade |

**GSAP:** em ticks autônomos o agente **declara** (1 linha) qual skill GSAP seguirá, **lê** o SKILL.md e **executa** — não depende de MCP nem de `/gsap-*` do owner. Ver `learned/proactive-orchestration-mandate.md`.

---

## MCP vs plugin vs skill — quando cada um entra

```
Pedido do owner ou task do tick
        │
        ├─ Regra P0 local? ──────────────► .cursor/lucy-brain/rules/ (vence tudo)
        │
        ├─ Protocolo Lucy? ───────────────► references/*.md (orquestrador lê)
        │
        ├─ Cursor skill description match? ► Plugin/skill auto-sugerido (GSAP, impeccable)
        │
        └─ Precisa tool externa? ─────────► CallMcpTool (se MCP cadastrado)
              ├─ claude-mem — opt-in L2
              ├─ Penpot — Caminho C design
              ├─ Firecrawl — @url / scrape
              └─ cursor-ide-browser — só Desktop local; VPS → Playwright
```

---

## Gaps conhecidos (honesto)

1. **Sem router executável** — tabelas são contrato para o LLM, não middleware.
2. **Auto-load de skills Cursor** — depende do modelo seguir `description`; Lucy reforça via protocolo.
3. **MCP opcionais** — Penpot, Firecrawl, claude-mem exigem setup Round 3 ou manual; agente não "adivinha" tokens.
4. **VPS** — Browser MCP inoperante; fallback Playwright é P0 mas não automático sem `ensure-headless-browser.sh`.
5. **`/lucy aprenda` no mesmo turno** — aprendizado novo no GitHub não entra no tick atual até HYDRATE seguinte.
6. **Máx 2 skills design / 2 GSAP por tick** — regra documentada; enforcement é soft.

---

## Checklist do agente — início de tick autônomo

- [ ] `brain-sync.sh hydrate` + rules P0
- [ ] Ler `next_prompt` + fase atual no JSON
- [ ] Se UI: `premium-tool-orchestration.md` + superfície em `design-skills-routing-table.md`
- [ ] Se animação JS: pirâmide html-native → GSAP plugin skill → Framer
- [ ] Se browser: `ensure-headless-browser.sh` antes
- [ ] Se FE gate: visual-gate se `quality_gates.visual_gate_on_fe_phase`
- [ ] `brain-sync.sh capture` antes do handoff

---

## Cross-links

- `learned/proactive-orchestration-mandate.md` — **mandato owner v2.9.30+** (checklist, anti-padrões, exceções)
- `premium-tool-orchestration.md` — ferramenta por momento
- `design-skills-routing-table.md` — superfície → skill
- `agent-routing-table.md` — subagentes
- `skill-ecosystem-map.md` — minor step × skills
- `learned/gsap-plugin-orchestration.md` — GSAP plugin
- `mcp-integrations-setup-guide.md` — MCP setup quiz
