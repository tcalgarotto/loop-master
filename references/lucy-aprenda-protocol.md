# Protocolo `/lucy aprenda` — evolução global do produto Lucy

**Escopo:** skill pack (`loop-master` / `lucy` no GitHub) — **todos os usuários** recebem no próximo `git pull` / `/lucy update`.

**Não confundir com:** `/lucy regra` — regras **locais e imutáveis** do projeto (`lucy-regra-protocol.md`).

---

## Comando

```
/lucy aprenda <conteúdo>
/lucy aprenda --dry-run <conteúdo>   # só mostra o que mudaria, sem commit
```

Entrada: texto, prints, `@arquivo.md`, transcrição de Reel.

**Intenção do owner:** transformar tema em **habilidade ou regra de produção** da Lucy (protocolo, routing, checklist, script).

---

## Pipeline obrigatório (agente)

### 1. Ingerir e classificar

| Tipo | Destino no skill pack |
|------|----------------------|
| Animação / perf UI | `html-native-light-protocol.md`, `gsap-premium-protocol.md` |
| Prototipação HTML antes de Next | `html-first-design-protocol.md` |
| Design editável híbrido (HTML + Penpot + Next) | `design-editable-hybrid-protocol.md` |
| QA visual / screenshots | `visual-gate-protocol.md` |
| Processo / orquestração premium | `premium-tool-orchestration.md` |
| Design systems tagados | `design-system-intake.md` |
| Design / UX | `ux-design-intelligence.md`, `premium-ui-stack.md` |
| Deploy / test / i18n | protocolo correspondente em `references/` |
| Novo domínio | `references/learned/<slug>.md` |
| Script / automação | `scripts/` |
| Processo / disciplina operacional | `docs-sync-discipline.md` + protocolo dono |
| Conflito com regra global | nota + ADR; **nunca** apagar regra de projeto (`/lucy regra`) |

### 2. Editar o skill pack

Trabalhar no clone canônico (`~/Projetos/Loop-master` ou `.cursor/skills/lucy`):

- Atualizar protocolo canônico com regras acionáveis.
- Atualizar `design-skills-routing-table.md` / `SKILL.md` se mudar comandos ou routing.
- **Aplicar `docs-sync-discipline.md`** — grep docs, sync README/MANUAL/SKILL/references/README/CHANGELOG.
- Registrar em `references/learned/INDEX.md`.
- Bump `version` em `SKILL.md` (patch: 2.9.1 → 2.9.2).

### 3. Registrar (log global)

```bash
bash .cursor/skills/lucy/scripts/aprenda-capture.sh \
  --slug "gsap-premium" \
  --summary "GSAP timelines + ScrollTrigger; CSS só hover"
```

Grava em `references/learned/` do **skill pack** (não no brain do app).

### 4. Publicar no GitHub (padrão)

`/lucy aprenda` **implica** commit + push no repo `loop-master`, salvo `--dry-run`:

```bash
cd /path/to/Loop-master
git add references/ SKILL.md scripts/
git commit -m "learn: <slug> via /lucy aprenda"
git push origin main
```

Owner vê URL do commit. Usuários atualizam com `/lucy update`.

### 5. Confirmar

Bullets: o que virou habilidade global, arquivos alterados, versão nova, como usar em ticks futuros.

---

## O que `/lucy aprenda` NÃO faz

| Ação | Comando correto |
|------|-----------------|
| Regra só deste CRM/ERP | `/lucy regra` |
| Memória de conversa pontual | brain-sync `capture` |
| Decisão arquitetural do app | `/lucy docs --adr` |

---

## `/lucy update` e aprendizado global

| Artefato | Efeito do update |
|----------|------------------|
| Protocolos novos no GitHub | **Baixados** — todos ganham |
| `.cursor/lucy-brain/rules/` do projeto | **Intocados** — regras locais prevalecem em conflito |

---

## Matriz rápida

| | `/lucy aprenda` | `/lucy regra` |
|--|-----------------|---------------|
| **Quem recebe** | Todos (GitHub) | Só este projeto |
| **Onde grava** | `references/` no skill pack | `.cursor/lucy-brain/rules/` |
| **Sobrevive update** | Sim (vem do upstream) | Sim (nunca sobrescrito) |
| **Commit** | repo `loop-master` | opcional `docs/lucy-rules/` no app |
| **Prioridade em conflito** | Base global | **P0 — vence** |
