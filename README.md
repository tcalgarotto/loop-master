# Lucy — 100% do Cérebro para Desenvolver Software

<div align="center">
  <img src="assets/lucy-hero-18x9-4k.png" alt="Lucy — orquestrador que usa 100% da capacidade do agente" width="100%" style="border-radius: 12px; margin-bottom: 24px; max-width: 720px;" />

  <p><i>"Nós humanos normais usamos 10% das capacidades do nosso cérebro. Imagina se usássemos 100%."</i><br>— Professor Norman, <b>Lucy</b> (2014)</p>

  <p>
    <a href="SKILL.md"><img src="https://img.shields.io/badge/version-2.9.1-blueviolet" alt="version"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="license"></a>
    <a href="https://cursor.com"><img src="https://img.shields.io/badge/Cursor-Agent_Compatible-blue" alt="cursor"></a>
  </p>
</div>

**Lucy transforma o Cursor Agent em um time de desenvolvimento inteiro** — memória cross-session, design premium autônomo, análise competitiva profunda e loop de autocorreção até 100% de conclusão. Não é magia: é processo rígido que o agente é obrigado a seguir.

> **Cursor Auto sozinho** = bom assistente que esquece, degrada e entrega UI genérica.  
> **Cursor + Lucy** = orquestrador com memória, gates de qualidade e estética premium embutida.

---

## O Problema — o "Slop" do modo Auto

Todo desenvolvedor já viveu isso:

| Sintoma | O que acontece |
|---------|----------------|
| **Amnésia de sessão** | IA esquece o contexto a cada nova abertura |
| **Degradação visual** | Design começa ok e vira template Bootstrap em 3 iterações |
| **Cegueira competitiva** | Não sabe o que o Linear/Notion/Stripe faz que o seu ainda não faz |
| **Coordenação manual** | Você vira PM do agente — "deixe mais bonito" 50 vezes |
| **Entrega sem gate** | Código sem auditoria de segurança, sem testes, sem DoD |

**Resultado:** 2 meses de trabalho que poderiam ser 1 semana.

---

## 1. Anti-Slop — fim do visual de template genérico

O maior problema do modo Auto (e de qualquer IA) é gerar código "preguiçoso" e interfaces com cara de template gratuito.

**Lucy resolve isso** instalando `taste-skill` + `impeccable` e forçando um pipeline invisível em toda superfície visual:

```
shape → craft → layout → colorize → critique → polish → gate
```

Você não precisa pedir "deixe mais bonito" de novo. O agente critica e refina até passar no gate — ou reentra no loop.

---

## 2. Leis de UX no piloto automático

IAs comuns não sabem o que é usabilidade. Lucy injeta **15 Laws of UX**, **12 padrões de sidebar** e a regra dos **8px** direto na inteligência de design (`references/ux-design-intelligence.md`).

Exemplos que o agente aplica sem você pedir:

| Lei | O que Lucy faz |
|-----|----------------|
| **Doherty Threshold** | Skeleton Screen antes do dado — elimina spinners feios |
| **Fitts's Law** | CTAs e botões de CRM/ERP com mínimo **44px** de alvo |
| **Miller's Law** | Máximo **7 itens** por grupo de menu, lista ou bloco de KPI |
| **Von Restorff** | **1 CTA de destaque** por tela — nunca três botões primários |
| **Jakob's Law** | Sidebar esquerda, header top, modal centro — padrões que o usuário já conhece |

---

## 3. Stack frontend — o padrão de ouro

O `/lucy init` detecta **Next.js** e instala o ecossistema de altíssimo nível automaticamente:

```
shadcn/ui              → componentes limpos e acessíveis
framer-motion          → Spring Physics (proíbe animações duras com duration fixo)
@tanstack/react-query  → cache SWR — dados instantâneos, sem tela branca
@tremor/react          → gráficos financeiros elegantes
lucide-react           → ícones vetoriais consistentes
```

