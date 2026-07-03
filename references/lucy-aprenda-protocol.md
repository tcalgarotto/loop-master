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
- Atualizar protocolo canônico com regras acionáveis.
- Atualizar matriz de decisão em `design-skills-routing-table.md` se mudar routing.
- Registrar entrada em `references/learned/INDEX.md` (data, slug, resumo 1 linha).

### 4. Persistir memória
```bash
bash .cursor/skills/lucy/scripts/aprenda-capture.sh \
  --slug "gsap-premium" \
  --summary "GSAP para timelines/ScrollTrigger; CSS só hover; sem transition-* com GSAP"
```
- Brain: `.cursor/lucy-brain/learned/` (log JSONL)
- Skill pack repo: commit com mensagem `learn: <slug> via /lucy aprenda` (se owner pedir publish)

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

Ver `references/learned/INDEX.md` — catálogo cronológico de tudo absorvido via `/lucy aprenda`.
