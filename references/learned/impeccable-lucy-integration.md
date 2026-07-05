# Impeccable × Lucy — integração no cérebro global

**Objetivo:** Lucy **roteia explicitamente** trabalho de design frontend pela skill Impeccable — não improvisa polish genérico.

**Catálogo completo:** `learned/impeccable-capabilities-map.md`  
**15 cmds no minor cycle:** `impeccable-routing-table.md`

---

## Mandamento P0

> Em qualquer tick com superfície UI, o orchestrator **declara** qual comando Impeccable vai rodar, **lê** `reference/<cmd>.md`, e **registra** em `phases[].design_skills_used[]`.

**Pair obrigatório:** ui-ux-pro-max (discover/plan) → impeccable (plan→gate). Landing: taste-skill antes de impeccable.

**Anti-padrão:** implementar CSS "na mão" sem passar por pelo menos `critique` ou `shape` quando a rota é nova ou está com slop.

---

## Árvore de decisão Lucy → Impeccable

```
UI no escopo do tick?
├─ Não → skip impeccable
└─ Sim
   ├─ Sem PRODUCT.md no projeto?
   │  └─ FORA do loop: owner ou init manual `/impeccable init`
   ├─ `/lucy refazer-frontend`
   │  └─ detect → critique → layout/typeset/colorize → polish @ gate
   ├─ `/lucy nova-pagina`
   │  └─ landing: taste → shape → craft → animate → polish
   │  └─ app: ui-ux-pro-max → shape → craft → layout → polish
   ├─ Discussão paleta/tema (owner)
   │  └─ design-visual-html-protocol PRIMEIRO → depois impeccable colorize no Next
   ├─ minor step plan → shape
   ├─ minor step implement → craft | layout | colorize | adapt | animate
   ├─ minor step audit → critique | harden
   ├─ minor step fix → typeset | clarify | distill | quieter | bolder | layout
   └─ minor step gate → polish | optimize + npx impeccable detect (zero critical)
```

---

## Por comando Lucy

### `/lucy` (tick autônomo)

| Minor step | Impeccable (máx 2) | Detector |
|------------|-------------------|----------|
| `discover` | — (ui-ux-pro-max) | — |
| `plan` | `shape` | `detect.mjs` opcional nos paths dirty |
| `implement` | `craft`, `layout`, `colorize`, `adapt`, `animate` | — |
| `verify` | — | `npx impeccable detect` no path da task |
| `audit` | `critique`, `harden` | detect JSON → alimenta backlog |
| `fix` | `typeset`, `clarify`, `distill`, `quieter`, `bolder`, `layout` | — |
| `gate` | `polish`, `optimize` | **detect obrigatório** — exit 0 |

**Sequência multi-tick (uma superfície):**  
`shape` → `craft`/`layout` → `colorize` → `typeset` → `critique` → `harden` → `polish` → `optimize`

**JSON:** `minor_cycle.tasks[].skill_hint: "impeccable:layout"` · `phases[id].design_skills_used: ["impeccable:critique"]`

### `/lucy refazer-frontend`

Pipeline do protocolo — **impeccable é o motor de refactor visual:**

| Fase | Impeccable | Outros |
|------|------------|--------|
| Audit inventário | `critique <rota>` | `npx impeccable detect` full frontend |
| Quiz design (r4) | profundidade: layout/typeset/colorize/polish | taste se landing no escopo |
| Por página/tick | critique → layout → typeset → colorize → polish | visual-gate na rota |
| Gate fase | `polish` + detect zero critical | vision V1–V8 |

**URLs preservadas** — só elevação visual, não re-arquitetura de rotas.

### `/lucy nova-pagina`

| Tipo | Pipeline Impeccable |
|------|---------------------|
| **landing** | taste (dials altos) → `shape` → `craft` → `animate` → `polish` |
| **app** | ui-ux-pro-max → `shape` → `craft` → `layout` → `polish` |
| Pós HTML-first | Após owner aprovar `preview/*.html` → `craft` port Next |

Gate: `npx impeccable detect` + `visual-gate-capture.sh` na URL Next.

### `/lucy visual-gate`

Impeccable **complementa**, não substitui vision:

| Camada | Ferramenta |
|--------|------------|
| Determinístico | `npx impeccable detect <path>` — slop rules |
| Pixel | Playwright screenshots + checklist V1–V8 |
| UX adversarial | `critique` se vision flagar hierarquia/copy |

**Regra:** não declarar `gate_passed` só com detect — precisa screenshot + vision.

---

## Comandos Impeccable FORA do loop Lucy

| Excluído | Motivo | Quando usar |
|----------|--------|-------------|
| `init`, `document`, `extract` | Setup one-time / ownership DS | `/lucy init` do projeto ou sessão manual |
| `audit` | Lucy usa `critique` + verifiers + detect CLI | Se owner pedir audit técnico explícito |
| `live`, `pin`, `hooks` | Interativo / harness | Sessão owner + dev server local |
| `onboard`, `delight`, `overdrive` | Escopo atípico produto | Pedido explícito do owner |

---

## Integração com premium-tool-orchestration

| Momento (R#) | Impeccable |
|--------------|------------|
| R4 landing sem vida | `critique` → depois GSAP/taste |
| R4 pipeline landing | `critique` → `craft` → `polish` (mínimo) |
| R6 gate FE | `polish` + detect + visual-gate |
| R7 init | `init.sh` instala impeccable; não substitui critique no fim |

---

## Integração skill-ecosystem-map

- **Máx 2 skills design por tick** — impeccable conta como 1; ui-ux-pro-max ou taste é o segundo.
- **Worker spawn:** ler `.cursor/skills/impeccable/SKILL.md` + `reference/<cmd>.md` + register (`brand.md`/`product.md`).
- **verify step:** shell roda `npx impeccable detect` (node, não bun).

---

## Checklist pré-gate (design) — Impeccable explícito

- [ ] `PRODUCT.md` existe (senão `init` manual antes do tick FE)
- [ ] Register correto (product para CRM; brand para landing)
- [ ] Pelo menos 1 cmd impeccable no tick da superfície (exceto verify puro)
- [ ] `npx impeccable detect <frontend-path>` — zero critical
- [ ] `critique` P0/P1 resolvidos ou documentados em `human_blockers`
- [ ] `phases[].design_skills_used` atualizado
- [ ] `docs/LUCY-INDEX.md` — impeccable ✅ se usado na fase

---

## VPS / browser

- `live` e extension Chrome: **não** no VPS headless default — usar detect CLI + visual-gate Playwright.
- `critique` browser pass: Playwright fallback se MCP browser indisponível (`vps-headless-browser-default.md`).

---

## Evolução futura (`/lucy aprenda`)

Quando Impeccable lançar novos comandos ou regras detector:

1. Atualizar `impeccable-capabilities-map.md`
2. Revisar `impeccable-routing-table.md` (incluir/excluir do loop)
3. Bump patch Lucy + `learned/INDEX.md`
