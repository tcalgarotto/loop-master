# HTML Native Light Protocol — sites leves sem JS desnecessário

**Objetivo:** reduzir bundle JS, melhorar INP/LCP e manter UX premium usando APIs nativas do navegador + HTMX onde couber — **sem abandonar** Framer Motion onde ele entrega valor real.

> Complementa: `references/perf-protocol.md`, `references/premium-ui-stack.md`, `references/design-skills-routing-table.md`

---

## Três camadas (não confundir)

| Camada | O que é | Quando usar |
|--------|---------|-------------|
| **HTML nativo** | `command` / `commandfor`, `<dialog>`, Popover API, `details/summary` | Modais simples, popovers, menus, confirmações — **zero React state** |
| **CSS scroll/view** | `@view-transition`, `animation-timeline: view()`, scrub | Header que encolhe no scroll, cards que surgem, timeline IA, transições de rota — **GPU, 0 JS** |
| **HTMX** | Atributos `hx-get`, `hx-post`, `hx-target`, `hx-swap` | Atualizar **fragmentos** da página via servidor, sem SPA pesado |
| **React + Framer Motion** | Componentes com ciclo de vida React | `layoutId`, AnimatePresence, DnD na árvore React |
| **GSAP** | Timelines, ScrollTrigger, stagger em escala | Abertura CRM em acts, pin+scrub, 50+ itens cascade |

**Regra Lucy:** nativo HTML → CSS scroll/view → CSS hover → GSAP (lógica/scroll) → Framer (React layout) → HTMX parcial onde couber.

---

## 1. Invoker Commands API (`command` / `commandfor`)

Padrão nativo (Chrome 135+, Firefox em rollout) para ligar botão → elemento controlado **sem JavaScript**.

```html
<!-- Modal nativo -->
<dialog id="create-deal">
  <form method="dialog">
    <h2>Novo negócio</h2>
    <!-- campos -->
    <button value="cancel">Cancelar</button>
    <button value="submit">Salvar</button>
  </form>
</dialog>

<button type="button" commandfor="create-deal" command="show-modal">
  Novo negócio
</button>
<button type="button" commandfor="create-deal" command="close">
  Fechar
</button>
```

### Por que isso deixa o sistema mais leve?

| Antes (React) | Depois (nativo) |
|---------------|-----------------|
| `useState`, handlers, portal, focus trap manual | Navegador gerencia top layer, Esc, foco |
| +2–8 kB por modal (lógica + AnimatePresence) | **0 kB** de JS de controle |
| Bugs de a11y comuns | Comportamento acessível por padrão |

### O que muda na prática?

- **Menos código** — elimina boilerplate de abrir/fechar modal.
- **INP melhor** — clique processado no motor nativo (C++), não no bundle React.
- **Manutenção** — HTML declarativo; backend pode devolver o `<dialog>` já preenchido (HTMX).

### Compatibilidade

- Usar `<dialog>` + `command` com **progressive enhancement**.
- Fallback Next.js: componente shadcn `Dialog` só onde `command` não é suportado (feature detect ou `typeof HTMLButtonElement.prototype.command !== 'undefined'`).
- Não quebrar SSR: `<dialog>` é HTML válido; abrir/fechar é client-only nativo.

---

## 2. Popover API

Para tooltips, menus contextuais leves, painéis laterais **não modais**:

```html
<button popovertarget="filters-panel" type="button">Filtros</button>
<div id="filters-panel" popover>
  <!-- filtros -->
</div>
```

**Preferir Popover** em vez de Dropdown React quando: só exibe conteúdo estático ou formulário simples, sem estado global compartilhado.

---

## 3. HTMX — HTML com superpoderes de rede

HTMX (~14 kB gzip) estende HTML para fazer requisições parciais **sem escrever fetch/useEffect**.

```html
<!-- Linha da tabela CRM: clique carrega detalhe na coluna ao lado -->
<tr hx-get="/deals/42/panel" hx-target="#deal-detail" hx-swap="innerHTML">
  <td>Acme Corp</td>
  <td>R$ 120k</td>
</tr>
<div id="deal-detail"></div>
```

