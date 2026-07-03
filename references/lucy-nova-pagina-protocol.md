# Protocolo `/lucy nova-pagina` — criar página do zero (app + landing)

**Objetivo:** gerar uma rota nova premium — product page **ou** landing marketing — usando template gallery, taste-skill, impeccable e stack completa.

---

## Comando

```
/lucy nova-pagina <nome> --tipo landing
/lucy nova-pagina <nome> --tipo app          # dashboard, settings, inbox…
/lucy nova-pagina <nome> --tipo marketing    # alias de landing
/lucy nova-pagina pricing --tipo landing --template hero-saas
/lucy nova-pagina crm-reports --tipo app --template dashboard-analytics
```

**Exemplos HubFU:**

```
/lucy nova-pagina hubfu-pricing --tipo landing
/lucy nova-pagina crm-pipeline --tipo app --template dashboard-analytics
```

---

## Pipeline obrigatório (agente)

### Fase 0 — Intake (1 turno se faltar info)

| Pergunta | Default se omitido |
|----------|-------------------|
| Nome da rota | kebab-case do nome (`hubfu-pricing` → `/hubfu-pricing` ou `/pricing`) |
| Tipo | `landing` |
| Objetivo | inferir do nome + `quiz_answers` + PRODUCT.md |
| Template base | `template-gallery.md` — melhor match |
| CTA principal | inferir (signup, demo, contact) |

Usar **AskQuestion** só se rota ou tipo forem ambíguos.

### Fase 1 — HYDRATE + design system

1. `brain-sync.sh hydrate` + regras P0
2. Confirmar stack instalada (`skills_installed` no JSON):
   - shadcn/ui, framer-motion, tremor (se dashboard), tanstack-query (se dados)
3. `ui-ux-pro-max` — persist design system se projeto sem tokens estáveis
4. Ler `premium-ui-stack.md` + `template-gallery.md`

### Fase 2 — Shape (impeccable + taste)

| Tipo | Skills |
|------|--------|
| **landing** | taste-skill (VARIANCE/MOTION altos) → impeccable `shape` → banner-design se assets |
| **app** | ui-ux-pro-max → impeccable `shape` → design-system tokens |

Documentar wireframe em `.lucy/pages/<slug>-shape.md` (seções, hierarquia, CTA).

### Fase 3 — Scaffold arquivos

**Landing** (`--tipo landing`):

```
src/app/(marketing)/<slug>/page.tsx    # Server Component default
src/app/(marketing)/<slug>/layout.tsx  # opcional — nav marketing mínima
src/components/marketing/<slug>/       # Hero, Features, Pricing, FAQ, CTA
```

**App** (`--tipo app`):

```
src/app/(app)/<slug>/page.tsx
src/components/<slug>/                 # superfície isolada
```

**Regras de arquivo:**

- `page.tsx` = Server Component quando possível
- `use client` só em ilhas (chart, animação GSAP, formulário interativo)
- `loading.tsx` + `error.tsx` em rotas app
- `globals.css` / tokens — não duplicar; usar design-system existente

### Fase 4 — Craft + implement

**Landing premium (checklist):**

- [ ] Hero com hierarquia clara (taste anti-slop)
- [ ] Social proof / logos (placeholder se sem assets)
- [ ] Bento ou features grid (`magic-ui` opcional)
- [ ] Motion: `animation-timeline: view()` reveal OU GSAP stagger — não ambos no mesmo nó
- [ ] CTA acima da dobra + repetido no footer
- [ ] Mobile-first, `prefers-reduced-motion`
- [ ] Meta title/description na page ou layout

**App page premium (checklist):**

- [ ] Shell persistente (sidebar layout do grupo `(app)`)
- [ ] KPI row se dashboard (`tremor-raw`)
- [ ] Skeleton states (`shadcn/ui`)
- [ ] Empty state projetado
- [ ] Dialog nativo para ações CRUD simples

### Fase 5 — Verify + gate

```bash
npm run build
npx impeccable detect <frontend-path>
```

Atualizar:

- `docs/LUCY-INDEX.md` — nova rota ✅
- `brain-sync capture`
- `lucy-progress.json` — adicionar rota em `context_files` se relevante

---

## Templates (`template-gallery.md`)

| Flag `--template` | Galeria # |
|-------------------|-----------|
| `dashboard-analytics` | §1 Dashboard Analytics |
| `double-sidebar` | §2 CRM double sidebar |
| `inbox` | §3 Inbox |
| `kanban` | §4 Kanban |
| `hero-saas` | §6 Landing hero SaaS |
| `pricing` | §7 Pricing page |
| `auth` | §8 Login/signup |

Se `--template` omitido: agente escolhe e documenta no shape.

---

## Motion por tipo

| Tipo | Padrão Lucy |
|------|-------------|
| Landing hero | GSAP timeline entrada OU CSS view() scrub |
| Landing scroll sections | `animation-timeline: view()` |
| App dashboard | GSAP stagger cards + tremor fade |
| Modais na nova página | `<dialog>` + `command` |

---

## Saída esperada ao owner

- Caminho da rota criada
- Lista de componentes novos
- Skills usadas (tabela)
- Comando para preview local
- Sugestão: `/lucy refazer-frontend --rota /x` se substituir página legada

---

## Anti-padrões

- Landing inteira como um único `use client`
- Copiar template sem impeccable critique
- Ignorar grupo de rotas `(marketing)` vs `(app)` do projeto existente
- Azul puro / preto puro (premium-ui-stack)
