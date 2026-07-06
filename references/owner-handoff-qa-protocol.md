# Protocolo — Owner Handoff QA (pós-loop)

**Quando usar:** `overall_pct` atinge teto do agente (~90–95%), `loop_status: paused_owner`, ou `delivery_contract.status: in_progress` com itens `owner_blocked`.

**Objetivo:** Não encerrar sessão em silêncio. Rodar **quiz de decisão por rodadas**, usar **todo o contexto da sessão** (logs `.lucy/*`, diffs, `lucy-progress.json`, handoff doc) como fonte das perguntas, persistir respostas na memória, e **continuar executando** tudo que não depende do humano até `delivery_contract.complete`.

**Pré-requisito (turnos com subagentes):** antes de iniciar rodadas QA, o coordinator deve entregar o handoff completo de 5 seções em `learned/multi-subagent-handoff-synthesis.md` (per-agent summary, estado, owner items, agent-next, checklist). Owner QA **complementa** a síntese — não a substitui.

---

## Gatilho (obrigatório)

Quando **qualquer** condição for verdadeira:

1. Agente declarou trabalho automatizado encerrado (`paused_owner`, `honest_cap_without_owner`)
2. Loop parou aguardando env/credenciais/decisão de produto
3. Owner invocou `/lucy continuar` após handoff

**Não** re-armar loop cego enquanto QA owner incompleto — usar `loop_status: paused_owner` até `owner_qa.complete: true` ou owner pedir `pare o loop`.

---

## Pipeline por turno

### 1. HYDRATE sessão inteira

- Ler `.lucy/lucy-100-handoff.md` (ou handoff doc do tick)
- Ler `functional_100.delivery_contract.criteria[]` em `.cursor/lucy-progress.json`
- Scan logs `.lucy/f*.md`, `design-refactor-log.md`, último `next_prompt`
- brain-sync `hydrate`

### 2. Montar rodada N

Rodadas **sequenciais** (uma por turno), agrupadas por tema:

| Rodada | Tema típico | Exemplo IDs |
|--------|-------------|-------------|
| R1 | Env / secrets / deploy VPS | `oh_r1_multitenant_strict`, `oh_r1_secrets`, `oh_r1_backend_restart` |
| R2 | LaunchDarkly / flags | `oh_r2_ai_tenant_data`, `oh_r2_erp_native` |
| R3 | QA manual funcional | `oh_r3_assistente_e2e`, `oh_r3_smoke_kanban` |
| R4 | Decisões produto/design | `oh_r4_whatsapp_skin`, `oh_r4_inbox_skin`, `oh_r4_live_mode_vps` |
| R5 | Ops / migração / prioridade 100% | `oh_r5_alembic`, `oh_r5_commit_deploy` |

**Fonte das perguntas:** extrair de `owner_blocked[]`, handoff §, e critérios parciais — **nunca** quiz genérico de init.

### 3. AskQuestion (formato)

Cada pergunta **deve** incluir opções padronizadas:

| Opção | Significado |
|-------|-------------|
| **Concluído** | Owner fez; agente valida se possível (health, smoke script) |
| **Adiar** | Explicitamente postergado; registrar data/motivo em memória |
| **Preciso de ajuda** | Agente responde com passo a passo (credenciais, LD console, docker) **neste turno ou próximo** |
| **N/A** | Não se aplica a este ambiente |

Para **credenciais / cadastros**:

- Incluir instruções curtas no `label` ou follow-up imediato se escolher "Preciso de ajuda"
- **Nunca** pedir valor do secret no chat — só confirmar "Concluído" ou placeholder em `.env.example`
- Sugerir: "Concluído / Adiar / Preciso de ajuda / N/A"

### 4. Persistir respostas

Após cada rodada:

```json
"owner_qa": {
  "complete": false,
  "current_round": 2,
  "round_1": {
    "oh_r1_multitenant_strict": "adiar",
    "answered_at": "ISO8601"
  }
}
```

Em `.cursor/lucy-progress.json` + brain-sync `capture` com summary das decisões.

Regras imutáveis do projeto → `/lucy regra` se owner disser "sempre/nunca".

### 5. Executar o possível (mesmo turno ou próximo)

Após respostas da rodada:

- **Concluído** → smoke/validação automatizada; marcar critério `pct` subindo
- **Adiar** → manter `owner_blocked`; não bloquear outras trilhas
- **Preciso de ajuda** → tutorial + re-perguntar só aquele ID na rodada seguinte
- **Live Mode na VPS** (`oh_r4_live_mode_vps` ou pedido explícito) → **neste turno:** carregar `learned/vps-live-mode-owner-guide.md`; subir dev server se aplicável; passo a passo tunnel SSH ou Cursor Ports — **nunca** só "MCP não funciona"
- Código/tests/deploy que **não** dependem do item adiado → **continuar**

Repita rodadas até `owner_qa.complete: true` **ou** todos critérios `done` **ou** só restarem itens explicitamente adiados com owner ciente.

### 6. Fechar 100%

Quando checklist owner OK:

1. `delivery_contract.status: "complete"`
2. `functional_100.overall_pct: 100`
3. `loop_status: stopped` (motivo: delivered)
4. brain-sync capture final
5. Opcional: `/lucy docs --changelog` se owner pedir

---

## Anti-padrões

- Encerrar com "subagent completed" ou pedir ao owner que leia transcripts — ver `learned/multi-subagent-handoff-synthesis.md`
- Parar em `paused_owner` **sem** iniciar owner QA
- Perguntas de init quiz (`r1_goal`, etc.) no handoff
- Imprimir secrets ou colar `.env` no progress JSON
- Marcar 100% com critérios `owner_blocked` ainda abertos sem "Adiar" explícito
- Re-arm loop 45s enquanto aguarda respostas do owner na mesma sessão

---

## Relacionados

- `quiz-protocol.md` — init only (7 rodadas)
- `lucy-regra-protocol.md` — decisões locais imutáveis
- `autonomous-orchestrator-protocol.md` — contrato 100%, loop states
- `mcp-integrations-setup-guide.md` — Round 3 init; handoff R2 flags
