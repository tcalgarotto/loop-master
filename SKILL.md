---
name: lucy
description: >-
  Autonomous AI orchestrator with Second Brain memory, premium design intelligence,
  and competitive analysis. Uses 100% of AI capacity: 6-round quiz, dynamic AGI
  workflows, design director routing, gap analysis. Commands: /lucy init, /lucy, /lucy analise.
version: "2.9.1"
---
# Lucy v2.9.1 — 100% do cérebro + segundo cérebro + inteligência competitiva

**Manual completo:** [MANUAL.md](MANUAL.md)  
**Second Brain:** `references/second-brain-protocol.md`  
**Hooks Cursor:** `hooks/` + `scripts/install-hooks.sh`

---

## Second Brain — memória viva

A cada `/lucy` (tick ou chat):

1. **HYDRATE** — `brain-sync.sh hydrate` + claude-mem search + ler **`.cursor/lucy-brain/rules/*.md` (P0)** + protocolos do skill pack
2. **TRABALHAR** — com contexto acumulado
3. **CAPTURE** — `brain-sync.sh capture` + claude-mem observation_add

Armazena: perfil dev, decisões de arquitetura, log de interações, consciência crescente.
Diretório: `.cursor/lucy-brain/`

**Nunca encerrar turno sem CAPTURE.**

## `/lucy init` — zero-config

**Ordem obrigatória — sem pedir permissão:**

1. **Shell automático** (silencioso):
   ```bash
   bash .cursor/skills/lucy/scripts/init.sh
   ```
   Instala: impeccable, ui-ux-pro-max, taste-skill, caveman, claude-mem (+ start), motion, shadcn/ui, framer-motion, tremor, tanstack-query, symlinks, JSON, PLAN, INDEX.

2. **Quiz 6 rodadas** — **OBRIGATÓRIO** executar antes de perguntar:
   ```bash
   bash .cursor/skills/lucy/scripts/quiz-next.sh
   ```
   Ler saída → usar **AskQuestion** **somente** com os IDs da rodada atual (`r1_goal`, `r2_scope`, …).
   
   **PROIBIDO** quiz legado (6 perguntas flat num turno).
   **Uma rodada por turno.** Detalhe: `references/quiz-protocol.md`

3. Após cada rodada: persistir `quiz_answers.round_N`, incrementar `quiz_round`.

4. Após Round 6 (`quiz_complete: true`): fases, INDEX, `arm-dynamic-loop.sh`, tick 1, `next_prompt`.

**Usuário só digita:** `/lucy init`

---

## Progress file

| Contexto | Arquivo |
|----------|---------|
| App | `.cursor/lucy-progress.json` |
| Skill pack | `.cursor/lucy-progress.skill-pack.json` |
| Index | `docs/LUCY-INDEX.md` |

Campos novos v2.4: `quiz_round`, `quiz_complete`, `index_doc`, `memory_sync`

---

## Comandos

### Orquestração
| Comando | Ação |
|---------|------|
| `/lucy init` | Bootstrap shell + quiz 6 rodadas + plano + arm loop |
| `/lucy update` | git pull + re-init preservando contexto |
| `/lucy` | Um tick autônomo |
| `pare o loop` | Stop + `loop_status: stopped` |

### Análise competitiva
| Comando | Ação |
|---------|------|
| `/lucy @url [prints]` | Análise competitiva + implementação faseada |
| `/lucy --auto @url` | Id. sem checkpoint |
| `/lucy analise @url` | Só gap analysis (não codar) |
| `/lucy build` | Implementar plano existente |
| `/lucy audit` | Auditar fase atual |
| `/lucy continuar` | Retomar sessão anterior |

### Frontend (design premium + páginas novas)

| Comando | Ação |
|---------|------|
| `/lucy refazer-frontend` | Audit design (slop, órfãs, duplicatas) + quiz 4 rodadas + polish impeccable — **mantém URLs** |
| `/lucy refazer-frontend --escopo todo` | Todo o frontend |
| `/lucy refazer-frontend --escopo /crm` | Só rotas indicadas (ou as mencionadas no prompt) |
| `/lucy refazer-frontend --audit-only` | Inventário + audit + quiz — não codar |
| `/lucy refazer-frontend --sem-quiz` | Pula quiz (só se já completo no JSON) |
| `/lucy nova-pagina <nome> --tipo landing` | Landing do zero |
| `/lucy nova-pagina <nome> --tipo app` | Página app do zero |

Ver: `lucy-refazer-frontend-protocol.md` · `design-quiz-next.sh` · `lucy-nova-pagina-protocol.md`

### Aprendizado e regras (dois escopos)

| Comando | Escopo | Onde grava | GitHub |
|---------|--------|------------|--------|
| `/lucy aprenda` + conteúdo | **Global** — evolui a Lucy para todos | `references/` no repo `loop-master` | **Sim** — commit + push |
| `/lucy regra` + pedido | **Projeto** — imutável após update | `.cursor/lucy-brain/rules/` | Opcional (`--versionar` → `docs/lucy-rules/`) |

Ver: `lucy-aprenda-protocol.md` · `lucy-regra-protocol.md`

### Qualidade e entrega
| Comando | Ação |
|---------|------|
| `/lucy test` | Gera e executa testes (unit + E2E) |
| `/lucy test --ci` | Modo CI silencioso (exit 1 se falhar) |
| `/lucy perf` | Audit de performance (bundle, CWV, N+1) |
| `/lucy perf --fix` | Audit + aplica correções automáticas |
| `/lucy deploy` | Build + validate + deploy + health check |
| `/lucy deploy --dry-run` | Simula deploy sem push real |
| `/lucy deploy --rollback` | Reverte para último estado estável |

