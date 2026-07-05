# Impeccable Live Mode — guia completo para Lucy

**Fonte canônica:** `skill/reference/live.md` (Impeccable v3.9.x)  
**Escopo:** workflow interativo pick → 3 variantes → accept grava no source  
**Integração Lucy:** `impeccable-lucy-integration.md` · pilares: `impeccable-eight-pillars.md`

---

## O que é

Live Mode é o comando `/impeccable live` em **beta**: o owner (ou agente em sessão interativa) abre o app no browser com dev server + HMR, **seleciona um elemento**, opcionalmente anota com comentário ou traço, e recebe **3 variantes visuais** geradas pelo agente. O owner cicla entre elas, ajusta knobs (density, cor, etc.) e **Accept** promove a escolhida para o arquivo fonte real.

Diferente de `polish`/`shape` (batch no chat), Live Mode é **visual-first, elemento a elemento**, com feedback instantâneo via HMR.

---

## Pré-requisitos

| Requisito | Detalhe |
|-----------|---------|
| **Dev server com HMR** | Next.js, Vite, Bun, SvelteKit, Astro, Nuxt, ou HTML estático servido |
| **Node 24+** | Scripts `live*.mjs` no harness Impeccable |
| **PRODUCT.md** | Contexto estratégico em todo comando (register, voz, anti-references) |
| **DESIGN.md** (recomendado) | Tokens normativos; sem ele, extrair identidade de CSS vars + computed styles |
| **`.impeccable/live/config.json`** | Criado por `/impeccable init` ou primeiro boot de `live.mjs` |
| **Browser interativo** | Cursor Desktop local com Browser MCP **ou** browser do owner na mesma máquina do dev server |
| **CSP dev** (se aplicável) | Allowlist `http://localhost:8400` em `script-src` e `connect-src` (porta do helper Impeccable, não do app) |

**HubFU (hermes-crm):** `PRODUCT.md` e `DESIGN.md` já existem na raiz. Register = **product**. Live config Next.js App Router → `files: ["app/layout.tsx"]`, `commentSyntax: "jsx"`.

---

## Arquitetura (dois servidores)

```
┌─────────────────────┐     ┌──────────────────────────┐
│  App dev server     │     │  Impeccable live helper   │
│  localhost:3000     │     │  localhost:8400 (típico)  │
│  (Next/Vite/HMR)    │     │  /live.js, SSE, /poll     │
└─────────────────────┘     └──────────────────────────┘
         ▲                            ▲
         │                            │
    browser do owner              agente poll loop
```

- **`serverPort` do `live.mjs`** = helper HTTP (injeta `live.js`, SSE). **Não** é a URL do app.
- **URL do app** = origem que serve `pageFiles` (ex. `http://localhost:3000/dashboard`).

---

## Fluxo completo (contrato do agente)

Ordem **obrigatória**, sem pular etapas:

### 1. Boot

```bash
node .cursor/skills/impeccable/scripts/live.mjs
# monorepo: --target <path-do-pacote>
```

JSON de saída: `{ ok, serverPort, serverToken, pageFiles, hasProduct, hasDesign, ... }`.

Se `config_missing` → escrever `.impeccable/live/config.json` (ver § Config por framework).

### 2. Abrir app no browser

**Cursor Desktop:** `browser_navigate` para URL do dev server **antes** de poll.

**Outros:** browser tool disponível ou pedir ao owner abrir a rota.

### 3. Poll loop (Cursor: one-shot em background)

```bash
node .cursor/skills/impeccable/scripts/live-poll.mjs
# timeout longo default (600000 ms); NUNCA --timeout curto
# Cursor: background terminal + notify em "type":"(steer|generate|accept|discard|exit)"
# NÃO usar --stream no Cursor (~5s vs sub-second)
```

Eventos:

| `type` | Ação do agente |
|--------|----------------|
| `prefetch` | Ler arquivo da rota (latência); sem `--reply` |
| `generate` | Wrap → 3 variantes → `--reply done` |
| `steer` | Direção de página sem elemento → `--reply steer_done` |
| `accept` | Carbonize cleanup se necessário → poll |
| `discard` | Nada (script já restaurou) → poll |
| `manual_edit_apply` | Aplicar batch do owner → `--reply done --data '{...}'` |
| `exit` | Cleanup |

### 4. Owner no browser (UI Impeccable bar)

1. **Pick** — clicar no elemento alvo
2. **Anotar** (opcional) — comentário textual ou traço (círculo = ênfase, seta = direção, X = remover)
3. **Ação** — sub-comando (`bolder`, `layout`, `polish`, …) ou freeform
4. **Go** — dispara `generate`
5. **Cycle** — alterna v1/v2/v3; ajusta knobs (range/steps/toggle)
6. **Accept** ou **Discard**

### 5. Generate (agente)

1. Ler screenshot **só se** owner colocou comentário/traço (`screenshotPath`)
2. `live-wrap.mjs` — envolve elemento no source (passar `--text` para disambiguar listas)
3. Carregar `reference/<action>.md` ou register (`brand.md`/`product.md`) para freeform
4. **Phase A–D:** extrair identidade → modo default vs departure → 3 variantes em eixos distintos → squint test
5. Escrever **todas** as variantes em **um** edit (HTML+CSS scoped, knobs `data-impeccable-params`)
6. `--reply EVENT_ID done --file RELATIVE_PATH`

### 6. Accept (grava no source)

