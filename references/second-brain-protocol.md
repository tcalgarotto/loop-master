# Second Brain Protocol — memória viva dentro do Cursor

O loop-master inclui um **segundo cérebro**: agente de memória que roda **dentro** do Cursor,
acumula consciência sobre projeto + dev a cada interação, e alimenta ticks futuros.

Equivalente operacional ao chat Hermes que grava contexto a cada mensagem — mas nativo na skill.

---

## Arquitetura — 4 camadas

| Camada | Storage | O que guarda | Quando | Obrigatório |
|--------|---------|--------------|--------|-------------|
| **L0 Brain** | `.cursor/lucy-brain/` | Perfil dev, decisões, log | **Toda interação** | **Sim** |
| **L1 Handoff** | `lucy-progress.json` | Tick, fases, next_prompt | Todo tick | **Sim** |
| **L2 Semantic** | claude-mem MCP | Busca semântica cross-session | Hydrate + capture | **Opcional** |
| **L3 Human** | PLAN + INDEX + brain/INDEX.md | Legível por humanos | Sync contínuo | **Sim** |

```
Usuário → /lucy
            │
            ├─ HYDRATE (início)
            │    ├─ brain-sync.sh hydrate          ← sempre
            │    └─ claude-mem search (se L2 ativo) ← opt-in
            │
            ├─ TRABALHAR (tick ou chat)
            │
            └─ CAPTURE (fim — obrigatório)
                 ├─ brain-sync.sh capture --summary ...  ← sempre
                 └─ claude-mem observation_add (se L2)   ← opt-in
```

---

## L2 claude-mem — opt-in (v2.9.14+)

**Padrão:** desabilitado. L0 + L1 cobrem handoff e memória local sem worker em background.

**Habilitar:**

```bash
export LUCY_CLAUDE_MEM=1
bash .cursor/skills/lucy/scripts/init.sh
# Cadastrar MCP claude-mem no Cursor (plugin ou mcp.json)
npx claude-mem start   # worker local
```

**Desabilitar / remover:**

```bash
npx claude-mem stop    # ou kill worker
unset LUCY_CLAUDE_MEM
# Opcional: rm -rf ~/.claude-mem  # SQLite + Chroma (~MB) — só se não usar em outro projeto
```

Sem L2: `brain-sync.sh` não emite erros; agente **não** deve chamar MCP claude-mem.

**Setup NVIDIA (build.nvidia.com):** `references/claude-mem-nvidia-setup.md` — openrouter provider + base URL NIM.

---

## Multi-sessão paralela — design / integração / security

Sessões Cursor simultâneas são seguras quando cada concern respeita **single-writer** por artefato:

| Artefato | Paralelo? | Regra |
|----------|-----------|-------|
| L0 `rules/` | ❌ | Append só via `/lucy regra` — uma sessão por vez |
| L1 `lucy-progress.json` | ❌ | **Single writer**; demais sessões leem + usam L2 search |
| L2 claude-mem | ✅ | Índice semântico compartilhado na mesma máquina |
| `preview/`, `src/` (paths distintos) | ✅ | Dividir arquivos por sessão |
| L3 INDEX / PLAN | ❌ | Só sessão orquestradora ou fim de tick |

**Handoff:** prefixar `next_prompt` com rótulos — `[design]`, `[integration]`, `[security]` — e declarar qual sessão é single writer L1.

Detalhes: `claude-mem-nvidia-setup.md` § Multi-sessão · `memory-protocol.md` § Concorrência L1.

---

## Diretório `.cursor/lucy-brain/`

| Arquivo | Conteúdo |
|---------|----------|
| `STATE.json` | interaction_count, consciousness_level, topics_active |
| `dev-profile.json` | Preferências do dev, fatos aprendidos, estilo |
| `project-mind.json` | ADRs compactos, convenções, glossary, key_paths |
| `interaction-log.jsonl` | Append-only — uma linha por interação |
| `INDEX.md` | Status ✅ ⏳ 🔮 👤 das camadas de memória |

**consciousness_level** = min(100, interaction_count) — proxy de quanto o agente "conhece" o projeto.

---

## Ciclo obrigatório — TODA invocação `/lucy`

### 1. HYDRATE (antes de agir)

```bash
bash .cursor/skills/lucy/scripts/brain-sync.sh hydrate
```

