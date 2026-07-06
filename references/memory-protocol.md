# Memory Protocol — persistência entre ticks e sessões

Loop-master usa **quatro camadas** de memória. O **Second Brain (L0)** é o diferencial v2.5.

Ver protocolo completo: `references/second-brain-protocol.md`  
Mapa L0–L5: `references/memory-architecture.md`  
Knowledge-agent (L2b): `references/learned/l2-knowledge-agent-protocol.md`

## Camadas

| Camada | Storage | Escopo | Obrigatório |
|--------|---------|--------|-------------|
| **L0 Brain** | `.cursor/lucy-brain/` | Perfil dev, ADRs, log interações | **Sim — toda interação** |
| **L1 Handoff** | `.cursor/lucy-progress.json` | Este loop / projeto | Sim |
| **L2 Semantic** | claude-mem MCP | Cross-session, busca semântica | **Opcional** (opt-in) |
| **L3 Human** | PLAN + INDEX + brain/INDEX.md | Legível por humanos | Sim |

## L1 — JSON handoff (fonte da verdade)

Todo tick **termina** atualizando L1. Campos críticos:

```json
{
  "tick_count": 42,
  "overall_pct": 65,
  "next_prompt": "/lucy tick #43 — ...",
  "skills_installed": ["impeccable", "ui-ux-pro-max"],
  "loop_arm": { "mode": "fixed", "sentinel": "AGENT_LOOP_TICK_...", "next_wake_seconds": 240 },
  "minor_cycle": { "step": "audit", "iteration": 2 },
  "archive_summaries": [{ "tick": 41, "summary": "...", "phase": "...", "step": "fix" }],
  "doc_versions": [{ "path": "docs/LUCY-PLAN.md", "version": "tick-41", "tick": 41 }]
}
```

### Regras L1

- **`next_prompt`** — obrigatório todo tick; próximo agente começa por ele
- `agent_summary`: 3–8 frases densas
- `archive_summaries`: manter últimos 10 ticks
- Sem transcripts, sem secrets

## L2 — claude-mem (opt-in desde v2.9.14)

**Padrão desabilitado.** Habilitar: `LUCY_CLAUDE_MEM=1` + `init.sh` + MCP cadastrado + worker.

Ver [claude-mem](https://github.com/thedotmack/claude-mem) e `second-brain-protocol.md`.

### Init + cada sessão (só se L2 ativo)

| Momento | Ação |
|---------|------|
| `init.sh` | `npx claude-mem install` + `start` **somente se** `LUCY_CLAUDE_MEM=1` |
| Início de tick | `search(query="<target> <current_phase>", limit=5)` |
| Fim de tick | capture compacto (paths, findings, decisões quiz) |
| Nova sessão Cursor | Re-hydrate L1 + claude-mem search antes de agir |
| `memory_sync` JSON | `claude_mem: disabled` (padrão) ou `running` |

Registrar em JSON:

```json
"memory_sync": {
  "claude_mem": "disabled",
  "last_sync_at": "2026-07-03T00:00:00Z"
}
```

Valores: `disabled` | `pending` | `installed` | `running` | `failed`

### Worker (só se L2 opt-in)

Após install, iniciar o worker (install não-TTY não autostart):

```bash
export LUCY_CLAUDE_MEM=1
npx claude-mem start
# UI opcional: http://localhost:37700
```

Sem worker ou sem MCP: L0 + L1 JSON continuam como fonte da verdade; L2 ignorado silenciosamente.

**Setup NVIDIA:** `references/claude-mem-nvidia-setup.md` (build.nvidia.com + openrouter provider).

### Concorrência L1 — multi-sessão

| Cenário | Seguro? | Como |
|---------|---------|------|
| 3 chats editando `lucy-progress.json` | ❌ | **Proibido** — corrupção JSON |
| 3 chats em arquivos diferentes + 1 writer L1 | ✅ | Rótulos `[design]`/`[integration]`/`[security]` no `next_prompt` |
| 3 chats só L2 search + observation_add | ✅ | L2 append-only; L1 read-only nas secundárias |
| C62 + VPS mesmo projeto | ⚠️ | L2 **não** sincroniza entre hosts — cada máquina tem índice local |

```
1. Ler L1 inteiro
2. Se claude-mem ativo:
   - search(query="<target> <current_phase>", limit=5)
   - timeline se observação relevante encontrada
3. Merge resumo em memory_refs[] — só IDs + 1 linha cada
```

### Capture (fim de tick)

Registrar observação compacta (se hook disponível):
- O que mudou (paths)
- Findings abertos/fechados
- Decisões de produto do quiz

### Privacidade

- Tags `<private>` em prompts sensíveis
- Nunca gravar `.env`, tokens, PII em memória
- JSON `quiz_answers` sem dados pessoais identificáveis

## L3 — Documentos humanos + INDEX

| Evento | Atualizar |
|--------|-----------|
| Fase concluída (gate passed) | `plan_doc` + INDEX ✅ |
| Finding waived | `last_audit.waivers` + INDEX 👤 |
| Skill instalada | INDEX ✅ em skills ecosystem |
| Loop completo | `docs/LOOP-MASTER-COMPLETE.md` + INDEX ✅ |
| Todo tick | `docs/LUCY-INDEX.md` — emojis ✅ ⏳ 🔮 👤 |

### INDEX (`docs/LUCY-INDEX.md`)

Legenda obrigatória:
- ✅ OK — pronto / concluído
- ⏳ Pendente — em andamento
- 🔮 Futuro — próxima fase
- 👤 Human — blocker ou decisão humana

Orchestrator **sincroniza INDEX a cada tick** junto com L1 JSON.

## caveman — compressão

Quando contexto JSON crescer (>8KB):

1. `/caveman-compress` em `agent_summary` e notas longas de tasks
2. Arquivar ticks antigos em `archive_summaries[]` (últimos 5 ticks detalhados)
3. Manter `next_actions` e `findings` open sempre legíveis

## Recuperação de sessão nova

Agente sem histórico de chat deve:

1. Ler L1
2. Ler plan_doc + context_files
3. Query L2 se disponível
4. **Não** replanejar se step ∈ {implement, verify, audit, fix, gate}

## delivery_contract — contrato de 100%

```json
"delivery_contract": {
  "status": "in_progress | complete | blocked_human",
  "target_pct": 100,
  "acceptance_summary": "Feature X production-ready with security gate",
  "phases_required": ["foundation", "api", "ui", "go-live"],
  "completed_phases": ["deploy"],
  "blocked_on_human": false,
  "blocked_reason": null
}
```

**Loop só para** quando:
- `overall_pct === 100`
- `delivery_contract.status === "complete"`
- `loop_status = "stopped"` (manual ou auto)

Auto-stop: orchestrator marca complete e desarma sentinel.
