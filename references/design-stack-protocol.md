# Design Stack Protocol — Impeccable × ui-ux-pro-max × taste × motion

Pipeline unificado para entregas com **design premium** em qualquer projeto web/app.

## Princípio

```
Descobrir (ui-ux-pro-max) → Planejar (shape) → Construir (craft/taste) → Refinar (impeccable) → Animar (motion) → Validar (critique) → Ship (polish+gate)
```

Uma fase master pode exigir **vários ticks** — máximo 1–2 comandos design por tick.

## Register product (inferir no discover)

| Atributo | Como definir |
|----------|--------------|
| Register | `quiz_answers.design_surface` ou `PRODUCT.md` |
| Público | PRODUCT.md — usuário final do app |
| Densidade | ui-ux-pro-max design system ou taste-skill DENSITY dial |
| Motion | Sutil em product; maior em marketing |
| Anti-slop | Impeccable detector + taste-skill |

Fontes: `PRODUCT.md`, `DESIGN.md`, `.impeccable/design.json` (se Impeccable instalado)

## Pipeline por tipo de entrega

### A) Página product nova (dashboard, inbox, settings…)

| Tick | Skill | Ação |
|------|-------|------|
| 1 | ui-ux-pro-max | `--design-system --persist` |
| 2 | impeccable | `shape <surface>` |
| 3 | impeccable | `craft <surface>` |
| 4–N | impeccable | layout → colorize → typeset → clarify |
| N+1 | motion | springs se task pede |
| Gate | impeccable | critique → harden → polish → optimize |

### B) Refino de UI existente

| Tick | Skill | Ação |
|------|-------|------|
| 1 | impeccable | `critique <surface>` |
| 2+ | impeccable | fixes do relatório (1–2/tick) |
| Gate | impeccable | polish |

Alternativa: taste-skill `redesign-existing-projects`

### C) Landing / marketing

| Tick | Skill | Ação |
|------|-------|------|
| 1 | taste-skill | `design-taste-frontend` — dials altos |
| 2 | ui-ux-pro-max | design system por indústria |
| 3+ | impeccable | craft → animate → polish |

### D) Backend-only

**Nenhuma skill de design.** Seguir `agent-routing-table.md` padrão.

## motion/react

```tsx
import { motion } from "motion/react"

const transition = { type: "spring", stiffness: 400, damping: 30 }
```

Respeitar `prefers-reduced-motion`. Só no step `implement` quando `skill_hint` inclui `motion` ou Impeccable `animate`.

## ui-ux-pro-max — exemplo genérico

```bash
python3 .cursor/skills/ui-ux-pro-max/scripts/search.py "<product type>" \
  --design-system --persist -p "<AppName>" --page "<page-id>"

python3 .cursor/skills/ui-ux-pro-max/scripts/search.py "data table" --stack nextjs
```

## taste-skill — dials (orientação)

| Superfície | VARIANCE | MOTION | DENSITY |
|------------|----------|--------|---------|
| Dashboard product | 4 | 3 | 7 |
| Board / kanban | 5 | 4 | 7 |
| Login / marketing | 7 | 5 | 4 |
| Settings modal | 3 | 2 | 6 |

Ajustar no SKILL.md da taste-skill conforme brief do quiz.

## Verificação pré-gate (design)

- [ ] `npx impeccable detect <frontend-path>` — zero critical
- [ ] ui-ux-pro-max pre-delivery checklist
- [ ] build frontend passa
- [ ] critique P0/P1 resolvidos ou waived