**Sempre** ler L0 + rules P0. **Se L2 ativo** (`LUCY_CLAUDE_MEM=1` + worker + MCP):

```
1. session_start_context(project="<repo-name>", platformSource="cursor")
2. search(query="<target> <current_phase> <user last intent>", limit=5, platformSource="cursor")
3. timeline(anchor=<id>) — só se search retornar hit relevante
4. get_observations([ids]) — só IDs filtrados
```

Merge em `memory_refs[]` no progress JSON. **Não agir** sem hydrate L0.

### 2. CAPTURE (antes de encerrar turno)

```bash
bash .cursor/skills/lucy/scripts/brain-sync.sh capture \
  --kind tick \
  --summary "3-8 frases: o que mudou, decisões, findings" \
  --paths "src/foo.tsx,docs/bar.md" \
  --decisions "Usar tokens OKLCH do theme-tokens.css" \
  --dev-note "Dev prefere respostas em PT-BR, commits focados"
```

**Se L2 ativo**, agente **também** chama:

```
observation_add(
  content="<narrativa compacta>",
  kind="lucy-tick",
  metadata={tick, phase, paths, consciousness_level}
)
```

Para chat casual (não tick):

```
observation_add(kind="lucy-chat", ...)   # só se L2
brain-sync.sh capture --kind chat --summary "..."
```

---

## O que capturar (checklist)

| Tipo | Exemplos | Onde |
|------|----------|------|
| **Decisão arquitetura** | "Multitenancy via company_id" | project-mind.json |
| **Preferência dev** | "Não fazer force push" | dev-profile.json |
| **Convenção** | "FE usa PageHeader + tokens" | project-mind.conventions |
| **Blocker** | "Serviço externo bloqueou requisição" | human_blockers + brain |
| **Fato domínio** | "CRM referência = parity alvo" | project-mind.glossary |
| **Mudança código** | paths touched | interaction-log.jsonl |

---

## Consciência crescente

A cada interação o agente fica mais "consciente":

| Interações | Comportamento esperado |
|------------|------------------------|
| 1–5 | Pergunta mais, aprende stack |
| 6–20 | Reusa convenções do project-mind |
| 21–50 | Antecipa preferências do dev |
| 50+ | Evita repetir erros/decisões revertidas |

Orchestrator deve **citar** fatos do brain quando relevante:
> "Pelo brain (#34): você prefere diffs mínimos — vou manter escopo fechado."

---

## Integração com ticks autônomos

- **Sempre** brain-sync hydrate no início
- **Sempre** brain-sync capture no fim
- claude-mem L2 é extensão semântica opcional — L0+L1 bastam para a maioria dos projetos

---

## Privacidade

- Nunca gravar: `.env`, tokens, senhas, PII
- Tags `<private>` em observation_add para prompts sensíveis
- dev-profile: preferências, não dados pessoais identificáveis

---

## Comandos

| Comando | Ação |
|---------|------|
| `brain-sync.sh init` | Criar diretório brain |
| `brain-sync.sh hydrate` | Carregar contexto |
| `brain-sync.sh capture --summary "..."` | Gravar interação |
| `brain-sync.sh status` | Health check |

Init v2.5 roda `brain-sync.sh init` + `install-hooks.sh` automaticamente.

---

## Hooks Cursor (Opção B — memória em todo chat Agent)

Instalados em `.cursor/hooks/lucy/` pelo `install-hooks.sh`:

| Evento | Script | Comportamento |
|--------|--------|---------------|
| `sessionStart` | `brain-hydrate.sh` | Hidrata brain L0 → `additional_context` |
| `stop` | `brain-capture.sh` | Captura resumo do turno (sem followup) |

Fonte na skill: `hooks/hooks.template.json`  
Reinstalar: `bash .cursor/skills/lucy/scripts/install-hooks.sh`

**Nota:** hooks só aplicam ao **Agent Chat**, não ao Tab inline. Hooks **não** chamam claude-mem — só L0.

## Anti-padrões

- Terminar turno sem capture L0
- Ignorar dev-profile em decisões de estilo/escopo
- Duplicar fatos já em project-mind (atualizar, não append infinito)
- Substituir L1 JSON pelo brain — são complementares
- Chamar MCP claude-mem quando L2 desabilitado (ruído / falhas)
- Instalar worker claude-mem sem opt-in (`LUCY_CLAUDE_MEM=1`)