### Padrão Next.js + HTMX (híbrido)

| Superfície | Abordagem |
|------------|-----------|
| Shell (sidebar, header, layout) | Next.js App Router + RSC onde possível |
| Listas, inbox, tabelas com refresh parcial | Route Handler `GET /api/fragments/deals` → HTML snippet + HTMX |
| Formulários CRUD simples | `hx-post` + resposta HTML ou `HX-Trigger` |
| Páginas marketing / landing | SSG estático; HTMX opcional |

```tsx
// app/api/fragments/deals/[id]/route.ts
export async function GET(_req: Request, { params }: { params: { id: string } }) {
  const deal = await getDeal(params.id)
  return new Response(renderDealPanelHtml(deal), {
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  })
}
```

**Não substituir** todo o Next.js por HTMX — usar HTMX para **hot spots** que hoje geram `use client` + polling + re-fetch pesado.

---

## 4. Animações — nativo vs Framer Motion

### São compatíveis? Sim, em modelo híbrido.

| Cenário | Solução | Peso |
|---------|---------|------|
| Modal/popover estrutural | CSS `@starting-style` + `transition` no `<dialog>` / `[popover]` | Mínimo |
| Troca de página/fragmento HTMX | View Transitions API (`hx-swap="innerHTML transition:true"`) | Baixo |
| Sidebar spring, stagger de cards, layoutId card→modal | Framer Motion | Médio — **justificado** |
| Gráficos Tremor | Entrada via CSS ou motion leve no wrapper | Médio |

```css
/* Animação nativa em dialog (Chrome 117+) */
dialog {
  transition: opacity 0.2s ease, transform 0.2s ease;
  transform: translateY(8px);
  opacity: 0;
}
dialog[open] {
  opacity: 1;
  transform: translateY(0);
}
@starting-style {
  dialog[open] {
    opacity: 0;
    transform: translateY(8px);
  }
}
```

```tsx
// Híbrido: modal nativo + motion só no conteúdo interno (gráfico, lista)
<dialog id="metrics" className="...">
  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
    <TremorChart ... />
  </motion.div>
</dialog>
```

**Proibido:** Framer Motion para **só** abrir/fechar modal que poderia ser `<dialog command>`.

**Obrigatório:** `prefers-reduced-motion` em CSS nativo e `useReducedMotion()` no motion restante.

---

## 4b. View Transitions (`@view-transition`) — transições cinematográficas

O navegador captura snapshot do estado **antigo** e **novo** da UI e interpola entre eles na GPU — sensação de app nativo ao trocar rotas ou painéis.

### Dois modos

| Modo | API | Caso |
|------|-----|------|
| **Same-document** | `document.startViewTransition(() => updateDOM)` | SPA/Next.js client navigation, swap HTMX |
| **Cross-document** | `@view-transition { navigation: auto; }` em CSS global | MPA, links `<a>` full page (menos comum em App Router) |

### Next.js App Router (padrão Lucy)

```tsx
// lib/view-transition.ts
export function startViewTransition(callback: () => void) {
  if (typeof document !== 'undefined' && 'startViewTransition' in document) {
    ;(document as Document & { startViewTransition: (cb: () => void) => void })
      .startViewTransition(callback)
  } else {
    callback()
  }
}
```

```tsx
// Troca de rota com transição suave (client)
'use client'
import { useRouter } from 'next/navigation'
import { startViewTransition } from '@/lib/view-transition'

startViewTransition(() => router.push('/crm/deals'))
```

```css
/* app/globals.css — transição padrão entre estados */
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 0.25s;
  animation-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Shared element — card CRM que “viaja” até o painel de detalhe */
.deal-card { view-transition-name: deal-card; }
.deal-detail-header { view-transition-name: deal-card; }
```

### HTMX + View Transitions

```html
<div hx-get="/fragments/inbox" hx-target="#main" hx-swap="innerHTML transition:true">
```

Ou evento `htmx:afterSwap` + `startViewTransition` no handler.

### Onde usar no CRM/ERP

- Troca de abas do dashboard (métricas ↔ pipeline)
- Navegação entre módulos com shell persistente
- Abertura de painel lateral que substitui área central

