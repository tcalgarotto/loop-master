# Docs Protocol — `/lucy docs`

Geração automática de documentação técnica por fase: API, componentes, decisões de arquitetura e changelog.

---

## Modos

| Comando | Pipeline |
|---------|----------|
| `/lucy docs` | Gera documentação completa do projeto |
| `/lucy docs --api` | Só documenta rotas de API |
| `/lucy docs --components` | Só documenta componentes React |
| `/lucy docs --changelog` | Gera/atualiza CHANGELOG.md |
| `/lucy docs --adr` | Registra decisão de arquitetura (ADR) |

---

## Fase 1 — Documentação de API

### Geração automática de OpenAPI/Swagger

```bash
# Para Next.js App Router: detectar rotas em app/api/
find app/api -name "route.ts" | head -20

# Instalar se necessário
npm install -D swagger-jsdoc swagger-ui-react
```

### Template de rota documentada

```typescript
/**
 * @swagger
 * /api/deals:
 *   get:
 *     summary: Lista todos os negócios do usuário autenticado
 *     tags: [Deals]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema: { type: string, enum: [open, won, lost] }
 *     responses:
 *       200:
 *         description: Lista de negócios
 *       401:
 *         description: Não autenticado
 */
export async function GET(request: Request) { ... }
```

### Saída gerada

- `docs/api/openapi.json` — spec completa
- `docs/api/README.md` — tabela de rotas legível

```markdown
## API Reference

| Método | Rota | Auth | Descrição |
|--------|------|------|-----------|
| GET | /api/deals | ✅ | Lista negócios |
| POST | /api/deals | ✅ | Cria negócio |
```

---

## Fase 2 — Documentação de Componentes

Gerar `docs/components/README.md` a partir dos arquivos em `src/components/`:

```markdown
## Componentes

### `<PipelineBoard />`
**Arquivo:** `src/components/Pipeline/PipelineBoard.tsx`
**Descrição:** Board visual de negócios com colunas arrastar-e-soltar.

**Props:**
| Prop | Tipo | Obrigatório | Descrição |
|------|------|-------------|-----------|
| deals | Deal[] | ✅ | Lista de negócios |
| onMove | (id, stage) => void | ✅ | Callback ao mover |

**Uso:**
\`\`\`tsx
<PipelineBoard deals={deals} onMove={handleMove} />
\`\`\`
```

---

## Fase 3 — Architecture Decision Records (ADR)

Para cada decisão técnica importante tomada durante o loop:

```markdown
# ADR-001 — TanStack Query para cache de dados

**Data:** YYYY-MM-DD
**Status:** Aceito

## Contexto
O sistema precisava de cache client-side para evitar re-fetch a cada navegação.

## Decisão
Usar TanStack Query com staleTime de 30s.

## Consequências
- ✅ Zero spinner em navegação interna
- ✅ Refetch automático em foco de janela
- ⚠️ Estado deve ser invalidado explicitamente após mutações
```

Salvar em `docs/adr/ADR-NNN-titulo.md`.

---

## Fase 4 — CHANGELOG automático

Gerar/atualizar `CHANGELOG.md` baseado nos gates de fase concluídos:

```markdown
# Changelog

## [Unreleased]

## [1.2.0] — YYYY-MM-DD
### Added
- Pipeline visual com drag-and-drop (LUCY-007)
- Filtros por status e responsável (LUCY-012)

### Fixed
- Contagem de negócios com bug no timezone (LUCY-003)

### Security
- Rate limiting adicionado em /api/auth (detectado em review-security)
```

---

## Fase 5 — README do projeto

Gerar/atualizar `README.md` do projeto (não da skill Lucy):

```markdown
# <Nome do Projeto>

> <tagline de 1 linha>

## Stack
- Next.js 15 (App Router)
- shadcn/ui + Tailwind CSS
- Prisma + PostgreSQL
- TanStack Query

## Setup
\`\`\`bash
npm install
cp .env.example .env.local
npm run dev
\`\`\`

## Estrutura
\`\`\`
src/
├── app/          # Rotas Next.js
├── components/   # Componentes React
├── lib/          # Utilitários e config
└── hooks/        # React Hooks customizados
\`\`\`

## Rotas de API
Ver docs/api/README.md

## Testes
\`\`\`bash
npm run test        # Unit + Integration
npm run test:e2e    # Playwright E2E
\`\`\`
```

---

## Integração com o loop

Ao fechar gate de fase, Lucy gera automaticamente:
1. Entradas no CHANGELOG para features do gate
2. ADR para cada decisão arquitetural registrada no loop
3. Atualiza tabela de API se houve novas rotas

```json
// No progress JSON
"docs_generated": {
  "api": true,
  "components": false,
  "changelog_version": "1.2.0",
  "adrs": ["ADR-001", "ADR-002"]
}
```

---

## Anti-padrões

- Documentação gerada sem revisão antes de publicar
- ADR sem "Consequências" (a parte mais importante)
- CHANGELOG com mensagens de commit cruas (não legíveis)
- API sem exemplos de request/response
