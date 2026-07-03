# i18n Protocol — `/lucy i18n`

Internacionalização automática: detecta strings hardcoded, extrai para dicionário e configura o pipeline de tradução.

---

## Modos

| Comando | Pipeline |
|---------|----------|
| `/lucy i18n` | Detecta stack → extrai strings → configura i18n |
| `/lucy i18n --scan` | Só lista strings hardcoded (não altera código) |
| `/lucy i18n --add pt-BR en-US` | Adiciona locales ao projeto existente |
| `/lucy i18n --sync` | Sincroniza chaves entre arquivos de locale |

---

## Fase 0 — Detecção de stack i18n

```bash
# Verificar se já tem i18n configurado
grep -r "next-intl\|react-i18next\|i18next\|next-i18n-router" package.json

# Se não tem: instalar next-intl (padrão para Next.js App Router)
npm install next-intl
```

### Stack recomendada

| Projeto | Lib recomendada |
|---------|----------------|
| Next.js App Router | `next-intl` |
| React SPA | `react-i18next` |
| Node.js backend | `i18next` |

---

## Fase 1 — Scan de strings hardcoded

Varrer arquivos `.tsx`, `.ts`, `.jsx`, `.js`:

```bash
# Padrões a detectar
# 1. Strings em JSX: >Texto em português<
# 2. Props de texto: placeholder="Nome completo"
# 3. Strings em JS: toast.success("Salvo com sucesso")
# 4. aria-label: aria-label="Fechar modal"

# Gerar relatório
grep -rn '"[A-Za-zÀ-ú ]\{5,\}"' src/ --include="*.tsx" | head -50
```

Gerar `.lucy/i18n-strings.md`:

```markdown
| Arquivo | Linha | String | Chave sugerida |
|---------|-------|--------|----------------|
| src/components/Pipeline.tsx | 42 | "Adicionar negócio" | pipeline.addDeal |
| src/app/dashboard/page.tsx | 18 | "Receita total" | dashboard.totalRevenue |
```

---

## Fase 2 — Configuração next-intl

```typescript
// next.config.ts
import createNextIntlPlugin from 'next-intl/plugin'
const withNextIntl = createNextIntlPlugin()
export default withNextIntl({ /* config */ })
```

```typescript
// src/i18n/request.ts
import { getRequestConfig } from 'next-intl/server'

export default getRequestConfig(async ({ locale }) => ({
  messages: (await import(`../../messages/${locale}.json`)).default
}))
```

```
messages/
├── pt-BR.json   ← locale padrão (todas as chaves)
├── en-US.json   ← inglês (gerado automaticamente)
└── es-ES.json   ← espanhol (opcional)
```

---

## Fase 3 — Extração automática

Para cada string detectada:

1. Gerar chave semântica (ex: `pipeline.addDeal`)
2. Substituir no código:

```tsx
// Antes
<Button>Adicionar negócio</Button>

// Depois
import { useTranslations } from 'next-intl'
const t = useTranslations('pipeline')
<Button>{t('addDeal')}</Button>
```

3. Adicionar ao `messages/pt-BR.json`:

```json
{
  "pipeline": {
    "addDeal": "Adicionar negócio",
    "emptyState": "Nenhum negócio encontrado"
  }
}
```

---

## Fase 4 — Geração de tradução base

Gerar `messages/en-US.json` com traduções automáticas de baixa fidelidade
(marcar com `[REVIEW]` para revisão humana):

```json
{
  "pipeline": {
    "addDeal": "[REVIEW] Add deal",
    "emptyState": "[REVIEW] No deals found"
  }
}
```

> ⚠️ Traduções automáticas precisam de revisão antes de ir para produção.

---

## Fase 5 — Sync de chaves

Detectar chaves presentes em `pt-BR.json` mas ausentes em outros locales:

```bash
# Comparar chaves entre arquivos
node -e "
  const ptBR = require('./messages/pt-BR.json')
  const enUS = require('./messages/en-US.json')
  // deep diff keys
"
```

Relatório `.lucy/i18n-missing-keys.md`:

```markdown
## Chaves faltando em en-US.json
- pipeline.deleteConfirm
- settings.dangerZone.title
```

---

## Anti-padrões

- Chaves genéricas: `button1`, `text_2` — usar chaves semânticas
- Tradução hardcoded no código (`{lang === 'en' ? 'Add' : 'Adicionar'}`)
- Strings de erro sem i18n (são as mais críticas para internacionalização)
- Deploy sem revisar strings marcadas com `[REVIEW]`
