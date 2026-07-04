# HubFU — EditableTable / InlineEditCell

**Espécime HTML:** `preview/hubfu-sheet.js` (`HubfuSheet`)  
**Catálogo visual:** `preview/hubfu-design-system.html` § Data spreadsheet  
**Port Next.js:** `snippets/optimistic-leads-table.tsx.example`  
**Protocolo global:** [`../../optimistic-inline-edit-protocol.md`](../../optimistic-inline-edit-protocol.md)

---

## Visão geral

Planilha densa estilo Excel/MeetGeek scraper — edição inline, navegação Tab, redimensionamento de colunas e **save otimista** (UI instantânea, persistência debounced).

```
HubfuSheet (vanilla)  ──port──►  EditableTable (React)
     │                                │
     ├─ .ds-sheet-table               ├─ shadcn Table
     ├─ contenteditable td            ├─ InlineEditCell → Input borderless
     ├─ row-syncing dot               ├─ useOptimistic
     └─ hubfu-toast on error          └─ Server Action + Sonner toast
```

---

## HubfuSheet → EditableTable (mapeamento)

| HubfuSheet (HTML) | EditableTable (Next) | Notas |
|-------------------|----------------------|-------|
| `.ds-sheet-table` | `<Table />` shadcn | Sticky header + row nums |
| `td[data-editable]` | `<InlineEditCell />` | Double-click ou foco → Input |
| `.cell-active` | `ring` + Input focus | Focus ring verde `--hubfu-success` |
| `.row-syncing` | `opacity` + pulse dot na row | Durante Server Action pendente |
| `.ds-sheet-hint` | `<Alert variant="muted">` ou caption | Copy UX otimista |
| `bindCellEdit` blur | `onSave` → `startTransition` + action | Debounce 300ms recomendado |
| `exportCsv()` | Server export ou client CSV | Mantém botão download no tab bar |
| `optimisticSave` option | `useOptimistic(leads, reducer)` | Mesma semântica |

---

## InlineEditCell — contrato

| Estado | UI | Interação |
|--------|-----|-----------|
| **Display** | Texto truncado, hover sutil | Single click seleciona row; double-click edita |
| **Editing** | `<Input variant="ghost" />` borderless, full cell | Enter/blur commit; Esc revert local |
| **Saving** | Row com `.row-syncing` | Não bloquear outras células |
| **Error** | Valor revertido + toast | Mensagem: "Falha ao salvar — valor revertido" |

### Props sugeridas (React)

```typescript
type InlineEditCellProps = {
  value: string;
  rowId: string;
  field: string;
  onCommit: (rowId: string, field: string, value: string) => void;
  className?: string;
};
```

---

## EditableTable — contrato

```typescript
type EditableTableProps<T extends { id: string }> = {
  columns: ColumnDef<T>[];
  data: T[];
  onCellSave: (rowId: string, field: keyof T, value: string) => Promise<void>;
  pageSize?: number;
};
```

**Comportamentos obrigatórios:**

1. `useOptimistic` espelha mudanças antes da action resolver
2. Server Action valida + persiste; retorna `{ ok: boolean }` ou throw
3. Erro → reducer reverte + toast
4. Tab navega células editáveis na ordem visual
5. Colunas redimensionáveis: opcional v2 (HTML já tem; port com `@tanstack/react-table` column resize)

---

## Tokens e CSS

| Token / classe | Uso |
|----------------|-----|
| `--hubfu-sheet-bg` | Fundo da planilha |
| `--hubfu-success` | Focus ring célula ativa |
| `.row-syncing` | Indicador pulse na `<tr>` |
| `.hubfu-toast-host` | Container fixed bottom-right |
| `.hubfu-toast--error` | Toast de rollback |

Definidos em `preview/hubfu-design-tokens.css`.

---

## API HubfuSheet (otimista)

```javascript
new HubfuSheet('#selector', {
  editable: true,
  optimisticSave: true,    // default true quando editable
  saveDebounceMs: 300,
  saveFailRate: 0.05       // só demo HTML — usar 0 em prod
});
```

| Evento | Comportamento |
|--------|---------------|
| `focus` | Guarda valor original; `.cell-active` |
| `blur` | Atualiza `opts.rows` imediatamente; agenda save mock |
| save OK | Remove `.row-syncing` |
| save fail (~5% demo) | Revert DOM + modelo + toast |

---

## Checklist port Next.js

- [ ] Copiar snippet `optimistic-leads-table.tsx.example` para `components/crm/`
- [ ] Server Action `updateLeadCell(id, field, value)` com Zod
- [ ] `revalidatePath` ou tag cache após save
- [ ] Sonner toast em erro (espelhar copy HubFU)
- [ ] Manter `preview/hubfu-sheet.js` como referência aprovada
- [ ] Visual gate na rota `/crm/leads` ou equivalente

---

## Changelog

| Versão | Data | Notas |
|--------|------|-------|
| 1.0 | 2026-07-04 | Spec EditableTable; mapeamento HubfuSheet → Next; optimistic layer |
