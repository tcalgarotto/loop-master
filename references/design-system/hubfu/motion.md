# HubFU — Motion

Padrões de animação do preview v9. Stack: **GSAP 3.12.7 + ScrollTrigger** (CDN) + CSS transitions para hover.

Protocolo Lucy: `references/gsap-premium-protocol.md`

---

## Pirâmide (HubFU landing)

| Camada | Onde no preview |
|--------|-----------------|
| CSS `@keyframes` | `pulse`, `intScroll`, `typing` |
| CSS `transition` | buttons, cards hover, FAQ, nav border |
| GSAP | hero entrance, scroll reveals, tabs, kanban snap, chart draw |
| CSS `prefers-reduced-motion` | desliga GSAP + carousel scroll |

Guard global:

```javascript
const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
```

---

## GSAP — inventário

### Hero entrance (on load)

```javascript
gsap.from(".hero-in", {
  opacity: 0, y: 24, duration: 1, stagger: 0.08,
  ease: "power3.out", delay: 0.1
});
gsap.from(".hero-device", {
  opacity: 0, y: 60, scale: 0.94, duration: 1.4,
  ease: "power3.out", delay: 0.35
});
```

### Chart stroke draw (hero overview)

```javascript
path.style.strokeDasharray = len;
path.style.strokeDashoffset = len;
gsap.to(path, { strokeDashoffset: 0, duration: 2, ease: "power2.inOut", delay: 1 });
```

### ScrollTrigger — parallax device

```javascript
gsap.to(".hero-device", {
  y: -40,
  scrollTrigger: {
    trigger: ".device-stage",
    start: "top bottom",
    end: "bottom top",
    scrub: 1.5
  }
});
```

### ScrollTrigger — section reveals

```javascript
gsap.utils.toArray(".reveal").forEach(el => {
  gsap.from(el, {
    scrollTrigger: { trigger: el, start: "top 85%" },
    opacity: 0, y: 32, duration: 1, ease: "power2.out"
  });
});
```

### Counter animation

```javascript
ScrollTrigger.create({
  trigger: el, start: "top 90%", once: true,
  onEnter: () => gsap.to(el, {
    innerText: +el.dataset.target,
    duration: 2, snap: { innerText: 1 }, ease: "power2.out"
  })
});
```

### Tab indicator

```javascript
gsap.to(indicator, { x, scaleX, duration: 0.45, ease: "power2.out", overwrite: true });
```

Tab panel fade on switch: `opacity 0.88 → 1`, `duration: 0.4`.

### Hero device view swap

```javascript
gsap.fromTo(next, { opacity: 0.55 }, { opacity: 1, duration: 0.28, ease: "power2.out" });
```

### Kanban DnD drop snap

```javascript
gsap.fromTo(card, { scale: 0.92 }, {
  scale: 1, duration: 0.45, ease: "elastic.out(1, 0.6)", overwrite: true
});
```

### Bar chart (finance tabs)

```javascript
gsap.to(bar, {
  scaleY: h, duration: 0.6, ease: "power2.out",
  transformOrigin: "bottom center", overwrite: true
});
```

### Integration grid pagination

```javascript
gsap.from(grid.querySelectorAll(".int-card"), {
  opacity: 0, y: 16, duration: 0.4, stagger: 0.04, ease: "power2.out", overwrite: true
});
```

---

## CSS motion

### Carousel (`.int-track`)

```css
animation: intScroll 90s linear infinite;
/* paused on .int-carousel:hover */
```

Reduced motion: flex-wrap estático, mask removido.

### Pulse dot (device sidebar)

```css
@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 0 rgba(52,211,153,.5); }
  50% { box-shadow: 0 0 0 6px rgba(52,211,153,0); }
}
```

### Typing indicator (chat tab)

3 dots, stagger `.15s`, `@keyframes typing`.

### Card micro-interactions

| Elemento | Property | Duration | Easing |
|----------|----------|----------|--------|
| `.deal-card:hover` | transform, shadow | `.25s` | `var(--hubfu-ease)` |
| `.int-pill:hover` | transform, shadow | `.2s` | `var(--hubfu-ease)` |
| `.link-btn` | opacity, transform | `.2s` | default |
| `.faq-a` | grid-template-rows | `.35s` | `var(--hubfu-ease)` |
| `.nav` border | border-color | `.4s` | `var(--hubfu-ease)` |

