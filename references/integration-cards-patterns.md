# Integration Cards — 3 modelos canônicos (memória Lucy)

**Origem:** `/lucy aprenda` — 2026-07-03 — refs owner (fotos 5, 6, 7)  
**Papel:** escolher e replicar o padrão certo de integrações em landing, onboarding ou marketplace.

> Complementa: `html-preview-interactive-mocks-protocol.md` · `design-system-intake.md`

---

## Quando usar qual modelo

| Modelo | Nome | Melhor para | Mín. logos |
|--------|------|-------------|------------|
| **A** | Carousel pills | Landing hero/social proof, marquee infinito | **8+** |
| **B** | Marketplace sidebar | Página "Conecte seus dados", settings | 12+ |
| **C** | Logo grid denso | Seção "Import data" / catálogo completo | 15+ |
| **D** | MeetGeek grid v2 | Marketplace premium, OAuth settings | 6+ |

**Regra:** com **≥8 integrações** na landing → preferir **Modelo A** (carousel). Com menos → grid compacto (Modelo C reduzido) ou cards 2×3.

---

## Modelo A — Carousel infinito (ref. foto 5)

**Visual:** logos reais em **círculos brancos**, fundo lavanda/cinza claro, duas fileiras opcionais com offset, scroll infinito suave.

```
┌──────────────────────────────────────────────────────┐
│  (○ WA) (○ SF) (○ HS) (○ AI) (○ LI) → → → duplicado │
└──────────────────────────────────────────────────────┘
```

| Token | Valor |
|-------|--------|
| Fundo seção | `#f4f2f8` ou `var(--bg-alt)` |
| Pill | 56–64px círculo, `#fff`, sombra `0 2px 12px rgba(0,0,0,.06)` |
| Logo | SVG real 28–32px (`cdn.simpleicons.org` ou asset local) |
| Motion | `translateX` loop 35–50s linear; **pausar no hover** |
| A11y | `prefers-reduced-motion` → grid estático |

**HTML:** `.int-carousel` > `.int-track` (conteúdo duplicado 2× para loop seamless).

**HubFU landing:** WhatsApp, Google Calendar, Stripe, Salesforce, HubSpot, Slack, Power BI, Excel, Zapier, etc.

---

## Modelo B — Marketplace com sidebar (ref. foto 6 — Zoho Import)

**Visual:** layout app — sidebar categorias à esquerda, grid de cards à direita.

```
┌──────────┬─────────────────────────────────────┐
│ Category │  [logo] Files    [logo] Salesforce  │
│ • All    │  [logo] HubSpot  [logo] Stripe     │
│ • CRM    │  [logo] Zendesk  [logo] QuickBooks │
│ • Sales  │  ...                                │
└──────────┴─────────────────────────────────────┘
```

| Token | Valor |
|-------|--------|
| Card | branco, `border-radius: 8px`, logo topo + label 12px cinza |
| Sidebar | 200px, item ativo com underline azul/verde accent |
| Grid | `repeat(auto-fill, minmax(120px, 1fr))`, gap 12px |
| Interação | clique categoria filtra cards (`data-category`) |

**Uso:** página `/integrations` ou modal "Conectar integração" no app.

---

## Modelo C — Grid denso logo + label (ref. foto 7)

**Visual:** grade 5×7 estilo catálogo — card branco retangular, logo centralizado, nome abaixo.

```
┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐
│logo│ │logo│ │logo│ │logo│ │logo│
│name│ │name│ │name│ │name│ │name│
└────┘ └────┘ └────┘ └────┘ └────┘
```

| Token | Valor |
|-------|--------|
| Card | min-height 100px, padding 16px, border `1px solid #e8e8ed` |
| Logo | max 40px altura |
| Label | 11–12px, `#6b7280`, center |
| Hover | borda accent + sombra leve |
| Click | toggle conectado / abre detalhe |

**Uso:** seção "Todas as integrações" ou documentação.

---

## Modelo D — MeetGeek marketplace grid v2 (ref. 2026-07-03)

**Visual:** grid 3×3 de cards **brancos** em fundo cinza claro. Logo centralizado 48px, nome bold, descrição 2 linhas, estado no rodapé.

```
┌─────────────────────┐
│              [grid] │
│      [logo 48px]    │
│    Service Name     │
│  Short description  │
│  two lines max      │
│                     │
│  ✓ Connected  OR    │
│  [Connect btn]      │
└─────────────────────┘
```

| Token | Valor |
|-------|--------|
| Fundo seção | `var(--hubfu-mp-surface)` · `#f5f5f7` |
| Card | `#fff`, `border-radius: 14px`, `border: 1px solid rgba(29,29,31,.1)` |
| Sombra | `var(--hubfu-int-card-shadow)` |
| Connected | `var(--hubfu-success)` + checkmark SVG |
| Connect | `var(--hubfu-action)` roxo `#7c3aed` + ícone user-plus |
| Grid icon | 2×2 squares roxo, canto superior direito |
| Grid | `repeat(3, 1fr)`, gap 16px |
| Metadata | `.int-v2-meta` opcional — email, "Ver templates" |

**Classes:** `.int-v2-card`, `.int-v2-grid`, `.int-v2-connected`, `.int-v2-connect`

**HubFU:** `preview/hubfu-design-system.html#integracoes` · landing `#marketplace` · dados `hubfu-integrations-data.js`

**Motion (Next.js):** Framer `whileHover` scale/shadow · `whileTap` no Connect · ver `motion.md`

**Ref image:** `preview/assets/ref-integration-cards-meetgeek.png`

---

## Logos reais (P0)

| Fonte | Quando |
|-------|--------|
| `https://cdn.simpleicons.org/{slug}/{color}` | HTML preview rápido (nem todo slug existe) |
| `https://cdn.jsdelivr.net/npm/simple-icons@11/icons/{slug}.svg` | Fallback quando simpleicons.org retorna 404 |
| SVG em `public/integrations/` | Next.js produção |
| Asset oficial do parceiro | Quando exigido por brand guidelines |

**Proibido:** só iniciais "WA", "GC" em landing final aprovada (ok só em wireframe v1).

Slugs úteis HubFU: `whatsapp`, `googlecalendar`, `stripe`, `salesforce`, `hubspot`, `slack`, `powerbi`, `microsoftexcel`, `zapier`, `notion`, `googledrive`, `openai`.

---

## Anti-padrões

- Carousel com 3 logos (parece vazio)
- Grid sem screenshot QA (cards cortados)
- Texto escuro herdado do `body` em mock **dark** (contraste zero)
- Mesmo modelo em landing e app settings sem adaptar densidade

---

## Comandos

| Comando | Uso |
|---------|-----|
| `/lucy aprenda` | Evoluir modelos |
| `bash scripts/html-preview-section-gate.sh` | Screenshot por seção |
| HTML-first | `preview/*.html` |
