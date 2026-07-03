# HTML Native Light Protocol — sites leves sem JS desnecessário

**Objetivo:** reduzir bundle JS, melhorar INP/LCP e manter UX premium usando APIs nativas do navegador + HTMX onde couber — **sem abandonar** Framer Motion onde ele entrega valor real.

> Complementa: `references/perf-protocol.md`, `references/premium-ui-stack.md`, `references/design-skills-routing-table.md`

---

## Três camadas (não confundir)

| Camada | O que é | Quando usar |
|--------|---------|-------------|
| **HTML nativo** | `command` / `commandfor`, `<dialog>`, Popover API, `details/summary` | Modais simples, popovers, menus, confirmações — **zero React state** |
| **HTMX** | Atributos `hx-get`, `hx-post`, `hx-target`, `hx-swap` | Atualizar **fragmentos** da página via servidor, sem SPA pesado |
| **React + Framer Motion** | Componentes com ciclo de vida React | Dashboards complexos, drag-and-drop, `layoutId`, gráficos animados, listas reordenáveis |

**Regra Lucy:** preferir nativo → HTMX parcial → React só onde o nativo não resolve.

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

## 5. Matriz de decisão Lucy (implement)

```
Nova superfície UI?
├─ Confirmação / alerta / form simples em overlay?
│  └─ SIM → <dialog> + command/commandfor (ou shadcn Dialog só com fallback)
├─ Menu, filtros, dica contextual flutuante?
│  └─ SIM → Popover API ou shadcn Popover (wrapper fino)
├─ Atualizar lista/célula sem navegar?
│  └─ SIM → HTMX fragment + Route Handler HTML
├─ Drag Kanban, reorder, layoutId mágico, chart animado?
│  └─ SIM → React client + Framer Motion
└─ Dúvida?
   └─ Default nativo/HTMX; medir bundle antes de adicionar use client
```

---

## 6. Checklist `/lucy perf` — peso de UI

```
[ ] Modais CRUD usam <dialog>+command OU shadcn com justificativa no ADR
[ ] Popovers leves não usam useState só para toggle visível
[ ] Listas com refresh parcial avaliadas para HTMX (antes de useQuery + skeleton chain)
[ ] Cada "use client" novo tem motivo documentado (1 linha no componente)
[ ] Chunk inicial < 100kB gzip (perf-protocol)
[ ] View Transitions em swaps HTMX quando troca de painel inteiro
[ ] Framer Motion reservado para motion de produto (sidebar, stagger, layoutId)
[ ] prefers-reduced-motion em CSS nativo E framer-motion
```

---

## 7. Anti-patterns

| ❌ Evitar | ✅ Preferir |
|-----------|-------------|
| `useState` + `onClick` só para abrir modal | `commandfor` + `<dialog>` |
| React Query refetch de página inteira para 1 linha | `hx-get` + swap `outerHTML` |
| Framer `AnimatePresence` em todo dropdown | Popover API + CSS |
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
- **HTMX** = ERP/CRM leve com atualizações parciais sem inflar o bundle React.
- **Framer Motion** = mantido para **movimento de produto** onde nativo não compete.
- Lucy deve **auditar cada `use client`** e aplicar esta matriz antes de implementar UI nova.
