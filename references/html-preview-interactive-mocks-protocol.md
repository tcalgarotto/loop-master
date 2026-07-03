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

## 3. Integrações — grid de cards

Estilo marketplace (logo + nome + status), não só pills de texto.

| Propriedade | Valor |
|-------------|--------|
| Layout | `grid` 3–4 colunas, gap 12–16px |
| Card | fundo branco, borda sutil, ícone/initials, nome, badge status |
| Hover | `translateY(-2px)` + sombra leve |
| Click | alterna "Conectado" / "Conectar" |

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

Na view **Pipeline** do hero device: kanban **full width**, sem gráfico de linha competindo.

---

## Checklist antes de aprovar HTML

- [ ] Nav sidebar troca 4 views distintas
- [ ] Tabs produto trocam 4 cenas completas
- [ ] Filtros CRM funcionam
- [ ] Integrações em grid de cards interativos
- [ ] Barras financeiras = crescimento exponencial
- [ ] Kanban organizado (headers, totais, seleção)
- [ ] Motion equilibrado (≤2 GSAP por viewport)

---

## Comandos

| Comando | Uso |
|---------|-----|
| `/lucy aprenda` | Evoluir este protocolo |
| HTML-first | `preview/<slug>.html` |
| Port | `lucy-nova-pagina` / `refazer-frontend` |
