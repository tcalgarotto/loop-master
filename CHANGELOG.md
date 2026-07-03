# Changelog — Lucy (loop-master)

## [2.9.3] — 2026-07-03

### Aprendizado global (`/lucy aprenda`) — Visual gate

- **`/lucy visual-gate`** — Playwright captura desktop + mobile por rota
- **`scripts/visual-gate-capture.sh`** — grava `.lucy/visual-gates/tick-N/`
- **`references/visual-gate-protocol.md`** — checklist vision V1–V8 (ux-design-intelligence)
- `last_visual_audit` no progress JSON + `audit-checklist.md` §9
- Gate FE bloqueado sem análise visual de PNGs no Cursor

---

## [2.9.2] — 2026-07-03

### Aprendizado global (`/lucy aprenda`)

- **`references/docs-sync-discipline.md`** — regra P0: após mudança em comando/script/protocolo → grep docs → sync README/MANUAL/SKILL/references/README/CHANGELOG → bump patch → `learned/INDEX`
- Integrado em `SKILL.md` (handoff + anti-padrão), `lucy-aprenda-protocol.md`, `autonomous-orchestrator-protocol.md`

---

## [2.9.1] — 2026-07-03

### Documentação

- `README.md`, `MANUAL.md`, `getting-started.md`, `references/README.md` sincronizados com v2.9.1

### `/lucy refazer-frontend` — design premium (sem mudar rotas)

- Foco em **design only**: impeccable critique → craft → polish; **URLs preservadas**
- Inventário detecta **AI slop**, rotas **órfãs** e **duplicadas**
- **Quiz de design** em 4 rodadas (`design-quiz-next.sh`, IDs `d1_*`–`d4_*`)
- Escopo: **todo o frontend** ou **só rotas mencionadas** (`--escopo`)

---

## [2.9.0] — 2026-07-03

### Novos comandos frontend

- **`/lucy refazer-frontend`** — inventário page-by-page + refactor com skills mapeadas
- **`/lucy nova-pagina`** — landing ou página app do zero (`--tipo landing|app`)
- Script `frontend-inventory.sh`

---

## [2.8.5] — 2026-07-03

### Dois escopos de aprendizado

- **`/lucy aprenda`** — evolução **global** → GitHub (todos recebem no update)
- **`/lucy regra`** — regras **P0 imutáveis** do projeto (`.cursor/lucy-brain/rules/`)

---

## [2.8.4] — 2026-07-03

- Protocolo **GSAP premium** (timelines, ScrollTrigger, stagger)
- Comando **`/lucy aprenda`** + `aprenda-capture.sh`

---

## [2.8.3] — 2026-07-03

- `html-native-light-protocol`: **View Transitions**, `animation-timeline: view()`, scroll scrub

---

## [2.8.2] — 2026-07-03

- Comando único **`/lucy`** (remove alias `/loop-master` e pasta `lucy-pack`)
- `html-native-light-protocol`: dialog/`command`, Popover, HTMX parcial

---

## [2.8.1] — 2026-07-03

- Fix migração `loop-master` → `lucy` (fallbacks corrompidos na 2.8.0)

---

## [2.8.0] — 2026-07-03

### Rebrand Lucy

- `loop-master` → **Lucy** (`lucy-progress.json`, `lucy-brain/`, hooks `lucy/`)
- `migrate-loop-master-to-lucy.sh` + `lucy-paths.sh`
- README e hero `assets/lucy-hero-18x9-4k.png`

---

[2.9.3]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.3
[2.9.2]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.2
[2.9.1]: https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.1
