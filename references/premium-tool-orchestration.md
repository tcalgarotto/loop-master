# Premium Tool Orchestration — usar a ferramenta certa, sempre

**Mandamento P0 global:** em todo tick Lucy, o agente **escolhe e executa** a melhor combinação de skills/libs/browser **no momento** — foco **qualidade de código + design premium**. Não improvisar com uma só ferramenta.

**Origem:** `/lucy aprenda` — HubFU landing plana; stack completo deve estar **instalado** (init) e **acionado** (protocolo).

---

## North Star de entrega

> Código limpo + UI com **vida** (motion, hierarquia, CTA claro) + evidência visual (screenshot) antes do gate.

**Anti-entrega:** página estática “template Bootstrap”, hero sem motion, “Carregando…” visível na landing, gate sem print.

---

## Mapa mestre — ferramenta por momento

| Momento | Ferramentas (usar todas que aplicam) | Protocolo |
|---------|--------------------------------------|-----------|
| **Init / update** | init.sh incremental — skills + Playwright + Firecrawl* | `init-protocol.md` |
| **Landing nova (design incerto)** | **HTML-first** `preview/*.html` → owner valida → port Next | `html-first-design-protocol.md` |
| **Mocks interativos na landing** | Nav/tabs/filtros trocam view real; kanban funcional; barras exponenciais | `html-preview-interactive-mocks-protocol.md` |
| **Design editável híbrido (C)** | HTML loop até aprovar → Penpot MCP tokens → port Next → Puck opcional | `design-editable-hybrid-protocol.md` |
| **Landing nova (aprovada)** | taste-skill → ui-ux-pro-max → template-gallery → **GSAP plugin skills** / view() → shadcn → impeccable polish | `lucy-nova-pagina-protocol.md` · GSAP: `learned/gsap-plugin-orchestration.md` |
| **Iteração visual 1 elemento (owner Desktop)** | `/impeccable live` — pick → 3 variantes → accept grava source | `learned/impeccable-live-mode.md` · VPS: **guiar** tunnel/Ports (`vps-live-mode-owner-guide.md`) ou fallback polish/layout |
| **Landing sem vida** | impeccable `critique` → **gsap-timeline** ou **gsap-scrolltrigger** (plugin) → `/lucy refazer-frontend --escopo /rota` | `gsap-premium-protocol.md` · `learned/gsap-plugin-orchestration.md` |
| **App page nova** | ui-ux-pro-max → shadcn → tremor → tanstack-query → impeccable | `design-stack-protocol.md` |
| **QA visual nosso app** | Playwright `visual-gate-capture.sh` + vision V1–V8 | `visual-gate-protocol.md` |
| **@url concorrente** | Firecrawl scrape/sandbox + screenshot + vision | `browser-ai-scrape-protocol.md` |
| **Design system do owner** | intake → tokens em `DESIGN_SYSTEM.md` + routing | `design-system-intake.md` |
| **Sugestão de site (brand)** | Checar `case-studies/INDEX.md` → propor 1–2 refs + justificativa → craft/shape se do zero | `case-studies/INDEX.md`, `premium-motion-scroll-protocol.md` |
| **Código** | test, bugbot, security-review | `test-protocol.md` |
| **Deploy** | deploy + visual-gate URL produção | `deploy-protocol.md` |

\*Firecrawl: init se `FIRECRAWL_API_KEY` no ambiente; senão Playwright + MCP.

---

## Regras P0 (agente)

### R1 — Orquestrar, não monotool

Antes de implementar UI, **scan** `skills_installed[]` + protocolos. Se taste-skill instalado e landing → **usar**. Se GSAP no package.json → **pelo menos uma** timeline ou view() scroll na landing. Se **GSAP Cursor plugin** instalado → ler skill adequada (`gsap-react` em Next, `gsap-scrolltrigger` em scroll brand) — ver `learned/gsap-plugin-orchestration.md`.

### R2 — Browser funcional obrigatório

**Bootstrap P0:** antes de qualquer task com browser, rodar:

```bash
bash .cursor/skills/lucy/scripts/ensure-headless-browser.sh --project .
```

Ler `.lucy/headless-browser-ready.json` → seguir `primary` e `agent_rule`.

| Contexto | Browser | Como |
|----------|---------|------|
| **VPS / Remote SSH / Cloud Agent** (default HubFU) | **Playwright headless** | `browser-open-url.mjs`, `visual-gate-capture.sh`, `make security-browser` |
| Cursor Desktop local + `tools/` ≥ 10 | Cursor Browser MCP | `browser_navigate`, `browser_snapshot` (agente pai); **Live Mode** `/impeccable live` |
| Site externo / SPA | Firecrawl | `browser-ai-scrape-protocol.md` |

**Proibido:** `CallMcpTool` → `browser_*` quando `primary: "playwright"` ou `cursor_mcp_available: false`.

Ver: `references/learned/vps-headless-browser-default.md`

**Nunca** declarar landing/pricing “pronta” sem screenshot em `.lucy/visual-gates/` ou `.lucy/browser/`.

### R3 — HTML-first quando design incerto

Se owner pede preview local, falta contexto do produto ou landing atual está “plana”:

1. Criar `preview/<slug>.html` com seções completas + GSAP (`html-first-design-protocol.md`)
2. Servir com `html-preview-serve.sh` ou `xdg-open`; iterar com owner
3. Só então port para Next (`lucy-nova-pagina-protocol.md`)

### R4 — Pipeline landing premium (mínimo)

Toda `--tipo landing` passa por:

