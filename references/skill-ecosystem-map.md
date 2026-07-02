# Skill Ecosystem Map — loop-master v2

Mapeamento de **quando**, **onde no ciclo minor** e **como** invocar cada skill integrada.
O orchestrator consulta esta tabela antes de spawnar workers.

## Legenda do ciclo minor

```
discover → plan → implement → verify → audit → fix → [repeat audit/fix] → gate → next phase
```

| Step JSON | Alias | Entrega |
|-----------|-------|---------|
| `discover` | quiz, clarify | Contexto fechado via AskQuestion + explore |
| `plan` | shape | Tasks com acceptance_criteria |
| `implement` | execute | Código / infra / docs |
| `verify` | smoke | Testes rápidos pós-implement |
| `audit` | review | Verifiers adversariais |
| `fix` | remediate | Corrige findings |
| `gate` | done | 100% + regressão |

**Regra de entrega:** `loop_status` permanece `running` até `overall_pct === 100` e `delivery_contract.status === "complete"`.

---

## Tabela mestre de skills

| Skill | Repo | Instalação | Quando usar | Minor step | Não usar |
|-------|------|------------|-------------|------------|----------|
| **loop** | Cursor built-in | já presente | Agendar ticks recorrentes | fora do minor (infra) | Dentro de execute |
| **loop-master** | este pacote | `init.sh` | Orquestração multi-fase | sempre (orchestrator) | — |
| **impeccable** | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | `npx impeccable install` | Refino UI product; 23 cmds design | plan→gate (FE) | Backend, migrations |
| **ui-ux-pro-max** | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | `uipro init --ai cursor` | Design system inicial; regras por indústria | discover, plan | Polish pontual |
| **taste-skill** | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) | `npx skills add …` | Anti-slop greenfield; landing/marketing | implement (FE novo) | Product UI estável |
| **motion** | [motiondivision/motion](https://github.com/motiondivision/motion) | `npm install motion` + skill Motion | Animações React (`motion/react`) | implement (animate) | Backend; CSS-only trivial |
| **caveman** | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | `curl install.sh \| bash` | Comprimir handoff JSON; commits; reviews | persist (todo tick) | Comunicação com humano |
| **claude-mem** | [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | `npx claude-mem install` | Memória cross-session; busca histórico | discover, hydrate | Substituir JSON handoff |

### Subagents Cursor (via Task)

| subagent_type | Quando | Step |
|---------------|--------|------|
| `explore` | Mapear código desconhecido | discover, plan |
| `generalPurpose` | Implementar / fixar | implement, fix |
| `shell` | Testes, migrate, deploy | verify, gate |
| `security-review` | Auth, tenant, APIs, webhooks | audit |
| `bugbot` | Lógica, regressões | audit |
| `ci-investigator` | CI vermelho | audit, fix |
| `ai-architect` | Decisão arquitetural grande | plan |
| `deployment-expert` | Deploy / VPS / Vercel | implement, gate |
| `performance-optimizer` | Bundle, CWV, queries | audit, fix |

---

## Impeccable — 15 comandos permitidos no loop

| Comando | Step | Trigger |
|---------|------|---------|
| `shape` | plan | UX ainda não definida |
| `craft` | implement | Página/componente novo |
| `layout` | implement, fix | Grid, spacing, rhythm |
| `colorize` | implement | Paleta monocromática |
| `typeset` | fix | Hierarquia tipográfica fraca |
| `clarify` | fix | Copy confusa |
| `distill` | fix | UI densa demais |
| `quieter` / `bolder` | fix | Tom visual errado |
| `adapt` | implement | Responsive |
| `animate` | implement | Motion (pair com Motion lib) |
| `critique` | audit | Review UX adversarial |
| `harden` | audit, fix | Edge cases, a11y |
| `polish` | gate | Pass final design system |
| `optimize` | gate | Performance FE |

**Excluídos no loop:** `init`, `document`, `extract`, `audit`, `onboard`, `delight`, `overdrive`, `live`, `pin`, `hooks`

Detalhe: `references/impeccable-routing-table.md`

---

## ui-ux-pro-max — quando invocar

| Fase | Ação |
|------|------|
| **discover** | Gerar design system: `python3 .cursor/skills/ui-ux-pro-max/scripts/search.py "<produto>" --design-system --persist -p "<App>"` |
| **plan** | Ler `design-system/MASTER.md`; definir tokens na task |
| **implement** | Worker segue stack do projeto (Next.js, Tailwind, shadcn) |
| **audit** | Checklist pre-delivery da skill (contraste, hover, reduced-motion) |
| **gate** | Validar anti-patterns da indústria (ex.: purple gradient em fintech) |

**Pair com:** Impeccable (`shape`→`craft`), taste-skill (se landing/marketing)

---

## taste-skill — variantes e dials

| Install name | Quando |
|--------------|--------|
| `design-taste-frontend` | Default — infer brief, 3 dials (VARIANCE/MOTION/DENSITY) |
| `design-taste-frontend-v1` | Pin v1 se v2 quebrar workflow |
| `gpt-taste` | GPT/Codex — anti-slop agressivo |
| `redesign-existing-projects` | Audit UI existente antes de implement |
| `minimalist-ui` | Product editorial (Linear/Notion vibes) |
| `high-end-visual-design` | Premium calm — dashboards executivos |
| `image-to-code` | Pipeline imagem → código |
| `full-output-enforcement` | Model trunca output — forçar entrega completa |

**Dials (1–10):** ajustar conforme `quiz_answers.design_surface` e PRODUCT.md:
- Product app denso → VARIANCE 4–6, MOTION 3–5, DENSITY 6–8

---

## motion (biblioteca + skill)

| Uso | Como |
|-----|------|
| Micro-interações | `import { motion } from "motion/react"` |
| Layout transitions | `layout` prop + AnimatePresence |
| Scroll-linked | `useScroll`, `useTransform` |
| Spring | `type: "spring"` — preferir sobre bounce |

**No loop:** só no step `implement` quando task `agent_hint` inclui `motion` ou Impeccable `animate`.
Worker deve ler skill Motion se disponível em `.agents/skills/`.

---

## caveman — compressão de contexto

| Comando | Uso no loop-master |
|---------|-------------------|
| `/caveman` | Respostas ao usuário em ticks longos (opcional) |
| `/caveman-compress` | Comprimir `agent_summary` e `next_actions` no JSON |
| `/caveman-commit` | Mensagens de commit quando usuário pedir |
| `/caveman-review` | Comentários de PR one-liner |

**Regra:** JSON handoff usa frases densas (estilo caveman-lite) — paths + status, sem transcript.

---

## claude-mem — memória persistente (opcional)

| Camada | Fonte | Propósito |
|--------|-------|-----------|
| L1 | `.cursor/loop-master-progress.json` | Handoff obrigatório entre ticks |
| L2 | claude-mem SQLite + MCP | Histórico cross-session, busca semântica |
| L3 | `docs/LOOP-MASTER-PLAN.md` | Plano humano-legível |

**Hydrate (início de tick):**
1. Ler JSON L1
2. Se claude-mem instalado: `search(query="<current_phase> <target>", limit=5)` → contexto extra
3. Nunca colocar secrets em memória

Detalhe: `references/memory-protocol.md`

---

## Árvore de decisão — qual skill de design?

```
Novo projeto / sem DESIGN.md?
├─ Marketing/landing → taste-skill ou ui-ux-pro-max
└─ Product/app → ui-ux-pro-max (design-system) → impeccable shape

UI existente a refinar?
├─ Audit primeiro → impeccable critique OU taste redesign-existing-projects
└─ Fix pontual → impeccable layout/typeset/clarify (1–2 por tick)

Precisa animação?
├─ Product subtle → impeccable animate + motion/react springs
└─ Marketing hero → taste-skill MOTION dial alto + motion scroll

Entrega truncada pelo model?
└─ taste-skill full-output-enforcement
```

---

## Matriz minor step × skills (máx por tick)

| Step | Skills permitidas | Máx invocações |
|------|-------------------|----------------|
| discover | loop-master quiz, ui-ux-pro-max, explore, claude-mem | 1 quiz + 1 explore |
| plan | ui-ux-pro-max, impeccable shape, ai-architect | 2 |
| implement | generalPurpose, impeccable (1–2), taste-skill, motion | 4 workers |
| verify | shell, impeccable detect CLI | 1 shell |
| audit | bugbot, security-review, impeccable critique, ci-investigator | 2 verifiers + 1 critique |
| fix | generalPurpose, impeccable (1–2) | 4 workers |
| gate | shell, impeccable polish+optimize | 1 shell + 1–2 impeccable |

---

## O que o init instala (v2.4 — tudo por padrão)

| Componente | Instalado no init? |
|------------|-------------------|
| **loop-master** | Sim |
| **impeccable, ui-ux-pro-max** | Sim (se ausente) |
| **taste-skill, caveman, claude-mem, motion** | **Sim (padrão v2.4)** |
| **design, design-system, ui-styling, brand, slides, banner-design** | Symlink se presentes em `.agents/skills/` |
| **security-review, bugbot** | Nativos Cursor |

Design routing completo: `references/design-skills-routing-table.md`

Override: `init.sh --skip-skills` ou `--skills a,b` (subset)

**Paths verificados (exemplo multi-skill repo):**

| Skill | Path |
|-------|------|
| loop-master | `.agents/skills/loop-master` → `.cursor/skills/loop-master` |
| impeccable | `.cursor/skills/impeccable` (symlink) |
| ui-ux-pro-max | `.cursor/skills/ui-ux-pro-max` |
| taste-skill | `.agents/skills/design-taste-frontend` + `.cursor/skills/design-taste-frontend` |
| caveman | `.agents/skills/caveman` + `.cursor/skills/caveman` |
| claude-mem | `~/.claude/plugins/marketplaces/thedotmack` |
| motion | `frontend/node_modules/motion` |

Rodar `scripts/link-ecosystem-skills.sh` após install de taste/caveman.
