# HubFU — Componentes

Especificação extraída de `preview/hubfu-landing-premium.html`. Classes CSS = contrato até port Next/shadcn.

---

## Nav (`.nav`)

| Propriedade | Valor |
|-------------|-------|
| Position | `fixed`, `z-index: 100` |
| Height inner | `52px` |
| Background | `var(--hubfu-nav-bg)` + blur |
| Border | transparent → `var(--hubfu-line)` quando `.scrolled` |

**Filhos:** `.logo`, `.nav-links a`, `.link-btn`, `.theme-toggle`

**Breakpoint:** links visíveis `@media (min-width: 900px)`.

---

## Buttons (`.link-btn`)

| Variante | Background | Color | Border |
|----------|------------|-------|--------|
| Default | `var(--hubfu-btn-primary-bg)` | `#fff` / dark: `#0a0a0b` | none |
| `.outline` | transparent | `var(--hubfu-fg)` | `inset 0 0 0 1px var(--hubfu-line)` |

| Estado | Comportamento |
|--------|---------------|
| `:hover` | `opacity: .88` (filled) / `bg-alt` (outline) |
| `:active` | `transform: scale(.98)` |

Padding: `8px 16px` · Radius: `980px` · Font: `.8125rem / 500`.

---

## Hero

| Elemento | Classe | Notas |
|----------|--------|-------|
| Kicker | `.hero-kicker` | Accent, uppercase, `.75rem` |
| Title | `h1` + `em` | Serif italic no destaque |
| Sub | `.hero-sub` | `fg-secondary`, max 42ch |
| Actions | `.hero-actions` | Flex gap 14px |
| Meta | `.hero-meta` | Counters + labels terciários |

**Device mock (`.device`):** superfície escura fixa — não inverte com tema landing.

| Parte | Background |
|-------|------------|
| Frame | `#1c1c1e` |
| Bar | `#2c2c2e` |
| UI gradient | `#161618 → #0d0d0f` |
| Main text | `#f5f5f7` |

---

## Kanban

### Coluna (`.kanban-col`)

Dark UI (device/tab/feature dark):
- `background: rgba(255,255,255,.02–.03)`
- `border: 1px solid rgba(255,255,255,.05–.1)`
- Head: uppercase micro label

Light variant (`.feature-visual.light`):
- Col: `rgba(29,29,31,.025)` + dashed border
- Dark theme landing: overrides em `hubfu-design-tokens.css`

### Deal card (`.deal-card`)

| Estado | Border | Background |
|--------|--------|------------|
| Default | `rgba(255,255,255,.06)` | `rgba(255,255,255,.04)` |
| `:hover` | lift `-3px`, shadow | — |
| `.selected` | `rgba(52,211,153,.5)` | `rgba(52,211,153,.08)` |
| `.dragging` | — | `opacity .55`, scale `.98` |
| `.drag-over` (col) | emerald border | emerald tint |

**Filhos:** `.avatar`, `.deal-name`, `.deal-amt`, `.prob-bar` / `.prob-fill`, `.deal-meta`, `.deal-advance`

Prob fill gradient: `#0a7f5c → #34d399`.

---

## Integrações

### Carousel (`.integrations`)

Faixa horizontal com `.int-carousel` + `.int-track` (CSS animation `intScroll 90s`).

**Pill (`.int-pill`):** 64×64 circle, logo 32px, hover lift.

### Marketplace (`.int-marketplace`)

Sempre superfície escura (`--hubfu-mp-bg`). Sidebar `.int-mp-sidebar`:

| Item | Classe | Estado ativo |
|------|--------|--------------|
| Filtro | `.int-mp-cat` | `.on` — light: white tint; dark landing: emerald tint |
| Busca | `.int-mp-search` | Input escuro |
| Paginação | `.int-mp-page-btn` | disabled `opacity .35` |

### Integration card v2 (`.int-v2-card`) — MeetGeek marketplace

Grid responsivo em superfície clara (`--hubfu-mp-surface`). **Canônico** para marketplace e settings.

| Breakpoint | Colunas |
|------------|---------|
| ≥1280px | 3 |
| 768–1279px | 2 |
| &lt;768px | 1 |

**Regra P0 — tamanho uniforme:** `.int-v2-grid` / `.int-mp-grid` usam `grid-auto-rows: 1fr` + cards com `height: 100%`. Cada card na mesma linha tem **largura e altura idênticas**, independente do conteúdo (Conectado vs Conectar vs footer dual Zapier).

