# Protocolo `/lucy refazer-frontend` — redesign completo page-by-page

**Objetivo:** ler **todo** o frontend atual (`page.tsx`, `layout.tsx`, CSS), mapear estado real, e refazer com **todas** as skills instaladas + protocolos Lucy (premium stack, html-native, GSAP, regras P0 do projeto).

---

## Comando

```
/lucy refazer-frontend
/lucy refazer-frontend --audit-only     # inventário + gap report, não codar
/lucy refazer-frontend --rota /crm      # só uma rota e filhos
/lucy refazer-frontend --auto           # sem checkpoint entre fases
```

---

## Pipeline obrigatório (agente)

### Fase 0 — HYDRATE + regras P0

1. `brain-sync.sh hydrate`
2. Ler `.cursor/lucy-brain/rules/*.md` (prevalecem sobre tudo)
3. Ler `DESIGN_SYSTEM.md`, `docs/LUCY-INDEX.md`, `lucy-progress.json`

### Fase 1 — Inventário automático

```bash
bash .cursor/skills/lucy/scripts/frontend-inventory.sh \
  --project . \
  --out .lucy/frontend-inventory.md
```

Agente **lê cada `page.tsx`** na ordem do inventário (rotas de menor para maior complexidade: `/` → auth → dashboard → módulos).

Por página, registrar em `.lucy/frontend-refactor-plan.md`:

| Campo | Conteúdo |
|-------|----------|
| Rota | `/crm/deals` |
| Arquivo | `src/app/(app)/crm/deals/page.tsx` |
| Superfície | dashboard / inbox / settings / marketing |
| Problemas | anti-slop, `use client` desnecessário, cores fora zinc, sem skeleton |
| Template | `template-gallery.md` #N mais próximo |
| Skills | routing table — lista explícita |
| Motion | CSS scrub / GSAP / Framer / nativo dialog |
| Prioridade | P0 / P1 / P2 |

### Fase 2 — Gap + plano master

Consolidar:

- `impeccable critique` (ou taste `redesign-existing-projects`) no frontend path
- `ui-ux-pro-max` design system persist se tokens inconsistentes
- Matriz vs `premium-ui-stack.md`, `ux-design-intelligence.md`, `html-native-light-protocol.md`, `gsap-premium-protocol.md`

Saída: `.lucy/frontend-refactor-plan.md` com **fases ordenadas** (1 página ou 1 superfície por tick).

### Fase 3 — Checkpoint (padrão)

Mostrar ao owner:

- Total de páginas
- Top 5 gaps críticos
- Ordem de refatoração proposta
- Estimativa de ticks

Perguntar **sim** para iniciar Fase 1 de implementação — exceto `--auto`.

### Fase 4 — Loop de implementação (1 superfície / tick)

Por tick, **uma** rota ou grupo coeso:

```
discover (página atual) → plan → implement → verify (build/lint) → impeccable critique → fix → gate
```

**Skills por superfície** — consultar `design-skills-routing-table.md`:

| Superfície | Stack |
|------------|-------|
| Dashboard CRM | shadcn double sidebar + tremor + tanstack-query + GSAP stagger entrada |
| Inbox/chat | shadcn + html-native partial se lista pesada |
| Settings | dialog nativo + forms |
| Auth | shape + craft impeccable, motion mínimo |

**Obrigatório em cada página refeita:**

- [ ] Tokens zinc/slate (`premium-ui-stack.md`)
- [ ] `prefers-reduced-motion`
- [ ] Sem `transition-*` em elemento com GSAP
- [ ] Skeleton + loading states
- [ ] Regras P0 do projeto respeitadas
- [ ] `npx impeccable detect <frontend-path>` — zero critical na rota

### Fase 5 — Handoff

- Atualizar `lucy-progress.json`: `frontend_refactor_phase`, `next_route`
- `brain-sync capture`
- `next_prompt` com rota exata do próximo tick
- Re-arm loop se < 100%

---

## Ordem de leitura das páginas (padrão)

1. `layout.tsx` raiz + `globals.css`
2. Layouts de grupo `(app)`, `(auth)`, `(marketing)`
3. `/` e landing se existir
4. Auth (`/login`, `/signup`)
5. Dashboard home
6. Módulos por tráfego de negócio (CRM → inbox → settings)
7. Páginas órfãs / legado

---

## Artefatos `.lucy/`

```
.lucy/
├── frontend-inventory.md
├── frontend-refactor-plan.md
├── frontend-refactor-log.md      # uma linha por rota concluída
└── session-state.json            # retomada via /lucy continuar
```

---

## Comandos relacionados

| Comando | Uso |
|---------|-----|
| `/lucy nova-pagina` | Criar rota nova (landing ou app) do zero |
| `/lucy perf` | Após cada 3–5 rotas refeitas |
| `/lucy regra` | Fixar constraint do projeto antes do refactor |
| `/lucy continuar` | Retomar plano em `.lucy/` |

---

## Anti-padrões

- Refatorar todas as páginas num único tick
- Ignorar inventário shell — pular `frontend-inventory.sh`
- Adicionar `use client` sem passar pela matriz html-native
- Quebrar rotas API/backend no mesmo tick que UI
