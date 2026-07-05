# Impeccable — 8 pilares (impeccable.style) × routing Lucy

**Fonte:** [impeccable.style](https://impeccable.style/) — capacidades centrais v3.9.x  
**Catálogo expandido:** `impeccable-capabilities-map.md`  
**Live Mode detalhado:** `impeccable-live-mode.md`

---

## Visão geral

Impeccable não é só uma skill de polish: é um **sistema** de contexto (PRODUCT/DESIGN), registers, pipeline por agente, detector determinístico, e Live Mode com persistência no source. Lucy deve **declarar qual pilar** está ativo em cada tick FE.

---

## Pilar 1 — Respeita design system

**O que é:** Antes de qualquer comando, Impeccable escaneia tokens CSS, Tailwind config, componentes existentes e `DESIGN.md`. Variantes e craft **herdam** identidade, não reinventam paleta.

**Mecanismo:**
- Setup: `context.mjs` lê `PRODUCT.md` + `DESIGN.md`
- Todo comando: ler pelo menos um arquivo CSS/tokens/componente do projeto
- Live Mode Phase A: extrair identidade de DESIGN.md → CSS vars → computed styles → siblings

**Lucy routing:**

| Comando Lucy | Como aplicar |
|--------------|--------------|
| `/lucy` tick implement | `craft`/`layout` só após ler tokens do projeto |
| `/lucy refazer-frontend` | `extract` se drift; senão `critique` alimentado por detect |
| `/lucy nova-pagina` | `shape` confirma brief contra DESIGN.md; app usa `ui-ux-pro-max` + tokens HubFU |
| Gate | `npx impeccable detect` confirma slop não reintroduziu padrões banidos |

**HubFU:** `DESIGN.md` na raiz (`--hf-*` tokens, zinc + roxo restrito). Lucy nunca ignora em favor de cream AI default.

---

## Pilar 2 — PRODUCT.md em todo comando

**O que é:** Contexto estratégico obrigatório: usuários, register, personalidade, anti-references, princípios. **Todo** sub-comando Impeccable carrega via `context.mjs`.

**Mecanismo:**
- Sem `PRODUCT.md` → parar e rodar `/impeccable init`
- Live: PRODUCT vence em decisões estratégicas/voz; DESIGN vence em visual

**Lucy routing:**

| Comando Lucy | Como aplicar |
|--------------|--------------|
| Qualquer tick FE | Checklist pré-gate: `PRODUCT.md` existe |
| Projeto novo | **FORA** do loop: owner ou `/impeccable init` antes do primeiro tick |
| `human_blockers` | Se ausente, bloquear gate FE até init manual |

**HubFU:** `PRODUCT.md` — register **product**, anti-references cream/SaaS genérico, superfícies P0/P1 documentadas.

---

## Pilar 3 — DESIGN.md portável (`/impeccable document`)

**O que é:** Spec visual no formato [Google Stitch design.md](https://github.com/google-labs-code/design.md): YAML frontmatter (tokens normativos) + 6 seções markdown fixas. Portável entre Stitch, awesome-design-md, Live panel.

**Mecanismo:**
- `/impeccable document` — scan mode extrai do código; seed mode para greenfield
- `/impeccable extract` — consolida drift em design system
- Não sobrescrever `DESIGN.md` existente sem confirmação

**Lucy routing:**

| Comando Lucy | Como aplicar |
|--------------|--------------|
| `/lucy init` do projeto | Sugerir `document` se código existe sem DESIGN.md |
| `refazer-frontend` fase audit | Se DESIGN.md stale → `document` antes de polish em massa |
| `nova-pagina` pós HTML-first | Após owner aprovar preview → `document` refresh opcional antes de port Next |
| Live Mode | DESIGN.md = fonte autoritativa Phase A (identidade lock) |

**HubFU:** `DESIGN.md` commitado com paleta Premium tick 111, light/dark zinc, accent roxo ≤8%.

---

## Pilar 4 — Afinado por agente (visualize → shape → craft)

**O que é:** Pipeline intencional por estágio — não um único prompt genérico. Cada sub-comando tem `reference/<cmd>.md` com disciplina própria.

**Pipeline típico:**

```
discover (ui-ux-pro-max) → shape (brief) → craft (build) → refine (layout/typeset/colorize)
→ evaluate (critique) → harden → polish → optimize → gate (detect)
```

**Live Mode** é ramo paralelo de **iteração visual** (não substitui shape em brief incerto).

**Lucy routing:**

| Comando Lucy | Pipeline Impeccable |
|--------------|---------------------|
| `/lucy` plan | `shape` |
| `/lucy` implement | `craft`, `layout`, `colorize`, `adapt`, `animate` |
| `/lucy` audit | `critique`, `harden` |
| `/lucy` fix | `typeset`, `clarify`, `distill`, `quieter`, `bolder`, `layout` |
| `/lucy` gate | `polish`, `optimize` + detect |
| `refazer-frontend` | detect → critique → layout/typeset/colorize → polish |
| `nova-pagina` landing | taste → shape → craft → animate → polish |
| `nova-pagina` app | ui-ux-pro-max → shape → craft → layout → polish |

**JSON:** `skill_hint: "impeccable:layout"` · `design_skills_used: ["impeccable:critique"]`

---

## Pilar 5 — Registers brand vs product

**O que é:** Dois registers com barras diferentes. Primeiro match: cue da tarefa → superfície → `## Register` em PRODUCT.md.

| Register | Barra | Superfícies Lucy |
|----------|-------|------------------|
| **brand** | Distintividade — design **é** o produto | Landing `/`, marketing, legal premium |
| **product** | Familiaridade ganha — design **serve** a tarefa | CRM, dashboard, kanban, inbox, settings |

Comandos com divergência: `typeset`, `animate`, `bolder`, `delight`, `colorize`, `layout`, `quieter`.

**Lucy routing:**

| Superfície | Register | Pair |
|------------|----------|------|
| `/crm/*`, `/configuracoes` | product | ui-ux-pro-max |
| `/`, `/termos`, landing nova | brand | taste-skill (dials altos) |
| Live departure mode | Só se anti-reference aponta superfície atual ou owner pede | — |

**HubFU:** default **product**; landing `/` em refazer usa taste + brand laws.

---

## Pilar 6 — `npx impeccable detect` (45 regras, CI gate)

**O que é:** Detector **determinístico** (sem LLM) com 45 regras anti-pattern: `slop` (tells AI) e `quality` (a11y, legibilidade). Roda em CLI, extension Chrome, hooks pós-edição, overlay em `critique`.

**Mecanismo:**

```bash
npx impeccable detect <frontend-path> --json   # CI / gate
node .agents/skills/impeccable/scripts/detect.mjs --json <paths>  # bundled, sem rede
```

Exit 0 = zero critical. Mapeamento slop → comando sugerido em `impeccable-capabilities-map.md`.

**Lucy routing:**

| Momento | Obrigatório? |
|---------|--------------|
| `/lucy` verify step | Sim no path da task |
| `/lucy` gate | **Sim** — exit 0 |
| `refazer-frontend` audit | Full frontend scan |
| `visual-gate` | Complementa (não substitui) — precisa screenshot + vision |
| Live generate | Opcional nos paths dirty via `detect.mjs` no init scan |

**Anti-padrão:** declarar `gate_passed` só com detect — vision V1–V8 ainda obrigatório.

---

## Pilar 7 — Live Mode BETA (pick → comment/stroke → 3 variantes HMR)

**O que é:** Iteração visual no browser: selecionar elemento, anotar intenção, escolher ação Impeccable, receber 3 direções distintas com knobs ajustáveis, preview via HMR.

**Mecanismo resumido:**
1. `live.mjs` boot + inject `live.js`
2. Owner pick + Go → evento `generate`
3. Agente: wrap → 3 variantes scoped → `--reply done`
4. Owner cycle + knobs → Accept/Discard

**Detalhe completo:** `impeccable-live-mode.md`

**Lucy routing:**

| Contexto | Live? |
|----------|-------|
| Tick autônomo | **Não** |
| Owner + Cursor Desktop + dev server | **Sim** — sugerir explicitamente |
| VPS / Remote SSH | **Não** — fallback polish/shape |
| Elemento único pós-critique P1 | Sugerir em handoff QA |

---

## Pilar 8 — Accept grava em arquivos fonte reais

**O que é:** Accept não é screenshot — promove HTML+CSS da variante escolhida para o source rastreado (`.tsx`, `.svelte`, stylesheet). Carbonize temporário → cleanup obrigatório → CSS permanente sem markers `data-impeccable-*`.

**Mecanismo:**
- `live-accept.mjs` no poll (determinístico)
- `carbonize: true` → 5 passos cleanup antes do próximo poll
- Fallback se elemento em arquivo gerado → editar template gerador
- Param values bakeados no CSS final

**Lucy routing:**

| Contexto | Ação |
|----------|------|
| Sessão Live owner | Owner Accept; agente faz carbonize |
| Pós-Live em tick seguinte | `polish` + `detect` no path alterado |
| Gate | Verificar ausência de markers `impeccable-variants-start` no repo |

---

## Matriz rápida — qual pilar em qual comando Lucy

| Comando Lucy | Pilares ativos (ordem) |
|--------------|------------------------|
| `/lucy` tick FE | 1, 2, 4, 5, 6 |
| `/lucy refazer-frontend` | 1, 2, 3, 4, 5, 6 |
| `/lucy nova-pagina` | 2, 3, 4, 5, 6 |
| `/lucy visual-gate` | 1, 6 (+ vision) |
| Sessão owner Live | 1, 2, 3, 5, 7, 8 |
| `/lucy init` projeto | 2, 3 (init/document) |

---

## Cross-links

| Doc | Relação |
|-----|---------|
| `impeccable-lucy-integration.md` | Árvore decisão + checklist |
| `impeccable-routing-table.md` | 15 cmds no minor cycle |
| `premium-tool-orchestration.md` | R4 pipeline + momento Live |
| `design-skills-routing-table.md` | Árvore design director |
