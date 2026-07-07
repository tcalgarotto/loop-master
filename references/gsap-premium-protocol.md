# GSAP Premium Protocol — fluidez de alto nível (aprendido via `/lucy aprenda`)

**Origem:** owner · 2026-07-03 · `/lucy aprenda`  
**Papel:** timelines complexas, scroll cinematográfico, stagger em escala — **acima** de Framer Motion nesses casos.

> Stack híbrida completa: `references/html-native-light-protocol.md`  
> **Scroll storytelling premium (pin/scrub/sandwich/imagery):** `references/premium-motion-scroll-protocol.md`  
> **GSAP Cursor plugin (8 skills, não MCP):** `references/learned/gsap-plugin-orchestration.md`  
> Design routing: `references/design-skills-routing-table.md`

---

## Por que GSAP no ecossistema Lucy?

GSAP é referência em animação JS premium (Apple, Godly, portfolios award). No CRM/ERP/IA Lucy:

| Força | Plugin / recurso |
|-------|------------------|
| Física real (peso, elasticidade) | `CustomEase`, easings GSAP |
| GPU / performance | `x`, `y`, `scale`, `rotation` → `matrix3d` |
| Orquestração | `gsap.timeline()` — cadeia com precisão de ms |
| Scroll avançado | `ScrollTrigger` — pin, scrub, storytelling |

**Não substitui** CSS nativo leve (`view()`, `dialog`) nem hovers simples — **complementa** onde lógica e multi-elemento exigem controle total.

---

## Pirâmide de animação Lucy (v2.8.4+)

```
1. CSS nativo     → dialog, view-transition, animation-timeline (0 JS)
2. CSS transition → hover/active isolados (botão, card lift)
3. GSAP           → timelines, stagger 50+, ScrollTrigger, pin+scrub
4. Framer Motion  → layoutId React, AnimatePresence em árvore de componentes, DnD React
```

---

## Regra 1 — Sem `transition-*` do Tailwind no mesmo elemento GSAP

Se `gsap.to(".card", { x: 100 })` anima o elemento, **remover** `transition-all`, `transition-transform`, etc. da classe.

Conflito GPU: Tailwind transition e GSAP brigam no compositor → jank.

```tsx
// ❌
<div className="card transition-all duration-300" ref={ref} />

// ✅
<div className="card will-change-transform" ref={ref} />
// GSAP controla transform; CSS não
```

---

## Regra 2 — CSS só para micro-interações de hover/active

JavaScript **não precisa saber** do evento:

```tsx
<button className="transition-transform active:scale-95 hover:-translate-y-0.5">
  Salvar
</button>
```

| Use CSS | Use GSAP |
|---------|----------|
| `hover:`, `active:`, `focus-visible:` | Sequências multi-step |
| Um elemento, um estado | 50 cards em cascade |
| Sem timeline | ScrollTrigger pin/scrub |

---

## Regra 3 — GSAP para timelines e scroll complexo

### Stagger — lista CRM (50 clientes)

```tsx
'use client'
import { useEffect, useRef } from 'react'
import gsap from 'gsap'

export function ClientList({ items }: { items: unknown[] }) {
  const root = useRef<HTMLUListElement>(null)

  useEffect(() => {
    if (!root.current) return
    const ctx = gsap.context(() => {
      gsap.from('.client-row', {
        opacity: 0,
        y: 24,
        duration: 0.5,
        stagger: 0.05,
        ease: 'power3.out',
      })
    }, root)
    return () => ctx.revert()
  }, [items])

  return (
    <ul ref={root}>
      {items.map((c) => (
        <li key={/* id */} className="client-row">
          {/* sem transition-* aqui */}
        </li>
      ))}
    </ul>
  )
}
```

### Timeline — abertura do CRM (sidebar → cards → gráficos)

```tsx
const tl = gsap.timeline({ defaults: { ease: 'power3.inOut' } })
tl.to('.sidebar', { x: 0, duration: 0.4 })
  .from('.metric-card', { y: -40, opacity: 0, stagger: 0.08 }, '-=0.1')
  .from('.chart-line', { drawSVG: '0%', duration: 1.2 }, '-=0.2')
```

### ScrollTrigger — gráfico ERP pinado

```tsx
import { ScrollTrigger } from 'gsap/ScrollTrigger'
gsap.registerPlugin(ScrollTrigger)

gsap.to('.chart-morph', {
  scrollTrigger: {
    trigger: '.report-section',
    start: 'top center',
    end: 'bottom center',
    scrub: true,
    pin: '.chart-pin',
  },
  // propriedades aceleradas
  scale: 1.1,
  rotation: 0.02,
})
```

**Preferir ScrollTrigger** sobre `useScroll` + Framer quando: pin longo, scrub 1:1, múltiplos triggers na mesma página marketing/dashboard storytelling.

### Scroll-scrub pin (vídeo + sandwich) — receitas completas

Padrões Apple-style (vídeo frame-a-frame, cards sandwich) têm receitas detalhadas em **`premium-motion-scroll-protocol.md`**:

| Padrão | GSAP | Link |
|--------|------|------|
| Vídeo `currentTime` + pin | `ScrollTrigger.create({ pin, scrub, onUpdate })` | §3 Abordagem A |
| Canvas image sequence | `onUpdate` → `drawImage` só se frame mudou | §3 Abordagem B |
| Sandwich stack (fallback JS) | `pin` + scale por card | §4 + CSS nativo prefer |

**Não duplicar** aqui — manter GSAP neste arquivo para stagger/timeline/GPU; storytelling cinematográfico no protocolo premium motion.

---

## Regra 4 — Propriedades aceleradas (GPU)

