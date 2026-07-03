# Competitive Intelligence — Análise de Gaps e Implementação

Protocolo integrado para analisar funcionalidades de sistemas de referência de mercado,
identificar gaps, e implementá-los de forma faseada no nosso sistema.

Fontes: skill Lucy (análise competitiva) + loop-master (orquestração faseada).

---

## Quando usar este protocolo

Usar sempre que o usuário pedir:
- "leia este sistema e melhore o nosso"
- "quero paridade funcional com X"
- "o que esse concorrente tem que a gente não tem?"
- "analise este site / prints e implemente o que falta"
- gap analysis competitiva
- `/lucy` em qualquer variante

---

## Modos de operação

| Modo | Comando | Pipeline |
|------|---------|----------|
| **Padrão** | `/lucy` | Intake → extração → gap → plano → **checkpoint** → implementação → relatório |
| **Auto** | `/lucy --auto` | Igual ao padrão, **sem checkpoint** — implementa direto após plano |
| **Análise** | `/lucy analise` | Intake → extração → gap → plano → **para** (não codar) |
| **Build** | `/lucy build` | Lê `.lucy/` existente → loop de implementação → relatório |
| **Audit** | `/lucy audit` | Reaudita fase atual; não implementa features novas |
| **Continuar** | `/lucy continuar` | Lê `session-state.json` → retoma de onde parou |

**Entrada obrigatória** (exceto `build`, `audit`, `continuar`): ≥1 print ou URL do sistema de referência.

---

## Visão geral do pipeline

```
INTAKE → EXTRAÇÃO → GAP ANALYSIS → PLANO → [CHECKPOINT?] → LOOP → RELATÓRIO
```

- **`--auto` / `build`**: sem checkpoint entre plano e código.
- **Padrão `/lucy`**: após gap + plano, uma pergunta antes de codar.
- **Bloqueio real** (credenciais, decisão de produto): parar e pedir ao usuário.

---

## Fase 0 — Intake

1. Identificar o **sistema de referência** (URL, prints, docs fornecidos pelo usuário).
2. Identificar **nosso sistema** (repo, README, `package.json`, docs).
3. Inventariar inputs: imagens, URLs, `@link`.
4. Detectar modo e inicializar/atualizar `session-state.json`.
5. Tentar Firecrawl se disponível:

```bash
command -v firecrawl > /dev/null 2>&1 && firecrawl --status 2>/dev/null
```

6. Criar estrutura `.lucy/` na raiz do projeto:

```
.lucy/
├── session-state.json       # estado da sessão (fonte de retomada)
├── competitor-features.md   # features extraídas do sistema de referência
├── gap-matrix.md            # comparação com nosso sistema
├── differentiation.md       # o que temos e o referência não
├── implementation-plan.md
├── audit-log.md
├── final-report.md
└── firecrawl/               # scrape/map markdown
└── browser/                 # screenshots + manifest (browser-ai-scrape-protocol.md)
    ├── screenshots/
    ├── markdown/
    └── manifest.json
```

Adicionar `.lucy/` ao `.gitignore` (inteligência competitiva).

---

## Fase 1 — Extração

### De imagens

Ler **todas** as funções visíveis — menus, modais, tooltips, badges, planos, integrações.
Item a item, sem resumir demais.

### De URLs — ordem de fallback

Ver **`browser-ai-scrape-protocol.md`** — roteamento completo scrape + screenshots.

1. **Firecrawl scrape/map** (se autenticado) — Markdown LLM-ready
2. **Firecrawl Browser Sandbox** — SPA, auth, paginação, multi-step → `snapshot` + screenshot
3. **Playwright** (script local) — se sandbox indisponível e URL pública simples
4. **Browser MCP** — navegar seções, snapshot por área
5. **WebFetch** — último recurso páginas estáticas

**Obrigatório para `@url` sem prints do usuário:** salvar ≥1 screenshot em `.lucy/browser/screenshots/` além do markdown.

