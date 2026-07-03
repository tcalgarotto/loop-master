# Protocolo `/lucy aprenda` — memória evolutiva do skill pack

**Objetivo:** incorporar conhecimento que o owner envia (texto, prints, transcrições, links resumidos) no ecossistema Lucy — sem perder o que já existe.

---

## Comando

```
/lucy aprenda <conteúdo>
```

Variantes:
- `/lucy aprenda` + texto colado na mesma mensagem
- `/lucy aprenda @arquivo.md`
- `/lucy aprenda` + prints (frames de vídeo/Reels)

---

## Pipeline obrigatório (agente)

### 1. Ingerir
- Ler **todo** o conteúdo enviado (texto, imagens, anexos).
- Extrair: conceitos, regras, anti-patterns, exemplos de código, casos de uso (CRM/ERP/IA).

### 2. Classificar
| Tipo | Destino |
|------|---------|
| Animação / performance UI | `gsap-premium-protocol.md`, `html-native-light-protocol.md` |
| Design / UX | `ux-design-intelligence.md`, `premium-ui-stack.md` |
| Deploy / perf / test | protocolo correspondente |
| Novo domínio | `references/learned/<slug>.md` + entrada no INDEX |
| Conflito com regra existente | **ADR** em `docs/adr/` ou nota no protocolo — nunca sobrescrever silenciosamente |

### 3. Integrar (não só arquivar)

**Ordem de persistência (obrigatória — sobrevive a `/lucy update`):**

| Camada | Onde grava | Sobrevive `git pull` no skill pack? |
|--------|------------|-------------------------------------|
| **1. Projeto (primário)** | `.cursor/lucy-brain/learned/<slug>.md` + `entries.jsonl` | **Sim** — update não apaga brain |
| **2. Projeto (handoff)** | entrada em `references/learned/INDEX.md` **do projeto** se existir `docs/` local | **Sim** |
| **3. Skill pack (opcional)** | `references/*.md` no clone `~/.cursor/skills/lucy` | **Só se commitado** no fork do usuário; `git pull` upstream pode sobrescrever edits locais não commitados |

**Regra:** conhecimento do **owner/usuário** → sempre camada 1 primeiro. Skill pack upstream (GitHub) só recebe o que for publicado de propósito (PR/fork).

- Atualizar protocolo canônico do **projeto** em `.cursor/lucy-brain/learned/` com regras acionáveis.
- Opcionalmente espelhar no skill pack se o owner pedir publish global.
- Atualizar matriz em `design-skills-routing-table.md` só no skill pack se for mudança de produto Lucy; senão nota no `<slug>.md` do projeto.
- Registrar em `references/learned/INDEX.md` do skill pack **apenas** quando publicar upstream; no projeto, append em `.cursor/lucy-brain/learned/INDEX.md`.

### 4. Persistir memória
```bash
bash .cursor/skills/lucy/scripts/aprenda-capture.sh \
  --slug "gsap-premium" \
  --summary "GSAP para timelines/ScrollTrigger; CSS só hover; sem transition-* com GSAP"
```
- **Brain (sempre):** `.cursor/lucy-brain/learned/entries.jsonl` + `.cursor/lucy-brain/learned/<slug>.md` (conteúdo completo)
- **HYDRATE:** agente deve ler `lucy-brain/learned/*.md` após protocolos do skill pack
- Skill pack upstream: commit `learn: <slug>` só se owner pedir publish

### 5. Confirmar ao owner
Resumo em 3–5 bullets: o que aprendeu, onde foi gravado, como afeta implementações futuras.

---

## O que NÃO é `/lucy aprenda`

| Comando | Diferença |
|---------|-----------|
| `/lucy` tick | Executa trabalho no projeto (código, deploy) |
| `/lucy docs --adr` | Uma decisão pontual formal |
| `/lucy aprenda` | **Evolui o cérebro da Lucy** para todos os projetos futuros |

---

## Formato de entrada aceito

- Texto corrido (como GSAP abaixo)
- Bullets de Reels / YouTube (owner transcreve)
- Screenshots de código ou UI
- Links + resumo do owner (agente não depende de Instagram/YouTube direto)

---

## Índice de aprendizados

| Escopo | Arquivo |
|--------|---------|
| Skill pack (upstream) | `references/learned/INDEX.md` |
| **Seu projeto (não perde no update)** | `.cursor/lucy-brain/learned/INDEX.md` + `*.md` |

---

## `/lucy update` — o que preserva?

| Artefato | Update apaga? |
|----------|---------------|
| `.cursor/lucy-progress.json` | **Não** (backup + preserve-context) |
| `.cursor/lucy-brain/` (incl. `learned/`) | **Não** |
| Edits locais no clone `skills/lucy` sem commit | **Sim** — perdidos no `git pull` |
| Protocolos já no GitHub (ex. GSAP v2.8.4) | **Não** — você recebe a versão mais nova |

**Conclusão:** aprendizado do usuário fica no **brain do projeto**; update só atualiza o pacote Lucy, não o cérebro do app.
