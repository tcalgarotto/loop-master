# HubFU — Tokens

Fonte canônica: `preview/hubfu-design-tokens.css` · extraído de `preview/hubfu-landing-premium.html`.

Arquitetura em três camadas (ver `.cursor/skills/design-system/SKILL.md`):

```
Primitive → Semantic (--hubfu-*) → Component (classes CSS)
```

---

## Cores — primitivos

| Token | Hex / valor | Uso |
|-------|-------------|-----|
| `--hubfu-primitive-white` | `#fbfbfb` | Fundo landing light |
| `--hubfu-primitive-gray-50` | `#f4f4f5` | Seções alternadas |
| `--hubfu-primitive-gray-900` | `#1d1d1f` | Texto principal light |
| `--hubfu-primitive-emerald-600` | `#0a7f5c` | Accent primary light |
| `--hubfu-primitive-emerald-400` | `#34d399` | Accent bright, deltas, pulse |
| `--hubfu-primitive-emerald-300` | `#6ee7b7` | Valores monetários em UI escura |
| `--hubfu-primitive-violet-600` | `#7c3aed` | Integrações / conectar |
| `--hubfu-primitive-surface` | `#1c1c1e` | Device, tab-panel, feature-visual |
| `--hubfu-primitive-integrations-tint` | `#f4f2f8` | Faixa carousel light |

---

## Cores — semânticos (light vs dark)

| Token | Light | Dark | Notas |
|-------|-------|------|-------|
| `--hubfu-bg` | `#fbfbfb` | `#0a0a0b` | Body |
| `--hubfu-bg-alt` | `#f4f4f5` | `#111114` | `.feature-section.alt`, capabilities |
| `--hubfu-fg` | `#1d1d1f` | `#f5f5f7` | Texto principal |
| `--hubfu-fg-secondary` | `rgba(29,29,31,.72)` | `rgba(245,245,247,.72)` | Subtítulos |
| `--hubfu-fg-tertiary` | `rgba(29,29,31,.48)` | `rgba(245,245,247,.48)` | Meta, labels |
| `--hubfu-line` | `rgba(29,29,31,.08)` | `rgba(255,255,255,.08)` | Bordas, divisores |
| `--hubfu-accent` | `#0a7f5c` | `#34d399` | Kickers, tags, prob-fill start |
| `--hubfu-accent-bright` | `#34d399` | `#6ee7b7` | Deltas, métricas positivas |
| `--hubfu-violet` | `#7c3aed` | `#8b5cf6` | Botão conectar integração |
| `--hubfu-violet-soft` | `rgba(124,58,237,.15)` | `rgba(139,92,246,.22)` | Badge beta |
| `--hubfu-nav-bg` | `rgba(251,251,251,.72)` | `rgba(10,10,11,.82)` | Nav blur |
| `--hubfu-integrations-bg` | `#f4f2f8` | `#12121a` | Carousel section |
| `--hubfu-pill-bg` | `#ffffff` | `rgba(255,255,255,.06)` | Logo pills carousel |
| `--hubfu-card-bg` | `#ffffff` | `rgba(255,255,255,.04)` | Quote cards |
| `--hubfu-btn-primary-bg` | `#1d1d1f` | `#f5f5f7` | `.link-btn` filled |
| `--hubfu-statement-bg` | `#000000` | `#000000` | Statement band (sempre escuro) |

### Aliases legados (preview HTML)

| Alias | Mapeia para |
|-------|-------------|
| `--bg` | `--hubfu-bg` |
| `--fg` | `--hubfu-fg` |
| `--accent` | `--hubfu-accent` |
| `--line` | `--hubfu-line` |
| `--violet` | `--hubfu-violet` |

---

## Tipografia

| Token | Valor |
|-------|-------|
| `--hubfu-font-sans` | `-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif` |
| `--hubfu-font-serif` | `"Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif` |
| `--hubfu-font-mono` | `ui-monospace, monospace` |

### Escala (extraída do CSS)