- `live-accept.mjs` roda automaticamente no poll
- **`carbonize: true`** → agente **deve** limpar markers, mover CSS para stylesheet real, unwrap `data-impeccable-*`, rodar `live-complete.mjs`
- Accept escreve no arquivo fonte rastreado pelo git (não em arquivos GENERATED)

### 7. Cleanup (exit)

```bash
node .cursor/skills/impeccable/scripts/live-server.mjs stop
# remove inject live.js de layout/entry HTML
```

---

## Config por framework (HubFU = Next.js App Router)

```json
{
  "files": ["app/layout.tsx"],
  "exclude": [],
  "insertBefore": "</body>",
  "commentSyntax": "jsx",
  "cspChecked": true
}
```

| Framework | `files` | `commentSyntax` |
|-----------|---------|-----------------|
| Next.js App Router | `app/layout.tsx` | `jsx` |
| Next.js Pages | `pages/_document.tsx` | `jsx` |
| Vite/React SPA | `index.html` | `html` |
| SvelteKit | `src/app.html` | `html` |
| Astro | layout root `.astro` | `html` |
| Multi-page static | `public/**/*.html` (glob) | `html` |

---

## Suporte a frameworks (preview HMR)

| Target | Preview mode | Accept |
|--------|--------------|--------|
| HTML / JSX / TSX | Wrapper + `@scope` ou prefixed selectors | Inline → carbonize → stylesheet |
| Svelte/SvelteKit | Componentes temp em `node_modules/.impeccable-live/` | Inline component no `.svelte` |
| Astro | `astro-global-prefixed` selectors | CSS para partial/stylesheet |
| Arquivo gerado | `fallback: agent-driven` | Editar template gerador, não HTML servido |

**Insert mode:** `mode: "insert"` — conteúdo novo before/after âncora (sem `action`; precisa freeform ou anotações).

---

## Parâmetros (knobs) por variante

- **0–4 params** por variante conforme peso visual (hero = 2–3; botão = 0)
- Tipos: `range` → `--p-<id>`, `steps` → `data-p-<id>`, `toggle` → ambos
- Accept grava valores escolhidos em comentário `impeccable-param-values` → carbonize bakeia no CSS final

---

## Limitações conhecidas

| Limitação | Mitigação |
|-----------|-----------|
| Requer interação humana no browser | Fora do loop autônomo Lucy |
| Browser MCP indisponível no VPS | Cursor Desktop local **ou** fallback polish/shape |
| CSP bloqueia helper :8400 | `detect-csp.mjs` + patch dev-only ou manual |
| Elemento só em arquivo gerado | Fallback agent-driven → editar template |
| `configDrift` — HTML órfãos | Avisar owner; sugerir glob `public/**/*.html` |
| Params resetam ao trocar variante | Limitação documentada; preservação futura |
| Codex sandbox | `require_escalated` para localhost + npm |

---

## Quando Lucy sugere Live vs polish/shape

| Situação | Ferramenta |
|----------|------------|
| Owner quer iterar **um componente** com feedback visual imediato | **Live Mode** (sessão interativa) |
| Tick autônomo `/lucy`, refazer-frontend, nova-pagina | **shape → craft → polish** (não live) |
| VPS / Remote SSH sem Browser MCP | **polish/layout/colorize** + `npx impeccable detect` + visual-gate Playwright |
| Hero/card específico após gate falhar em 1 elemento | Sugerir Live **se** owner em Desktop local com dev server |
| Brief incerto, discovery multi-round | **shape** primeiro; Live depois de identidade definida |
| Landing brand com departure exploratório | **shape + taste**; Live em default mode preserva identidade |
| Pós-accept carbonize pendente | Agente **não** poll até cleanup completo |

**Regra Lucy P0:** Live Mode **nunca** entra em `minor_cycle.tasks[]` autônomo. Registrar em `human_blockers` ou sugerir ao owner em handoff QA.

---

## VPS / HubFU — resposta prática

| Pergunta | Resposta |
|----------|----------|
| Lucy no VPS pode rodar Live? | **Não** de forma interativa — Browser MCP `toolCount=0` (ver `vps-headless-browser-default.md`) |
| Owner no VPS com Cursor Remote SSH? | **Não** — helper e picker precisam de browser na máquina do dev server + agente com poll |
| Owner com Cursor Desktop local + clone local? | **Sim** — dev server local, `browser_navigate`, `/impeccable live` |
| Fallback no VPS? | `polish`/`layout`/`colorize` no path + `npx impeccable detect` + `visual-gate-capture.sh` |
| hermes-crm já tem contexto? | Sim — `PRODUCT.md` (product) + `DESIGN.md` (tokens HubFU) na raiz |

---

## Recovery

```bash
node .cursor/skills/impeccable/scripts/live-status.mjs
node .cursor/skills/impeccable/scripts/live-resume.mjs --id SESSION_ID
node .cursor/skills/impeccable/scripts/live-complete.mjs --id SESSION_ID
```

Journal durável em `.impeccable/live/sessions/` — replay após restart do helper.

---

## Cross-links

| Doc | Relação |
|-----|---------|
| `impeccable-eight-pillars.md` | Pilar 7–8 (Live + Accept) |
| `impeccable-lucy-integration.md` | Routing ticks vs sessão owner |
| `premium-tool-orchestration.md` | Momento "iteração visual interativa" |
| `vps-headless-browser-default.md` | Por que VPS não usa Live |
| `impeccable-capabilities-map.md` | Catálogo 23 cmds |
