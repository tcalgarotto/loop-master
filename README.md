# Loop Master v2.3

> **Pacote standalone** — este README descreve apenas o orchestrator Cursor para qualquer projeto.

**Orquestrador autônomo para Cursor** — planeja, executa e entrega até **100%**, com autocorreção e integração com skills de UI, design, memória e segurança.

[Guia rápido (PT)](references/getting-started.md) · [Skills disponíveis](references/skills-you-can-use.md) · [Prompt inicial](references/setup-prompt.md)

---

## Está funcionando?

Sim, se estes passos passarem no seu ambiente:

```bash
bash scripts/verify-pack.sh          # → PASSED
bash scripts/init.sh --preserve-context  # → exit 0
```

No Cursor: `/loop-master init` → cria `.cursor/loop-master-progress.json` e `docs/LOOP-MASTER-PLAN.md`.

---

## Para quem está começando

### 1. Clone ou copie

```bash
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/loop-master
cd seu-projeto
ln -sf ~/.cursor/skills/loop-master .cursor/skills/loop-master   # opcional, in-repo
```

### 2. Instale dependências opcionais

```bash
bash .cursor/skills/loop-master/scripts/init.sh \
  --skills impeccable,ui-ux-pro-max,taste-skill,caveman,claude-mem,motion
bash .cursor/skills/loop-master/scripts/link-ecosystem-skills.sh
```

### 3. No Cursor Agent

```
/loop-master init
```

Depois, para continuar o trabalho:

```
/loop-master
```

---

## O que você pode invocar?

| Tipo | Skills / ferramentas |
|------|----------------------|
| **UI produto** | impeccable |
| **Design system** | ui-ux-pro-max |
| **Landing / marketing** | taste-skill |
| **Animação** | motion (npm) |
| **Memória** | claude-mem |
| **Handoff** | caveman |
| **Segurança** | security-review (Cursor) |
| **Bugs** | bugbot (Cursor) |
| **Agendamento** | loop + `arm-dynamic-loop.sh` |

Tabela completa: **[references/skills-you-can-use.md](references/skills-you-can-use.md)**

---

## Comandos

| Comando | Descrição |
|---------|-----------|
| `/loop-master init` | Primeira configuração (quiz + plano) |
| `/loop-master` | Executa **um tick** (um passo do plano) |
| `/loop-master update` | Atualiza o pacote sem perder progresso |
| `pare o loop` | Para o loop automático |

### Loop dinâmico (padrão)

Encadeia o próximo tick ~45s após o atual terminar:

```bash
./scripts/arm-dynamic-loop.sh --progress-file .cursor/loop-master-progress.json --seconds 45
```

---

## Scripts incluídos

| Script | Função |
|--------|--------|
| `init.sh` | Bootstrap + skills + progress JSON |
| `update.sh` | Atualizar pack preservando contexto |
| `link-ecosystem-skills.sh` | Symlinks para Cursor achar taste/caveman |
| `arm-dynamic-loop.sh` | Re-arm do próximo tick (chain) |
| `verify-pack.sh` | Teste antes de publicar no GitHub |

---

## Publicar no GitHub

1. Rode `verify-pack.sh` → **PASSED**
2. Siga **[references/git-publish-checklist.md](references/git-publish-checklist.md)**

```bash
cd loop-master   # raiz do clone standalone
git init
git add SKILL.md README.md .gitignore scripts/ references/
git commit -m "loop-master v2.3 — autonomous orchestrator for Cursor"
git remote add origin https://github.com/tcalgarotto/loop-master.git
git push -u origin main
```

**Não inclua** no repo publicado: `.env`, `loop-master-progress.json` de projetos reais, credenciais.

---

## Estrutura do pacote

```
loop-master/
├── SKILL.md              ← instruções para o Cursor Agent
├── README.md             ← este arquivo
├── .gitignore
├── scripts/
│   ├── init.sh
│   ├── update.sh
│   ├── link-ecosystem-skills.sh
│   ├── arm-dynamic-loop.sh
│   └── verify-pack.sh
└── references/
    ├── getting-started.md       ← guia amigável (PT)
    ├── skills-you-can-use.md    ← o que o loop pode chamar
    ├── setup-prompt.md          ← prompt copiável
    ├── git-publish-checklist.md
    ├── skill-ecosystem-map.md   ← roteamento técnico
    └── autonomous-orchestrator-protocol.md
```

---

## Multi-projeto (mesmo repo)

| Loop | Arquivo de progresso |
|------|----------------------|
| App principal | `.cursor/loop-master-progress.json` |
| Segundo loop | `.cursor/loop-master-progress.<nome>.json` |

Ver `references/multi-project-protocol.md`.

---

## Versão

**2.3.1** — pacote funcional; docs amigáveis para distribuição pública/privada.

Licença: MIT
