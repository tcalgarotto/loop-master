# Design Skills Routing — mapa completo (design director–style)

O orchestrator age como **design director**: escolhe a skill certa por superfície, fase e tipo de entrega.
Consultar **antes** de spawnar workers de design.

> 📖 Stack completa e prompts-mestre em: `references/premium-ui-stack.md`

## Legenda de status (INDEX)

| Emoji | Significado |
|-------|-------------|
| ✅ | Instalada e usada nesta fase |
| ⏳ | Instalada, pendente uso |
| 🔮 | Futura / próxima fase |
| 👤 | Requer decisão humana |

---

## Tabela mestre — todas as skills de design

| Skill / Lib | Path / Pacote | Quando usar | Minor step | Par com |
|-------------|--------------|-------------|------------|---------|
| **ui-ux-pro-max** | `.cursor/skills/ui-ux-pro-max` | Design system inicial; regras por indústria | discover, plan | impeccable shape |
| **impeccable** | `.cursor/skills/impeccable` | Product UI: shape, craft, layout, polish, critique | plan→gate | ui-ux-pro-max |
| **taste-skill** | `design-taste-frontend` | Anti-slop; landing/marketing; dials VARIANCE/MOTION/DENSITY | implement | ui-ux-pro-max |
| **design** | `.cursor/skills/design` | Router unificado: logo, CIP, ícones, social | plan, implement | brand, slides |
| **design-system** | `.cursor/skills/design-system` | Tokens 3 camadas; component specs; slides técnicos | plan, implement | ui-styling |
| **ui-styling** | `.cursor/skills/ui-styling` | shadcn/Tailwind styling; component polish | implement, fix | design-system |
| **brand** | `.cursor/skills/brand` | Identidade, voz, assets de marca | discover, plan | design |
| **banner-design** | `.cursor/skills/banner-design` | Social, ads, web banners | implement | brand |
| **slides** | `.cursor/skills/slides` | Apresentações, pitch decks | implement | design-system |
| **framer-motion** | `npm:framer-motion` | layoutId, AnimatePresence, sidebar React, DnD | implement | gsap |
| **gsap** | `npm:gsap` | Timelines, ScrollTrigger, stagger, CustomEase | implement (animate) | framer-motion |
| **shadcn/ui** | `npx shadcn@latest` | Componentes premium prontos (sidebar, cards, badges, skeleton) | implement, fix | ui-styling |
| **tremor-raw** | `npm:@tremor/react` | Gráficos de dashboard leves, limpos, responsivos | implement | tanstack-query |
| **magic-ui** | `npm:magic-ui` | Efeitos IA: Dot Pattern, Bento Grid, texto digitado | implement | shadcn |
| **aceternity-ui** | aceternity.com | Spotlight, hover effects avançados | polish | shadcn |
| **tanstack-query** | `npm:@tanstack/react-query` | Cache SWR, atualização background de dados | implement | Server Actions |
| **html-native** | navegador + opcional `htmx.org` | `<dialog>`+`command`, Popover API, HTMX partial | implement | perf-protocol |

---

## Árvore de decisão

```
Entrega tem UI?
├─ Não → skip design skills
└─ Sim
   ├─ Refazer todo o frontend existente?
   │  └─ lucy-refazer-frontend-protocol → inventory → page-by-page
   ├─ Criar landing ou página nova do zero?
   │  └─ html-first-design-protocol (preview HTML) → lucy-nova-pagina-protocol → template-gallery + taste/impeccable
   ├─ HTML preview com mocks SaaS (nav, kanban, integrações)?
   │  └─ html-preview-interactive-mocks-protocol → integration-cards-patterns → html-preview-section-gate.sh
   ├─ Product app (CRM, dashboard, settings)?
   │  └─ ui-ux-pro-max (tokens) → impeccable shape→craft→critique→polish
   ├─ Brand / identidade nova?
   │  └─ brand → design → design-system tokens
   ├─ Componente shadcn/Tailwind?
   │  └─ design-system → ui-styling → impeccable layout/typeset
   ├─ Apresentação / deck?
   │  └─ slides → design-system
   ├─ Troca de rota ou painel com transição suave?
   │  └─ html-native-light-protocol → View Transitions (antes de motion global)
   ├─ Reveal no scroll, header compact, timeline IA?
   │  └─ html-native-light-protocol → animation-timeline: view() / scroll() scrub
   ├─ Lista/tabela com refresh parcial?
   │  └─ html-native-light-protocol → HTMX fragment (antes de client fetch chain)
   ├─ Timeline multi-step, stagger 20+, ScrollTrigger?
   │  └─ gsap-premium-protocol (sem transition-* no elemento)
   ├─ Hover micro (scale, lift)?
   │  └─ CSS transition — nunca misturar com GSAP no mesmo nó
   └─ Animação React (sidebar, layoutId, Kanban)?
      └─ framer-motion (GSAP se scroll storytelling global)
```

