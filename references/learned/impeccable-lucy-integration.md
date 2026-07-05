# Impeccable × Lucy — integração no cérebro global

**Objetivo:** Lucy **roteia explicitamente** trabalho de design frontend pela skill Impeccable — não improvisa polish genérico.

**Catálogo completo:** `learned/impeccable-capabilities-map.md`  
**8 pilares (impeccable.style):** `learned/impeccable-eight-pillars.md`  
**Live Mode (beta):** `learned/impeccable-live-mode.md`  
**15 cmds no minor cycle:** `impeccable-routing-table.md`

---

## Mandamento P0

> Em qualquer tick com superfície UI, o orchestrator **declara** qual comando Impeccable vai rodar, **lê** `reference/<cmd>.md`, e **registra** em `phases[].design_skills_used[]`.

**Pair obrigatório:** ui-ux-pro-max (discover/plan) → impeccable (plan→gate). Landing: taste-skill antes de impeccable.

**Anti-padrão:** implementar CSS "na mão" sem passar por pelo menos `critique` ou `shape` quando a rota é nova ou está com slop.

---

## Árvore de decisão Lucy → Impeccable

```
UI no escopo do tick?
├─ Não → skip impeccable
└─ Sim
   ├─ Sem PRODUCT.md no projeto?
   │  └─ FORA do loop: owner ou init manual `/impeccable init`
   ├─ `/lucy refazer-frontend`
   │  └─ detect → critique → layout/typeset/colorize → polish @ gate
   ├─ `/lucy nova-pagina`
   │  └─ landing: taste → shape → craft → animate → polish
   │  └─ app: ui-ux-pro-max → shape → craft → layout → polish
   ├─ Discussão paleta/tema (owner)
   │  └─ design-visual-html-protocol PRIMEIRO → depois impeccable colorize no Next
   ├─ minor step plan → shape
   ├─ minor step implement → craft | layout | colorize | adapt | animate
   ├─ minor step audit → critique | harden
   ├─ minor step fix → typeset | clarify | distill | quieter | bolder | layout
   └─ minor step gate → polish | optimize + npx impeccable detect (zero critical)
```

---

## Por comando Lucy

### `/lucy` (tick autônomo)

| Minor step | Impeccable (máx 2) | Detector |
|------------|-------------------|----------|
| `discover` | — (ui-ux-pro-max) | — |
| `plan` | `shape` | `detect.mjs` opcional nos paths dirty |
| `implement` | `craft`, `layout`, `colorize`, `adapt`, `animate` | — |
| `verify` | — | `npx impeccable detect` no path da task |
| `audit` | `critique`, `harden` | detect JSON → alimenta backlog |
| `fix` | `typeset`, `clarify`, `distill`, `quieter`, `bolder`, `layout` | — |
| `gate` | `polish`, `optimize` | **detect obrigatório** — exit 0 |

**Sequência multi-tick (uma superfície):**  
`shape` → `craft`/`layout` → `colorize` → `typeset` → `critique` → `harden` → `polish` → `optimize`

**JSON:** `minor_cycle.tasks[].skill_hint: "impeccable:layout"` · `phases[id].design_skills_used: ["impeccable:critique"]`

### `/lucy refazer-frontend`

Pipeline do protocolo — **impeccable é o motor de refactor visual:**

| Fase | Impeccable | Outros |
|------|------------|--------|
| Audit inventário | `critique <rota>` | `npx impeccable detect` full frontend |
| Quiz design (r4) | profundidade: layout/typeset/colorize/polish | taste se landing no escopo |
| Por página/tick | critique → layout → typeset → colorize → polish | visual-gate na rota |
| Gate fase | `polish` + detect zero critical | vision V1–V8 |

**URLs preservadas** — só elevação visual, não re-arquitetura de rotas.

### `/lucy nova-pagina`

| Tipo | Pipeline Impeccable |
|------|---------------------|
| **landing** | taste (dials altos) → `shape` → `craft` → `animate` → `polish` |
| **app** | ui-ux-pro-max → `shape` → `craft` → `layout` → `polish` |
| Pós HTML-first | Após owner aprovar `preview/*.html` → `craft` port Next |

Gate: `npx impeccable detect` + `visual-gate-capture.sh` na URL Next.

### `/lucy visual-gate`

