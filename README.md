# Lucy — 100% do Cérebro para Desenvolver Software

<div align="center">
  <img src="assets/nanobanana.png" alt="Lucy Nano Banana Mascot" width="320" style="border-radius: 24px; margin-bottom: 20px;" />

  <p><i>"Nós humanos normais usamos 10% das capacidades do nosso cérebro. Imagina se usássemos 100%."</i><br>— Professor Norman, <b>Lucy</b> (2014)</p>

  <p>
    <a href="SKILL.md"><img src="https://img.shields.io/badge/version-2.7.0-blueviolet" alt="version"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="license"></a>
    <a href="https://cursor.com"><img src="https://img.shields.io/badge/Cursor-Agent_Compatible-blue" alt="cursor"></a>
  </p>
</div>

**Lucy é o orquestrador de IA que usa 100% da capacidade do seu agente** — memória cross-session, design premium autônomo, análise competitiva profunda, loop de autocorreção até 100% de conclusão. Uma skill sob medida para levar seu ambiente de desenvolvimento ao nível máximo com a ajuda da nossa mascote **Nano Banana**! 🍌⚡

---

## O Problema

Todo desenvolvedor já viveu isso:

- IA esquece o contexto a cada nova sessão
- Design começa premium e vai degradando com cada iteração
- Não sabe o que o sistema de referência de mercado faz que o seu ainda não faz
- Perde horas coordenando o que a IA fez, o que falta fazer, e onde parou
- Código entregue sem auditoria de segurança, sem gate de qualidade

**Resultado:** 2 meses de trabalho que poderiam ser 1 semana.

---

## A Solução — Lucy

Como no filme, **Lucy não tem limites artificiais**.

Enquanto outros agentes param no fim da janela de contexto, Lucy:

| Capacidade | Como funciona |
|-----------|---------------|
| 🧠 **Memória persistente** | Second Brain de 4 camadas — lembra de tudo entre sessões |
| 🎨 **Design premium autônomo** | 12+ skills de design encadeadas: audit → refina → aprova |
| 🔍 **Inteligência competitiva** | Lê sistemas de referência, mapeia gaps e implementa automaticamente |
| 🔄 **Loop até 100%** | Autocorrição contínua: implement → audit → fix → gate |
| ⚡ **Zero-config** | Um comando inicia tudo — quiz, plano, stack, hooks |
| 🛡️ **Auditoria obrigatória** | `review-security` + `bugbot` em todo gate de fase |

---

## Quick Start

```bash
# 1. Instalar
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/lucy

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

### Controle

```
pare o loop         → Para o loop autônomo
```

---

## O que o `/lucy init` instala

```
Stack de desenvolvimento:
├── impeccable          → 23 comandos de design (shape, craft, critique, polish...)
├── ui-ux-pro-max       → Design system por indústria
├── taste-skill         → Anti-slop: interfaces que não parecem template
├── caveman             → Compressão de contexto (70% menos tokens)
└── claude-mem          → Memória MCP cross-session

Stack frontend (detecta Next.js automaticamente):
├── shadcn/ui           → Componentes premium acessíveis
├── framer-motion       → Spring physics, AnimatePresence, layoutId
├── @tremor/react       → Gráficos financeiros limpos
├── @tanstack/react-query → Cache SWR, dados assíncronos sem spinner
└── lucide-react        → Ícones vetoriais consistentes

Inteligência:
├── Second Brain        → .cursor/loop-master-brain/ (perfil dev + projeto)
├── competitive-intel   → Pipeline /lucy para análise de gaps
└── design-intelligence → Laws of UX + Refactoring UI + 12 padrões sidebar
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

**Nenhuma intervenção manual necessária.** Lucy só para quando:
- Atinge 100% com gate de produção aprovado
- Você digita `pare o loop`
- Encontra um bloqueio que exige decisão humana (e avisa)

---

## Inteligência Competitiva — `/lucy @url`

> *"Você já tem os dados. Agora veja o que o mercado tem que você não tem."*

```
/lucy @https://sistema-de-referencia.com [prints]
```

Lucy executa automaticamente:

```
1. INTAKE        → identifica o sistema e o seu projeto
2. EXTRAÇÃO      → lê todas as funcionalidades (Firecrawl / Browser MCP / fetch)
3. GAP ANALYSIS  → compara item a item com seu código (path:line como evidência)
4. PLANO         → prioriza por P0/P1 + confiança Alta/Média
5. CHECKPOINT    → mostra o plano, pede confirmação
6. BUILD LOOP    → implement → audit → fix → gate por fase
7. RELATÓRIO     → gaps fechados, débito aceito, veredito de produção
```

Cada feature implementada é versionada:
- `0.x.x` — Beta (implementado, não maduro)
- `1.x.x` — Alpha (DoD 6/6 atendido, pronto para produção)

---

## Design Premium — Automático

Lucy não entrega interfaces medianas. Cada tick de UI passa por:

```
ui-ux-pro-max  → design system por indústria
     ↓
impeccable     → shape → craft → layout → colorize → critique
     ↓
shadcn/ui      → componentes acessíveis e consistentes
     ↓
framer-motion  → spring physics (nunca duration fixo)
     ↓
impeccable     → polish → optimize → gate
```

**Leis de UX aplicadas automaticamente:** Miller's Law (7 itens max por grupo), Fitts's Law (44px targets), Doherty Threshold (skeleton antes de spinner), Von Restorff (1 CTA de destaque por tela).

---

## Second Brain — Memória que Cresce

```
L0  .cursor/loop-master-brain/
    ├── dev-profile.json      → suas preferências, stack, decisões
    ├── project-mind.json     → arquitetura, glossário, convenções
    └── interaction-log.jsonl → histórico de cada interação

L1  .cursor/loop-master-progress.json  → handoff entre ticks
L2  claude-mem (MCP SQLite)            → busca semântica cross-session
L3  docs/LOOP-MASTER-PLAN.md          → plano humano-legível
```

Na próxima sessão, Lucy lembra:
- O que foi implementado e o que falta
- Suas preferências de código
- As decisões de arquitetura tomadas
- Os blockers pendentes

---

## Referências internas

| Arquivo | Conteúdo |
|---------|---------|
| `references/premium-ui-stack.md` | Stack Next.js completa + paletas + prompts-mestre |
| `references/ux-design-intelligence.md` | 15 Laws of UX + 12 padrões sidebar + Refactoring UI |
| `references/competitive-intelligence.md` | Protocolo completo de gap analysis (/lucy analise) |
| `references/design-skills-routing-table.md` | Qual skill de design usar por superfície |
| `references/second-brain-protocol.md` | Como a memória funciona |
| `references/autonomous-orchestrator-protocol.md` | Os 7 mandamentos do loop autônomo |
| `MANUAL.md` | Manual completo em português |

---

## Versão

**v2.7.0** — Lucy completa: design intelligence v2.7 (15 Laws of UX + 12 padrões sidebar), inteligência competitiva (/lucy analise), testes autônomos (/lucy test), audit de performance (/lucy perf), deploy com rollback (/lucy deploy), i18n (/lucy i18n), documentação (/lucy docs), CI hook, template gallery e Second Brain 4 camadas.

MIT License — feito com 100% do cérebro.