Mais a stack de orquestração:

```
impeccable          → 23 comandos de design (shape, craft, critique, polish...)
ui-ux-pro-max       → design system por indústria
taste-skill         → anti-slop visual
caveman             → compressão de contexto (~70% menos tokens)
claude-mem          → memória MCP cross-session
```

---

## 4. O recurso mais apelão — Inteligência Competitiva

```bash
/lucy @https://linear.app
```

Lucy lê a interface de referência, mapeia o que eles fazem de melhor em design e usabilidade, gera um plano de gaps com evidência `path:line` e implementa — de forma autônoma ou com checkpoint, você escolhe.

```
INTAKE → EXTRAÇÃO → GAP ANALYSIS → PLANO → [CHECKPOINT] → BUILD LOOP → RELATÓRIO
```

| Modo | Comando | Comportamento |
|------|---------|---------------|
| Padrão | `/lucy @url` | Plano + confirmação antes de codar |
| Auto | `/lucy --auto @url` | Implementa direto após o plano |
| Só análise | `/lucy analise @url` | Gap report sem alterar código |

---

## Quick Start

```bash
# 1. Instalar
git clone https://github.com/tcalgarotto/lucy.git ~/.cursor/skills/lucy

# 2. No seu projeto, dentro do Cursor Agent:
/lucy init
```

**É isso.** Lucy faz o resto:
- Instala o ecossistema completo de skills
- Conduz o quiz de 6 rodadas para entender seu projeto
- Cria o plano de fases com critérios de aceite
- Arma o loop autônomo
- Nunca para até chegar a 100%

---

## Comandos

### Orquestração

```
/lucy init          → Bootstrap completo: skills + quiz + plano + loop
/lucy               → Próximo tick autônomo (continua de onde parou)
/lucy update        → Atualiza sem perder progresso
pare o loop         → Para o loop autônomo
```

### Análise Competitiva

```
/lucy @url          → Analisa o sistema de referência e implementa os gaps
/lucy --auto @url   → Mesmo pipeline, sem pausa para aprovação
/lucy analise @url  → Só gap analysis (não codar)
/lucy build         → Implementa plano existente
/lucy audit         → Reaudita fase atual
/lucy continuar     → Retoma sessão após nova abertura do editor
```

### Qualidade e Entrega

```
/lucy test          → Gera e executa testes (unit + integração + E2E)
/lucy test --ci     → Modo silencioso para CI (exit 1 se falhar)
/lucy perf          → Audit de performance (bundle, CWV, queries N+1)
/lucy perf --fix    → Audit + aplica correções automáticas de baixo risco
/lucy deploy        → Build → validate → deploy → health check
/lucy deploy --dry-run   → Simula tudo sem push real
/lucy deploy --rollback  → Reverte para último estado estável
```

### Internacionalização e Documentação

```
/lucy i18n          → Detecta strings hardcoded + configura next-intl
/lucy i18n --scan   → Só lista strings (não altera código)
/lucy docs          → Gera documentação completa (API + componentes + changelog)
/lucy docs --adr    → Registra decisão de arquitetura (ADR)
/lucy docs --changelog → Atualiza CHANGELOG.md
```

### Frontend premium

```
/lucy refazer-frontend              → Audit slop/órfãs/duplicatas + quiz design + polish (mantém URLs)
/lucy refazer-frontend --escopo todo
/lucy refazer-frontend --escopo /crm,/inbox
/lucy refazer-frontend --audit-only → Só diagnóstico
/lucy nova-pagina pricing --tipo landing
/lucy nova-pagina crm-reports --tipo app
```

### Aprendizado e regras

```
/lucy aprenda <texto>   → Evolui a Lucy global (GitHub — todos recebem no update)
/lucy regra <pedido>    → Regra P0 do projeto (imutável após update)
```

---

## Como funciona o Loop

