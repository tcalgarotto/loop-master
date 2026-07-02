# Memory Protocol — persistência entre ticks e sessões

Loop-master usa **três camadas** de memória. Nenhuma substitui outra.

## Camadas

| Camada | Storage | Escopo | Obrigatório |
|--------|---------|--------|-------------|
| **L1 Handoff** | `.cursor/loop-master-progress.json` | Este loop / projeto | Sim |
| **L2 Semantic** | claude-mem (SQLite + Chroma) | Cross-session, cross-agent | Opcional |
| **L3 Human** | `docs/LOOP-MASTER-PLAN.md`, plan_doc | Legível por humanos | Sim |

## L1 — JSON handoff (fonte da verdade)

Todo tick **termina** atualizando L1. Campos críticos:

```json
{
  "tick_count": 42,
  "overall_pct": 65,
  "next_prompt": "/loop-master tick #43 — ...",
  "skills_installed": ["impeccable", "ui-ux-pro-max"],
  "loop_arm": { "mode": "fixed", "sentinel": "AGENT_LOOP_TICK_...", "next_wake_seconds": 240 },
  "minor_cycle": { "step": "audit", "iteration": 2 },
  "archive_summaries": [{ "tick": 41, "summary": "...", "phase": "...", "step": "fix" }],
  "doc_versions": [{ "path": "docs/LOOP-MASTER-PLAN.md", "version": "tick-41", "tick": 41 }]
}
```

### Regras L1

- **`next_prompt`** — obrigatório todo tick; próximo agente começa por ele
- `agent_summary`: 3–8 frases densas
- `archive_summaries`: manter últimos 10 ticks
- Sem transcripts, sem secrets

## L2 — claude-mem (opcional)

Instalação: `npx claude-mem install` — ver [claude-mem](https://github.com/thedotmack/claude-mem)

### Worker (obrigatório para L2 ativo)

Após install, iniciar o worker (install não-TTY não autostart):

```bash
npx claude-mem start
# UI opcional: http://localhost:37700
```

Verificar: processo escutando na porta do worker. Sem worker, L1 JSON continua como fonte da verdade; L2 fica inativo.


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

## L3 — Documentos humanos

| Evento | Atualizar |
|--------|-----------|
| Fase concluída (gate passed) | Seção status no plan_doc |
| Finding waived | `last_audit.waivers` + nota no plan_doc |
| Loop completo | `docs/LOOP-MASTER-COMPLETE.md` |

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
