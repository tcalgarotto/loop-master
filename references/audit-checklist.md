# Audit checklist — minor cycle (step `audit`)

Use na fase atual antes de `gate`. Registrar tudo em `last_audit` no JSON.

## 1. Testes automatizados

- [ ] Comando(s) registrados em `last_audit.tests`
- [ ] Escopo cobre arquivos alterados nesta fase
- [ ] Nenhuma falha nova vs baseline da fase anterior
- [ ] Lint/typecheck se o projeto usa (ruff, mypy, eslint)

## 2. Bugs funcionais

- [ ] Happy path da feature da fase
- [ ] Erros tratados (4xx/5xx coerentes, sem stack trace vazado)
- [ ] Estados vazios / null / tenant sem dados
- [ ] Idempotência em imports e webhooks se aplicável

## 3. Segurança

- [ ] Auth em rotas novas/alteradas
- [ ] Tenant isolation (RLS, `organization_id`, `assert_*_access`)
- [ ] IDOR: IDs de outro tenant retornam 403/404
- [ ] Input validation (SQLi, mass assignment, path traversal)
- [ ] Webhooks: assinatura verificada **antes** de DB
- [ ] Subagent `security-review` se diff > ~50 linhas em auth/integrations

## 4. Credenciais e secrets

- [ ] `git diff` sem API keys, tokens, passwords
- [ ] `.env` / `.env.example` — example sem valores reais
- [ ] Logs sem PII/secrets
- [ ] JSON de progresso sem credenciais

## 5. Contexto e handoff

- [ ] `phases[current].pct` reflete realidade (não inflar)
- [ ] `minor_cycle.tasks` status correto
- [ ] `next_actions` específicas e ordenadas
- [ ] `agent_summary` legível por agente sem histórico de chat

## 6. Regressões

- [ ] APIs públicas: contrato JSON estável ou versionado
- [ ] Fluxos das fases anteriores ainda passam smoke
- [ ] Migrations reversíveis ou documentadas

## 7. Gaps de produto

- [ ] Cada `acceptance_criteria` da fase: done ou waived com motivo
- [ ] UI expõe dados importados se a fase exige
- [ ] Docs de operação atualizadas para operadores

## 8. Qualidade de código

- [ ] Diff mínimo; sem refatoração gratuita
- [ ] Nomes e padrões do repo
- [ ] Sem TODOs críticos deixados sem ticket/nota no JSON

## Severidade e gate

| Severity | Gate |
|----------|------|
| critical | Bloqueia — must fix |
| high | Bloqueia — must fix |
| medium | Fix ou waiver documentado |
| low | Pode adiar com nota em `next_actions` |

`gate_passed: true` somente se zero critical/high abertos.
