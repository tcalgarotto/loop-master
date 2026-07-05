# Migrations + recreate backend — proativo, sem pedir permissão

**Origem:** `/lucy aprenda` — 2026-07-05  
**Autorização do owner (verbatim):** *"Sempre que precisar rodar migration e/ou recriar backend, faça isso."*

---

## Regra P0

Quando uma mudança de backend/schema **exige** migration ou restart, o agente **executa na hora** — não pergunta, não deixa como "próximo passo" para o owner.

| Gatilho | Ação obrigatória |
|---------|------------------|
| Nova revision Alembic criada/puxada | `alembic upgrade head` imediatamente |
| Modelo SQLAlchemy alterado sem revision | Gerar revision + `upgrade head` |
| Código backend alterado (env, deps, routers, workers) | Recriar/restartar o serviço backend |
| `.env` backend alterado (novo token, flag) | Recreate para o container reler o env |
| Endpoint 500 por coluna/tabela ausente | Diagnosticar → migration → upgrade → retest |

## Comandos padrão (Docker Compose)

```bash
cd <projeto>
# migrations — dentro do container se ele estiver de pé, senão run --rm
docker compose exec backend alembic upgrade head \
  || docker compose run --rm backend alembic upgrade head

# recreate backend (relê env, aplica código novo)
docker compose up -d --force-recreate backend
```

Sem Docker: `alembic upgrade head` no venv + restart do processo (systemd/supervisor/pm2).

## Pós-ação obrigatória (verify)

1. **Health** — `curl -sf http://127.0.0.1:<porta>/health` (ou endpoint equivalente) até responder 200.
2. **Migration status** — `alembic current` confere com `head`.
3. **Smoke do que motivou a mudança** — testar o endpoint/feature que exigiu a migration.
4. Logs: `docker compose logs backend --tail 50` se health falhar.

## O que continua exigindo confirmação

Este mandato **não** cobre operações destrutivas (ver exceções em `proactive-orchestration-mandate.md`):

- `alembic downgrade` em ambiente com dados
- Drop de tabela/coluna com dados de produção
- Recreate de **banco de dados** (postgres/redis) — só o serviço de aplicação
- Deploy em produção externa

## Anti-padrões — PROIBIDO

| Frase proibida | Fazer em vez disso |
|----------------|-------------------|
| "Quer que eu rode a migration?" | Rodar `alembic upgrade head` + reportar resultado |
| "Depois você precisa recriar o backend" | Recriar agora + verificar health |
| Encerrar tick com migration pendente | Migration + recreate + smoke fazem parte do Definition of Done |

## Cross-links

- `learned/proactive-orchestration-mandate.md` — mandato geral + exceções
- `learned/autonomous-routing-contract.md` — enforcement é disciplina do agente
