# Premium Motion & Scroll Protocol — storytelling cinematográfico (aprendido via `/lucy aprenda`)

**Origem:** owner · 2026-07-05 · `/lucy aprenda`  
**Papel:** padrões premium de scroll, imagem, vídeo pinado, morphism e sandwich layouts — **sugerir e implementar** em superfícies brand; **restringir** em product/CRM.

> Stack híbrida: `html-native-light-protocol.md` (CSS scrub nativo) · `gsap-premium-protocol.md` (ScrollTrigger pin/scrub) · Impeccable `animate`/`delight` (motion com propósito, anti-slop)

---

## Registro impeccable — SUGERIR vs RESTRINGIR

| Register | Superfície | Lucy DEVE | Lucy NÃO DEVE |
|----------|------------|-----------|---------------|
| **brand** | Landing, pricing, portfolio, campanha, hero marketing | **Propor ativamente** 1–3 assinaturas deste protocolo quando a página está plana ou genérica | Forçar pin+scrub em toda seção; morphism em tabelas |
| **product** | CRM, dashboard, inbox, settings, ERP, tabelas | Motion **funcional** (150–250 ms, feedback, skeleton) — ver `animate.md` product | Scroll storytelling, vídeo pinado, sandwich stack, morphism decorativo |
| **ambíguo** | Login, onboarding, pricing em app | Perguntar ou inferir de `PRODUCT.md` `## Register` | Assumir brand só porque “parece marketing” |

**Gatilho de sugestão proativa (brand):** durante `nova-pagina --tipo landing`, `refazer-frontend` em `/landing`, `critique` com “sem vida”, ou HTML-first preview — Lucy **lista 2–3 padrões** deste protocolo com justificativa de 1 linha cada. Owner pode recusar; Lucy não implementa sem fit.

**Gatilho de restrição (product):** rotas `/crm`, `/dashboard`, tabelas densas, forms longos — Lucy **não sugere** pin/scrub/sandwich; no máximo `animation-timeline: view()` sutil em cards de métrica (já em `html-native-light-protocol.md`).

---

## Pirâmide de decisão (motion premium)

```
Superfície brand + storytelling no scroll?
├─ Reveal simples por seção (fade/scale)?
│  └─ CSS animation-timeline: view() — 0 JS (html-native-light-protocol §4c)
├─ Transição entre acts (3+ seções coreografadas)?
│  └─ GSAP ScrollTrigger timeline OU CSS view-timeline nomeada
├─ Vídeo/produto frame-a-frame no scroll?
│  └─ ScrollTrigger pin + scrub → canvas sequence (prefer) OU video.currentTime
├─ Cards empilhados que pinam e revelam?
│  └─ CSS sticky sandwich (nativo) OU GSAP pin stack (fallback)
├─ Glass/clay/neu como material?
│  └─ morphism § abaixo — máx 2 superfícies por viewport
└─ Fotografia hero editorial?
   └─ art-directed imagery § — sempre antes de morphism
```

**Ordem de preferência:** CSS scroll-driven → GSAP ScrollTrigger → canvas/video scrub. Nunca `useScroll` + Framer em 20 cards (ver `html-native-light-protocol.md`).

---

## 1. Fotografia e imagem como elemento de design

### Quando usar

- Landing brand onde **a imagem é o argumento** (produto físico, moda, arquitetura, food, SaaS com UI forte)
- Hero com art direction clara: crop editorial, duotone, grain, overlay tipográfico
- Seções “magazine spread” alternando full-bleed + texto na coluna

### Quando NÃO usar

- Dashboards, listas, settings — thumb pequeno ou avatar basta
- Stock genérico sem tratamento (slop)
- Hero image que compete com CTA (imagem > copy = conversão cai)

### Acessibilidade e performance

- `alt` descritivo; texto hero não depende só da imagem
- LCP: `priority` só no hero above-the-fold; demais lazy
- Formatos: AVIF/WebP via `<picture>` ou `next/image`; fallback JPEG
- LQIP/blur-up: `placeholder="blur"` + `blurDataURL` ou CSS `background-image` tiny + `filter: blur(20px)` até load
- `aspect-ratio` + `object-fit: cover` — evita CLS
- `prefers-reduced-motion`: sem Ken Burns / parallax em foto; estado estático

### Receita mínima — Next.js art-directed hero

