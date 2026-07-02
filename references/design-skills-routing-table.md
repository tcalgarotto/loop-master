# Design Skills Routing — mapa completo (Claude Design–style)

O orchestrator age como **design director**: escolhe a skill certa por superfície, fase e tipo de entrega.
Consultar **antes** de spawnar workers de design.

## Legenda de status (INDEX)

| Emoji | Significado |
|-------|-------------|
| ✅ | Instalada e usada nesta fase |
| ⏳ | Instalada, pendente uso |
| 🔮 | Futura / próxima fase |
| 👤 | Requer decisão humana |

---

## Tabela mestre — todas as skills de design

| Skill | Path | Quando usar | Minor step | Par com |
|-------|------|-------------|------------|---------|
| **ui-ux-pro-max** | `.cursor/skills/ui-ux-pro-max` | Design system inicial; regras por indústria | discover, plan | impeccable shape |
| **impeccable** | `.cursor/skills/impeccable` | Product UI: shape, craft, layout, polish, critique | plan→gate | ui-ux-pro-max |
| **taste-skill** | `design-taste-frontend` | Anti-slop; landing/marketing; dials VARIANCE/MOTION/DENSITY | implement | ui-ux-pro-max |
| **design** | `.cursor/skills/design` | Router unificado: logo, CIP, ícones, social | plan, implement | brand, slides |
| **design-system** | `.cursor/skills/design-system` | Tokens 3 camadas; component specs; slides técnicos | plan, implement | ui-styling |
| **ui-styling** | `.cursor/skills/ui-styling` | shadcn/Tailwind styling; component polish | implement, fix | design-system |
| **brand** | `.cursor/skills/brand` | Identidade, voz, assets de marca | discover, plan | design |
| **banner-design** | `.cursor/skills/banner-design` | Social, ads, web banners | implement | brand |
| **slides** | `.cursor/skills/slides` | Apresentações, pitch decks | implement | design-system |
| **motion** | `motion/react` + npm | Micro-interações, springs, scroll | implement | impeccable animate |

---

## Árvore de decisão

```
Entrega tem UI?
├─ Não → skip design skills
└─ Sim
   ├─ Marketing / landing / hero?
   │  └─ taste-skill → ui-ux-pro-max → impeccable craft → banner-design (assets)
   ├─ Product app (CRM, dashboard, settings)?
   │  └─ ui-ux-pro-max (tokens) → impeccable shape→craft→critique→polish
   ├─ Brand / identidade nova?
   │  └─ brand → design → design-system tokens
   ├─ Componente shadcn/Tailwind?
   │  └─ design-system → ui-styling → impeccable layout/typeset
   ├─ Apresentação / deck?
   │  └─ slides → design-system
   └─ Animação?
      └─ motion + impeccable animate (prefers-reduced-motion)
```

---

## Pipeline Claude Design–style (product)

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

| Superfície | Skills primárias | Impeccable cmds |
|------------|------------------|-----------------|
| Login/auth | ui-ux-pro-max, impeccable | shape, craft, harden |
| Dashboard | ui-ux-pro-max, impeccable, motion | layout, polish |
| Kanban/board | impeccable, motion | layout, animate |
| Inbox/chat | impeccable, ui-styling | craft, clarify |
| Settings | impeccable, design-system | distill, quieter |
| Landing | taste-skill, banner-design | craft, animate |
| Admin | impeccable, design-system | layout, typeset |

Detalhe Impeccable: `references/impeccable-routing-table.md`

---

## Registro no JSON

Ao usar skill design, atualizar:
- `phases[id].design_skills_used[]`
- `minor_cycle.tasks[].skill_hint`
- `docs/LOOP-MASTER-INDEX.md` — marcar skill ✅

---

## Verificação pré-gate (design)

- [ ] `npx impeccable detect <frontend-path>`
- [ ] ui-ux-pro-max pre-delivery checklist
- [ ] taste-skill dials alinhados a PRODUCT.md
- [ ] `prefers-reduced-motion` respeitado
- [ ] critique P0/P1 resolvidos