| Filho | Função |
|-------|--------|
| `.int-v2-meta` | Slot fixo no topo (placeholder `&nbsp;` se vazio) |
| `.int-v2-grid-icon` | Ícone 2×2 roxo canto superior direito |
| `.int-v2-logo` | Logo 52px — altura fixa |
| `.int-v2-name` | Nome do serviço, 1 linha ellipsis |
| `.int-v2-desc` | Descrição 2 linhas (`line-clamp: 2`) + `min-height` |
| `.int-v2-foot` | Slot fixo 56px no rodapé (`margin-top: auto`) |
| `.int-v2-connected` | Verde + checkmark SVG |
| `.int-v2-connect` | Botão roxo (`--hubfu-action`) + ícone user-plus |
| `.int-v2-foot-dual` | Footer Zapier — mesma altura de slot que `.int-v2-foot` |

Tokens: `--hubfu-int-card-bg`, `--hubfu-int-card-border`, `--hubfu-int-card-shadow`.

### Integration card v1 (`.int-card`) — legado dark

Min-height `200px` · superfície escura marketplace antigo. Manter só para referência histórica.

### Data spreadsheet (`.ds-sheet`) — v2 interativo

Workflow leads/produtos — ref MeetGeek scraper UI. **Implementação:** `preview/hubfu-sheet.js` (`HubfuSheet`).

| Parte | Classe | Notas |
|-------|--------|-------|
| Shell | `.ds-sheet` | Fundo `--hubfu-sheet-bg`, sombra suave |
| Header | `.ds-sheet-header` | Logo duplo + título + créditos pill + lápis + Run roxo + fechar |
| Tab | `.ds-sheet-tab` | Pill com ícone gradiente + paginação visível (`1 / N`) + download CSV |
| Dicas | `.ds-sheet-hint` | Barra acima da grid: editar · redimensionar · Tab |
| Tabela | `.ds-sheet-table` | Row nums sticky, headers sticky, altura de linha uniforme |
| Header col | `.col-label` + `.col-count` | Título bold + contagem menor abaixo |
| Célula ativa | `.cell-active` | Focus ring verde estilo Excel + indicador de edição |
| Resize | `.col-resize-handle` | Visível no hover do header; linha guia `.ds-sheet-resize-guide` ao arrastar |
| Sidebar | `.ds-sheet-sidebar` | 280px · etapas com conectores + toggles Export/Schedule |
| Mini | `.ds-sheet-mini` | Versão compacta (tab CRM landing) — mesma barra de dicas |

**Colunas exemplo (specimen):** URL do perfil, Nome, Localização, Headline, Sobre — com contadores abaixo do header.

**Colunas mini CRM:** Lead, Empresa, Status, Valor.

#### API `HubfuSheet` (vanilla)

```javascript
new HubfuSheet('#ds-sheet-specimen', {
  variant: 'full',           // 'full' | 'mini'
  title: 'Adicionar leads qualificados à planilha',
  credits: 64,
  tabLabel: 'Extrator de resultados',
  pageSize: 12,
  columns: [{ label, count, width, cellClass }],
  rows: [[...]],
  editable: true,
  resizable: true,
  keyboardNav: true,         // setas + Tab entre células
  sidebar: true              // false em mini
});
```

| Comportamento | Detalhe |
|---------------|---------|
| Edição inline | `contenteditable` em `<td>` (exceto `#` row-num) |
| Redimensionar | `mousedown` no handle → linha guia vertical → `mousemove` → largura em `<col>` |
| Paginação | Botões ‹ › + indicador `página / total` no tab bar |
| Dicas UX | Barra `.ds-sheet-hint` renderizada pelo `HubfuSheet` |
| Export | Botão download gera CSV client-side |
| Toggles | Export (verde on) · Agendar (cinza off) |
| Navegação | Tab e setas entre células editáveis |

Framer port: ver `motion.md` § Framer Motion — row insert com `staggerChildren`; HTML preview usa vanilla.

#### Save otimista (v1.3+)

Quando `optimisticSave: true` (default com `editable`):

