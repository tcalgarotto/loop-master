# Design Visual HTML Protocol — exemplos visuais antes de código

**Origem:** `/lucy aprenda` — 2026-07-05 — owner (global)  
**Versão skill:** 2.9.21

> Complementa: `html-first-design-protocol.md` · `html-preview-interactive-mocks-protocol.md` · `design-editable-hybrid-protocol.md`

---

## Mandamento (P0 — owner rule)

> **Sempre que discutir design** (paleta, layout, tema, variantes, polish de página), o agente **cria exemplos visuais em HTML** — preferencialmente lendo o `page.tsx` alvo e recriando a superfície em HTML standalone com sugestões de paleta/design **e botões/seletor para alternar variantes**.

**Por quê:** owner decide olhando, não inferindo de bullets; reduz idas e vindas; alimenta owner QA (`owner-handoff-qa-protocol.md`).

---

## Default de variantes

| Modo app | Variantes mínimas | Quando pedir mais |
|----------|-------------------|-------------------|
| **Padrão** | **2 light + 2 dark** (4 total) | Owner pede N explícito (`--variants 6`, "mostra 3 opções") |
| Tema único | 2 opções no mesmo register | Superfície sem dark mode |

**Nomenclatura sugerida:** A/B/C/D ou descritiva (`hubfu-light`, `zinc-dark-v3`, …). Documentar escolha em `.cursor/lucy-brain/rules/` ou handoff.

---

## Pipeline obrigatório

```
1. Ler alvo     → page.tsx + componentes + theme-tokens.css / preview tokens
2. HTML mock    → frontend/preview/<slug>-theme-picker.html (ou skill pack preview/)
3. Seletor      → toolbar com botões aria-pressed + data-* para variantes
4. Apresentar   → owner escolhe; registrar decisão (regra local ou progress JSON)
5. Port mínimo  → CSS vars (--chat-*, --hf-*) + classes; visual-gate se FE
```

### Fase 1 — Ler o alvo

| Ler | Para quê |
|-----|----------|
| `frontend/src/app/**/page.tsx` | Layout, hierarquia, copy real |
| Componentes filhos citados | Lista, filtros, bubbles, empty states |
| `theme-tokens.css` / `hubfu-design-tokens.css` | Tokens existentes vs gap |
| `.lucy/design-refactor-log.md` | Exceções/waivers anteriores |

### Fase 2 — HTML standalone

| Regra | Detalhe |
|-------|---------|
| Local | `frontend/preview/<feature>-theme-picker.html` no app; ou `preview/` no skill pack para templates genéricos |
| Stack | HTML + CSS vars + JS mínimo (toggle variantes); link `hubfu-design-tokens.css` quando HubFU |
| Conteúdo | Copy e estrutura espelham o produto; dados mock realistas (PT-BR) |
| Seletor | `<button class="variant" data-variant="…" aria-pressed>` + `document.body.dataset.*` |
| Light/dark app | Toggle `data-theme="light|dark"` **separado** do seletor de variante quando ambos importam |
| Anti-slop | impeccable + taste; tokens `--hf-*`; sem gradiente roxo genérico |

### Fase 3 — Variantes (2L + 2D default)

Exemplo inbox (owner QA 2026-07-05):

| ID | Register | Uso |
|----|----------|-----|
| B | HubFU light (tokens) | `data-theme=light` / paths claros |
| C | Zinc dark v3 | `.dark` / `data-theme=dark` |
| A | Legado (opcional no picker) | Só se ainda existir no produto — marcar "atual" |
| D+ | Extra light/dark | Sob pedido do owner |

**Proibido:** commitar só texto descrevendo cores sem HTML quando a tarefa é decisão visual.

### Fase 4 — Persistir decisão owner

| Escopo | Onde |
|--------|------|
| Projeto HubFU | `.cursor/lucy-brain/rules/<feature>-theme-choice.md` |
| Progress | `owner_qa.round_N` no `.cursor/lucy-progress.json` |
| Design log | `.lucy/design-refactor-log.md` waiver/decision |
| Handoff | `.lucy/lucy-100-handoff.md` |

### Fase 5 — Port para produto (mínimo)

1. Definir CSS vars canônicas (ex.: `--chat-bg`, `--chat-list-bg`, …) em `theme-tokens.css` — light = variante B, `.dark` = variante C.
2. Substituir `gray-*` hardcoded nos componentes alvo por `var(--chat-*)`.
3. **Não** quebrar contraste intencional de rotas legadas sem decisão explícita.
4. `npm run build` + visual-gate nas rotas afetadas.

---

## Checklist agente (design discussion)

- [ ] Li `page.tsx` + tokens antes de propor cores
- [ ] Criei/atualizei HTML preview com **≥2 light + ≥2 dark** (ou N pedido)
- [ ] Seletor de variantes funcional (aria-pressed)
- [ ] Owner escolheu ou default documentado
- [ ] Decisão persistida (brain rule + progress + design log)
- [ ] Port CSS vars mínimo no FE (se escopo incluir implementação)

---

## Routing

Ver `design-skills-routing-table.md` — **HTML visual preview primeiro** em tarefas de design/paleta/tema antes de impeccable shape no Next.

---

## Referência canônica HubFU

- Preview: `frontend/preview/inbox-theme-picker.html`
- Decisão owner: B = light (HubFU tokens), C = dark (zinc v3)
- Regra local: `.cursor/lucy-brain/rules/inbox-theme-choice.md`
