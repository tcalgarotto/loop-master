# Protocolo — Edição inline otimista em planilhas densas

**Origem:** `/lucy aprenda` — 2026-07-04 — owner  
**Papel:** planilhas de leads, produtos, clientes e inventário com **UX instantânea** — UI atualiza na hora; persistência em background com rollback em erro.

> Complementa: `html-first-design-protocol.md` · `html-native-light-protocol.md` · `references/design-system/hubfu/editable-table.md`

---

## Quando usar

| Superfície | Exemplos | Por quê |
|------------|----------|---------|
| CRM / leads | Nome, status, valor, owner | Edição celular a celular, alta densidade |
| ERP / estoque | SKU, qty, preço, local | Muitas linhas; modal por célula mata fluxo |
| Catálogo | Produto, categoria, margem | Copy/paste + Tab entre células |
| Ops / filas | Prioridade, SLA, assignee | Feedback imediato reduz ansiedade do operador |

**Não usar** quando cada célula exige validação complexa multi-campo, wizard ou upload — aí modal/drawer com form completo.

---

## Mapa de stack

| Camada | HTML preview (Caminho C) | Port Next.js |
|--------|--------------------------|--------------|
| **Visual** | `HubfuSheet` + `hubfu-design-tokens.css` | shadcn `<Table />` + `<InlineEditCell />` |
| **UI instantânea** | Fila otimista vanilla em `preview/hubfu-sheet.js` | React `useOptimistic` |
| **Persistência** | `fetch` mock debounced 300ms / demo localStorage | Server Action (`"use server"`) |
| **Fallback erro** | Revert célula + toast `.hubfu-toast` | Rollback `useOptimistic` + toast Sonner |
| **Navegação** | Tab + setas entre `contenteditable` | Tab + Enter; double-click → `<Input />` borderless |

### Hook-based design system

Comportamento e visual **juntos** — não só tokens Figma:

- **HTML:** `HubfuSheet` encapsula grid + edição + save queue + indicador `row-syncing`
- **React:** `EditableTable` + `useInlineEdit` (ou inline no componente) + `useOptimistic`
- **HTMX:** `hx-post` por célula com `hx-swap="none"` + indicador CSS — ver § HTMX abaixo

---

## Componentes canônicos

| Componente | Onde | Papel |
|------------|------|-------|
| `HubfuSheet` | `preview/hubfu-sheet.js` | Espécime HTML-first interativo |
| `EditableTable` | Next.js (snippet) | Tabela densa com estado otimista |
| `InlineEditCell` | Next.js (snippet) | Célula: display → double-click → Input borderless |

Ver spec HubFU: [`design-system/hubfu/editable-table.md`](design-system/hubfu/editable-table.md)  
Snippet: [`design-system/hubfu/snippets/optimistic-leads-table.tsx.example`](design-system/hubfu/snippets/optimistic-leads-table.tsx.example)

---

## Pipeline recomendado

```
1. HTML     → HubfuSheet com optimisticSave (owner valida UX)
2. Tokens   → hubfu-design-tokens.css (toast, row-syncing)
3. Port     → EditableTable + useOptimistic + Server Action
4. Gate     → visual-gate na rota Next (não só HTML)
```

---

## HTMX / Invoker Commands — alternativa ultra-leve

Para páginas **sem React** ou admin interno mínimo:

```html
<td contenteditable
    hx-post="/api/leads/42/cell"
    hx-trigger="blur delay:300ms"
    hx-vals='js:{field: "nome", value: event.target.innerText}'
    hx-swap="none"
    hx-indicator="#row-42-sync">
  Ana Ribeiro
</td>
<span id="row-42-sync" class="row-syncing-dot" aria-hidden="true"></span>
```

| Escolher HTMX quando | Escolher React + useOptimistic quando |
|----------------------|---------------------------------------|
| Página mostly static, poucos islands | Dashboard app com shell React existente |
| Time prefere HTML + partials no servidor | DnD, filtros client-side, undo complexo |
| Bundle JS deve ficar &lt; 50 kB | Design system shadcn já no projeto |
| Invoker Commands para modais pontuais | AnimatePresence / layout animations na grid |

Ver também: `html-native-light-protocol.md` § HTMX.

---

## Anti-padrões

| Anti-padrão | Por quê | Correto |
|-------------|---------|---------|
| Modal por célula | Quebra fluxo Tab/copy-paste | Inline edit + blur save |
| Reload da tabela inteira após save | Flash, perde scroll/foco | Atualizar só a célula ou row |
| Sem rollback em erro | Usuário acha que salvou | Revert + toast explícito |
| Spinner full-page por edição | Latência percebida alta | Dot `row-syncing` na linha |
| `useEffect` + fetch manual sem otimismo | UI trava até response | `useOptimistic` ou fila vanilla |
| Server Action síncrona bloqueando UI | INP ruim | Action em background; UI já commitou |

---

## Prompt template (Lucy)

```
Use o padrão EditableTable do design system HubFU:
- HTML-first: HubfuSheet em preview/ com optimisticSave
- Next: shadcn Table + InlineEditCell + useOptimistic + Server Action
- Sem modal por célula; rollback + toast em erro
- Ver references/optimistic-inline-edit-protocol.md
```

---

## Demo local (HTML)

```bash
bash scripts/html-preview-serve.sh
# → http://127.0.0.1:8765/hubfu-design-system.html
# Seção Data spreadsheet — editar célula, blur, ver dot syncing; ~5% falha simulada
```

Opções `HubfuSheet`:

```javascript
new HubfuSheet('#ds-sheet-specimen', {
  optimisticSave: true,   // default quando editable
  saveDebounceMs: 300,
  saveFailRate: 0.05      // demo only — 0 em produção
});
```

---

## Changelog

| Versão | Data | Notas |
|--------|------|-------|
| 1.0 | 2026-07-04 | Protocolo inicial; HubfuSheet optimistic layer; snippet Next.js |