| Estado | Classe / UI | Comportamento |
|--------|-------------|---------------|
| Editando | `.cell-active` | Valor original guardado no `focus` |
| Salvando | `.row-syncing` na `<tr>` | Dot pulse sutil na linha (300ms debounce) |
| Erro (~5% demo) | `.hubfu-toast--error` | Revert célula + toast "Falha ao salvar — valor revertido" |
| OK | — | Remove indicador; modelo `opts.rows` já atualizado |

Dica UX (`.ds-sheet-hint`): menciona **salvo otimista (instantâneo)**.

**Port Next.js:** [`editable-table.md`](./editable-table.md) — `EditableTable` + `InlineEditCell` + `useOptimistic` + Server Action.  
Snippet: [`snippets/optimistic-leads-table.tsx.example`](./snippets/optimistic-leads-table.tsx.example)  
Protocolo global: [`../../optimistic-inline-edit-protocol.md`](../../optimistic-inline-edit-protocol.md)

---

### EditableTable / InlineEditCell (Next.js)

Componentes alvo do port — **não** existem ainda no app; spec + snippet são a referência.

| Componente | Base shadcn | Padrão |
|------------|-------------|--------|
| `EditableTable` | `Table`, `TableRow`, `TableCell` | `useOptimistic` + lista paginada |
| `InlineEditCell` | `Input` variant ghost / borderless | Double-click → edit; blur/Enter → commit |

**Anti-padrões:** modal por célula · reload full table · save sem rollback.

Ver checklist completo em [`editable-table.md`](./editable-table.md).

---

## Tabs produto (`.tab-bar` + `.tab-panel`)

| Elemento | Comportamento |
|----------|---------------|
| `.tab-btn` | 4 tabs iguais; `.active` bold |
| `.tab-indicator` | 2px bar, GSAP `x` + `scaleX` |
| `.tab-panel` | Device-like dark panel, min-height 480px |

**Scenes:** CRM kanban, ERP stock table, IA chat, FIN bar chart.

### Filter pills (`.filter-pill`)

Pill radius 980px · `.on` → emerald bg.

### Chat (`.chat-ui`)

| Tipo | Estilo |
|------|--------|
| `.msg.user` | `rgba(10,127,92,.35)` |
| `.msg.bot` | `rgba(255,255,255,.06)` |
| `.action-chip` | outline; `.done` strikethrough emerald |

---

## Feature sections (`.feature-section`)

| Variante | Background |
|----------|------------|
| Default | `var(--hubfu-bg)` |
| `.alt` | `var(--hubfu-bg-alt)` |

`.feature-row` grid 1fr/1fr @900px · `.flip` inverte ordem visual.

`.feature-visual` — mock escuro · `.feature-visual.light` — mock claro para contraste ERP.

---

## Pricing (`.pricing`)

**Presente no preview v9** — 3 planos: Starter R$149, Business R$349 (`.featured`), Enterprise sob consulta.

| Elemento | Estilo |
|----------|--------|
| `.pricing-grid` | 1px gap via `background: var(--line)` |
| `.plan` | `bg` padrão |
| `.plan.featured` | `#fff` light / elevated dark + emerald ring |

---

## FAQ (`.faq-item`)

Accordion CSS grid `grid-template-rows: 0fr → 1fr` · icon `+` rotate 45° quando `.open`.

---

## CTA & Footer

`.cta` — headline + dual buttons (mesmo padrão hero).

`footer` — `.75rem` tertiary, links inline.

---

## Preview chrome

`.preview-tag` — fixed bottom-left, badge versão Lucy.

`.theme-toggle` — alterna `data-theme`; ícone ☀/☾.

---

## Checklist port Next.js

- [ ] Mapear `.link-btn` → Button variant `default` / `outline`
- [ ] Kanban → dnd-kit + tokens surface-ui
- [ ] Integration card v2 → `int-v2-card` + Framer hover/tap
- [ ] Data table → `EditableTable` + `InlineEditCell` + `useOptimistic` + Server Action (ver `editable-table.md`)
- [ ] HTML specimen → manter `HubfuSheet` em `preview/` como referência otimista
- [ ] Tabs → Tabs + motion indicator (GSAP ou Framer spring)
- [ ] Import `hubfu-design-tokens.css` em `globals.css`
- [ ] ThemeProvider com `data-theme` + system preference
- [ ] Connect/Run → `--hubfu-action` (roxo); Connected → `--hubfu-success` (verde)