**Não usar** para Kanban drag ou animações que dependem de física de mola em tempo real — aí Framer Motion.

---

## 4c. Scroll-driven animations (`animation-timeline: view`) — scrub

Animação **amarrada ao scroll**, não ao relógio. O usuário “scruba” o progresso: 10% de scroll = 10% da animação; volta o scroll = animação reversa.

### Conceitos

| Propriedade | Função |
|-------------|--------|
| `animation-timeline: view()` | Timeline = visibilidade do elemento no scrollport |
| `animation-range: entry 10% cover 40%` | Início/fim do efeito relativo à entrada na viewport |
| `animation-timeline: scroll()` | Timeline = posição de scroll de um container |
| **Scrub** | Progresso 1:1 com scroll — congela se o usuário parar |

### CSS canônico (card premium)

```css
@keyframes surgir {
  from {
    opacity: 0;
    transform: translateY(50px) scale(0.9);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.card-premium-scrub {
  animation: surgir linear both;
  animation-timeline: view();
  animation-range: entry 10% cover 40%;
}

@media (prefers-reduced-motion: reduce) {
  .card-premium-scrub {
    animation: none;
    opacity: 1;
    transform: none;
  }
}
```

### Tailwind (arbitrary properties)

```tsx
<div
  className={cn(
    'rounded-2xl border bg-card p-6',
    '[animation:card-surgir_linear_both]',
    '[animation-timeline:view()]',
    '[animation-range:entry_10%_cover_40%]',
    'motion-reduce:animate-none motion-reduce:opacity-100'
  )}
/>
```

Registrar keyframes em `tailwind.config.ts` ou `globals.css`:

```css
@theme {
  --animate-card-surgir: card-surgir linear both;
}
@keyframes card-surgir {
  from { opacity: 0; transform: translateY(2rem) scale(0.95); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}
```

### Casos CRM / ERP / IA (premium sem JS)

| Superfície | Efeito scrub |
|------------|--------------|
| **Header dashboard** | `animation-timeline: scroll()` no root — encolhe, opacidade, `backdrop-blur` conforme rola extrato |
| **Cards de métricas** | `view()` + `entry` — surgem com scale/opacity ao entrar na viewport |
| **Timeline de conversas IA** | Linha vertical `scaleY` ligada a `view()` no container do histórico |
| **Landing / marketing** | Seções que revelam conteúdo no scroll — substitui `useScroll` + motion |

### Header estilo Apple (scroll root)

```css
.dashboard-header {
  position: sticky;
  top: 0;
  z-index: 40;
  animation: header-compact linear both;
  animation-timeline: scroll(nearest block);
  animation-range: 0px 120px;
}

@keyframes header-compact {
  from {
    padding-block: 1.25rem;
    background: transparent;
  }
  to {
    padding-block: 0.5rem;
    background: color-mix(in oklab, var(--background) 80%, transparent);
    backdrop-filter: blur(12px);
  }
}
```

### View Transitions vs scroll scrub vs Framer Motion

| Efeito | Ferramenta | JS |
|--------|------------|-----|
| Troca de página/painel | `@view-transition` / `startViewTransition` | Mínimo (1 helper) |
| Reveal no scroll, header compact | `animation-timeline: view()` / `scroll()` | **0** |
| Sidebar spring, layoutId, drag | Framer Motion | Sim — justificado |
| `useScroll` + `useTransform` em 20 cards | **Substituir** por CSS scrub | Economia grande |

**Para scroll e transições de rota: preferir CSS nativo.** Ganho: compositor/GPU, sem listeners `scroll` no main thread, bundle menor.

### Compatibilidade e fallback

- Chrome 115+, Edge 115+, Safari 18+ (scroll-driven); View Transitions amplamente suportados em Chromium.
- Feature query:

```css
@supports (animation-timeline: view()) {
  .card-premium-scrub { /* scrub ativo */ }
}
@supports not (animation-timeline: view()) {
  .card-premium-scrub { opacity: 1; transform: none; } /* estado final estático */
}
```

- Nunca bloquear conteúdo se API ausente — progressive enhancement obrigatório.