### Internacionalização e documentação
| Comando | Ação |
|---------|------|
| `/lucy i18n` | Detecta strings hardcoded + configura i18n |
| `/lucy i18n --scan` | Só lista strings (não altera código) |
| `/lucy docs` | Gera documentação completa (API, componentes, changelog) |
| `/lucy docs --adr` | Registra decisão de arquitetura (ADR) |
| `/lucy docs --changelog` | Atualiza CHANGELOG.md |

---

## Modo autônomo — cada tick

### Antes (hidratação)
1. **Second Brain HYDRATE** — `brain-sync.sh hydrate` + claude-mem search
2. L1 JSON + `next_prompt` + L0 dev-profile + project-mind
3. INDEX sync emojis
4. Scan `skills_installed[]`

### Durante (minor step)
`discover → plan → implement → verify → audit → fix ↺ → gate`

Design: rotear via `design-skills-routing-table.md` (design director–style)

**UI leve + motion premium (v2.8.4+):** aplicar `references/html-native-light-protocol.md` (nativo/CSS scrub) e `references/gsap-premium-protocol.md` (timelines, ScrollTrigger, stagger) antes de `use client` / Framer. CSS `transition-*` só em hover — nunca no mesmo elemento que GSAP anima.

### Depois (handoff)
1. JSON + INDEX + **brain-sync capture** + claude-mem observation_add
2. `next_prompt` completo
3. **Re-arm:** `arm-dynamic-loop.sh --seconds 45` se `< 100%`

---

## Skills — init instala tudo (padrão)

| Skill | Init v2.6 |
|-------|-----------|
| lucy (legado loop-master) | sim — use `migrate-loop-master-to-lucy.sh` |
| impeccable, ui-ux-pro-max | sim |
| taste-skill, caveman, claude-mem, motion | sim |
| **nextjs-premium-stack** | **sim (auto-detecta Next.js e instala: shadcn/ui, framer-motion, tremor, tanstack-query, lucide-react)** |
| design, design-system, ui-styling, brand, slides, banner-design | symlink se presentes |
| security-review, bugbot | nativos Cursor |

---

## Memória (4 camadas)

| Camada | Obrigatório |
|--------|-------------|
| L0 Brain | `.cursor/lucy-brain/` — **toda interação** |
| L1 JSON | progress handoff |
| L2 claude-mem | MCP search + observation_add |
| L3 PLAN/INDEX | docs humanos |

Ver `references/second-brain-protocol.md` + `memory-protocol.md`

---

## Dynamic workflows

Self-pacing loop: re-arm chain 45s, branching audit→fix, parallel workers, event watchers opcionais.
Ver seção "Dynamic workflows" em `autonomous-orchestrator-protocol.md`.

---

## Contrato 100%

- `overall_pct === 100`
- `delivery_contract.status === "complete"`
- Zero critical/high abertos

Enquanto incompleto: re-arm automático obrigatório.

---

## Referências

### Núcleo
- `references/autonomous-orchestrator-protocol.md` — os 7 mandamentos do loop
- `references/skill-ecosystem-map.md` — qual skill usar em cada step
- `references/agent-routing-table.md` — roteamento de subagentes
- `references/quiz-protocol.md` — quiz de 6 rodadas
- `references/init-protocol.md`

### Design
- `references/premium-ui-stack.md` — **stack Next.js + paletas + prompts-mestre**
- `references/html-native-light-protocol.md` — **UI leve: dialog, HTMX, view-transition, scroll scrub**
- `references/gsap-premium-protocol.md` — **GSAP: timelines, ScrollTrigger, stagger premium**
- `references/lucy-aprenda-protocol.md` — **`/lucy aprenda` global → GitHub**
- `references/lucy-regra-protocol.md` — **`/lucy regra` local imutável**
- `references/lucy-refazer-frontend-protocol.md` — **`/lucy refazer-frontend`**
- `references/lucy-nova-pagina-protocol.md` — **`/lucy nova-pagina`**
- `references/learned/INDEX.md` — catálogo do que o owner ensinou
- `references/ux-design-intelligence.md` — **15 Laws of UX + 12 padrões sidebar**
- `references/design-skills-routing-table.md` — routing por superfície
- `references/design-stack-protocol.md`
- `references/template-gallery.md` — **layouts premium prontos para copiar**

### Análise competitiva
- `references/competitive-intelligence.md` — **protocolo /lucy analise**

### Qualidade e entrega
- `references/test-protocol.md` — **geração de testes /lucy test**
- `references/perf-protocol.md` — **audit de performance /lucy perf**
- `references/deploy-protocol.md` — **pipeline de deploy /lucy deploy**
- `references/i18n-protocol.md` — **internacionalização /lucy i18n**
- `references/docs-protocol.md` — **geração de docs /lucy docs**

### Memória
- `references/second-brain-protocol.md`
- `references/memory-protocol.md`

### Onboarding
- `references/getting-started.md`
- `references/setup-prompt.md`
- `MANUAL.md`

---

## Anti-padrões

- Pedir permissão antes de rodar init.sh
- Pular quiz ou implementar antes de Round 6
- Terminar tick sem next_prompt + re-arm
- Ignorar INDEX / claude-mem sync
- Secrets no progress JSON
- Misturar `/lucy aprenda` (global) com pedido só do projeto — use `/lucy regra`
- Ignorar `rules/` P0 no HYDRATE
