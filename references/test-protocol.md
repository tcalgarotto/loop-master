# Test Protocol — `/lucy test`

Geração automática de testes para features implementadas. Cobre unit, integração e E2E.
Integra com o DoD do competitive-intelligence.md (critérios 3 e 4 para `1.x.x`).

---

## Quando usar

- Após implementar uma feature (`/lucy build` ou tick de `implement`)
- Antes de gate de fase (`/lucy audit`)
- Como pre-check de deploy (`/lucy deploy` chama internamente)
- Manualmente: `/lucy test`

---

## Modos

| Comando | Pipeline |
|---------|----------|
| `/lucy test` | Detecta stack → gera testes → executa → relatório |
| `/lucy test --ci` | Modo silencioso para pipelines CI (exit 1 se falhar) |
| `/lucy test --unit` | Só testes unitários |
| `/lucy test --e2e` | Só testes E2E (requer Playwright ou Cypress) |
| `/lucy test --feature LUCY-007` | Testa uma feature específica do gap matrix |
| `/lucy test --coverage` | Relatório de cobertura por arquivo |

---

## Fase 0 — Detecção de stack de testes

```bash
# Ordem de detecção
1. package.json → scripts.test, devDependencies
   - vitest → usar vitest
   - jest → usar jest
   - playwright → disponível para E2E
   - cypress → disponível para E2E

2. Se nenhum configurado → instalar vitest (recomendado para Next.js/Vite)
   npm install -D vitest @testing-library/react @testing-library/user-event jsdom

3. E2E: se Playwright não instalado e projeto tem UI → oferecer instalar
   npm install -D @playwright/test && npx playwright install chromium
```

Registrar em `test_config` no JSON de progresso.

---

## Fase 1 — Mapeamento de cobertura

Antes de gerar testes, mapear o que já existe:

```bash
# Listar arquivos de teste existentes
find . -name "*.test.*" -o -name "*.spec.*" | grep -v node_modules

# Mapear funções/rotas sem cobertura
# Para cada arquivo em src/: verificar se existe *.test.* correspondente
```

Gerar `test-coverage-map.md`:
```markdown
| Arquivo | Tem teste? | Cobertura estimada |
|---------|-----------|-------------------|
| src/api/deals.ts | ✅ | ~60% |
| src/components/Pipeline.tsx | ❌ | 0% |
```

---

## Fase 2 — Geração de testes por camada

### Unit tests (funções puras, utils, hooks)

```typescript
// Template para função
describe('nomeDaFuncao', () => {
  it('happy path — caso de uso principal', () => {
    expect(nomeDaFuncao(input)).toBe(expectedOutput)
  })

  it('edge case — input vazio', () => {
    expect(nomeDaFuncao('')).toBe(fallback)
  })

  it('edge case — input inválido', () => {
    expect(() => nomeDaFuncao(null)).toThrow()
  })
})
```

### Integration tests (API routes, Server Actions)

```typescript
// Next.js App Router — Server Action
import { createServer } from 'http'
import { testApiHandler } from 'next-test-api-route-handler'

it('POST /api/deals — cria deal com dados válidos', async () => {
  await testApiHandler({
    appHandler: import('./app/api/deals/route'),
    test: async ({ fetch }) => {
      const res = await fetch({ method: 'POST', body: JSON.stringify({ title: 'Deal 1' }) })
      expect(res.status).toBe(201)
    }
  })
})

it('POST /api/deals — rejeita sem auth', async () => {
  // 401 sem token
})
```

### E2E tests (Playwright — fluxos críticos)

```typescript
// Padrão para feature do gap matrix
import { test, expect } from '@playwright/test'

test.describe('LUCY-007 — Pipeline visual', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login')
    await page.fill('[data-testid="email"]', process.env.TEST_EMAIL!)
    await page.fill('[data-testid="password"]', process.env.TEST_PASSWORD!)
    await page.click('[data-testid="submit"]')
    await page.waitForURL('/dashboard')
  })

  test('happy path — arrastar card entre colunas', async ({ page }) => {
    await page.goto('/pipeline')
    const card = page.locator('[data-testid="deal-card"]').first()
    const target = page.locator('[data-testid="column-won"]')
    await card.dragTo(target)
    await expect(target.locator('[data-testid="deal-card"]')).toBeVisible()
  })

  test('edge case — coluna vazia exibe estado vazio', async ({ page }) => {
    await page.goto('/pipeline?empty=true')
    await expect(page.locator('[data-testid="empty-state"]')).toBeVisible()
  })
})
```

---

## Fase 3 — Execução e relatório

```bash
# Executar suite
npx vitest run --reporter=verbose 2>&1 | tee .lucy/test-results.txt

# E2E
npx playwright test --reporter=list 2>&1 | tee .lucy/e2e-results.txt
```

Gerar `test-report.md`:

```markdown
## Test Report — <projeto> — YYYY-MM-DD

### Resumo
| Suite | Total | ✅ Pass | ❌ Fail | ⏭ Skip |
|-------|-------|---------|---------|---------|
| Unit | 42 | 40 | 2 | 0 |
| E2E | 8 | 8 | 0 | 0 |

### Falhas
| Teste | Erro | Arquivo |
|-------|------|---------|
| ...   | ...  | ...     |

### Cobertura por feature (gap matrix)
| ID | Feature | Testes | Status DoD #3/#4 |
|----|---------|--------|-----------------|
| LUCY-007 | Pipeline visual | 3 unit + 2 E2E | ✅ |
```

---

## Integração com DoD

Quando `/lucy test` passa para uma feature:
- Atualizar `audit-log.md`: critérios 3 e 4 do DoD marcados
- Feature pode avançar para `1.x.x` se demais critérios atendidos

```json
// Em session-state.json (competitive-intelligence)
"test_coverage": {
  "LUCY-007": { "unit": 3, "e2e": 2, "all_pass": true }
}
```

---

## Configuração recomendada

### `vitest.config.ts`
```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    coverage: {
      reporter: ['text', 'lcov'],
      exclude: ['node_modules/', '.next/']
    }
  }
})
```

### `playwright.config.ts`
```typescript
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  use: {
    baseURL: process.env.TEST_BASE_URL || 'http://localhost:3000',
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure'
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }]
})
```

---

## Anti-padrões

- Gerar testes que sempre passam sem validar nada real
- Mockar tudo no E2E (deve usar ambiente real ou staging)
- Testes sem `data-testid` explícito (frágeis a mudanças de UI)
- Ignorar falhas de teste no gate de deploy
- Testar implementação em vez de comportamento
