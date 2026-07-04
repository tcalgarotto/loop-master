# Browser AI — scrape + screenshots para pipelines Lucy

**Objetivo:** padronizar como a Lucy (e CRM/ERP alvo) combina **navegador headless**, **dados estruturados** (Markdown/JSON) e **capturas de tela** para alimentar LLM + vision.

**Origem:** `/lucy aprenda` — ecossistema 2026: não usar Puppeteer/Selenium puros isolados; combinar browser + formatador LLM-ready.

**Relacionado:** `competitive-intelligence.md` (gap @url), `visual-gate-protocol.md` (QA do **nosso** app), Firecrawl skills no Cursor.

---

## Pipeline canônico (3 passos)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. BROWSER — headless entra na URL, espera JS, interage     │
│    (click, fill, paginação, auth se necessário)             │
├─────────────────────────────────────────────────────────────┤
│ 2. CAPTURE — screenshot(s) + HTML/Markdown/JSON limpo       │
│    Salvar em .lucy/browser/ ou .lucy/visual-gates/          │
├─────────────────────────────────────────────────────────────┤
│ 3. INTELLIGENCE — texto → LLM (gap, CRM)                    │
│                   imagem → vision (validar UI, layout, slop) │
└─────────────────────────────────────────────────────────────┘
```

**Regra Lucy:** nunca confiar só em texto nem só em pixel — **par** markdown + screenshot para análise competitiva e gates visuais.

---

## Roteamento — qual ferramenta usar

| Cenário | Ferramenta | Por quê |
|---------|------------|---------|
| QA visual **do nosso** Next.js (local/staging) | **Playwright** (`visual-gate-capture.sh`) | Já no init; desktop+mobile; sem custo API |
| URL conhecida, conteúdo estático/SSR | **Firecrawl scrape** | Markdown LLM-ready, rápido |
| Mapear site (features, pricing, docs) | **Firecrawl map** + scrape por URL |
| SPA, login, paginação, multi-step | **Firecrawl Browser Sandbox** | Zero Chromium local; `liveViewUrl`; sessões isoladas |
| `/lucy @url` gap analysis completo | Firecrawl scrape + **screenshot** + vision | Paridade com prints do usuário |
| Site anti-bot pesado (e-commerce, WAF) | **Bright Data Scraping Browser** ou **Browserbase** | Proxies + human-like |
| Bulk self-hosted VPS (baixo custo RAM) | **Obscura** (CDP, Rust) ou **Crawl4AI** (Python) | Containers; sem $/req cloud |
| Agente autônomo “decide onde clicar” | **Browser-Use** (Python) ou Stagehand + Browserbase | LLM controla browser |

### Árvore de decisão (agente)

```
Rodar ensure-headless-browser.sh — ler primary
  → playwright (VPS/SSH) → NUNCA CallMcpTool browser_*
       → nosso app? visual-gate-capture.sh
       → URL externa? browser-open-url.mjs
       → segurança? make security-browser / Playwright spec
  → cursor-mcp (Desktop local) → browser_navigate / browser_snapshot

É site externo concorrente?
  → Firecrawl scrape/map → Sandbox se SPA/auth