Impeccable **complementa**, não substitui vision:

| Camada | Ferramenta |
|--------|------------|
| Determinístico | `npx impeccable detect <path>` — slop rules |
| Pixel | Playwright screenshots + checklist V1–V8 |
| UX adversarial | `critique` se vision flagar hierarquia/copy |

**Regra:** não declarar `gate_passed` só com detect — precisa screenshot + vision.

---

## Bootstrap PRODUCT.md + DESIGN.md (HubFU / hermes-crm)

O projeto **já possui** contexto Impeccable na raiz:

| Arquivo | Conteúdo | Register |
|---------|----------|----------|
| `PRODUCT.md` | PMEs BR, anti-references cream/SaaS, superfícies P0–P2 | **product** |
| `DESIGN.md` | Tokens `--hf-*`, zinc + roxo ≤8%, light/dark next-themes | product |

**Antes de qualquer tick FE:** agente confirma que `context.mjs` encontraria ambos (não re-rodar `init` se intactos).

| Gap | Ação Lucy |
|-----|-----------|
| Sem `PRODUCT.md` | `human_blockers` → owner roda `/impeccable init` |
| Código sem `DESIGN.md` | Sugerir `/impeccable document` no handoff ou `/lucy init` |
| DESIGN.md stale pós-refactor grande | `extract` ou `document` refresh antes de `refazer-frontend` massivo |
| Live Mode primeira vez | Verificar `.impeccable/live/config.json` — Next App Router: `app/layout.tsx` |

**Live config HubFU (referência):**

```json
{
  "files": ["app/layout.tsx"],
  "insertBefore": "</body>",
  "commentSyntax": "jsx",
  "cspChecked": true
}
```

---

## Live Mode — sessão interativa (fora do loop autônomo)

**Guia completo:** `learned/impeccable-live-mode.md` · **Playbook VPS:** `learned/vps-live-mode-owner-guide.md` · **Pilares 7–8:** `learned/impeccable-eight-pillars.md`

Live Mode (`/impeccable live`) é **beta** e **exige** browser interativo + dev server HMR na mesma sessão do owner. Lucy **não** spawna Live em ticks autônomos.

### Gatilhos de frase → routing (P0)

| Owner diz (PT-BR / EN) | Ação Lucy — **obrigatória** |
|------------------------|------------------------------|
| "live mode", "/impeccable live", "abrir live", "iterar visual no browser" | Carregar `impeccable-live-mode.md` + iniciar boot checklist |
| + contexto **VPS / Remote SSH / servidor** | **Não** recusar. Carregar § "Quando o owner pede Live Mode no VPS" + `vps-live-mode-owner-guide.md`; oferecer opções A/B/C/D; subir dev server se pedido |
| "não consigo abrir no browser" / "Preciso de ajuda" (handoff QA) | Tutorial tunnel ou Cursor Ports neste turno |
| Tick autônomo `/lucy` sem owner presente | **Não** Live — fallback polish + detect; `suggested_live_mode` no handoff |

**Anti-padrão:** responder "Browser MCP não funciona na VPS" **sem** guia de tunnel/Desktop/Ports.

### Quando sugerir ao owner

| Sinal | Sugestão |
|-------|----------|
| Owner reclama de **um** componente/hero/card após critique | Live no elemento (Desktop local) |
| Dev server rodando + owner em Cursor Desktop | `/impeccable live` |
| Iteração rápida com comentário/traço no browser | Live > polish genérico no chat |
| Brief ainda incerto | **shape** primeiro; Live depois |

### Quando NÃO sugerir Live autônomo (fallback batch)

| Sinal | Fallback Lucy |
|-------|---------------|
| VPS / Remote SSH **e owner não quer configurar acesso remoto agora** | `polish`/`layout`/`colorize` + detect + visual-gate Playwright |
| VPS / Remote SSH **e owner pede Live explicitamente** | **Guiar** tunnel/Ports/Desktop — ver `vps-live-mode-owner-guide.md`; agente pode subir dev server + `live.mjs` |
| Tick autônomo `/lucy` | Pipeline shape→craft→polish no minor cycle |
| `refazer-frontend` em massa | detect → critique → layout → polish por rota |
| Sem dev server | Subir `npm run dev` ou usar polish offline |

### Fluxo resumido (owner + agente)

