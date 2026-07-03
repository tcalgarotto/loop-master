# Publicar Loop Master no GitHub

Guia para **mantenedores** que vão distribuir este pacote para outras pessoas.

---

## Antes de publicar

Execute no projeto onde o pack foi testado:

```bash
bash .cursor/skills/lucy/scripts/verify-pack.sh
```

Deve aparecer: **`verify-pack PASSED`**.

Confira também:

- [ ] Nenhum secret em arquivos do pack (`.env`, tokens, senhas)
- [ ] Nenhum nome de cliente/projeto específico em `SKILL.md`, `README.md`, `references/*`
- [ ] Versão em `SKILL.md` (`version: "2.3.1"`) bate com a release

---

## Opção A — Repositório só do loop-master (recomendado)

Ideal para `git clone` direto em `~/.cursor/skills/lucy`.

```bash
cd .agents/skills/lucy   # ou pasta do clone standalone
git init
git add SKILL.md README.md .gitignore scripts/ references/
git status   # confira: SEM .env, SEM progress JSON de projetos
git commit -m "loop-master v2.3.1 — orchestrator for Cursor"
git branch -M main
git remote add origin https://github.com/tcalgarotto/lucy.git
git push -u origin main
```

### O que vai no repo

| Incluir | Não incluir |
|---------|-------------|
| `SKILL.md`, `README.md` | `.env` |
| `scripts/*` | `.cursor/lucy-progress.json` de clientes |
| `references/*` | `node_modules/`, credenciais |
| `.gitignore` | Código do app host |

---

## Opção B — Submodule no monorepo

```bash
git submodule add https://github.com/tcalgarotto/lucy.git .agents/skills/lucy
ln -sf ../../.agents/skills/lucy .cursor/skills/lucy
```

---

## Como outras pessoas instalam

Compartilhe este bloco no README do GitHub:

```markdown
## Instalação

git clone https://github.com/tcalgarotto/lucy.git ~/.cursor/skills/lucy
cd seu-projeto
bash ~/.cursor/skills/lucy/scripts/init.sh --skills impeccable,ui-ux-pro-max
bash ~/.cursor/skills/lucy/scripts/link-ecosystem-skills.sh
```

No Cursor Agent: `/lucy init`

Documentação: [getting-started.md](references/getting-started.md)
```

---

## Releases

1. Atualize `version` em `SKILL.md`
2. Rode `verify-pack.sh`
3. Tag: `git tag v2.3.1 && git push origin v2.3.1`
4. Release notes: scripts novos, skills suportadas, breaking changes

---

## Atualizar quem já usa

Consumidores rodam:

```bash
bash ~/.cursor/skills/lucy/scripts/update.sh
```

Ou no Cursor: `/lucy update`

O progress JSON do projeto **não é apagado**.
