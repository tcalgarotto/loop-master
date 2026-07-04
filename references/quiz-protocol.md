# Quiz Protocol — 7 rodadas (formulário multi-etapas)

O `/lucy init` usa **AskQuestion** em **7 rodadas sequenciais**.
Cada rodada é **uma interação completa** (várias perguntas com opções + sugestões).
**Não implementar** até `quiz_complete: true` no JSON.

## Regra de ouro

1. **Antes do quiz:** rodar `bash .cursor/skills/lucy/scripts/init.sh` **sem perguntar** (bootstrap completo).
2. **Antes de cada rodada:** rodar `bash .cursor/skills/lucy/scripts/quiz-next.sh` e usar **só** os IDs impressos.
3. **Round 3 (MCP):** rodar `mcp-setup-status.sh` **antes** do AskQuestion; guiar cadastro se owner escolher.
4. **Durante init:** uma rodada por turno; persistir `quiz_answers.round_N` após cada rodada.
5. **Após Round 7:** criar fases, atualizar INDEX/plan, armar loop dinâmico, tick 1.

## ⛔ Quiz legado — PROIBIDO

Não usar o formato antigo (v2.3) de **6 perguntas num único turno**.

Formato v2.9.9+: **7 rodadas** com IDs `r1_*` … `r7_*` (+ `r3m_*` na rodada MCP).

Se o agente misturar rodadas ou pular `quiz-next.sh`, o init está **incorreto**.

### Migração v2.9.8 → v2.9.9 (quiz em andamento)

| `quiz_round` antigo | Continuar em |
|---------------------|--------------|
| 0–2 | Mesmo número |
| 3 (design antigo) | Round **4** (design) — re-perguntar design se necessário |
| 4–5 | Round **5–6** |
| 6 | Round **7** (kickoff) |

---

## Round 1 — Produto & North Star

| ID | Pergunta | Opções (sugestões) |
|----|----------|-------------------|
| `r1_goal` | Qual o objetivo north-star deste loop? | "Entregar MVP funcional" / "Production-ready 100%" / "Go-live com deploy" / Other |
| `r1_users` | Quem usa o produto? | "Equipe interna" / "Clientes B2B" / "Consumidor final" / "Devs/API" / Other |
| `r1_delivery` | Barra de entrega? | **Production-ready 100% (Recommended)** / MVP funcional / Go-live imediato |
| `r1_success` | Como sabemos que terminou? | Sugestões baseadas no repo + Other |

Persistir: `quiz_answers.round_1`

---

## Round 2 — Escopo técnico

| ID | Pergunta | Opções |
|----|----------|--------|
| `r2_scope` | Escopo principal? | Backend / **Frontend** / Full-stack / Infra / Docs-only |
| `r2_stack` | Stack detectada — confirmar? | Inferida de `package.json` + Other |
| `r2_integrations` | Integrações críticas? | Multi: API, DB, auth, pagamentos, nenhuma |
| `r2_constraints` | Restrições técnicas? | Multi: não quebrar prod, zero downtime, etc. |

Persistir: `quiz_answers.round_2`

---

## Round 3 — MCP, integrações & design pipeline (NOVO v2.9.9)

**Objetivo:** detectar gaps, **sugerir cadastro** e guiar o owner com eficácia.

**Preflight obrigatório (agente):**

```bash
bash scripts/mcp-setup-status.sh --json
bash scripts/mcp-setup-guide.sh   # se owner escolher guiar agora
```

| ID | Pergunta | Opções |
|----|----------|--------|
| `r3m_priority` | Integrações a priorizar? | Multi: **Cursor Browser**, HTML preview, Penpot MCP, visual-gate, Firecrawl, claude-mem — opções anotadas com **falta** ou **OK** pelo status script |
| `r3m_guidance` | Como configurar o que falta? | **Guiar setup agora (Recommended)** / Marcar tick 1 / Pular |
| `r3m_pipeline` | Pipeline de design? | **HTML-first até aprovar** / Penpot+HTML (Caminho C) / Direto Next |
| `r3m_optional` | MCPs opcionais Cursor? | Multi: Vercel, Supabase, Stripe, Sentry, Linear, Notion, Nenhum |

**Se `r3m_guidance` = guiar agora:**

