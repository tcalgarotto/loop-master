# HTML Preview — Mocks interativos espelhando o produto real

**Origem:** `/lucy aprenda` — 2026-07-03 — owner (HubFU)  
**Papel:** regras P0 para `preview/*.html` antes do port Next.

> Complementa: `html-first-design-protocol.md` · `design-editable-hybrid-protocol.md` · `gsap-premium-protocol.md`

---

## Mandamento (P0)

> Mocks na landing **não são decoração**. Clique em nav, abas ou filtros **deve trocar o conteúdo visível** como no SaaS real. Dados e layout espelham dashboard de produto (CRM kanban, estoque, financeiro).

---

## 1. Interatividade real (não fake)

| Elemento | Comportamento mínimo |
|----------|-------------------|
| Sidebar / nav do device | Troca **view** inteira (overview, pipeline, estoque, financeiro) |
| Tabs de módulo | Troca `tab-scene` com conteúdo distinto |
| Filtros (Todos / Quente / Estagnado) | Filtra cards visíveis no DOM |
| Cards de negócio | Seleção + painel de detalhe; opcional avançar etapa |
| Integrações | Grid de cards clicáveis (estado conectado/desconectado) |
| Chips de ação (IA) | Toggle estado feito |

**Proibido:** botão que só muda classe visual sem trocar conteúdo.

---

## 2. Motion — equilíbrio (não tudo animado)

| Usar motion | Evitar motion |
|-------------|---------------|
| Hero: 1x draw de linha de receita | Animar cada card do kanban no load |
| Troca de aba: fade curto + stagger leve | Loop infinito em todos os gráficos |
| Barras financeiras: scaleY na entrada da view | Parallax em 5 seções |
| Hover em cards (CSS transform) | `transition: width/height` em layout |

**Regra:** no máximo **2 assinaturas GSAP** por viewport (ex.: hero line + tab switch). Resto estático ou hover CSS.

Ver `gsap-premium-protocol.md` — CSS `transition-*` só hover; não no mesmo node que GSAP anima.

---

## 3. Integrações — 3 modelos (ver catálogo)

**Canônico:** `integration-cards-patterns.md` — Modelo A (carousel), B (marketplace sidebar), C (grid denso).

| Contexto | Modelo | Regra |
|----------|--------|-------|
| Landing com **≥8** integrações | **A** — carousel infinito | Logos **reais** (SVG), não iniciais |
| Página settings / conectar dados | **B** — sidebar + grid | Filtro por categoria |
| Catálogo completo | **C** — grid 5×7 | Logo + label |

**Landing HubFU:** Modelo A com `cdn.simpleicons.org` no preview; assets em `public/integrations/` no port Next.

**Proibido:** só iniciais "WA", "GC" em HTML aprovado para cliente.

---

## 6. Contraste em mocks dark (P0)

Texto dentro de device mock (`#1c1c1e`) **não herda** `body { color: #1d1d1f }`.

| Superfície | Mínimo |
|------------|--------|
| `.device-main` | `color: #f5f5f7` no container |
| Tabelas estoque (hero + tabs) | células `rgba(245,245,247,.88)`; headers `.55` |
| `.deal-name` em dark | `rgba(255,255,255,.92)` |
| `.deal-meta` em dark | `rgba(255,255,255,.55)` — nunca `.35` |

**Gate:** zoom 100% desktop — ler nomes de produto na view Estoque do hero sem esforço.

---

## 7. QA por seção (screenshot obrigatório)

Antes de aprovar `preview/*.html`:

```bash
bash scripts/html-preview-serve.sh   # terminal 1
bash scripts/html-preview-section-gate.sh --file preview/<slug>.html
```

**Checklist vision (cada PNG):**

| Seção | Verificar |
|-------|-----------|
| Hero device | 4 views; tabela estoque legível |
| Integrações | logos reais; carousel sem gap; não cortado |
| Feature rows | kanban 4 colunas visíveis (sem clip) |
| Tabs produto | 4 cenas completas; filtros CRM |
| Mobile | sem overflow horizontal indesejado |

