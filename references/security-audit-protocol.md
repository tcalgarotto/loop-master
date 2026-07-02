# Security Audit Protocol — red team, pentest, adversarial review

Protocolo **genérico** para o step `audit` e `gate` quando a fase toca auth,
APIs públicas, multi-tenant, pagamentos ou deploy.

O loop-master **não embute** ferramentas de pentest no pacote da skill. Ele
**orquestra** o que existir no projeto + subagents/skills do Cursor.

---

## Camadas de segurança no ciclo

| Camada | O quê | Quem executa | Minor step |
|--------|-------|--------------|------------|
| **S1 — Code review** | Auth, IDOR, injection, secrets no diff | `security-review` readonly | audit |
| **S2 — Logic review** | Bugs, regressões, contratos API | `bugbot` readonly | audit |
| **S3 — Automated tests** | pytest security, SAST, lint | `shell` | verify, audit |
| **S4 — Red team probe** | HTTP probes, tenant isolation, headers | `shell` + scripts do **projeto** | audit, gate |
| **S5 — External scan** | Scanner externo (VPS, CDN, app URL) | `shell` + integração API do **projeto** | gate (fase deploy) |
| **S6 — Browser E2E** | Playwright/Cypress security specs | `shell` | audit, gate |

**Gate de segurança:** zero findings `critical`/`high` em S1–S4 antes de marcar fase 100%.

---

## Subagents e skills (sempre disponíveis no Cursor)

| Ferramenta | Uso |
|------------|-----|
| `security-review` | Diff em auth, middleware, webhooks, RBAC |
| `review-security` skill | Prompt shape para security-review |
| `bugbot` | Lógica adversarial (complementar, não substituto) |
| `ci-investigator` | Check CI de segurança falhando |

Spawn em **paralelo** com escopos distintos (ver `orchestrator-protocol.md`).

---

## Scripts do projeto (opcional — cada repo define os seus)

O orchestrator procura, nesta ordem, e executa se existirem:

| Padrão de path | Tipo |
|----------------|------|
| `scripts/security/run-audit.sh` | Orquestrador local SAST + probe + E2E |
| `scripts/security/redteam/probe.sh` ou `probe.py` | Red team HTTP/API |
| `scripts/security/sast-check.sh` | SAST estático |
| `Makefile` target `security-redteam` | Atalho make |
| `frontend` script `test:security` | Playwright security spec |

Registrar comandos usados em `last_audit.tests` e findings em `last_audit.findings`.

### Exemplo de task no JSON

```json
{
  "id": "t-audit-redteam",
  "title": "Run project red-team probe",
  "status": "pending",
  "agent_hint": "shell",
  "files_scope": ["scripts/security/**"],
  "acceptance_criteria": [
    "probe exits 0",
    "zero critical/high in report JSON"
  ]
}
```

---

## Scanner externo (padrão integrável)

Projetos podem integrar qualquer scanner externo (ex.: API de vulnerability
management, cloud posture, ou agente em VPS). Padrão:

1. **discover/plan:** quiz pergunta se fase exige scan externo
2. **audit/gate:** `shell` roda pull script → JSON report
3. Orchestrator parseia severidades → `last_audit.findings`
4. Findings High/Critical bloqueiam gate até fix ou waiver documentado

**Não assumir** vendor específico. Config via env do projeto (`.env.example` apenas).

---

## Checklist audit (segurança — aplicável a qualquer stack)

- [ ] Rotas novas/alteradas exigem autenticação coerente
- [ ] Isolamento de tenant/dados (IDOR: ID de outro tenant → 403/404)
- [ ] Webhooks verificam assinatura **antes** de persistir
- [ ] Input validation (SQLi, mass assignment, path traversal)
- [ ] `git diff` sem secrets; `.env` não commitado
- [ ] Headers de segurança (CSP, HSTS onde aplicável)
- [ ] Red team probe do projeto: 0 critical (se script existir)
- [ ] `security-review` spawnado se diff > ~50 linhas em auth/integrations

---

## Roteamento por tipo de fase

| Fase master | Camadas mínimas |
|-------------|-----------------|
| Feature backend API | S1 + S2 + S3 |
| Auth / billing / webhooks | S1 + S2 + S3 + S4 |
| Deploy / go-live | S1–S6 conforme scripts disponíveis |
| Docs-only | S3 credentials grep |

---

## Findings — categorias

Usar `category: "security"` em `last_audit.findings`. Subtags na `note`:

- `auth`, `idor`, `injection`, `secrets`, `headers`, `dependency`, `infra`, `redteam`

---

## Anti-padrões

- Substituir `security-review` só por grep manual
- Ignorar relatório JSON de probe com falhas critical
- Colocar tokens de scanner no JSON de progresso
- Rodar red team contra produção sem flag explícita no quiz/plano