1. Para cada slug em `missing_slugs`: `mcp-setup-guide.sh --slug <slug>`
2. Owner fornece secrets (token Penpot, API keys) — agente **nunca** commita
3. Re-rodar `mcp-setup-status.sh` e reportar progresso
4. Persistir snapshot em `mcp_setup_status` no progress JSON

**Guia canônico:** `references/mcp-integrations-setup-guide.md`

Persistir: `quiz_answers.round_3` + `mcp_setup_status`

---

## Round 4 — Design & UX

| ID | Pergunta | Opções |
|----|----------|--------|
| `r4_surface` | Superfície visual? | Product app / Marketing/landing / Nenhuma |
| `r4_register` | Register visual? | Product restrained / Marketing expressivo / DESIGN.md |
| `r4_priority_pages` | Páginas prioritárias? | Multi: inferir de `app/**/page.tsx` |
| `r4_design_skills` | Skills design? | Multi: impeccable, ui-ux-pro-max, taste-skill, motion, gsap-premium |

Persistir: `quiz_answers.round_4`

---

## Round 5 — Qualidade, segurança & gates

| ID | Pergunta | Opções |
|----|----------|--------|
| `r5_gate` | Gate por fase? | **100% + zero critical/high (Recommended)** / MVP / waiver |
| `r5_tests` | Verificação obrigatória? | Multi: pytest, npm test, build, e2e, impeccable |
| `r5_security` | Audit de segurança? | **security-review + bugbot (Recommended)** / Só bugbot / Pular |
| `r5_docs` | Docs versionados? | plan + INDEX / Só plan / Mínimo |

Persistir: `quiz_answers.round_5`

---

## Round 6 — Autonomia & loop dinâmico

| ID | Pergunta | Opções |
|----|----------|--------|
| `r6_mode` | Modo de loop? | **Dinâmico chain (Recommended)** / Fixo / Manual |
| `r6_interval` | Fallback seconds? | 45s / 90s / 240s |
| `r6_memory` | Memória claude-mem? | **Sim (Recommended)** / Só JSON L1 |
| `r6_parallel` | Workers paralelos? | 4+2 / Conservador / Sequencial |
| `r6_stop` | Quando parar? | **Só 100% ou "pare o loop"** / Pausar após fase |

Persistir: `quiz_answers.round_6` + `loop_arm.mode`, `loop_interval_seconds`

---

## Round 7 — Kickoff contextual

| ID | Pergunta | Opções |
|----|----------|--------|
| `r7_start_phase` | Por onde começar? | Maior gap / Página visível / P0 audit / **Completar MCP faltante** |
| `r7_first_tasks` | 1–3 tasks do primeiro tick? | Sugestões concretas |
| `r7_read_first` | Arquivos para ler? | Multi: repo + `mcp-integrations-setup-guide.md` |
| `r7_blockers` | Blockers humanos? | Multi: **Credenciais MCP**, deploy, produto, nenhum |
| `r7_confirm` | Confirmar init? | **Sim — fases + arm loop + tick 1 (Recommended)** |

Após confirmar:
- `quiz_complete: true`, `quiz_round: 7`
- Gerar `phases{}` + `docs/LUCY-PLAN.md`
- `loop_status: running` + `arm-dynamic-loop.sh`

Persistir: `quiz_answers.round_7`

---

## Formato JSON consolidado

```json
{
  "quiz_round": 3,
  "quiz_complete": false,
  "quiz_answers": {
    "round_1": { "goal": "..." },
    "round_3": {
      "mcp_priority": ["penpot", "html-first"],
      "guidance": "guide_now",
      "pipeline": "html_first_until_approved"
    }
  },
  "mcp_setup_status": {
    "missing_slugs": ["firecrawl"],
    "configured_slugs": ["penpot", "html-first"]
  }
}
```

---

## Quando repetir quiz (fora do init)

| Situação | Rodadas |
|----------|---------|
| MCP novo disponível / token rotacionado | Round 3 |
| Mudança de objetivo | Round 1 + 7 |
| Gate bloqueado por produto | Round 5 ou 7 |

## Anti-padrões

- Pular Round 3 MCP sem owner opt-out explícito
- Secrets no progress JSON
- Todas as 7 rodadas num único turno
- Implementar sem Round 7 confirmado
