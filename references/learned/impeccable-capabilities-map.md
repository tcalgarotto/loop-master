# Impeccable — mapa completo de capacidades

**Fonte:** [impeccable.style](https://impeccable.style/) (v3.9.x skill) + skill pack em `.cursor/skills/impeccable`.  
**Escopo Lucy:** catálogo global para routing — ver `impeccable-lucy-integration.md`.

---

## O que é

Impeccable é **uma skill com 23 comandos** de design frontend para agentes de código. Dá vocabulário compartilhado (tipografia, cor, motion, copy) e reduz "AI slop" com regras determinísticas + fluxos de craft.

**Componentes além da skill:**

| Componente | Uso | Comando |
|------------|-----|---------|
| **Skill** | 23 sub-comandos via `/impeccable <cmd>` | `npx impeccable install` |
| **CLI detector** | 45 regras anti-pattern, CI, exit codes | `npx impeccable detect src/` |
| **Chrome extension** | Overlay detector em qualquer aba | Chrome Web Store |
| **Live mode (beta)** | Pick elemento → 3 variantes → accept grava no source | `/impeccable live` |
| **Hooks** | Detector pós-edição de arquivos UI | `/impeccable hooks on` |

---

## Setup obrigatório (toda sessão Impeccable)

1. **`context.mjs`** — lê `PRODUCT.md` (+ `DESIGN.md` se existir). Sem `PRODUCT.md` → parar e rodar `init`.
2. **Sub-comando** — ler `reference/<cmd>.md` antes de executar.
3. **Código existente** — ler pelo menos um arquivo CSS/tokens/componente do projeto.
4. **Register** — ler `reference/brand.md` OU `reference/product.md` (ver § Register).
5. **Projeto novo** — `palette.mjs` para cor âncora OKLCH (só se não houver tokens commitados).

**Arquivos de contexto:**

| Arquivo | Conteúdo |
|---------|----------|
| `PRODUCT.md` | Usuários, register, voz, anti-references — **todo comando lê** |
| `DESIGN.md` | Spec visual (formato Google Stitch) — tokens, tipografia, componentes |
| `.impeccable/config.json` | Ignores do detector, config hooks |

**Comandos de setup (fora do loop Lucy):**

| Comando | Quando |
|---------|--------|
| `/impeccable init` | Projeto sem `PRODUCT.md` — entrevista + grava contexto |
| `/impeccable document` | Código existe mas sem `DESIGN.md` — extrai spec visual |
| `/impeccable extract` | Drift de tokens/componentes — consolidar design system |

---

## Register — brand vs product

Todo trabalho de design pertence a um **register**. Primeiro match vence:

1. Cue da tarefa ("landing" vs "dashboard")
2. Superfície em foco (rota/arquivo)
3. Campo `## Register` em `PRODUCT.md` (`brand` ou `product`)

| Register | Barra | Superfícies | Referência |
|----------|-------|-------------|------------|
| **brand** | Distintividade — design **é** o produto | Landing, marketing, portfolio, editorial | `reference/brand.md` |
| **product** | Familiaridade ganha — design **serve** a tarefa | CRM, dashboard, admin, settings, tools | `reference/product.md` |

Comandos com divergência register: `typeset`, `animate`, `bolder`, `delight`, `colorize`, `layout`, `quieter`.

**Lucy:** CRM/ERP HubFU = **product**; landing `/` ou marketing = **brand** (pair com taste-skill).

---

## 23 comandos — catálogo completo

### Create (3)

| Comando | PT-BR | Quando usar |
|---------|-------|-------------|
| `shape [feature]` | Planejar UX/UI antes do código | Brief incerto; discovery multi-round; gera design brief confirmado |
| `craft [feature]` | Shape + build end-to-end | Feature nova com brief; inclui shape se necessário |
| `init` | Setup do projeto | Uma vez: `PRODUCT.md`, opcional `DESIGN.md`, live config |

### Evaluate (2)

| Comando | PT-BR | Quando usar |
|---------|-------|-------------|
| `critique [target]` | Review UX com score | Hierarquia, IA, carga cognitiva, persona tests + detector |
| `audit [target]` | Check técnico P0–P3 | a11y, perf, responsive, anti-patterns — relatório scored |

### Refine (8)

| Comando | PT-BR | Quando usar |
|---------|-------|-------------|
| `polish [target]` | Pass final pré-ship | Alinhamento, spacing, micro-detalhes |
| `bolder [target]` | Amplificar design seguro | "Plano", genérico, sem personalidade |
| `quieter [target]` | Abaixar tom visual | Agressivo, saturado, overwhelming |
| `distill [target]` | Subtrair complexidade | UI densa, ruído, elementos demais |
| `layout [target]` | Grid, spacing, rhythm | Hierarquia fraca, grids monótonos |
| `typeset [target]` | Tipografia intencional | Fontes genéricas, hierarquia plana |
| `colorize [target]` | Cor estratégica | UI cinza/monocromática |
| `animate [target]` | Motion com propósito | Micro-interações, reveals — pair GSAP/framer |

### Simplify (3)

| Comando | PT-BR | Quando usar |
|---------|-------|-------------|
| `clarify [target]` | Copy UX | Labels confusos, erros vagos, microcopy |
| `adapt [target]` | Responsive | Breakpoints, touch, print |
| `distill` | *(ver Refine)* | — |

### Harden (4)

| Comando | PT-BR | Quando usar |
|---------|-------|-------------|
| `harden [target]` | Produção-ready | Erros, i18n, overflow, edge cases |
| `onboard [target]` | First-run / empty states | Ativação, welcome, tooltips |
| `optimize [target]` | Performance UI | LCP, bundle, animações pesadas |
| `polish` | *(ver Refine)* | — |

### Enhance (2 extras na skill)

| Comando | PT-BR | Quando usar |
|---------|-------|-------------|
| `delight [target]` | Personalidade memorável | Momentos de joy — brand-heavy |
| `overdrive [target]` | Efeitos ambiciosos | Shaders, physics, scroll cinematic |

### System (3)

| Comando | PT-BR | Quando usar |
|---------|-------|-------------|
| `document` | Gerar `DESIGN.md` | Extrair spec do código existente |
| `extract [target]` | Consolidar design system | Padrões repetidos, drift |
| `live` | Variantes no browser | Dev server rodando; HMR; pick → 3 variants → accept |

### Gestão (3 — manual)

| Comando | Função |
|---------|--------|
| `pin <cmd>` / `unpin <cmd>` | Atalho standalone `$<cmd>` |
| `hooks on\|off\|status` | Detector automático pós-edição |

---

## Design laws (SKILL.md — resumo acionável)

### Cor
- Contraste WCAG: body ≥4.5:1; large ≥3:1; placeholder também 4.5:1
- OKLCH; evitar cream/beige default AI (L 0.84–0.97, C<0.06, hue 40–100)
- Estratégias: Restrained / Committed / Full palette / Drenched

### Tipografia
- Body 65–75ch; hero clamp max ≤6rem; letter-spacing display ≥-0.04em
- `text-wrap: balance` (h1–h3); `pretty` (prose)
- Não parear duas sans similares — contraste de eixo (serif+sans)

### Layout
- Cards são resposta preguiçosa; nested cards = errado
- z-index semântico (dropdown → modal → toast) — nunca 9999
- `repeat(auto-fit, minmax(280px, 1fr))` para grids fluidos

### Motion
- ease-out-quart/quint/expo — sem bounce/elastic em UI
- `prefers-reduced-motion` obrigatório
- Não animar layout props; não gate conteúdo em class-triggered reveal

### Bans absolutos (amostra)
- Side-stripe borders, gradient text, glassmorphism default
- Hero-metric template, identical card grids, eyebrow em toda seção
- Ghost-card (border 1px + shadow blur ≥16px), border-radius 32px+ em cards

Referências de domínio em `skill/reference/`: `typography.md`, `color-and-contrast.md`, `motion.md`, etc.

---

## Detector anti-pattern — 45 regras

**Fonte:** `cli/engine/registry/antipatterns.mjs` — determinístico, sem LLM.

| Camada | Onde roda | Exemplos |
|--------|-----------|----------|
| **CLI** | `npx impeccable detect`, CI, hooks | side-tab, gradient-text, ai-color-palette, flat-type-hierarchy |
| **Browser** | Extension, critique overlay | line-length, overflow, cramped-padding, clipped dropdowns |
| **LLM only** | `/impeccable critique` | glassmorphism decorativo, hero-metric layout, hand-drawn SVG |
| **opt-in** | `--gpt` / `--gemini` | ghost-card, repeating-gradient stripes, image-hover-transform |

**Categorias:** `slop` (tells AI) vs `quality` (a11y, legibilidade, perf).

```bash
# Lucy gate — obrigatório em fases FE
npx impeccable detect <frontend-path> --json
node .agents/skills/impeccable/scripts/detect.mjs --json <paths>  # bundled, sem rede
```

**Mapeamento slop → comando Impeccable:**

| Hit detector | Comando sugerido |
|--------------|------------------|
| gradient-text, hero-eyebrow | `quieter`, `typeset` |
| side-tab, icon-tile-stack | `layout`, `distill` |
| ai-color-palette, cream-palette | `colorize` |
| flat-type-hierarchy, overused-font | `typeset` |
| low-contrast, gray-on-colored-bg | `audit`, `polish` |
| bounce-easing, layout-animation | `animate`, `optimize` |

---

## Live mode

**Guia Lucy completo:** `impeccable-live-mode.md` · **Pilares:** `impeccable-eight-pillars.md` §7–8

1. Dev server rodando (`localhost:3000`)
2. `/impeccable live` — `live.mjs` boot + poll loop
3. Owner: pick elemento → comentário/traço (opcional) → ação → Go
4. Agente: 3 variantes HMR + knobs → `--reply done`
5. Owner: cycle → **Accept** grava no source (carbonize cleanup obrigatório)

**Scripts:** `live.mjs`, `live-poll.mjs`, `live-wrap.mjs`, `live-accept.mjs`, `live-complete.mjs`

**Lucy:** excluído do loop autônomo (requer interação + Browser MCP). VPS → fallback polish/shape + detect + visual-gate. Cursor Desktop local + dev server = OK.

---

## Instalação e update

```bash
npx impeccable install          # skill + harness por provider (Cursor, Claude, etc.)
npx impeccable update           # atualizar skill
npx impeccable detect src/      # CI / pré-gate
```

Requer Node 24+. Builds por provider incluem regras slop extras (Codex ghost-cards, Gemini image-hover, etc.).

---

## Cross-links Lucy

| Doc | Relação |
|-----|---------|
| `impeccable-lucy-integration.md` | Como Lucy invoca no tick |
| `impeccable-eight-pillars.md` | 8 capacidades impeccable.style × routing |
| `impeccable-live-mode.md` | Live Mode beta — workflow completo PT-BR |
| `impeccable-routing-table.md` | 15 cmds permitidos no minor cycle |
| `design-skills-routing-table.md` | Árvore design director |
| `premium-tool-orchestration.md` | critique→craft→polish; Live em sessão owner |
