# HubFU Design System

Design system extraído de `preview/hubfu-landing-premium.html` (v9 — light canonical). Tokens reutilizáveis em Penpot, Next.js e futuros previews HTML.

## Referência visual canônica (HTML-first)

> **O catálogo HTML é a fonte de verdade visual.** Markdown documenta; o owner **vê** tokens, gradientes, bordas e componentes no navegador.

| Artefato | Caminho | Papel |
|----------|---------|-------|
| **Showcase DS** | `preview/hubfu-design-system.html` | **Canônico visual** — swatches, componentes vivos, light/dark |
| Tokens CSS | `preview/hubfu-design-tokens.css` | Variáveis `--hubfu-*` |
| Preview landing | `preview/hubfu-landing-premium.html` | Página marketing aprovada |
| Dados integrações | `preview/hubfu-integrations-data.js` | Marketplace/carousel |

**Abrir localmente:**

```bash
bash scripts/html-preview-serve.sh
# → http://127.0.0.1:8765/hubfu-design-system.html
```

## Arquivos markdown (suplementares)

| Arquivo | Conteúdo |
|---------|----------|
| [tokens.md](./tokens.md) | Cores, tipografia, spacing, radii, shadows (light + dark) |
| [components.md](./components.md) | Botões, nav, cards, kanban, integrações, tabs, pricing, planilha |
| [editable-table.md](./editable-table.md) | **EditableTable** — HubfuSheet → useOptimistic + Server Action |
| [snippets/optimistic-leads-table.tsx.example](./snippets/optimistic-leads-table.tsx.example) | Snippet Next.js (referência) |
| [motion.md](./motion.md) | GSAP + CSS + **Framer Motion** (port Next.js) |

## Como usar

### HTML preview (Caminho C)

```html
<link rel="stylesheet" href="hubfu-design-tokens.css" />
<html lang="pt-BR" data-theme="light">
```

Toggle de tema: botão `#theme-toggle` na nav. Persistência em `localStorage` (`hubfu-theme`).

### Next.js / Tailwind (futuro)

1. Importar `hubfu-design-tokens.css` em `globals.css` ou mapear primitivos para `@theme` no Tailwind v4.
2. Usar aliases `--hubfu-*` na camada semântica; componentes referenciam semânticos, nunca hex cru.
3. Dark mode: `class="dark"` ou `data-theme="dark"` no `<html>` — espelhar tabela em `tokens.md`.

### Penpot

Exportar primitivos como **color styles** e semânticos como **tokens nomeados**. Marketplace e device mock já são superfícies escuras — manter como **surface-ui** independente do tema da landing.

## Princípios visuais

- **Calma Apple-like:** fundo quase branco (light), tipografia system stack, serif italic só em destaques (`em`).
- **Accent emerald:** `#0a7f5c` (light) / `#34d399` (dark) — produto financeiro/CRM, Connected states.
- **Action purple:** `#7c3aed` (`--hubfu-action`) — Connect, Run, workflow CTAs.
- **Densidade dual:** landing respirada; mocks de produto (device, tab-panel) densos; marketplace v2 **claro**.
- **Violet secundário:** alinhado a `--hubfu-action` — distinto do accent verde.

## Regra de projeto (Hermes)

Para fixar como P0 no projeto HubFU/Hermes:

```
/lucy regra HubFU usa references/design-system/hubfu/ como fonte de tokens
```

## Workflow Lucy

```
HTML preview aprovado → Penpot MCP → port Next.js
```

Ver: `references/html-first-design-protocol.md`, `references/design-editable-hybrid-protocol.md`.

## Changelog

| Versão | Data | Notas |
|--------|------|-------|
| 1.3 | 2026-07-04 | EditableTable spec; HubfuSheet save otimista; snippet useOptimistic |
| 1.2 | 2026-07-04 | Cards v2 MeetGeek, data-table spreadsheet, Framer mapping, green+purple balance |
| 1.1 | 2026-07-04 | Catálogo HTML `hubfu-design-system.html` como referência visual canônica |
| 1.0 | 2026-07-03 | Extração v9 landing; dark mode via `data-theme` |
