# HubFU — Motion + shadcn/ui Guide

Guia canônico para animações no preview HTML e port Next.js com Framer Motion + shadcn/ui.

> Preview: `preview/hubfu-design-system.html` (#motion, #motion-framer, #shadcn)  
> Controller: `preview/hubfu-motion.js`  
> Tokens: `preview/hubfu-design-tokens.css`

---

## Pirâmide de animação

```
1. CSS nativo     → dialog, accordion, carousel keyframes
2. CSS transition → hover/active (botão, card lift)
3. GSAP           → stagger, tab indicator, replay demos
4. Framer Motion  → layoutId, AnimatePresence (port React)
```

**Regra:** um elemento = um dono. Não misturar `transition-*` Tailwind no mesmo nó que GSAP anima.

---

## Motion tokens

| Token | Valor | Uso |
|-------|-------|-----|
| `--hubfu-duration-instant` | 100ms | Ripple, micro feedback |
| `--hubfu-duration-fast` | 150ms | Dropdown open |
| `--hubfu-duration-normal` | 250ms | Tab panel, chat bubble |
| `--hubfu-duration-slow` | 400ms | Section entrance |
| `--hubfu-duration-slower` | 600ms | Cell save flash |
| `--hubfu-ease-out` | cubic-bezier(.25,.1,.25,1) | Entradas |
| `--hubfu-ease-in` | cubic-bezier(.4,0,1,1) | Saídas |
| `--hubfu-ease-spring` | cubic-bezier(.22,1,.36,1) | Port Framer spring approx |

`prefers-reduced-motion: reduce` desliga animações não essenciais (carousel, GSAP, shimmer, flow dots).

---

## Layer 1 — HTML/CSS specimens (preview)

| Padrão | Classe / API | Seção DS |
|--------|--------------|----------|
| Stagger fade-up | `.hubfu-animate-fade-up-stagger` + GSAP | #motion |
| Button ripple | `.hubfu-btn-ripple` | #botoes |
| Card lift | CSS hover `.int-v2-card`, `.deal-card` | #cards, #integracoes |
| Tab transition | GSAP indicator + `.hubfu-tab-panel-enter` | #tabs |
| Toast slide-in | `.hubfu-toast`, `@keyframes hubfu-toast-in` | #data-table |
| Cell save flash | `.cell-saved` | #data-table |
| Chat bubble | `.hubfu-chat-enter` | #chat |
| Workflow pulse | `.hubfu-node-pulse` on hover | #workflow |
| Integration stagger | `.hubfu-int-stagger.is-visible` | #integracoes |
| Carousel | `.motion-track` + `intScroll` | #integracoes, #motion |
| Dialog | `<dialog class="hubfu-dialog-specimen">` | #shadcn |
| Skeleton | `.hubfu-skeleton` | #motion |
| Accordion | `.faq-item` grid rows | #faq |

Controller `HubfuMotion.init()` liga: integrações stagger, tabs, ripple, chat hook, workflow pulse, shadcn demos.

---

## Layer 2 — Framer Motion mapping

| HubFU | Framer API | Snippet |
|-------|------------|---------|
| `.int-v2-card` | `whileHover` | scale 1.02, y -2 |
| `.int-v2-connect` | `whileTap` | scale 0.97 |
| `.tab-panel` | `AnimatePresence mode="wait"` | opacity + y |
| `.ds-sheet-sidebar` | `motion.aside` | initial x:220 |
| `.ds-sheet-table tbody` | `staggerChildren: 0.06` | row variants |
| `.hubfu-chat-row` | `initial/animate` | y:10, opacity |
| `.filter-pill` | `layoutId` | indicador ativo |
| `.hubfu-flow-node` | `whileHover` | scale 1.03 |

Ver exemplos TSX completos em [motion.md](./motion.md).

Port:

```bash
npm install framer-motion
# Import hubfu-design-tokens.css em globals.css
```

---

## Layer 3 — shadcn/ui mapping

| HubFU (HTML) | shadcn primitive | Notas |
|--------------|------------------|-------|
| `.link-btn` | `Button` | variants default/outline/ghost |
| `.hubfu-dialog-specimen` | `Dialog` | Preferir `<dialog>` nativo |
| `.hubfu-chat-catalog` | `Sheet` | side="right" |
| `.tab-bar` / `.hubfu-tabs-shadcn` | `Tabs` | Radix tabs |
| `.hubfu-sonner-toast` | `Sonner` | `npx shadcn@latest add sonner` |
| `.hubfu-dropdown-menu` | `DropdownMenu` | |
| `.hubfu-command` | `Command` | ⌘K palette |
| `.ds-sheet-table` | `DataTable` | + EditableTable |
| `.badge` | `Badge` | |
| `.hubfu-avatar` | `Avatar` | |
| `.hubfu-scroll-area` | `ScrollArea` | |

### Token overrides (globals.css)

```css
@import '../preview/hubfu-design-tokens.css';

:root {
  --background: var(--hubfu-bg);
  --foreground: var(--hubfu-fg);
  --primary: var(--hubfu-action);
  --primary-foreground: #fff;
  --secondary: var(--hubfu-bg-alt);
  --border: var(--hubfu-line);
  --ring: var(--hubfu-action);
  --radius: var(--hubfu-radius-chip);
}
```

---

## Audit: onde motion estava ausente (v1.7)

| Seção | Antes | Depois |
|-------|-------|--------|
| Integrações | Pills estáticos | Carousel auto + grid stagger on scroll |
| Botões | hover/active só | Ripple demo |
| Tabs | Indicador GSAP | + fade painel |
| Planilha | sync dot | + cell flash verde |
| Chat | append sem motion | slide-in `.hubfu-chat-enter` |
| Workflow | flow dots SVG | + pulse hover + scale select |
| Motion | 3 demos | Catálogo completo 12 padrões |
| shadcn | inexistente | Seção #shadcn + 6 demos interativos |

---

## Verificação

```bash
bash scripts/html-preview-serve.sh   # terminal 1
bash scripts/html-preview-section-gate.sh --file preview/hubfu-design-system.html
```

Protocolos: `references/gsap-premium-protocol.md`, `references/html-native-light-protocol.md`, `references/premium-ui-stack.md`