1. `node .cursor/skills/impeccable/scripts/live.mjs`
2. `browser_navigate` → `http://localhost:3000/<rota>` (Cursor Desktop)
3. Poll loop background (`live-poll.mjs`) até `exit`
4. Owner: pick → anotar → Go → cycle → Accept
5. Agente: carbonize cleanup se `accept` exigir → `polish` + detect no path

**JSON handoff:** registrar `"suggested_live_mode": true` em `human_blockers` ou owner QA — nunca em `minor_cycle.tasks[]`.

---

## Comandos Impeccable FORA do loop Lucy

| Excluído | Motivo | Quando usar |
|----------|--------|-------------|
| `init`, `document`, `extract` | Setup one-time / ownership DS | `/lucy init` do projeto ou sessão manual |
| `audit` | Lucy usa `critique` + verifiers + detect CLI | Se owner pedir audit técnico explícito |
| `live`, `pin`, `hooks` | Interativo / harness | Sessão owner + dev server + **Cursor Desktop local** |
| `onboard`, `delight`, `overdrive` | Escopo atípico produto | Pedido explícito do owner |

---

## Integração com premium-tool-orchestration

| Momento (R#) | Impeccable |
|--------------|------------|
| R4 landing sem vida | `critique` → depois GSAP/taste |
| R4 pipeline landing | `critique` → `craft` → `polish` (mínimo) |
| R6 gate FE | `polish` + detect + visual-gate |
| R7 init | `init.sh` instala impeccable; não substitui critique no fim |
| **Iteração visual 1 elemento** | **Live Mode** (owner Desktop) ou fallback `polish`/`layout` no VPS |

---

## Integração skill-ecosystem-map

- **Máx 2 skills design por tick** — impeccable conta como 1; ui-ux-pro-max ou taste é o segundo.
- **Worker spawn:** ler `.cursor/skills/impeccable/SKILL.md` + `reference/<cmd>.md` + register (`brand.md`/`product.md`).
- **verify step:** shell roda `npx impeccable detect` (node, não bun).

---

## Checklist pré-gate (design) — Impeccable explícito

- [ ] `PRODUCT.md` existe (senão `init` manual antes do tick FE)
- [ ] Register correto (product para CRM; brand para landing)
- [ ] Pelo menos 1 cmd impeccable no tick da superfície (exceto verify puro)
- [ ] `npx impeccable detect <frontend-path>` — zero critical
- [ ] `critique` P0/P1 resolvidos ou documentados em `human_blockers`
- [ ] `phases[].design_skills_used` atualizado
- [ ] `docs/LUCY-INDEX.md` — impeccable ✅ se usado na fase

---

## VPS / browser

- **Live Mode no VPS:** agente **não** usa Browser MCP; owner **pode** usar Live via tunnel/Ports/Desktop local. Lucy **guia** — nunca só "não funciona". Ver `impeccable-live-mode.md` § "Quando o owner pede Live Mode no VPS" + `vps-live-mode-owner-guide.md`.
- **Fallback batch:** `polish`/`shape` + detect + visual-gate Playwright quando owner adia tunnel.
- Extension Chrome + overlay detect: opcional no browser do owner (não no agente VPS).
- `critique` browser pass: Playwright fallback se MCP browser indisponível (`vps-headless-browser-default.md`).

---

## Checklist Live Mode (sessão owner)

- [ ] `PRODUCT.md` + `DESIGN.md` na raiz
- [ ] Dev server rodando (`localhost:3000` ou porta do projeto)
- [ ] Cursor **Desktop local** (não Remote SSH VPS)
- [ ] `.impeccable/live/config.json` válido
- [ ] CSP dev permite helper `:8400` (se CSP ativo)
- [ ] Agente: `live.mjs` → navigate → poll loop até exit
- [ ] Pós-accept: carbonize cleanup + `npx impeccable detect` no path

---

## Evolução futura (`/lucy aprenda`)

Quando Impeccable lançar novos comandos ou regras detector:

1. Atualizar `impeccable-capabilities-map.md`
2. Revisar `impeccable-routing-table.md` (incluir/excluir do loop)
3. Atualizar `impeccable-eight-pillars.md` / `impeccable-live-mode.md` se Live evoluir
4. Bump patch Lucy + `learned/INDEX.md`