```

---

## Tier 1 — Gerenciado na nuvem (sem Docker Chrome)

### Firecrawl (preferido no ecossistema Cursor/Thales)

| Endpoint / feature | Uso |
|--------------------|-----|
| `scrape` | HTML → Markdown limpo |
| `map` | Descobrir URLs do domínio |
| `search` | Pesquisa web + resultados |
| **Browser Sandbox** | Sessão Playwright gerenciada; `snapshot` / screenshot; auth flows |

```bash
# CLI — browser sandbox (zero Chromium local)
npx -y firecrawl-cli@latest init --all --browser
# scrape conhecido
firecrawl scrape "https://exemplo.com/pricing" -o .lucy/browser/pricing.md
```

**Quando Browser Sandbox vs scrape:** ver tabela Firecrawl — paginação/forms → Sandbox; URL única → scrape.

Refs: [Firecrawl browser tools comparison](https://www.firecrawl.dev/blog/browser-automation-tools-comparison)

### Browserbase

- Chrome serverless; **Session Live View**; screenshots full-page HD
- **Stagehand** — controle em linguagem natural
- Usar quando Firecrawl não bastar e precisar live view enterprise

### Bright Data Scraping Browser

- Proxies + headless integrado; sites com detecção agressiva
- Último recurso comercial antes de desistir da URL

---

## Tier 2 — Open-source (local / VPS)

| Tool | Stack | Melhor para |
|------|-------|-------------|
| **Playwright** | Node | visual-gate, E2E, app próprio |
| **Crawl4AI** | Python + Playwright | RAG pipelines; screenshots; blocos limpos |
| **Browser-Use** | Python + LLM | Agente clica sozinho; prints sequenciais |
| **Obscura** | Rust, CDP | ~80% menos RAM; bulk em Docker; anti-tracker |

Obscura: compatível CDP (Chrome DevTools Protocol) — drop-in para stacks que falam CDP.

Ref: [github.com/h4ckf0r0day/obscura](https://github.com/h4ckf0r0day/obscura)

**Lucy default:** Playwright local + Firecrawl cloud quando autenticado. Obscura/Crawl4AI — opt-in em VPS (HubFU, SOLD) via `/lucy regra` ou deploy script.

---

## Artefatos `.lucy/browser/`

```
.lucy/browser/
├── session-state.json      # URL, tool, timestamps
├── markdown/               # Firecrawl scrape output
│   └── pricing.md
├── screenshots/            # PNG full-page ou viewport
│   └── pricing__desktop.png
└── manifest.json           # índice para vision + gap matrix
```

Competitivo: merge com `.lucy/firecrawl/` existente — `browser/screenshots/` alimenta `competitor-features.md` + vision como prints manuais.

---

## Integração com comandos Lucy

| Comando | Browser AI |
|---------|--------------|
| `/lucy @url` | Fase extração: scrape + screenshot obrigatório se sem prints do usuário |
| `/lucy analise @url` | Idem; não codar |
| `/lucy visual-gate` | Só app próprio (Playwright) |
| `/lucy refazer-frontend` | visual-gate local — não confundir com scrape concorrente |
| Loop autônomo fase FE | visual-gate automático (`quality_gates`) |
| Loop fase competitiva | browser-ai pipeline step 1–3 |

### Fase extração atualizada (`competitive-intelligence.md`)

Ordem:

1. Firecrawl scrape/map (markdown)
2. Se SPA/auth → Browser Sandbox + `snapshot`
3. Salvar screenshot em `.lucy/browser/screenshots/`
4. Vision no Cursor (ou OpenRouter) — mesma checklist que `visual-gate-protocol.md` V1–V8 adaptada para **referência**
5. Gap matrix cita `screenshot` + `markdown` como fontes

---

## Vision pós-capture

| Dado | Modelo | Pergunta |
|------|--------|----------|
| Markdown | LLM texto | Features, pricing, integrações |
| PNG | Vision (Claude/GPT/Gemini via Cursor ou OpenRouter) | Layout, hierarquia, componentes que texto perdeu |

Registrar em `last_visual_audit` (app) ou `.lucy/browser/manifest.json` (concorrente).

---

## Segurança e custo

| Regra | Detalhe |
|-------|---------|
| Secrets | API keys só env — nunca progress JSON |
| `.lucy/` | gitignore (já em competitive-intelligence) |
| Rate limit | Preferir map uma vez → scrape URLs filtradas |
| Custo cloud | Browser Sandbox ~2 credits/min (Firecrawl) — usar só quando scrape falhar |
| VPS bulk | Obscura/Crawl4AI para volume; cloud para one-off competitivo |

---

## Anti-padrões

- Puppeteer/Selenium cru sem camada LLM-ready
- Gap analysis só com WebFetch em SPA
- Screenshot sem markdown (ou vice-versa) em análise competitiva
- Playwright cloud manual quando Browser Sandbox resolve
- Instalar Obscura no laptop dev — reservar para VPS/container

---

## Referências externas

- [Firecrawl — Top 9 Browser Automation Tools 2026](https://www.firecrawl.dev/blog/browser-automation-tools-comparison)
- [Obscura — headless browser for AI agents](https://github.com/h4ckf0r0day/obscura)
- [Crawl4AI](https://github.com/unclecode/crawl4ai)
- [Browser-Use](https://github.com/browser-use/browser-use)