### Comandos Firecrawl

```bash
mkdir -p .lucy/firecrawl
firecrawl scrape "<url>" -o .lucy/firecrawl/home.md
firecrawl map "<url>" --search "features OR pricing OR integrations" -o .lucy/firecrawl/urls.json
firecrawl scrape "<url-features>" -o .lucy/firecrawl/features.md
```

### Saída (`competitor-features.md`)

Por feature: **ID** (`LUCY-001`…), nome, claim, evidência, categoria, **plano/tier** (se visível).

---

## Fase 2 — Gap Analysis

Pergunta central:

> Todas essas funcionalidades que o sistema de referência tem, nós já temos ou está em planejamento?

### Paralelismo (repos grandes)

Lançar **2 subagentes** `explore` em paralelo:
- **A**: mapear código/docs do nosso sistema (rotas, models, TODO, roadmap)
- **B**: processar `competitor-features.md` + evidências

Sintetizar em `gap-matrix.md`.

### Classificação — nosso sistema

| Status | Significado |
|--------|-------------|
| ✅ **Pronto** | Maduro no repo — exige evidência `path:line` ou rota |
| 🟡 **Parcial** | Incompleto, mock ou só UI |
| 📋 **Planejado** | Issue/roadmap explícito |
| ❌ **Ausente** | Sem rastro |

### Confiança (claim do sistema de referência)

| Confiança | Critério |
|-----------|----------|
| **Alta** | Print ou navegação confirma |
| **Média** | Só texto de marketing |
| **Baixa** | Inferência / buzzword |

**Priorizar:** P0/P1 × confiança Alta primeiro.

### Gap reverso

Gerar `differentiation.md`: o que **nós** temos e o sistema de referência não (ou faz pior).
Não copiar cegamente — registrar o que **não** vale replicar.

### Template `gap-matrix.md`

```markdown
# Gap Matrix — Nosso Sistema vs Sistema de Referência

> Data: YYYY-MM-DD
> Fontes: [prints, URLs, firecrawl/, browser/]

| ID | Feature | Claim | Evidência | Confiança | Plano ref. | Nosso status | Evidência nossa | Gap | Prioridade | Fase |
|----|---------|-------|-----------|-----------|------------|--------------|-----------------|-----|------------|------|
| LUCY-001 | Pipeline visual | Arrastar etapas no funil | print-2 | Alta | Advanced | ❌ Ausente | — | model + UI | P0 | 1 |

## Priorização
Ordem: P0+Alta → P0+Média → P1+Alta → …
```

---

## Fase 3 — Plano faseado

`implementation-plan.md` para features ≠ ✅ Pronto.

Por feature: o que é, para que serve, fluxo no sistema de referência, stack nossa, **DoD**, versão alvo.

### Versionamento

| Estágio | Versão | Critério |
|---------|--------|----------|
| Beta | `0.x.x` | Implementado, não maduro |
| Alpha (produção) | `1.x.x` | **Todos os critérios DoD** atendidos |

**Nunca** `1.x.x` sem DoD completo.

### Fases padrão

1. **Fundação** — auth, permissões, dados core
2. **Core parity** — features principais do sistema de referência
3. **Diferenciais** — integrações, automações, relatórios
4. **Polish** — UX, performance, observabilidade

---

## Checkpoint (padrão)

Após gap + plano, no modo padrão:

```markdown
## Lucy — pronto para implementar

- Sistema de referência: [X] | Gaps: [N] (P0: [n], P1: [n])
- Fases planejadas: [1–4]
- Confiança baixa a validar: [lista curta ou "nenhuma"]

Implemento a Fase 1 automaticamente? Responda **sim** ou use `/lucy build` / `/lucy --auto`.
```

---

## Fase 4 — Loop implementação + auditoria

### Limite por ciclo