```
           LUCY — Loop Autônomo
           ┌─────────────────────────────┐
    /lucy  │                             │
    ──────►│  HYDRATE (Second Brain)     │
           │         ↓                   │
           │  discover → plan            │
           │         ↓                   │
           │  implement → verify         │
           │         ↓                   │
           │  audit ←──── fix            │
           │    ↓           ↑            │
           │  gate ─────────┘            │
           │    ↓  (se < 100%)           │
           │  re-arm 45s → próximo tick  │
           │                             │
           │  (repete até overall = 100%)│
           └─────────────────────────────┘
```

Lucy só para quando atinge 100% com gate aprovado, você digita `pare o loop`, ou encontra bloqueio que exige decisão humana.

---

## Second Brain — Memória que Cresce

```
L0  .cursor/lucy-brain/
    ├── dev-profile.json      → suas preferências, stack, decisões
    ├── project-mind.json     → arquitetura, glossário, convenções
    └── interaction-log.jsonl → histórico de cada interação

L1  .cursor/lucy-progress.json  → handoff entre ticks
L2  claude-mem (MCP SQLite)            → busca semântica cross-session
L3  docs/LUCY-PLAN.md          → plano humano-legível
```

---

## Veredito honesto

O elogio do Gemini não é exagero total — **a arquitetura está lá**: protocolos documentados, skills encadeadas, gates de qualidade, stack premium e pipeline competitivo. O que Lucy *não* faz sozinha:

- **Substituir julgamento humano** em decisões de produto ou credenciais
- **Garantir 100% de aderência** se o agente ignorar a skill (depende do Cursor seguir o SKILL.md)
- **Funcionar sem setup** em projetos que não são Next.js (a stack frontend é condicional)

O diferencial real: **forçar o modo Auto a seguir processos** em vez de improvisar. Menos slop, menos amnésia, menos "template vibes".

---

## Migração loop-master → Lucy

Projetos com caminhos legados (`loop-master-progress.json`, `loop-master-brain/`):

```bash
bash ~/.cursor/skills/lucy/scripts/migrate-loop-master-to-lucy.sh
# ou: /lucy update  (migra automaticamente)
```

Backup em `.cursor/lucy-migration-backup-*` — nenhum dado é apagado.

---

## Referências internas

| Arquivo | Conteúdo |
|---------|----------|
| `references/premium-ui-stack.md` | Stack Next.js completa + paletas + prompts-mestre |
| `references/ux-design-intelligence.md` | 15 Laws of UX + 12 padrões sidebar + Refactoring UI |
| `references/competitive-intelligence.md` | Protocolo completo de gap analysis |
| `references/design-skills-routing-table.md` | Qual skill de design usar por superfície |
| `references/second-brain-protocol.md` | Como a memória funciona |
| `references/autonomous-orchestrator-protocol.md` | Loop autônomo |
| `MANUAL.md` | Manual completo em português |
| `references/html-native-light-protocol.md` | UI leve: dialog, HTMX, view-transition, scroll scrub |
| `references/gsap-premium-protocol.md` | GSAP timelines, ScrollTrigger |
| `references/lucy-refazer-frontend-protocol.md` | Redesign visual page-by-page |
| `references/lucy-nova-pagina-protocol.md` | Landing e páginas app do zero |
| `references/lucy-aprenda-protocol.md` | `/lucy aprenda` global |
| `references/lucy-regra-protocol.md` | `/lucy regra` por projeto |
| `CHANGELOG.md` | Histórico de versões |

---

## Versão

**v2.9.1** — redesign frontend (`/lucy refazer-frontend`), páginas novas (`/lucy nova-pagina`), aprendizado dual (`/lucy aprenda` + `/lucy regra`), UI leve + GSAP. Ver [CHANGELOG.md](CHANGELOG.md) e [release v2.9.1](https://github.com/tcalgarotto/loop-master/releases/tag/v2.9.1).

MIT License — feito com 100% do cérebro.
