# Design System Intake — quando o owner taga referências

**Objetivo:** transformar design systems, prints e links que o owner envia em **tokens acionáveis** para impeccable, taste-skill e implementação.

**Gatilho:** owner pergunta “quer que eu te tague design systems?” → **sim**, use este protocolo.

---

## O que o owner pode enviar

| Input | Exemplo | Agente faz |
|-------|---------|------------|
| URL live | linear.app, vercel.com | browser-ai scrape + screenshot |
| Print / Figma export | PNG do hero | vision → extrair hierarquia, cores |
| `DESIGN.md` / Notion | doc colado | parse seções → tokens |
| `@arquivo` no chat | `stripe-design.md` | copiar para `.lucy/design-intake/` |
| Comando | `/lucy aprenda` com referência | global no skill pack se regra universal |

**Não precisa** encher de referências — **2–3 referências fortes** > 20 fracas.

### Biblioteca canônica (global `/lucy aprenda`)

| Superfície | URL | Uso |
|------------|-----|-----|
| Web / Next | [shadcn/ui docs](https://ui.shadcn.com/docs) | Componentes, blocks, theming — **port principal** |
| Web motion | [Atlassian Design](https://atlassian.design/whats-new) | Tipografia, motion de componentes |
| Web layouts | [Figma Community](https://www.figma.com/pt-br/comunidade) | UI kits, design systems |
| Android | [Material 3](https://m3.material.io/) | Guidelines mobile nativo |

Detalhe do fluxo HTML-first: `html-first-design-protocol.md`.

### Case study references (owner-provided)

Quando o owner envia **estudos de caso** completos (mock + live + pipeline), Lucy usa a biblioteca global — **não** substitui intake pontual de tokens.

| Recurso | Uso |
|---------|-----|
| `references/case-studies/INDEX.md` | Catálogo — checar antes de sugerir landing brand |
| `references/case-studies/<slug>.md` | Visual DNA, section anatomy, craft mapping, triggers |

**Fluxo:** owner pede sugestão de site → Lucy lê INDEX → propõe 1–2 cases com *"este estudo de caso combina com X porque…"* → opcionalmente intake tokens do case escolhido.

**Escopo:** register **brand** (landing, marketing, editorial). Cases **não** colam em CRM/dashboard — ver register product em `premium-tool-orchestration.md` R4b.

**Primeiro case:** #001 Neo Mirai — `case-studies/neo-mirai-impeccable.md`.

---

## Pipeline (ordem)

### 1. Coletar

```
.lucy/design-intake/
├── sources.json          # URLs, arquivos, data
├── screenshots/          # browser capture
├── notes.md              # o que o owner quer copiar
└── tokens-extracted.json # saída estruturada
```

### 2. Capturar pixel + texto

```bash
# Referência externa
firecrawl scrape "https://referencia.com" -o .lucy/design-intake/referencia.md
# ou browser-ai-scrape-protocol.md

# Nosso app
bash .cursor/skills/lucy/scripts/visual-gate-capture.sh \
  --base-url https://seu-app.vercel.app --escopo /landing
```

### 3. Extrair tokens (vision + LLM)

| Token | Extrair de |
|-------|------------|
| Paleta | backgrounds, texto, accent (OKLCH/zinc preferido) |
| Tipografia | escala H1–body, weight, tracking |
| Radius / shadow | cards, modais |
| Spacing | grid 8px, section padding |
| Motion | duração, easing, scroll behavior |
| Componentes | sidebar, hero, pricing table, CTA |

Gravar em `DESIGN_SYSTEM.md` (projeto) — **merge**, não apagar regras P0 (`/lucy regra`).

### 4. Aplicar

| Próximo comando | Uso dos tokens |
|-----------------|----------------|
| `/lucy nova-pagina` | shape usa tokens extraídos |
| `/lucy refazer-frontend` | polish alinha à referência |
| impeccable `colorize` / `typeset` | inputs do intake |

### 5. Registrar

`brain-sync capture --summary "Design intake: <refs> → tokens em DESIGN_SYSTEM.md"`

---

## Formato ideal para o owner tagar

```markdown
## Referência: Linear (hero + sidebar)
- URL: https://linear.app
- Copiar: hierarquia tipográfica, densidade calma, CTA ghost+solid
- Evitar: gradiente roxo slop
- Prints: [anexar hero.png]
```

---

## Integração com `/lucy aprenda` vs `/lucy regra`

| Escopo | Comando |
|--------|---------|
| Regra universal (“sempre zinc como Linear”) | `/lucy aprenda` → skill pack |
| Regra só HubFU (“nunca azul puro”) | `/lucy regra` → `lucy-brain/rules/` |
| Intake pontual desta landing | workflow acima — sem commit global |

---

## Anti-padrões

- Copiar pixel-perfect sem critique (direitos + slop)
- Ignorar `premium-ui-stack.md` base (zinc, 8px)
- Intake sem screenshot
- Tokens só no chat — não persistir em `DESIGN_SYSTEM.md`