```tsx
import Image from 'next/image'

export function EditorialHero() {
  return (
    <section className="relative min-h-[85vh] overflow-clip">
      <picture className="absolute inset-0">
        <source srcSet="/hero.avif" type="image/avif" />
        <source srcSet="/hero.webp" type="image/webp" />
        <Image
          src="/hero.jpg"
          alt="Produto em uso — contexto editorial"
          fill
          priority
          className="object-cover object-[center_30%] motion-reduce:scale-100 scale-105"
          sizes="100vw"
          placeholder="blur"
          blurDataURL="data:image/jpeg;base64,..."
        />
      </picture>
      {/* Overlay legível — não glass em cima de foto sem contraste */}
      <div className="absolute inset-0 bg-gradient-to-t from-ink/80 via-ink/20 to-transparent" />
      <div className="relative z-10 mx-auto max-w-6xl px-6 pb-24 pt-40">
        <h1 className="max-w-2xl text-balance text-5xl font-semibold text-cream">
          Headline editorial
        </h1>
      </div>
    </section>
  )
}
```

**Art direction checklist:** crop intencional (`object-position`), grade ou grain sutil em CSS (`mix-blend-mode`, noise PNG 3% opacity), tipografia sobre gradiente — não sobre foto crua.

**Fontes:** [web.dev LCP images](https://web.dev/articles/optimize-lcp) · Next.js Image docs

---

## 2. Transições elegantes seção-a-seção (scroll-driven)

### Quando usar

- Landing com 4–8 seções narrativas (problema → solução → prova → CTA)
- Reveal de cards, métricas, quotes ao entrar na viewport
- Header que compacta no scroll (já em `html-native-light-protocol.md`)

### Quando NÃO usar

- Cada `<section>` com fade-on-scroll idêntico (tell impeccable `animate` brand: “fade-and-rise em tudo”)
- CRM table rows, sidebar items, modais
- Conteúdo crítico que some até animar (a11y: estado final visível por default)

### Acessibilidade

```css
@media (prefers-reduced-motion: no-preference) {
  @supports (animation-timeline: view()) {
    .section-reveal {
      animation: reveal-up linear both;
      animation-timeline: view();
      animation-range: entry 10% cover 35%;
    }
  }
}
@media (prefers-reduced-motion: reduce) {
  .section-reveal {
    animation: none;
    opacity: 1;
    transform: none;
  }
}
```

### Performance

- Animar só `transform`, `opacity`, `filter` (blur leve) — compositor thread
- `@supports` fallback: layout estático
- Evitar `overflow: hidden` no ancestral de scrub — preferir `overflow: clip` ([Smashing Magazine 2024](https://www.smashingmagazine.com/2024/12/introduction-css-scroll-driven-animations/))

### Receita — CSS nativo (prefer)

```css
@keyframes reveal-up {
  from { opacity: 0; transform: translateY(2.5rem) scale(0.97); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}
.section-reveal {
  animation: reveal-up linear both;
  animation-timeline: view();
  animation-range: entry 8% cover 40%;
}
```

### Receita — GSAP (acts coreografados)

Ver cross-link: `gsap-premium-protocol.md` § ScrollTrigger + `premium-motion-scroll-protocol` acts:

```tsx
'use client'
import { useEffect, useRef } from 'react'
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

gsap.registerPlugin(ScrollTrigger)

export function ScrollActs({ children }: { children: React.ReactNode }) {
  const root = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return
    const ctx = gsap.context(() => {
      gsap.utils.toArray<HTMLElement>('.act').forEach((section, i) => {
        gsap.from(section.querySelector('.act-inner'), {
          opacity: 0,
          y: 48,
          duration: 1,
          ease: 'power3.out',
          scrollTrigger: {
            trigger: section,
            start: 'top 75%',
            toggleActions: 'play none none reverse',
          },
        })
      })
    }, root)
    return () => ctx.revert()
  }, [])

  return <div ref={root}>{children}</div>
}
```

**Fontes:** [Chrome scroll-driven animations](https://developer.chrome.com/docs/css-ui/scroll-driven-animations) · [MDN timelines](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_scroll-driven_animations/Timelines)

---

## 3. Vídeo scroll-scrubbed (pin + frame-a-frame)

Padrão Apple AirPods / product pages: seção **pinada**; scroll mapeia progresso 0→1 no vídeo ou sequência de frames.

### Abordagem A — `<video>` + `currentTime` (rápido de prototipar)

| Prós | Contras |
|------|---------|
| Um arquivo MP4/WebM | Seek pode ser impreciso/choppy em alguns browsers |
| Menos assets | Vídeo pesado no mobile |

```tsx
'use client'
import { useEffect, useRef } from 'react'
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

gsap.registerPlugin(ScrollTrigger)

export function ScrollScrubVideo() {
  const videoRef = useRef<HTMLVideoElement>(null)
  const wrapRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const video = videoRef.current
    const wrap = wrapRef.current
    if (!video || !wrap) return
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      video.pause()
      return
    }

    video.pause()
    const init = () => {
      ScrollTrigger.create({
        trigger: wrap,
        start: 'top top',
        end: '+=300%',
        pin: true,
        scrub: true,
        onUpdate: (self) => {
          video.currentTime = self.progress * video.duration
        },
      })
    }
    if (video.readyState >= 1) init()
    else video.addEventListener('loadedmetadata', init, { once: true })

    return () => ScrollTrigger.getAll().forEach((t) => t.kill())
  }, [])

  return (
    <div ref={wrapRef} className="relative h-screen">
      <video
        ref={videoRef}
        src="/product-loop.webm"
        muted
        playsInline
        preload="auto"
        className="h-full w-full object-contain"
      />
      {/* reduced-motion: poster estático */}
    </div>
  )
}
```

### Abordagem B — Canvas + image sequence (produção premium)

| Prós | Contras |
|------|---------|
| Frame-perfect, controle pixel | Muitos assets; preload strategy obrigatória |
| Usado em OPTIKKA, Apple-like sites | Bundle/CDN planning |

```tsx
// Esboço — desenhar só quando frame index muda (economia GPU ~80%)
onUpdate: (self) => {
  const frame = Math.round(self.progress * (FRAME_COUNT - 1))
  if (frame !== lastFrame) {
    lastFrame = frame
    ctx.drawImage(frames[frame], 0, 0, canvas.width, canvas.height)
  }
}
```

**Regras:** `pin: true` + `scrub: true`; `end` em px ou `%` viewport para duração do “filme”; mobile: considerar sequência menor ou poster estático abaixo de `md`.

**A11y:** `prefers-reduced-motion` → poster + copy estática; não depender do scrub para informação. `aria-hidden` no canvas se decorativo.

**Fontes:** [Codrops OPTIKKA frame sequences 2025](https://tympanus.net/codrops/2025/10/16/creating-smooth-scroll-synchronized-animation-for-optikka-from-html5-video-to-frame-sequences/) · [ux.dev Scroll Video](https://uxdev.org/lessons/gsap-scroll-video/)

Detalhe GSAP: `gsap-premium-protocol.md` § **Scroll-scrub pin (vídeo + sandwich)**

---

## 4. Sandwich / sticky-stacking layouts

Cards que **empilham** enquanto o usuário rola; cada card pinna e o próximo cobre o anterior (scale-down sutil).

### Quando usar

- Landing “feature stack” (3–5 benefícios)
- Case studies empilhados
- Pricing tiers com destaque progressivo

### Quando NÃO usar

- Listas CRM, kanban, inbox
- Mais de 5 cards (scroll fatigue)
- Mobile muito estreito sem teste — pode funcionar, mas validar no visual-gate

### CSS nativo (prefer — compositor, 0 JS)

Padrão [scroll-driven-animations.style stacking cards](https://scroll-driven-animations.style/demos/stacking-cards/css/):

```css
#cards {
  --numcards: 4;
  view-timeline-name: --cards-scroll;
}
.card {
  --index: 0; /* incrementar por card */
  position: sticky;
  top: calc(var(--index) * 1.5rem);
}
.card__content {
  animation: stack-scale linear forwards;
  animation-timeline: --cards-scroll;
  animation-range: exit-crossing calc(var(--index) / var(--numcards) * 100%)
                    exit-crossing calc((var(--index) + 1) / var(--numcards) * 100%);
}
@keyframes stack-scale {
  to { transform: scale(calc(1.05 - 0.05 * var(--reverse-index, 1))); }
}
```

**Sticky no `.card__content` interno**, não no wrapper — preserva scroll height ([Eric Valois demo](https://ericvalois.com/projects/scroll-driven-animations/)).

### GSAP fallback

Quando CSS timeline indisponível ou choreography complexa: `ScrollTrigger.batch` + pin por card — ver `gsap-premium-protocol.md`.

---

## 5. Morphism com bom gosto (glass · clay · neu)

### Tasteful bar (impeccable-aligned)

| Morfismo | Uso correto | Limite |
|----------|-------------|--------|
| **Glassmorphism** | Nav flutuante, modal, card hero **sobre** foto/gradiente saturado | blur 12–24px; fill rgba 20–40%; hairline border 1px |
| **Claymorphism** | CTAs playfulness brand, ilustração 3D soft | 1 família por página; não em data tables |
| **Neumorphism** | Quase nunca em 2026 — só toggles/icons isolados em bg flat | Nunca cards aninhados |

**Regra Lucy:** morphism é **camada sobre energia** (foto, gradiente, vídeo). Sem fundo vivo → efeito colapsa (slop).

### Hard bans (anti-slop)

- Glass em toda a página ou em cada card de grid
- `backdrop-filter` em área scrollável grande (FPS mobile)
- Neumorphism em forms densos ou tabelas ERP
- Clay + glass + neu na mesma viewport
- Morphism em register **product** exceto nav sticky com justificativa

```css
/* Glass canônico — uma superfície */
.glass-panel {
  background: color-mix(in oklab, var(--surface) 35%, transparent);
  backdrop-filter: blur(16px) saturate(1.2);
  border: 1px solid color-mix(in oklab, var(--cream) 25%, transparent);
  box-shadow: 0 8px 32px oklch(0% 0 0 / 0.12);
}
@supports not (backdrop-filter: blur(1px)) {
  .glass-panel { background: var(--surface); }
}
```

**Fontes:** impeccable `animate` motion materials · [UX Pilot glassmorphism 2025](https://uxpilot.ai/blogs/glassmorphism-ui)

---

## 6. Premium scroll storytelling (orquestração)

### Narrativa em 3 acts (landing)

| Act | Scroll | Técnica |
|-----|--------|---------|
| 1 — Hook | 0–100vh | Art-directed hero + GSAP intro timeline OU CSS view reveal |
| 2 — Proof | 100–300vh | Sandwich stack OU scrub vídeo pinado |
| 3 — Convert | 300vh+ | Seções view() + CTA glass sobre gradiente |

**Budget performance (brand landing):**

| Métrica | Alvo |
|---------|------|
| Scroll listeners JS | 0 para reveals CSS; 1 ScrollTrigger context se pin/scrub |
| Imagens hero | < 200KB AVIF/WebP |
| Vídeo scrub | WebM < 5MB ou sequence CDN |
| INP | Sem work pesado em `scroll` handler — usar scrub GSAP ou CSS timeline |
| `prefers-reduced-motion` | Layout completo sem pin; poster no lugar de vídeo |

### Degradação graceful

```tsx
const reduced = typeof window !== 'undefined' &&
  window.matchMedia('(prefers-reduced-motion: reduce)').matches

if (reduced) {
  // Sem ScrollTrigger pin; seções estáticas empilhadas
  return <StaticStorySections />
}
```

---

## Integração Lucy — comandos

| Comando | Ação com este protocolo |
|---------|-------------------------|
| `/lucy nova-pagina --tipo landing` | Sugerir 2–3 padrões; implementar ≥1 assinatura (R4 `premium-tool-orchestration`) |
| `/lucy refazer-frontend --escopo /landing` | `critique` + gap vs este protocolo |
| `/lucy analise @url` | Extrair padrões pin/scrub/sandwich do concorrente |
| `impeccable animate` | Brand: scroll moments que **ganham** animação; product: recusar storytelling |
| `impeccable delight` | Delight em acts 2–3, não em cada parágrafo |

---

## Checklist implement

```
[ ] Register verificado (brand vs product) antes de sugerir
[ ] prefers-reduced-motion: fallback estático testado
[ ] CSS view()/scroll() tentado antes de GSAP
[ ] Pin+scrub: informação não depende só do vídeo
[ ] Morphism: máx 2 superfícies; fundo com energia
[ ] Fotografia: LCP, aspect-ratio, alt, sem stock cru
[ ] Sandwich: ≤5 cards; sticky no inner content
[ ] Sem fade-on-scroll idêntico em todas as seções (anti-slop)
[ ] visual-gate desktop + mobile na landing
```

---

## Referências cruzadas

- `gsap-premium-protocol.md` — pin, scrub, stagger, GPU props
- `html-native-light-protocol.md` — view(), scroll(), view-transition
- `premium-tool-orchestration.md` — quando sugerir motion premium
- `design-skills-routing-table.md` — superfície → padrão
- `template-gallery.md` — templates pin-scrub, sandwich, editorial hero
- Impeccable `reference/animate.md`, `reference/delight.md`