---

## 5. Matriz de decisão Lucy (implement)

```
Nova superfície UI?
├─ Confirmação / alerta / form simples em overlay?
│  └─ SIM → <dialog> + command/commandfor (ou shadcn Dialog só com fallback)
├─ Menu, filtros, dica contextual flutuante?
│  └─ SIM → Popover API ou shadcn Popover (wrapper fino)
├─ Troca de rota ou painel inteiro (fade/slide/morph)?
│  └─ SIM → @view-transition / startViewTransition (antes de AnimatePresence global)
├─ Animação ligada ao scroll (cards, header, timeline)?
│  └─ SIM → animation-timeline: view() ou scroll() — scrub, 0 JS
├─ Atualizar lista/célula sem navegar?
│  └─ SIM → HTMX fragment + Route Handler HTML (+ transition:true se swap grande)
├─ Drag Kanban, reorder, layoutId mágico no React?
│  └─ SIM → Framer Motion
├─ Timeline multi-step, stagger 20+, ScrollTrigger pin/scrub?
│  └─ SIM → GSAP (gsap-premium-protocol) — sem transition-* no elemento
├─ Hover/active isolado (botão, card lift)?
│  └─ SIM → CSS transition apenas — GSAP não precisa saber
└─ Dúvida?
   └─ Default CSS nativo → HTMX; medir bundle antes de use client
```

---

## 6. Checklist `/lucy perf` — peso de UI

```
[ ] Modais CRUD usam <dialog>+command OU shadcn com justificativa no ADR
[ ] Popovers leves não usam useState só para toggle visível
[ ] Transições de rota/painel usam View Transitions antes de wrapper motion global
[ ] Reveal-on-scroll usa animation-timeline: view() — não useScroll+motion por card
[ ] Header sticky compact usa scroll() timeline — não listener scroll em JS
[ ] Listas com refresh parcial avaliadas para HTMX (antes de useQuery + skeleton chain)
[ ] Cada "use client" novo tem motivo documentado (1 linha no componente)
[ ] Chunk inicial < 100kB gzip (perf-protocol)
[ ] View Transitions em swaps HTMX quando troca de painel inteiro
[ ] Framer Motion reservado para motion interativo (sidebar spring, layoutId, DnD)
[ ] prefers-reduced-motion em CSS nativo E framer-motion
[ ] @supports fallback para animation-timeline onde scrub é crítico
```

---

## 7. Anti-patterns

| ❌ Evitar | ✅ Preferir |
|-----------|-------------|
| `useState` + `onClick` só para abrir modal | `commandfor` + `<dialog>` |
| React Query refetch de página inteira para 1 linha | `hx-get` + swap `outerHTML` |
| Framer `AnimatePresence` em todo dropdown | Popover API + CSS |
| `useScroll` + `motion` em cada card da lista | `animation-timeline: view()` scrub |
| `useEffect` + `window.scrollY` para header | `animation-timeline: scroll()` no header |
| HTMX em app 100% interativo (Kanban DnD) | React DnD + motion no board |
| Duplicar: modal nativo E Dialog React no mesmo fluxo | Um caminho canônico + fallback |

---

## 8. Pacotes opcionais (só se HTMX adotado)

```bash
npm install htmx.org
```

```tsx
// app/layout.tsx — carregar uma vez
import Script from 'next/script'
<Script src="https://unpkg.com/htmx.org@2.0.4" strategy="lazyOnload" />
```

Ou Server Components puros sem HTMX quando RSC + forms Server Actions bastam.

---

## Resumo executivo

- **HTML nativo** = menos JS, melhor a11y, resposta instantânea em modais/popovers simples.
- **CSS view/scroll** = transições de rota e scrub no scroll na GPU — visual premium sem Framer em listas/header.
- **HTMX** = ERP/CRM leve com atualizações parciais sem inflar o bundle React.
- **Framer Motion** = mantido para **interação** (springs, layoutId, DnD) onde CSS timeline não compete.
- Lucy deve **auditar cada `use client` e cada `useScroll`** e aplicar esta matriz antes de implementar UI nova.
