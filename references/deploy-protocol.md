# Deploy Protocol — `/lucy deploy`

Pipeline autônomo de deploy com validação pré-deploy, rollback automático e health check pós-deploy.

---

## Quando usar

- `delivery_contract.status === "complete"` (após loop atingir 100%)
- Usuário pedir `/lucy deploy`
- Gate de fase com `apto_producao: SIM` e usuário confirmar deploy

---

## Modos

| Comando | Pipeline |
|---------|----------|
| `/lucy deploy` | Build → validate → deploy → health check → relatório |
| `/lucy deploy --dry-run` | Simula tudo sem fazer push real |
| `/lucy deploy --rollback` | Reverte para último estado estável |
| `/lucy deploy --stage` | Deploy para ambiente de staging (não produção) |

---

## Fase 0 — Detecção de alvo

Lucy detecta automaticamente o destino de deploy com base no projeto:

```bash
# Ordem de detecção
1. Ler .cursor/lucy-progress.json → delivery_contract.deploy_target
2. Verificar: Dockerfile, docker-compose.yml → VPS/container
3. Verificar: vercel.json, next.config.js → plataforma serverless
4. Verificar: package.json scripts (build, start) → inferir destino
5. Se não detectado: AskQuestion com opções [VPS SSH, serverless, container, manual]
```

Salvar em `deploy_config` no JSON de progresso.

---

## Fase 1 — Validação pré-deploy (obrigatória, não pular)

```
✓ Build local sem erros
✓ Testes passando (se test-protocol.md disponível: /lucy test --ci)
✓ impeccable detect → zero critical
✓ review-security diff → zero 🔴
✓ Variáveis de ambiente verificadas (sem secrets hardcoded)
✓ .env.production existe e está no .gitignore
```

Se qualquer item falhar → **bloqueio imediato** + AskQuestion antes de prosseguir.

---

## Fase 2 — Build de produção

```bash
# Next.js
npm run build
# Verificar: sem erros, bundle size aceitável (warning se > 500kB por chunk)

# Docker
docker build -t app:$(git rev-parse --short HEAD) .
# Tag com hash do commit para rastreabilidade

# Variáveis de ambiente
# Verificar .env.production — nunca logar valores, só chaves presentes/ausentes
```

---

## Fase 3 — Deploy por destino

### VPS via SSH

```bash
# Template — adaptar ao projeto
ssh $DEPLOY_HOST "cd $DEPLOY_PATH && git pull origin main && npm install --production && pm2 restart app"

# Com Docker
ssh $DEPLOY_HOST "docker pull $IMAGE && docker stop app || true && docker run -d --name app --restart=always $IMAGE"
```

### Serverless (auto-detectado)

```bash
# Detectar CLI disponível e usar
npx vercel --prod   # ou alternativa detectada
```

### Container / docker-compose

```bash
docker-compose pull && docker-compose up -d --no-build
```

### Manual (fallback)

Gerar `DEPLOY.md` com instruções passo-a-passo específicas para o projeto detectado.

---

## Fase 4 — Health Check pós-deploy

Executar em loop por até **3 minutos** (36 tentativas × 5s):

```bash
# HTTP check
curl -sf $DEPLOY_URL/health || curl -sf $DEPLOY_URL/api/health || curl -sf $DEPLOY_URL

# Critérios de sucesso
HTTP 200 em ≤ 3s

# Falha → rollback automático (ver Fase 5)
```

Verificar também:
- [ ] Rotas críticas respondem (inferir de `package.json` / rotas do projeto)
- [ ] Sem erros 5xx nos primeiros 60s (se logs acessíveis)

---

## Fase 5 — Rollback automático

Acionado se health check falhar após 3 minutos:

```bash
# VPS / Docker: reverter para imagem anterior
docker stop app && docker run -d --name app $PREVIOUS_IMAGE

# Git: revert do commit de deploy
git revert HEAD --no-edit && git push

# serverless: revert de deployment anterior via CLI
```

Registrar em `deploy_log.md`:
```markdown
## Deploy YYYY-MM-DD HH:MM — FALHOU
- Commit: <hash>
- Erro: <mensagem do health check>
- Rollback: executado / manual necessário
- Ação: <o que o usuário deve fazer>
```

---

## Fase 6 — Relatório de deploy

```markdown
## Deploy Report — <projeto>

**Data:** YYYY-MM-DD HH:MM
**Commit:** <hash> — <mensagem>
**Destino:** <url ou servidor>
**Build:** ✅ OK | Bundle: <size>
**Deploy:** ✅ OK | Duração: <Xs>
**Health check:** ✅ OK | Resposta: <Xms>

### Métricas
- Downtime estimado: <X>s
- Versão anterior: <tag/hash>
- Rollback disponível: SIM

### Próximos passos recomendados
- [ ] Monitorar logs por 30min
- [ ] Verificar alertas de erro
- [ ] Notificar equipe
```

---

## Integração com o loop

O deploy é o **último gate** antes de `delivery_contract.status = "complete"`.

```json
"deploy_config": {
  "target": "vps|serverless|container|manual",
  "url": "https://...",
  "health_endpoint": "/health",
  "last_deploy_at": "ISO8601",
  "last_deploy_hash": "abc1234",
  "last_deploy_status": "success|failed|rolled_back"
}
```

---

## Anti-padrões

- Deploy sem build local validado
- Deploy com variável de ambiente ausente
- Ignorar falha no health check
- Deploy de branch diferente de `main`/`master` sem flag explícita
- Secrets em logs de deploy
