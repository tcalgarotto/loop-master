# Handoff completo após subagentes — síntese obrigatória do coordinator

**Origem:** `/lucy aprenda` — 2026-07-06 (HubFU owner feedback)  
**Versão Lucy:** v2.9.36+  
**Escopo:** todo turno em que o orchestrator/parent delegou a 1+ subagentes (`Task` tool) ou workers paralelos.

---

## Mandamento P0

> Quando múltiplos subagentes completam trabalho, o **parent/coordinator** DEVE entregar handoff **completo** na resposta user-facing — **não** "subagent completed", confirmação de uma linha, nem delegar síntese ao owner ("veja o transcript").

O owner não deve abrir transcripts de subagentes para entender o que mudou.

---

## Template obrigatório (5 seções)

Usar **nesta ordem** na resposta final do turno (chat ou tick):

### 1. Per-agent summary

Para **cada** subagente/worker:

| Campo | Conteúdo |
|-------|----------|
| **Agente** | `subagent_type` ou label (`explore`, `shell`, `bugbot`, …) |
| **Task id** | ID do `Task` quando existir; senão slug curto (`fe-audit`, `migration-verify`) |
| **Investigou** | Pergunta/escopo em 1–2 frases |
| **Achou** | Fatos, root cause, bloqueios |
| **Mudou** | Arquivos/commits/deploy ou "nenhuma alteração" |

Formato sugerido: bullet por agente; link markdown para task id quando o harness expõe.

### 2. Current system state

Snapshot honesto **agora**:

- **Working** — rotas, serviços, smoke, gates que passaram
- **Broken / degraded** — erros reproduzíveis, env faltando, CI vermelho
- **Unknown** — o que não foi verificado neste turno

Separar **produção** vs **local/VPS** quando relevante.

### 3. Owner action items

Lista **numerada**; só o que o humano pode fazer:

- Cliques em dashboard (LaunchDarkly, Vercel, DNS, Stripe, …)
- Secrets / `.env` (confirmar "feito", nunca colar valor)
- Aprovações de produto ou deploy
- QA manual que Playwright não cobre

Cada item: verbo imperativo + onde clicar + critério de "feito".

### 4. Agent-can-do-next

O que o agente executa **autonomamente** se o owner:

- disser "pode seguir" / "continua"
- responder rodada owner QA (`owner-handoff-qa-protocol.md`)
- fornecer input mínimo (flag name, URL, branch)

Máx 5 bullets ordenados por impacto.

### 5. Verification checklist

Como o **owner** confirma sucesso (não só o agente):

```markdown
- [ ] `curl` / health endpoint retorna 200
- [ ] Smoke: login → dashboard carrega
- [ ] Visual: screenshot path ou URL
- [ ] LD flag X visível para tenant Y
```

Incluir comando ou URL quando possível; marcar o que o agente já validou vs pendente owner.

---

## Quando aplicar

| Cenário | Obrigatório |
|---------|-------------|
| 2+ `Task` no mesmo turno | Sim |
| 1 subagent + orchestrator alterou código | Sim |
| Tick autônomo com workers em `minor_cycle` | Sim — na resposta do tick **e** em `last_iteration.agent_summary` + `next_prompt` |
| Chat único sem subagentes | Não — resposta normal basta |
| Subagent falhou / timeout | Sim — reportar blocker + estado parcial |

---

## Persistência (além da resposta)

| Artefato | O quê gravar |
|----------|--------------|
| `brain-sync.sh capture` | Summary das 5 seções (compacto) |
| `.cursor/lucy-progress.json` | `last_iteration.agent_summary` espelha §1–2 |
| `human_blockers[]` / `owner_blocked[]` | Itens da §3 |
| `next_actions[]` | Itens da §4 |
| Handoff doc (`.lucy/*-handoff.md`) | Versão longa se tick grande |

**Não** substituir a resposta user-facing por "capturei no brain".

---

## Anti-padrões — PROIBIDO

| Frase / comportamento | Por quê |
|-----------------------|---------|
| "Subagent completed" | Zero valor para o owner |
| "Veja o transcript do agente X" | Delega trabalho cognitivo ao humano |
| Só colar `background subagent's result` sem síntese | Notification ≠ handoff |
| Listar arquivos sem working/broken | Sem estado operacional |
| Misturar owner items com agent-next sem rótulo | Owner não sabe o que fazer |
| Encerrar sem checklist | Não há como validar |

---

## Integração

| Protocolo | Relação |
|-----------|---------|
| `owner-handoff-qa-protocol.md` | §3 alimenta rodadas QA; §4 continua após respostas |
| `autonomous-orchestrator-protocol.md` | §7 handoff + `next_prompt` devem referenciar este template |
| `agent-routing-table.md` | Parent sintetiza; subagent não fala com owner |
| `docs-sync-discipline.md` | Handoff completo = memória + docs quando skill pack mudou |
| `learned/proactive-orchestration-mandate.md` | Proatividade **inclui** síntese, não só disparar workers |

---

## Exemplo mínimo (chat)

```markdown
## Subagentes neste turno

- **explore** (`audit-routes`) — mapeou rotas ERP sem RLS; achou 3 handlers sem `tenant_id`; nenhum patch (readonly).
- **shell** (`alembic-up`) — rodou `alembic upgrade head`; migration 0012 OK; backend recreate + health 200.

## Estado

- **OK:** API `/health`, login cookie, kanban lista
- **Broken:** `/erp/finance` 500 (trace em log backend)
- **Não testado:** inbox WhatsApp

## Owner — só você

1. LaunchDarkly: ligar flag `erp-native-finance` para tenant demo.
2. Confirmar `RESEND_API_KEY` no `.env` VPS (não colar aqui).

## Agente — próximo (com seu ok)

1. Corrigir 500 em finance router + smoke pytest
2. Visual gate dashboard pós-fix

## Verificação

- [x] Agent: `curl -s localhost:8000/health` → 200
- [ ] Owner: abrir `/financeiro` logado → sem 500
- [ ] Owner: flag LD visível no painel
```