**Proibido:** gate_passed com seção vazia, texto ilegível ou card cortado na borda.

Ver `visual-gate-protocol.md` — extensão HTML preview.

---

## 4. Gráficos de barra — lucro exponencial

Barras de **receita/lucro** devem subir de forma **monotônica crescente** (curva exponencial suave), nunca aleatório.

Exemplo normalizado (6–7 períodos): `28, 35, 44, 55, 68, 82, 95` (% da altura máx).

**Proibido:** barras que descem no meio da série de lucro (só séries de saída/custo podem variar).

---

## 5. Pipeline — kanban funcional e organizado

| Requisito | Detalhe |
|-----------|---------|
| Colunas | Lead → Proposta → Negociação → Fechado (ou equivalente produto) |
| Header coluna | Nome + contagem + soma R$ |
| Cards | Avatar, nome, valor, prob bar, data |
| Coluna body | `min-height`, fundo distinto, scroll se muitos cards |
| Interação | Clique seleciona; botão ou duplo-clique avança etapa |
| Drag-and-drop (v9+) | Cards `draggable`; colunas como drop targets; `.drag-over` no hover; GSAP snap ao soltar |

Na view **Pipeline** do hero device: kanban **full width**, sem gráfico de linha competindo.

---

## Checklist antes de aprovar HTML

- [ ] Nav sidebar troca 4 views distintas
- [ ] Tabs produto trocam 4 cenas completas
- [ ] Filtros CRM funcionam
- [ ] Integrações: modelo certo (carousel se ≥8) + logos reais
- [ ] Contraste OK em mocks dark (estoque hero, deal cards)
- [ ] Screenshot por seção (`html-preview-section-gate.sh`)
- [ ] Barras financeiras = crescimento exponencial
- [ ] Kanban organizado (headers, totais, seleção)
- [ ] Kanban DnD funcional nas feature rows (CRM/ERP/finance) — v9+
- [ ] Motion equilibrado (≤2 GSAP por viewport)
- [ ] **P0 regressão:** hero nav + tabs produto — smoke manual após qualquer JS novo
- [ ] Marketplace ≥20 itens: paginação 9/página + busca re-renderiza grid
- [ ] Carousel ≥80s; logos com fallback `simpleicons.org` → jsdelivr SVG

---

## Anti-padrões (HTML preview interativo)

| Anti-padrão | Correção |
|-------------|----------|
| `initIntegrations()` ou JS novo referencia variável declarada depois (`reduced`) | Declarar deps no topo do `<script>`; `try/catch` no init; não bloquear handlers P0 |
| Marketplace renderiza 54 cards de uma vez | Paginar 9/página; contador `N de total` |
| Busca/filtro só atualiza contador | Re-renderizar grid (slice ou `.hidden`); reset `page=0` ao filtrar |
| Carousel rápido + logos sem fallback | Animação ≥80s; `onerror`: CDN colorido → jsdelivr SVG → iniciais |
| GSAP opacity em hero/tab deixa view invisível | `killTweensOf`; limpar `opacity` inline; toggle `.active` antes de animar |
| Feature kanban com wrap feio | `minmax(112px,1fr)` colunas; `white-space: nowrap` + ellipsis em `.deal-name` |
| Section gate trava em `networkidle` | Playwright `waitUntil: 'load'` em `html-preview-section-gate.mjs` |
| Tab/hero view switch quebrado após edit | Checklist P0 acima — smoke obrigatório antes de gate |

---

## Comandos

| Comando | Uso |
|---------|-----|
| `/lucy aprenda` | Evoluir este protocolo |
| `bash scripts/html-preview-section-gate.sh --file preview/<slug>.html` | Screenshot por seção (gate HTML) |
| `bash scripts/html-preview-serve.sh` | Servidor local :8765 |
| HTML-first | `preview/<slug>.html` |
| Port | `lucy-nova-pagina` / `refazer-frontend` |
