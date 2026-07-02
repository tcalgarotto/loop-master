# Prompt inicial — configurar loop-master + ecossistema

Cole no **Cursor Agent** após instalar o pacote. Troque `<SEU_OBJETIVO>` pelo que você quer entregar.

---

## Instalação CLI (antes do prompt)

```bash
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/loop-master
cd seu-projeto
bash .cursor/skills/loop-master/scripts/init.sh \
  --skills impeccable,ui-ux-pro-max,taste-skill,caveman,claude-mem,motion
bash .cursor/skills/loop-master/scripts/link-ecosystem-skills.sh
bash .cursor/skills/loop-master/scripts/verify-pack.sh
```

---

## Prompt — projeto novo (copiar)

```
/loop-master init — skill loop-master

Objetivo: <SEU_OBJETIVO>
Progress file: .cursor/loop-master-progress.json

1. AskQuestion: goal, scope, delivery_bar, design_surface, loop_mode (dinâmico chain), skills
2. Confirmar skills_installed: impeccable, ui-ux-pro-max, taste-skill, caveman, claude-mem, motion
3. Criar docs/LOOP-MASTER-PLAN.md com fases até 100%
4. Primeiro tick discover → plan
5. Ao fim: arm-dynamic-loop.sh --seconds 45 (loop dinâmico encadeado)

Regras: implement → verify → audit → fix → gate; nunca commitar .env
```

---

## Prompt — continuar trabalho

```
/loop-master — skill loop-master

Leia .cursor/loop-master-progress.json e execute o next_prompt.
Mantenha loop dinâmico (arm-dynamic-loop.sh --seconds 45) até overall_pct === 100.
```

---

## Prompt — segundo loop no mesmo repo

```
/loop-master init — skill loop-master

Progress file: .cursor/loop-master-progress.<NOME>.json
NÃO alterar .cursor/loop-master-progress.json do outro loop.

Objetivo: <SEU_OBJETIVO>
```

Ver `references/multi-project-protocol.md`.

---

## Documentação

- Guia amigável: `references/getting-started.md`
- Skills disponíveis: `references/skills-you-can-use.md`