| Role | Size | Weight | Tracking | Line-height |
|------|------|--------|----------|-------------|
| Hero H1 | `clamp(2.75rem, 7vw, 4.5rem)` | 600 | `-0.04em` | 1.05 |
| Section H2 | `clamp(1.75rem, 3vw, 2.5rem)` | 600 | `-0.03em` | 1.1 |
| Hero sub | `clamp(1.125rem, 2.5vw, 1.375rem)` | 400 | default | 1.5 |
| Body | inherit | 400 | `-0.022em` | 1.47 |
| Kicker / tag | `.75rem` | 600 | `0.06–0.08em` | uppercase |
| Nav link | `.8125rem` | 400 | default | — |
| Button | `.8125rem` | 500 | default | — |
| Metric value | `1.75rem` | 600 | `-0.03em` | — |
| Deal name | `.75rem` | 500 | default | 1.2 |
| Micro label | `.625rem` | 600 | `0.06–0.08em` | uppercase |

**Serif italic:** apenas em `<em>` dentro de headlines (`font-family: var(--serif)`).

---

## Spacing

| Token | Valor | Uso |
|-------|-------|-----|
| `--hubfu-wrap` | `min(1080px, 88vw)` | Conteúdo padrão |
| `--hubfu-wrap-wide` | `min(1280px, 94vw)` | Device, marketplace, produto |
| `--hubfu-nav-height` | `52px` | Nav fixa |
| `--hubfu-section-hero` | `120px` | Padding vertical hero/features/pricing |
| `--hubfu-section-lg` | `100px` | Steps, CTA, marketplace |
| `--hubfu-section-md` | `80px` | FAQ top |

### Grid gaps (recorrentes)

| Contexto | Gap |
|----------|-----|
| Hero actions | `14px` |
| Hero meta | `32px` |
| Kanban columns | `10–12px` |
| Feature row (desktop) | `80px` |
| Cap grid padding | `32px` / `48px` lateral |
| Integration grid | `14px` |

---

## Radii

| Token | Valor | Uso |
|-------|-------|-----|
| `--hubfu-radius-pill` | `980px` | Buttons, pills, chips |
| `--hubfu-radius-device` | `20px` | Device frame, tab-panel |
| `--hubfu-radius-card` | `18px` | Quote, pricing grid |
| `--hubfu-radius-panel` | `16px` | Feature visual |
| `--hubfu-radius-control` | `12px` | Kanban col, chart, inputs |
| `--hubfu-radius-chip` | `10px` | Deal card |
| `--hubfu-radius-avatar` | `8px` | Avatar, page btn |
| `--hubfu-radius-badge` | `6px` | Status badges |

---

## Shadows & effects

| Token / pattern | Light | Dark |
|-----------------|-------|------|
| Device | `0 24px 80px rgba(0,0,0,.18)` | `0 24px 80px rgba(0,0,0,.55)` |
| Feature visual | `0 20px 60px rgba(0,0,0,.12)` | `0 20px 60px rgba(0,0,0,.45)` |
| Int pill | `0 2px 14px rgba(0,0,0,.07)` | `0 2px 14px rgba(0,0,0,.35)` + border |
| Int card hover | `0 12px 40px rgba(0,0,0,.35)` | igual (UI escura) |
| Nav blur | `backdrop-filter: saturate(180%) blur(20px)` | igual |
| Hero glow | `radial-gradient rgba(10,127,92,.1)` | `rgba(52,211,153,.12)` |

---

## Motion tokens

| Token | Valor |
|-------|-------|
| `--hubfu-ease` | `cubic-bezier(.25, .1, .25, 1)` |

Durações recorrentes: `.2s` (hover), `.25s` (cards), `.35–.45s` (tabs), `.4s` (nav border).

Ver [motion.md](./motion.md) para GSAP.

---

## Status & semantic colors (UI produto)

| Estado | Background | Foreground |
|--------|------------|------------|
| Connected | `rgba(52,211,153,.12)` | `#6ee7b7` |
| OK badge | `rgba(52,211,153,.15)` | `#6ee7b7` |
| Warn badge | `rgba(220,38,38,.15)` | `#fca5a5` |
| Low badge | `rgba(251,191,36,.15)` | `#fcd34d` |
| Beta | `var(--hubfu-violet-soft)` | `#c4b5fd` |
| OAuth auth | `rgba(96,165,250,.12)` | `#93c5fd` |
| Webhook auth | `rgba(251,146,60,.15)` | `#fdba74` |

---

## Toggle dark mode

```html
<html data-theme="light">  <!-- ou dark -->
```

```javascript
document.documentElement.setAttribute('data-theme', 'dark');
localStorage.setItem('hubfu-theme', 'dark');
```

Botão demo: `#theme-toggle` na nav do preview.
