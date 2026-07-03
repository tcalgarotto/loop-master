# Protocolo `/lucy refazer-frontend` — premium design (sem mudar rotas)

**Objetivo:** auditar e **elevar o design** do frontend existente — duplicatas visuais, órfãos, cara de IA (slop) — estilo **impeccable critique → craft → polish**, com **quiz de design** antes de codar.

**Não é:** reorganizar App Router, renomear URLs, ou reescrever backend.

---

## Comando

```
/lucy refazer-frontend
/lucy refazer-frontend --escopo todo
/lucy refazer-frontend --escopo /crm,/inbox
/lucy refazer-frontend --audit-only
/lucy refazer-frontend --sem-quiz
/lucy refazer-frontend --auto
```

**Escopo inteligente (default):**

| Situação | Escopo |
|----------|--------|
| Owner menciona rotas no prompt | **Só essas rotas** |
| `--escopo /a,/b` | Rotas listadas |
| `--escopo todo` ou sem menção | **Todo o frontend** |
| Quiz `d1_scope` | Confirma / corrige o inferido |

---

## Princípio: design only

| ✅ Permitido | ❌ Proibido (salvo ordem explícita) |
|-------------|-------------------------------------|
| Tokens, tipografia, espaçamento, hierarquia | Mover `page.tsx` entre pastas |
| Unificar **visual** de páginas duplicadas | Renomear URLs / deletar rotas |
| Integrar órfã na sidebar (link) | Mudar lógica de negócio / API |
| impeccable critique, layout, polish | Refactor arquitetural de rotas |
| Reduzir `use client` onde slop | Novo módulo backend no mesmo tick |

---

## Pipeline obrigatório (agente)

### Fase 0 — HYDRATE

1. `brain-sync.sh hydrate` + regras P0 (`lucy-brain/rules/`)
2. `DESIGN_SYSTEM.md`, `premium-ui-stack.md`, regras P0

### Fase 1 — Inventário + diagnóstico design

```bash
bash .cursor/skills/lucy/scripts/frontend-inventory.sh \
  --project . --out .lucy/frontend-inventory.md
bash .cursor/skills/lucy/scripts/frontend-inventory.sh \
  --project . --json --out .lucy/frontend-inventory.json
```

Inventário detecta:

- **Duplicatas** — mesmo segmento de URL (`/deals` vs `/negocios`)
- **Órfãs** — rota sem `href` na nav/sidebar
- **AI slop** — gradiente genérico, azul/roxo, sombras pesadas, copy "Welcome to…"

Gerar `.lucy/frontend-design-audit.md`:

- Top slop por rota
- Lista órfãs + sugestão (link nav vs polish só)
- Duplicatas + plano **visual** (não merge de rotas)

Rodar mentalmente / via CLI:

```bash
npx impeccable critique <frontend-path>   # quando disponível
```

### Fase 2 — Quiz de design (4 rodadas) — OBRIGATÓRIO

**Exceto** `--sem-quiz` ou `design_refactor_quiz.complete === true`.

Antes de **cada** rodada:

```bash
bash .cursor/skills/lucy/scripts/design-quiz-next.sh
```

Usar **AskQuestion** só com IDs `d1_*` … `d4_*`. **Uma rodada por turno.**

Persistir em `lucy-progress.json`:

```json
"design_refactor_quiz": {
  "round": 4,
  "complete": true,
  "round_1": { "d1_scope": "...", "d1_preserve_routes": "..." },
  ...
}
```

| Round | Tema |
|-------|------|
| 1 | Escopo (todo vs mencionado), manter URLs, profundidade impeccable |
| 2 | Register zinc/slate, anti-slop priorities, motion |
| 3 | Duplicatas, órfãs, rotas prioritárias (do inventário) |
| 4 | Pipeline impeccable, gate visual, páginas por tick |

Ver IDs completos: `scripts/design-quiz-next.sh`

### Fase 3 — Plano de refactor visual

`.lucy/frontend-refactor-plan.md` — **ordem de páginas** filtrada por:

- `d1_scope` + rotas mencionadas pelo owner
- `d3_priority_routes`
- Slop score desc, depois órfãs, depois resto

Por página:

| Campo | Exemplo |
|-------|---------|
| Rota | `/crm/deals` |
| Problemas | slop: gradient, hierarquia fraca |
| impeccable | critique → layout → typeset → colorize → polish |
| Skills | ui-ux-pro-max, taste-skill, shadcn, GSAP? |
| **Não fazer** | renomear rota, mover pasta |

### Fase 4 — Checkpoint

Resumo: N páginas no escopo, top 5 slop, órfãs, duplicatas.  
Pedir **sim** para implementar — exceto `--auto`.

### Fase 5 — Loop (1 página / tick default)

```
impeccable critique (página) → implement visual fixes → verify build
→ visual-gate-capture (rota) → vision checklist → impeccable polish → gate
```

**Por página refeita:**

- [ ] Hierarquia tipográfica (opacidade zinc, não 5 cinzas)
- [ ] Tokens `premium-ui-stack.md`
- [ ] Sem slop signals do inventário
- [ ] `prefers-reduced-motion`
- [ ] URLs **inalteradas**

### Fase 6 — Handoff

- `design_refactor_log.md` — rota ✅ + o que mudou visualmente
- `brain-sync capture`
- `next_prompt` = próxima rota no escopo
- Re-arm se ciclo incompleto

---

## Escopo: todo vs mencionado

```
Owner: "/lucy refazer-frontend foca em /crm e /inbox"
→ escopo = [/crm, /inbox] (+ filhos se layout compartilhado)
→ quiz d1 confirma

Owner: "/lucy refazer-frontend"
→ escopo = todas as pages do inventário
→ quiz d1 "Todo o frontend"
```

---

## Artefatos `.lucy/`

```
.lucy/
├── frontend-inventory.md / .json
├── frontend-design-audit.md
├── frontend-refactor-plan.md
├── frontend-refactor-log.md
└── session-state.json
```

---

## Comandos relacionados

| Comando | Uso |
|---------|-----|
| `/lucy nova-pagina` | Página nova (não confundir com refazer) |
| `/lucy regra` | Fixar "nunca mudar URL de X" |
| `/lucy perf` | Após 3–5 páginas |
| `/lucy continuar` | Retomar plano |

---

## Anti-padrões

- Pular inventário ou quiz de design
- Renomear rotas para "organizar"
- Deletar órfã sem decisão humana (quiz d3)
- Um tick refatorar 10 páginas
- Ignorar impeccable critique antes de polish
