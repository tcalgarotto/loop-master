# Performance Protocol — `/lucy perf`

Audit de performance: bundle, Core Web Vitals, queries N+1, imagens, cache.

---

## Modos

| Comando | Pipeline |
|---------|----------|
| `/lucy perf` | Audit completo |
| `/lucy perf --bundle` | Só bundle JS/CSS |
| `/lucy perf --backend` | Só queries e latência de API |
| `/lucy perf --cwv` | Só Core Web Vitals |
| `/lucy perf --fix` | Audit + aplica correções automáticas de baixo risco |

---

## Fase 1 — Bundle

```bash
# Análise de bundle Next.js
npm install -D @next/bundle-analyzer
ANALYZE=true npm run build
```

### Thresholds

| Métrica | Alvo | Bloqueador |
|---------|------|-----------|
| Chunk JS inicial | < 100kB gzip | > 300kB |
| Score Lighthouse | > 90 | < 70 |
| LCP | < 2.5s | > 4s |
| CLS | < 0.1 | > 0.25 |

### Checklist de bundle

```
[ ] Reveal-on-scroll e header compact: animation-timeline view()/scroll() — não useScroll por card
[ ] Transições de rota: View Transitions antes de AnimatePresence global
[ ] Popovers leves sem React state desnecessário
[ ] Listas com partial refresh avaliadas para HTMX antes de client component
[ ] Chunk JS inicial < 100kB (gzip)
[ ] Sem bibliotecas duplicadas
[ ] Dynamic imports em rotas pesadas
[ ] Imagens com next/image e lazy loading
[ ] Fontes com next/font (sem FOUT)
```

### Correções automáticas aplicáveis

```typescript
// Dependência pesada → alternativa tree-shakeable
// moment.js (300kB) → date-fns
// chart.js → Tremor Raw (já no stack)
// lodash completo → lodash/get, lodash/set

// priority em imagem above-the-fold (LCP)
<Image src="..." priority={true} alt="..." />
```

---

## Fase 2 — Core Web Vitals

```bash
npx lighthouse $URL --output=json --output-path=.lucy/lighthouse.json \
  --only-categories=performance --chrome-flags="--headless"
```

| Métrica | Bom | Precisa melhorar | Ruim |
|---------|-----|-----------------|------|
| LCP | < 2.5s | 2.5–4s | > 4s |
| INP | < 100ms | 100–300ms | > 300ms |
| CLS | < 0.1 | 0.1–0.25 | > 0.25 |

---

## Fase 3 — Backend: queries N+1

```typescript
// ❌ N+1 — 1 query para lista + 1 por item
const deals = await prisma.deal.findMany()
const withContact = await Promise.all(
  deals.map(d => prisma.contact.findUnique({ where: { id: d.contactId } }))
)

// ✅ 1 query com include
const deals = await prisma.deal.findMany({ include: { contact: true } })
```

### Thresholds de API

| Endpoint | Alvo | Bloqueador |
|---------|------|-----------|
| GET lista | < 200ms | > 1s |
| GET detalhe | < 100ms | > 500ms |
| POST criação | < 300ms | > 2s |

---

## Fase 4 — Cache TanStack Query

```typescript
// ✅ Cache inteligente obrigatório
useQuery({
  queryKey: ['deals'],
  queryFn: fetchDeals,
  staleTime: 30_000,
  gcTime: 5 * 60 * 1000,
  refetchOnWindowFocus: true
})
```

---

## Relatório

```markdown
## Performance Report — <projeto> — YYYY-MM-DD

### Lighthouse
| Métrica | Valor | Status |

### Bundle
| Chunk | Antes | Depois | Redução |

### Queries N+1 encontradas e corrigidas
| Arquivo | Problema | Correção |

### Ações manuais recomendadas
- [ ] ...
```

---

## Anti-padrões

- `useEffect + fetch` sem cache → TanStack Query
- `<img>` sem `next/image`
- Queries sem índice em campos de filtro
- Bundle > 300kB sem code splitting