---

## Easings usados

| Nome GSAP | Uso |
|-----------|-----|
| `power3.out` | Hero entrance |
| `power2.out` | Reveals, tabs, bars, grid |
| `power2.inOut` | Chart stroke |
| `elastic.out(1, 0.6)` | Kanban drop |

CSS: `--hubfu-ease: cubic-bezier(.25, .1, .25, 1)`.

---

## Regras para port Next.js

1. **Não** combinar `transition-all` Tailwind no mesmo elemento que GSAP anima.
2. Usar `gsap.context()` + `revert()` no unmount (React `useEffect`).
3. ScrollTrigger: registrar plugin uma vez; respeitar `prefers-reduced-motion`.
4. Marketing landing → GSAP; app product interno → **Framer Motion** (ver seção abaixo).
5. Device mock parallax: considerar `will-change: transform` (já em `.device`).

---

## Framer Motion (port Next.js)

Alvo para componentes React no app HubFU. GSAP permanece na landing marketing; Framer cobre UI interativa (cards, tabelas, sidebars, botões).

| Padrão HubFU | Framer API | Onde |
|--------------|------------|------|
| Page / tab transition | `AnimatePresence` + `mode="wait"` | Layout, tabs produto |
| Integration card hover | `whileHover={{ scale: 1.02, y: -2 }}` + shadow token | `.int-v2-card` marketplace |
| Connect button tap | `whileTap={{ scale: 0.97 }}` | `.int-v2-connect`, `.ds-sheet-run` |
| Table row enter | `staggerChildren: 0.06` em container | `.ds-sheet-table tbody` |
| Actions sidebar | `motion.aside` `initial={{ x: 220 }}` `animate={{ x: 0 }}` | `.ds-sheet-sidebar` |
| Filter pill switch | `layoutId` no indicador | Tabs / filter pills |

### Page transition

```tsx
'use client'
import { AnimatePresence, motion } from 'framer-motion'

export function TabPanels({ active, children }: { active: string; children: React.ReactNode }) {
  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={active}
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -8 }}
        transition={{ duration: 0.28, ease: [0.25, 0.1, 0.25, 1] }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  )
}
```

### Integration card v2

```tsx
<motion.article
  className="int-v2-card"
  whileHover={{ scale: 1.02, y: -2, boxShadow: 'var(--hubfu-int-card-shadow)' }}
  transition={{ type: 'spring', stiffness: 400, damping: 28 }}
>
  {/* logo, name, desc */}
  <motion.button
    className="int-v2-connect"
    whileTap={{ scale: 0.97 }}
    style={{ background: 'var(--hubfu-action)' }}
  >
    Conectar
  </motion.button>
</motion.article>
```

### Table row stagger

```tsx
const rowVariants = {
  hidden: { opacity: 0, y: 10 },
  show: (i: number) => ({ opacity: 1, y: 0, transition: { delay: i * 0.04 } }),
}

<motion.tbody variants={{ show: { transition: { staggerChildren: 0.06 } } }} initial="hidden" animate="show">
  {rows.map((row, i) => (
    <motion.tr key={row.id} variants={rowVariants} custom={i} whileHover={{ backgroundColor: 'rgba(124,58,237,0.04)' }} />
  ))}
</motion.tbody>
```

### Sidebar slide

```tsx
<motion.aside
  className="ds-sheet-sidebar"
  initial={{ x: 220, opacity: 0 }}
  animate={{ x: 0, opacity: 1 }}
  transition={{ type: 'spring', stiffness: 320, damping: 32 }}
/>
```

**Regra:** um elemento = um dono de animação (GSAP **ou** Framer, não ambos).

**HubfuSheet (preview HTML):** edição e resize são vanilla (`hubfu-sheet.js`). No port Next.js, novas linhas inseridas via workflow devem usar `motion.tr` + `staggerChildren: 0.06` no tbody; o preview estático não anima insert — só hover CSS.

Ver também: `references/gsap-premium-protocol.md` (seção Framer companion).

---

## Verificação

```bash
bash scripts/html-preview-section-gate.sh preview/hubfu-landing-premium.html
```

Gate valida load sem erros JS e screenshots por seção.
