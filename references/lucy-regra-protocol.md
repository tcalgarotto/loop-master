# Protocolo `/lucy regra` — regras imutáveis do projeto

**Escopo:** **um projeto** (HubFU, cliente X, etc.) — pedidos e convenções que **não podem** ser alterados pelo `/lucy update` nem por evolução global da skill.

**Não confundir com:** `/lucy aprenda` — evolui o produto Lucy no GitHub para todos.

---

## Comando

```
/lucy regra <texto da regra>
/lucy regra --slug nome-curto <texto>
/lucy regra --versionar   # espelha também em docs/lucy-rules/ (entra no git do app)
/lucy regra --list        # lista regras ativas
/lucy regra --revogar slug   # marca regra como revogada (não apaga histórico)
```

Exemplos:

- *"Nunca usar cor azul pura no HubFU — só tokens do DESIGN_SYSTEM.md"*
- *"Deploy só via script deploy/hubfu.sh, nunca vercel CLI direto"*
- *"Modal de negócio sempre em português BR, i18n depois"*

---

## Onde grava (imutável pelo update)

```
.cursor/lucy-brain/rules/
├── INDEX.md              # catálogo P0
├── entries.jsonl         # log append-only
├── hubfu-deploy-only.md  # uma regra por arquivo
└── no-pure-blue.md
```

**Proteção:** `update.sh` e `migrate-*.sh` **nunca** escrevem em `rules/`. `git pull` no skill pack **não** toca esta pasta.

### Opcional: versionar no app (`--versionar`)

```
docs/lucy-rules/<slug>.md   # mesmo conteúdo — vai no commit do app se não estiver no .gitignore
```

Use quando o time precisa das regras no GitHub do **produto**, não só na VPS.

---

## Formato de cada regra (`<slug>.md`)

```markdown
---
slug: hubfu-deploy-only
priority: P0
immutable: true
created_at: 2026-07-03T07:50:00Z
source: /lucy regra
revoked: false
---

# Deploy apenas via script

- **Obrigatório:** `bash deploy/hubfu.sh`
- **Proibido:** `vercel deploy` / `vercel --prod` direto pelo agente
- **Motivo:** env e domínio canônicos no script do owner
```

---

## Pipeline obrigatório (agente)

### 1. Parsear pedido do owner
Uma regra = uma intenção clara (Obrigatório / Proibido / Preferência).

### 2. Gravar

```bash
bash .cursor/skills/lucy/scripts/regra-capture.sh \
  --slug "hubfu-deploy-only" \
  --summary "Deploy só via deploy/hubfu.sh" \
  --body-file /tmp/regra.md
```

### 3. HYDRATE — prioridade P0

Em **todo** `/lucy` tick, **antes** de implementar:

1. Ler `.cursor/lucy-brain/rules/*.md` onde `revoked: false`
2. Se conflitar com skill pack global → **regra do projeto vence**
3. Citar regra aplicada no plano do tick

### 4. CAPTURE
Registrar em `brain-sync capture` que nova regra foi fixada.

### 5. Confirmar ao owner
Slug, resumo, caminho do arquivo, se `--versionar` foi usado.

---

## Revogar (sem apagar histórico)

`/lucy regra --revogar hubfu-deploy-only` → `revoked: true` no frontmatter + linha no INDEX.

Regras revogadas não entram no HYDRATE ativo.

---

## Conflito: regra local vs `/lucy aprenda` global

| Situação | Quem vence |
|----------|------------|
| Regra P0 no projeto vs protocolo global | **Regra do projeto** neste repo |
| Owner quer mudar regra local | `/lucy regra` nova versão ou `--revogar` + nova |
| Owner quer mudar Lucy para todos | `/lucy aprenda` no repo loop-master |

---

## Anti-padrões

- Colocar pedido do owner só em `learned/` sem `rules/` — use **`/lucy regra`**
- Editar `rules/` durante `/lucy update` ou migração
- Sobrescrever regra P0 sem `--revogar` explícito
- Commitar secrets dentro de regras