| ✅ Usar | ❌ Evitar |
|---------|-----------|
| `x`, `y`, `scale`, `rotation` | `top`, `left`, `width`, `height` |
| `opacity` | `margin`, `padding` animados |
| `transform` via GSAP | `box-shadow` pesado em 60 elementos |

---

## Next.js — instalação e SSR

```bash
npm install gsap
```

```tsx
// Sempre em 'use client' + useEffect ou gsap.context + cleanup revert()
// Nunca importar ScrollTrigger em Server Component
```

```tsx
useEffect(() => {
  const mq = window.matchMedia('(prefers-reduced-motion: reduce)')
  if (mq.matches) return
  // ... gsap animations
}, [])
```

---

## GSAP vs Framer Motion vs CSS scrub

| Cenário | Escolha |
|---------|---------|
| Card reveal no scroll simples | `animation-timeline: view()` (CSS) |
| 50 itens cascade na entrada | **GSAP stagger** |
| Sidebar spring no app React | Framer Motion **ou** GSAP (preferir Framer se já em `motion.div`) |
| `layoutId` card → modal | Framer Motion |
| Landing scroll storytelling 3+ acts | **GSAP ScrollTrigger** |
| Botão hover lift | CSS `transition-transform` |
| Integration card v2 hover/tap | **Framer** `whileHover` / `whileTap` |
| Spreadsheet row stagger | **Framer** `staggerChildren` |
| Workflow sidebar slide-in | **Framer** `motion.aside` x-axis |

**Não duplicar:** mesmo elemento não deve ter GSAP + Framer + `transition-all` simultâneos.

---

## Framer Motion companion (HubFU Next.js)

Mapeamento canônico para port do design system HTML → React. Tokens: `--hubfu-action` (roxo Connect/Run), `--hubfu-success` (verde Connected).

| Componente HTML | Classe | Framer target |
|-----------------|--------|---------------|
| Integration card v2 | `.int-v2-card` | `whileHover` scale + shadow |
| Connect CTA | `.int-v2-connect` | `whileTap={{ scale: 0.97 }}` |
| Run workflow | `.ds-sheet-run` | `whileTap` + `whileHover` opacity |
| Data table rows | `.ds-sheet-table tbody tr` | `staggerChildren` + `whileHover` bg |
| Actions sidebar | `.ds-sheet-sidebar` | `initial/animate` x spring |
| Tab panel swap | `.tab-scene` | `AnimatePresence mode="wait"` |

Docs completos: `references/design-system/hubfu/motion.md` · showcase: `#motion-framer` em `preview/hubfu-design-system.html`.

```tsx
// Exemplo: Connect button (roxo accent, não verde primary)
<motion.button
  className="int-v2-connect"
  whileTap={{ scale: 0.97 }}
  whileHover={{ backgroundColor: 'var(--hubfu-action-hover)' }}
>
  Conectar
</motion.button>
```

---

## Prompt de calibração (owner)

> Lucy, padronize animações premium: GSAP para fluxos complexos e CSS nativo para hovers. Ao animar com GSAP, remova classes `transition-*` do Tailwind no mesmo elemento. Use `x`, `y`, `scale`, `rotation` — nunca `top`/`left`/`width`/`height`.

---

## Checklist implement

```
[ ] Elemento com gsap.to/from sem transition-* Tailwind
[ ] Hovers isolados permanecem CSS puro
[ ] Timelines com gsap.context + revert() no unmount
[ ] ScrollTrigger com prefers-reduced-motion guard
[ ] Propriedades GPU-only em animações de lista
[ ] Conflito GSAP/Framer resolvido (um dono por elemento)
```

---

## GSAP Cursor plugin — skills oficiais (v2.9.27+)

O GSAP no Cursor é um **plugin com 8 skills** — **não** é MCP. Lucy lê a skill antes de codar; o agente pode auto-carregar pela `description` ou o owner invoca `/gsap-*`.

| Cenário Lucy | Skill plugin | Notas |
|--------------|--------------|-------|
| React / Next.js (`use client`) | **gsap-react** | `useGSAP({ scope })`, `@gsap/react`; nunca GSAP em Server Component |
| Pin, scrub, scroll storytelling | **gsap-scrolltrigger** | Pair com `premium-motion-scroll-protocol.md` em register **brand** |
| Hero intro multi-step, CRM opening acts | **gsap-timeline** | ScrollTrigger no timeline, não nos filhos |
| Stagger lista, easing, matchMedia a11y | **gsap-core** | `gsap.matchMedia()` para `prefers-reduced-motion` |
| Flip, SplitText, Draggable, DrawSVG | **gsap-plugins** | `gsap.registerPlugin()` uma vez por app |
| Jank, 60fps, listas longas | **gsap-performance** | Transforms only; `quickTo` para mouse followers |
| Scroll progress → frame index | **gsap-utils** | `mapRange`, `clamp`, `selector(scope)` |
| Vue / Nuxt / Svelte | **gsap-frameworks** | Não usar gsap-react |

**Auto-load vs manual:** pedidos como "animação React com GSAP" → Lucy carrega **gsap-react** primeiro; "scroll pin vídeo" → **gsap-scrolltrigger** + premium-motion-scroll. Detalhe completo: `references/learned/gsap-plugin-orchestration.md`.

---

## Referências

- https://gsap.com/docs/v3/
- ScrollTrigger: https://gsap.com/docs/v3/Plugins/ScrollTrigger/
- Pin/scrub/sandwich/imagery: `references/premium-motion-scroll-protocol.md`
- Plugin orchestration (8 skills): `references/learned/gsap-plugin-orchestration.md`
