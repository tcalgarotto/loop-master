# HTML-First Design Protocol — prototipar antes de Next.js

**Origem:** `/lucy aprenda` — 2026-07-03 — owner  
**Papel:** primeira versão visual em **HTML standalone** local → owner valida → portar para Next/shadcn com confiança.

> Complementa: `gsap-premium-protocol.md` (motion no HTML) · `design-system-intake.md` (referências) · `lucy-nova-pagina-protocol.md` (port para React) · **`design-editable-hybrid-protocol.md`** · **`design-visual-html-protocol.md`** · **`html-preview-interactive-mocks-protocol.md`** · **`optimistic-inline-edit-protocol.md`** (planilhas densas)

---

## Mandamento (P0)

> **Landing ou página marketing nova:** quando o owner pede “ver o design” ou quando falta contexto do produto, o agente **cria primeiro** um HTML em `preview/` **antes** de scaffold Next.js pesado.

**Por quê:** iteração rápida, zero hydration/i18n bloqueando hero, motion GSAP imediato, owner guia copy e hierarquia sem rebuild.

---

## Pipeline HTML-first (ordem)

```
1. Intake     → design-system-intake + referências canônicas (§ Biblioteca)
2. HTML v1    → preview/<projeto>-<pagina>.html (seções completas, motion)
3. Live loop  → serve local + owner feedback + ajustes no HTML
4. Aprovação  → owner confirma visual/copy
5. Port       → lucy-nova-pagina / refazer-frontend → shadcn + Framer Motion
6. Gate       → visual-gate na URL Next (não só no HTML)
```

### Fase 1 — HTML standalone

| Regra | Detalhe |
|-------|---------|
| Local | `preview/<slug>.html` no repo do projeto ou skill pack (exemplo: `preview/hubfu-landing-premium.html`) |
| Stack | HTML + CSS + GSAP CDN; **sem** build step |
| Conteúdo | Copy real do produto quando existir; senão inferir e marcar `[validar]` |
| Motion | GSAP hero + ScrollTrigger (parallax, pin, stagger) — ver `gsap-premium-protocol.md` |
| Anti-slop | impeccable + taste; Bricolage/outra fonte distinta; sem gradiente roxo genérico |
| Abrir | `xdg-open preview/<file>.html` ou `bash .cursor/skills/lucy/scripts/html-preview-serve.sh` |

### Fase 2 — Edição live (experiência do owner)

| Método | Uso |
|--------|-----|
| **Servidor local** | `html-preview-serve.sh` — hot reload via refresh (porta 8765) |
| **DevTools** | Owner ajusta CSS/copy no browser → agente replica no arquivo |
| **Cursor + browser lado a lado** | Editar HTML → F5 → feedback em turnos curtos |
| **Print/screenshot** | Owner manda print da área que gostou → agente extrai tokens |

**Loop recomendado:** 2–4 rodadas HTML antes de tocar `src/app/`.

### Fase 3 — Port para Next.js

| HTML | Next |
|------|------|
| Seções + hierarquia | `page.tsx` + componentes em `components/marketing/` |
| GSAP timelines | Framer Motion springs + GSAP em ilhas `use client` |
| Tokens CSS `:root` | `globals.css` + shadcn theme |
| Mock SVG/dashboard | Tremor charts + shadcn Card em app pages |

**Não descartar** o HTML após port: manter em `preview/` como referência de design aprovado.

**Design systems:** além da landing, shippar catálogo HTML standalone (ex.: `preview/hubfu-design-system.html`) com swatches, componentes vivos e toggle de tema. Markdown em `references/design-system/` aponta para o HTML como referência visual canônica.

---

## Quando usar HTML-first vs direto Next

| Situação | Caminho |
|----------|---------|
| Landing nova, design incerto | **HTML-first** |
| Owner quer “ver no navegador” | **HTML-first** |
| Falta contexto produto (como HubFU inicial) | **HTML-first** + pedir intake |
| Refatorar rota app existente com shell | Direto Next (`refazer-frontend`) |
| Dashboard interno com dados reais | Direto Next + Tremor |
| Design já aprovado em Figma | Next + intake tokens |

---

## Biblioteca canônica de referências (estudar, não copiar cegamente)

Owner curou estas fontes — agente **consulta** antes de craft:

### Web / Next.js (prioridade HubFU)

| Fonte | URL | O que extrair |
|-------|-----|---------------|
| **shadcn/ui** | https://ui.shadcn.com/docs | Composição, theming, blocks, charts, sidebar, data-table — **reutilizar componentes** no port |
| **shadcn blocks** | https://ui.shadcn.com/blocks | Layouts inteiros: dashboard, login, marketing |
| **Atlassian Design** | https://atlassian.design/whats-new | Motion de componentes, tipografia em escala, refresh visual |
| **Tailwind UI** (visual) | tailwindui.com | Espaçamento, hierarquia, densidade premium (referência visual) |
| **Figma Community** | https://www.figma.com/pt-br/comunidade | UI kits, design systems (Fluent, Material, indie) |

### Android (quando superfície mobile nativa)

| Fonte | URL | O que extrair |
|-------|-----|---------------|
| **Material 3** | https://m3.material.io/ | Elevação, cor dinâmica, componentes, motion guidelines |

### Como usar na prática

1. **2–3 referências fortes** por tarefa (não 20)
2. Anotar em `.lucy/design-intake/notes.md`: “copiar X, evitar Y”
3. HTML-first implementa a **síntese**; Next port usa **shadcn** como implementação
4. `@url` concorrente → `browser-ai-scrape-protocol.md` (screenshot + markdown)

---

## Checklist HTML v1 (mínimo “com vida”)

- [ ] Hero com headline + lead + 2 CTAs (sem “Carregando…”)
- [ ] ≥8 seções ou equivalente denso (problema, produto, features, prova, preço/CTA)
- [ ] ≥1 mock de produto (dashboard, kanban, tabela)
- [ ] GSAP: hero stagger + ≥1 ScrollTrigger (reveal, parallax ou pin)
- [ ] Marquee, stats ou social proof
- [ ] FAQ ou pricing (se landing comercial)
- [ ] `prefers-reduced-motion` respeitado
- [ ] Banner discreto “Preview local” se não for produção

---

## Anti-padrões

- Pular HTML e ir direto para Next quando owner pediu preview local
- HTML minimalista (4 blocos) por falta de intake — **pedir contexto** ou inferir rico
- Commitar HTML preview como produção sem port + visual-gate
- Copiar layout shadcn sem adaptar tokens do projeto
- Ignorar biblioteca canônica quando owner já tagou referências

---

## Comandos relacionados

| Comando | Uso |
|---------|-----|
| `/lucy nova-pagina` | Após HTML aprovado → port |
| `/lucy refazer-frontend --escopo /rota` | Substituir landing plana |
| `/lucy visual-gate` | Só na URL Next final |
| `/lucy aprenda` | Evoluir este protocolo |
| `/lucy regra` | Regra visual só do projeto (ex.: “nunca azul puro”) |