Máx. **1 feature P0** ou **2 features P1** por iteração. Evita diff gigante e auditoria superficial.

### Ciclo por fase

```
IMPLEMENTAR → TESTAR → AUDITAR → CORRIGIR → (até 100%)
→ AUDITORIA PRODUÇÃO → gate → próxima fase ou refazer
```

### Implementar

- Commits somente se usuário pedir.
- Marcar `0.x.x` ou `1.x.x` conforme DoD.
- Atualizar `session-state.json` após cada feature.

### Auditar (checklist por fase)

**Funcional:**
- [ ] Happy path de cada feature da fase
- [ ] Edge cases (vazio, limite, duplicata, permissão negada)
- [ ] Erros acionáveis ao usuário
- [ ] Estado consistente após refresh

**Contexto / conexão:**
- [ ] Sessão/auth isolada por usuário
- [ ] WebSockets/SSE reconectam
- [ ] Cache invalidado

**Segurança:**
- [ ] `review-security` executado
- [ ] AuthZ em rotas sensíveis
- [ ] Input validado
- [ ] Secrets fora do código
- [ ] Rate limit em endpoints públicos

**Qualidade:**
- [ ] Testes passam
- [ ] Linter limpo nos arquivos tocados
- [ ] Sem regressão em features ✅ anteriores

### Definition of Done (DoD) — obrigatório para `1.x.x`

| # | Critério | Evidência |
|---|----------|-----------| 
| 1 | API/rota existe e responde corretamente | `path:line` ou curl |
| 2 | UI conectada (não mock estático) | componente + chamada real |
| 3 | Happy path testado manualmente ou E2E | nota no audit-log |
| 4 | ≥2 edge cases cobertos | lista no audit-log |
| 5 | AuthZ na rota/ação sensível | review-security OK |
| 6 | Sem 🔴 aberto na feature no audit-log | audit-log |

### Gate de produção

```markdown
## Gate Fase N — [nome]

| Critério | OK? |
|----------|-----|
| 100% features da fase com DoD 6/6 ou aceite explícito | |
| Auditoria sem 🔴 | |
| review-security executado | |
| Versões 1.x.x nas features maduras | |

Conclusão: ___%
Apto produção: SIM / NÃO
Próxima fase: SIM / NÃO
Bloqueadores: ...
```

---

## Fase 5 — Relatório final

`final-report.md`:

```markdown
# Relatório Final — Análise Competitiva

**Paridade P0+P1:** SIM / PARCIAL / NÃO

## Gaps fechados
| ID | Antes | Depois | Versão |

## Débito aceito
| ID | Motivo | Confiança |

## Diferenciação mantida
[resumo de differentiation.md]

## Veredito
[go/no-go + riscos]
```

---

## `session-state.json`

```json
{
  "version": 1,
  "reference_system": "<nome genérico do sistema analisado>",
  "our_system": "<nome do nosso projeto>",
  "mode": "default",
  "status": "building",
  "phase": 1,
  "feature_index": 3,
  "total_features": 52,
  "total_gaps": 38,
  "gaps_closed": 5,
  "last_feature_id": "LUCY-007",
  "last_audit_cycle": 2,
  "checkpoint_pending": false,
  "blocked": false,
  "blockers": [],
  "parity_verdict": null,
  "started_at": "ISO8601",
  "updated_at": "ISO8601"
}
```

---

## Retomada

1. Ler `.lucy/session-state.json` primeiro (fonte de verdade).
2. Fallback: `implementation-plan.md` + `audit-log.md`.
3. Retomar fase, `feature_index` e ciclo de auditoria correntes.

---

## Anti-padrões

- Inventar features sem evidência.
- ✅ sem evidência no código (`path:line`).
- `1.x.x` sem DoD.
- Pular `review-security` no gate de fase.
- Ignorar `differentiation.md` — não copiar tudo cegamente.
- Mencionar nomes de sistemas de mercado em documentação permanente.
