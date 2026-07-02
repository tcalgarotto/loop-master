# Guia rápido — Loop Master

> **Para quem baixou o repositório e quer começar em 5 minutos.**

## O que é?

**Loop Master** é uma skill para o **Cursor Agent** que orquestra trabalho longo até **100% de entrega**: planeja em fases, executa em ticks, corrige erros (audit → fix), e chama outras skills automaticamente (UI, design, memória, segurança).

Você não precisa repetir contexto a cada mensagem — o progresso fica em `.cursor/loop-master-progress.json`.

---

## Pré-requisitos

1. **Cursor** com **Agent Skills** habilitado (Settings → Rules → Agent Skills)
2. **Git** e **Node.js** (para instalar skills opcionais via `npx`)
3. Um projeto com código (ou repo novo)

---

## Instalação (3 passos)

### 1. Baixar o pacote

```bash
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/loop-master
cd seu-projeto
```

Ou copie a pasta `loop-master/` para `.cursor/skills/loop-master` no seu repo.

### 2. Rodar o instalador

```bash
bash .cursor/skills/loop-master/scripts/init.sh \
  --skills impeccable,ui-ux-pro-max,taste-skill,caveman,claude-mem,motion
bash .cursor/skills/loop-master/scripts/link-ecosystem-skills.sh
bash .cursor/skills/loop-master/scripts/verify-pack.sh
```

O último comando deve terminar com **`verify-pack PASSED`**.

### 3. Iniciar no Cursor

Abra o **Agent** e cole:

```
/loop-master init
```

O agente fará um quiz curto (objetivo, escopo, skills, tipo de loop) e criará o plano em `docs/LOOP-MASTER-PLAN.md`.

**Prompt completo:** veja `references/setup-prompt.md`.

---

## Comandos no chat

| Você digita | O que acontece |
|-------------|----------------|
| `/loop-master init` | Primeira vez: quiz + instala deps + plano + loop |
| `/loop-master` | Um tick de trabalho (um passo do plano) |
| `/loop-master update` | Atualiza o pacote **sem apagar** seu progresso |
| `pare o loop` | Para o agendamento automático |

---

## Loop automático (padrão)

Depois de cada tick, o agente pode encadear o próximo (~45s):

```bash
bash .cursor/skills/loop-master/scripts/arm-dynamic-loop.sh \
  --progress-file .cursor/loop-master-progress.json --seconds 45
```

Ou peça no chat: *"mantenha loop dinâmico"*.

---

## Skills que o Loop Master pode usar por você

O orchestrator **não substitui** essas skills — ele **decide quando** chamá-las conforme a fase do trabalho.

### Instaladas pelo `init.sh` (opcionais)

| Skill | Para quê | Quando o loop usa |
|-------|----------|-------------------|
| **impeccable** | Refinar telas (layout, cores, polish, a11y) | Frontend product UI |
| **ui-ux-pro-max** | Design system, regras UX por indústria | Discover, plan |
| **taste-skill** | Anti-slop, landing/marketing premium | UI nova / marketing |
| **caveman** | Resumos densos, commits, compressão de contexto | Fim de tick / handoff |
| **claude-mem** | Memória entre sessões | Discover, hydrate (`npx claude-mem start`) |
| **motion** | Animações React (`motion/react`) | Implement em frontend |

### Já no Cursor (sem instalar)

| Ferramenta | Para quê |
|------------|----------|
| **security-review** | Auditoria de segurança no código |
| **bugbot** | Revisão de bugs e regressões |
| **loop** | Agendar ticks (`/loop 5m …`) |
| Subagents **explore**, **shell**, **deployment-expert**, etc. | Tarefas paralelas |

Detalhes: `references/skills-you-can-use.md` e `references/skill-ecosystem-map.md`.

---

## Dois projetos no mesmo repositório?

Use **arquivos de progresso separados**:

| Projeto | Arquivo |
|---------|---------|
| Seu app | `.cursor/loop-master-progress.json` |
| Outro loop (ex. meta) | `.cursor/loop-master-progress.skill-pack.json` |

```bash
bash scripts/init.sh --progress-file .cursor/loop-master-progress.meu-loop.json
```

Ver `references/multi-project-protocol.md`.

---

## Publicar este pacote no GitHub

Só depois de `verify-pack.sh` PASSED. Checklist passo a passo: `references/git-publish-checklist.md`.

---

## Problemas comuns

| Sintoma | Solução |
|---------|---------|
| Skill não encontrada | Confirme `.cursor/skills/loop-master/SKILL.md` e Agent Skills ON |
| Loop não continua | `loop_status` no JSON deve ser `running`; rode `arm-dynamic-loop.sh` |
| Perdeu contexto | Leia `.cursor/loop-master-progress.json` e `next_prompt` |
| Init falhou em skill | Rode `init.sh --skills …` de novo; veja WARN no terminal |

---

## Documentação completa

| Doc | Conteúdo |
|-----|----------|
| `README.md` | Visão geral (EN/PT) |
| `SKILL.md` | Instruções do Agent |
| `references/getting-started.md` | Este guia (EN) |
| `references/setup-prompt.md` | Prompt copiável |
| `references/skill-ecosystem-map.md` | Árvore de decisão técnica |

**Versão do pacote:** 2.3.1 (docs)