1. taste-skill (VARIANCE + MOTION altos)
2. impeccable: critique → craft → polish
3. **≥1** assinatura de vida: GSAP hero timeline OU `animation-timeline: view()` em ≥2 seções OU magic-ui dot/bento (sem slop)
4. Hero SSR — **proibido** flash “Carregando flags…” na primeira pintura (defer i18n/hydration blocking)
5. visual-gate na URL final (`localhost` ou Vercel)

### R4b — Quando SUGERIR premium motion (register=brand)

**Antes de codar** landing/pricing/portfolio, Lucy **propõe por escrito** 2–3 padrões de `premium-motion-scroll-protocol.md` quando qualquer sinal:

| Sinal | Padrões a considerar |
|-------|---------------------|
| Hero sem foto tratada / stock | Art-directed imagery + gradient overlay |
| Seções planas sem hierarquia scroll | `view()` reveals OU sandwich stack (3–4 cards) |
| Produto físico / demo visual forte | Pin + scroll-scrub vídeo OU canvas sequence |
| Nav/CTA flutuante sobre visual | Glassmorphism pontual (máx 2 superfícies) |
| Página longa tipo product launch | Scroll storytelling 3 acts |

**Template de sugestão (1 turno):**

> Para esta landing (register **brand**), recomendo: (1) … porque …; (2) … — quer que implemente algum?

**Restringir (register=product):** em CRM/dashboard/settings/tabelas, **não sugerir** pin/scrub/sandwich/morphism decorativo. Motion funcional 150–250 ms apenas (`impeccable animate` product). Exceção: `animation-timeline: scroll()` no header app (já em `html-native-light-protocol.md`).

### R5 — Design systems tagados pelo owner

Se o owner envia `@DESIGN.md`, prints, links Figma, ou “design system do X”:

1. Seguir `design-system-intake.md`
2. Extrair tokens (cor, tipo, radius, motion) → `DESIGN_SYSTEM.md` ou `.lucy/design-intake/`
3. Rotear impeccable + premium-ui-stack com esses tokens

**Sim — tagar design systems ajuda.** Formato ideal: link + 2–3 prints + “o que copiar” (sidebar, hero, cards).

### R5b — Case studies para sugestão de site (brand)

Quando o owner pede **sugestão de landing**, **nova página marketing**, ou **“como ficaria o site”**:

1. Ler `references/case-studies/INDEX.md`
2. Match triggers do pedido (conferência, editorial, retro-futurist, etc.)
3. Propor **1–2** estudos de caso: *“Este estudo de caso combina com [pedido] porque [2–3 traits]”*
4. Match forte + brief vago → pipeline craft (#001 Neo Mirai: mock → toolkit → `/impeccable craft`)
5. **Não** propor case brand para superfície product (CRM, dashboard, settings)

Ver: `case-studies/neo-mirai-impeccable.md` (#001 exemplar).

### R6 — Qualidade código + design juntos

Gate bloqueado se:

- `npm run build` falha
- critical/high em audit OU vision
- landing sem motion checklist (R3)
- `last_visual_audit.gate_passed !== true` (fases FE)

### R7 — Init entrega stack; agente entrega craft

`init.sh` garante deps. **Não** substitui impeccable critique nem visual-gate no fim.

---

## JSON — `quality_gates` (default v2.9.6+)

```json
"quality_gates": {
  "visual_gate_auto": true,
  "visual_gate_on_fe_phase": true,
  "require_vision_before_gate": true,
  "premium_tool_orchestration": true,
  "landing_requires_motion": true,
  "landing_visual_gate_production": true
}
```

---

## Diagnóstico — landing “sem vida” (ex. HubFU /landing)

Sinais comuns:

| Sintoma | Causa provável | Fix Lucy |
|---------|----------------|----------|
| Só título + texto plano | Pulou taste + GSAP | refazer-frontend escopo `/landing` |
| “Carregando flags…” no HTML | i18n/feature flags bloqueando SSR | Server hero estático; flags client-only |
| Sem scroll delight | Só CSS estático | view() scrub ou GSAP ScrollTrigger |
| CTA fraco | Von Restorff ignorado | impeccable colorize + CTA primário |
| Nunca validou pixel | Sem visual-gate | `visual-gate-capture.sh --base-url https://…vercel.app` |

---

## Anti-padrões

- Uma skill só (ex.: só shadcn sem taste/impeccable)
- Landing sem motion “por economia”
- Confiar em WebFetch para SPA
- Ignorar design system tagado pelo owner
- Ship sem browser evidence

---

## Referências cruzadas

- `design-stack-protocol.md` — pipeline A–D
- `premium-ui-stack.md` — tokens e prompts-mestre
- `premium-motion-scroll-protocol.md` — **pin/scrub/sandwich/imagery/morphism** + suggest vs restrain
- `ux-design-intelligence.md` — 15 laws
- `design-skills-routing-table.md` — superfície → skill
- `learned/gsap-plugin-orchestration.md` — **GSAP Cursor plugin** (8 skills, não MCP)
- `learned/impeccable-eight-pillars.md` — 8 capacidades Impeccable
- `learned/impeccable-live-mode.md` — Live Mode beta (owner Desktop)
- `learned/vps-live-mode-owner-guide.md` — Live Mode no VPS: tunnel, Ports, checklist owner
- `case-studies/INDEX.md` — catálogo owner-provided site refs (#001 Neo Mirai)
- `case-studies/neo-mirai-impeccable.md` — exemplar craft pipeline brand