---

## Pipeline design director–style (product)

| Ordem | Skill | Comando / ação |
|-------|-------|----------------|
| 1 | ui-ux-pro-max | `search.py --design-system --persist` |
| 2 | impeccable | `shape <surface>` |
| 3 | impeccable | `craft <surface>` |
| 4 | ui-styling | tokens → componentes |
| 5 | impeccable | layout → colorize → typeset |
| 6 | motion | springs sutis |
| 7 | impeccable | critique → harden |
| 8 | impeccable | polish → optimize @ gate |

Máx **2 skills design por tick**.

---

## Por superfície de página

| Superfície | Skills primárias | Libs obrigatórias | Impeccable cmds |
|------------|-----------------|-------------------|-----------------|
| Login/auth | ui-ux-pro-max, impeccable | shadcn, framer-motion | shape, craft, harden |
| Dashboard (simples) | ui-ux-pro-max, impeccable | shadcn, tremor-raw, framer-motion | layout, polish |
| Dashboard CRM/ERP | ui-ux-pro-max, impeccable, taste-skill | shadcn (double sidebar), tremor-raw, framer-motion, tanstack-query | layout, colorize, polish |
| Kanban/board | impeccable, motion | shadcn, framer-motion | layout, animate |
| HTML preview kanban (landing mock) | html-preview-interactive-mocks-protocol, gsap | HTML nativo + GSAP snap | DnD nativo + section gate |
| Inbox/chat | impeccable, ui-styling | shadcn, framer-motion | craft, clarify |
| Settings | impeccable, design-system | shadcn | distill, quieter |
| Landing | taste-skill, banner-design | shadcn, framer-motion, magic-ui | craft, animate |
| Admin/ERP | impeccable, design-system | shadcn, tremor-raw, tanstack-query | layout, typeset |
| IA/produto com IA | taste-skill, impeccable | shadcn, magic-ui, aceternity-ui, framer-motion | craft, animate, polish |

Detalhe Impeccable: `references/impeccable-routing-table.md`

---

## Registro no JSON

Ao usar skill design, atualizar:
- `phases[id].design_skills_used[]`
- `minor_cycle.tasks[].skill_hint`
- `docs/LUCY-INDEX.md` — marcar skill ✅

---

## Verificação pré-gate (design)

- [ ] `npx impeccable detect <frontend-path>` — zero critical
- [ ] ui-ux-pro-max pre-delivery checklist
- [ ] taste-skill dials alinhados a PRODUCT.md
- [ ] `prefers-reduced-motion` respeitado em todas as animações framer-motion
- [ ] critique P0/P1 resolvidos
- [ ] Paleta restrita a zinc/slate — sem azul puro ou verde saturado
- [ ] Padding mínimo `p-4` em todos os cards (preferido `p-6`)
- [ ] Nenhuma borda colorida em cards internos (`border-zinc-200` max)
- [ ] Ícones padronizados com lucide-react, 1 cor neutra
- [ ] Skeleton loading em todas as seções com dados assíncronos
- [ ] Dark mode funcional (shadcn theme)
- [ ] TanStack Query gerenciando cache — sem `useEffect` + fetch manual
- [ ] Gráficos com Tremor Raw (não recharts cru ou chart.js pesado)

Ver checklist completo: `references/premium-ui-stack.md`
