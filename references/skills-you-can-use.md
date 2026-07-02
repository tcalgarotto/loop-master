# Skills que você pode usar com Loop Master

O Loop Master é o **maestro**. As skills abaixo são os **músicos** — ele escolhe qual tocar em cada fase.

---

## Como invocar?

Você **não** precisa chamar cada skill manualmente na maioria dos casos. Basta:

```
/loop-master
```

O orchestrator lê `skills_installed[]` no seu JSON e roteia automaticamente.

Para forçar uma skill em um tick:

```
/loop-master — use impeccable shape + layout em src/app/dashboard/page.tsx
```

---

## Pacote 1 — Design & UI (instale no init)

| Skill | Comando de install | Use quando |
|-------|-------------------|------------|
| **impeccable** | `npx impeccable install --providers=cursor --scope=project` | Refinar páginas do produto (CRM, dashboard, settings…) |
| **ui-ux-pro-max** | `npx ui-ux-pro-max-cli init --ai cursor` | Criar design system no início do projeto |
| **taste-skill** | `npx skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend` | Landing pages, marketing, anti-“AI slop” |
| **motion** | `npm install motion` (no frontend) | Animações com `motion/react` |

**Impeccable — exemplos de comandos que o loop pode rodar:**

`shape`, `layout`, `colorize`, `typeset`, `clarify`, `polish`, `critique`, `harden`, `animate`

Máximo **1–2 comandos Impeccable por tick** (para não sobrecarregar).

---

## Pacote 2 — Memória & handoff (opcional)

| Skill | Install | Use quando |
|-------|---------|------------|
| **caveman** | installer JuliusBrussee/caveman | Commits, resumos, comprimir JSON grande |
| **claude-mem** | `npx claude-mem install` + `npx claude-mem start` | Lembrar decisões entre sessões do Cursor |

---

## Pacote 3 — Nativas do Cursor (já disponíveis)

| Ferramenta | Use quando |
|------------|------------|
| **security-review** | Audit de auth, APIs, secrets, tenant |
| **bugbot** | Revisão adversarial de diff |
| **ci-investigator** | CI vermelho no PR |
| **explore** | Mapear codebase desconhecido |
| **shell** | Testes, build, migrate |
| **deployment-expert** | Deploy Vercel/VPS |
| **performance-optimizer** | Bundle, Lighthouse, queries |

---

## Pacote 4 — Infra do próprio loop

| Skill | Função |
|-------|--------|
| **loop** | `/loop 5m /loop-master` — agendamento fixo |
| **loop-master** | Orquestrador (este pacote) |

---

## Por fase do trabalho (resumo)

```
discover  → ui-ux-pro-max, claude-mem, explore
plan      → ui-ux-pro-max, impeccable shape
implement → impeccable, taste-skill, motion, generalPurpose
verify    → shell, pytest, npm run build
audit     → security-review, bugbot, impeccable critique
fix       → generalPurpose, impeccable (1–2 cmds)
gate      → polish, deploy, docs
persist   → caveman-compress (JSON grande)
```

---

## Instalar tudo de uma vez

```bash
bash .cursor/skills/loop-master/scripts/init.sh \
  --skills impeccable,ui-ux-pro-max,taste-skill,caveman,claude-mem,motion
```

Mínimo (só UI básica):

```bash
bash .cursor/skills/loop-master/scripts/init.sh
# instala impeccable + ui-ux-pro-max por padrão
```

---

## Verificar o que está instalado

```bash
bash .cursor/skills/loop-master/scripts/verify-pack.sh
cat .cursor/loop-master-progress.json | jq .skills_installed
```
