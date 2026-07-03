# Design Stack Protocol — Impeccable × ui-ux-pro-max × taste × motion

Pipeline unificado para entregas com **design premium** em qualquer projeto web/app.

> 📖 Stack completa com padrões, paletas e prompts: `references/premium-ui-stack.md`

## Princípio

```
Descobrir (ui-ux-pro-max) → Planejar (shape) → Construir (craft+shadcn+taste) → Refinar (impeccable) → Animar (framer-motion) → Validar (critique) → Ship (polish+gate)
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

| Tick | Skill / Lib | Ação |
|------|------------|------|
| 1 | ui-ux-pro-max | `--design-system --persist` |
| 2 | impeccable | `shape <surface>` |
| 3 | shadcn/ui | instalar componentes da superfície (sidebar, card, badge, skeleton) |
| 4 | impeccable | `craft <surface>` |
| 5–N | impeccable | layout → colorize (zinc/slate) → typeset → clarify |
| N+1 | framer-motion | springs sutis, fade-in de cards |
| N+2 | tremor-raw | gráficos de dashboard (se houver métricas) |
| N+3 | tanstack-query | cache de dados, skeleton loading |
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
| 3 | shadcn/ui | componentes base |
| 4 | magic-ui | efeitos IA (Dot Pattern, Bento Grid) se produto IA |
| 5+ | impeccable | craft → animate → polish |

### D) CRM / ERP / Dashboard com IA

| Tick | Skill / Lib | Ação |
|------|------------|------|
| 1 | ui-ux-pro-max | design system |
| 2 | shadcn/ui | double sidebar (mini 64px + expansível 240px) |
| 3 | framer-motion | spring animation na sidebar |
| 4 | tremor-raw | gráficos de métricas |
| 5 | tanstack-query | cache de dados + skeleton loading |
| 6 | magic-ui | efeitos IA (Bento Grid para KPIs) |
| Gate | impeccable | critique → polish |

### E) Backend-only

**Nenhuma skill de design.** Seguir `agent-routing-table.md` padrão.

## framer-motion (padrão)

```tsx
import { motion } from "framer-motion"

// Spring padrão (sidebar, troca de abas)
const spring = { type: "spring", stiffness: 400, damping: 30 }

// Fade-in de cards
<motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.2 }}>
```

Respeitar `prefers-reduced-motion`. Só no step `implement` quando `skill_hint` inclui `motion` ou Impeccable `animate`.

## Estratégia de Modelo para Design

| Fase | Modelo | Por quê |
|------|--------|---------|
| Geração inicial da UI | Claude Sonnet 5 (OpenRouter) | Melhor "gosto estético" — entrega moderno de primeira |
| Iterações, bugs, páginas internas | DeepSeek V4 Pro | 50x mais barato, ótimo para lógica |
| Sistemas complexos do zero | Claude Fable 5 | Raciocínio profundo, 1M tokens contexto |
| Uso diário / rotina | Modo Auto do Cursor | Rápido, incluído no plano |

Regra: modelo com melhor critério estético para casca visual inicial → modelo eficiente para páginas internas e correções.

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
