# Distribuição — loop-master vs repositório host

## Dois READMEs, dois propósitos

| Arquivo | O que é |
|---------|---------|
| **`/README.md`** (raiz do monorepo) | Produto host — app, API, deploy |
| **`.agents/skills/lucy/README.md`** | Pacote **loop-master** — skill Cursor genérica |

**Não estão misturados.** São arquivos diferentes. A confusão costuma vir do monorepo: os dois vivem no mesmo clone.

## O que publicar no GitHub do loop-master

Só o conteúdo de **`loop-master/`** (esta pasta):

```
SKILL.md  README.md  .gitignore  scripts/  references/
```

**Não** inclua: README do app host, `frontend/`, `backend/`, docs de deploy do produto, etc.

## O que fica no repositório host (monorepo)

Tudo do produto + opcionalmente o skill pack como submodule ou pasta `.agents/skills/lucy/`.

Docs de índice no host (não vão no clone standalone):

- `docs/LOOP-MASTER-V2-INSTALL.md` — aponta para este pacote
- `docs/LOOP-MASTER-COMPLETE.md` — evidência de entrega no host

## Clone standalone (outras pessoas)

```bash
git clone https://github.com/tcalgarotto/lucy.git ~/.cursor/skills/lucy
```

Elas leem **apenas** `README.md` desta pasta e `references/getting-started.md`.
