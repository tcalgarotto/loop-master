# Design Editável Híbrido — HTML-first + Penpot + Next (Caminho C)

**Origem:** `/lucy aprenda` — 2026-07-03 — owner (Thales)  
**Papel:** fluxo canônico quando o owner quer **IA editando design de verdade** sem depender do Figma MCP.

> Complementa: `html-first-design-protocol.md` · `design-system-intake.md` · `premium-tool-orchestration.md` · `gsap-premium-protocol.md`

---

## Mandamento (P0)

> **Landing ou superfície marketing nova:** iterar em `preview/*.html` até o owner aprovar visual e interação. **Só depois** port para Next.js. Penpot entra para design system / tokens / wireframes; Figma só como intake (prints), nunca editor vivo da IA.

---

## Por que não Figma MCP

| Problema | Alternativa Lucy |
|----------|------------------|
| Rate limit / sessão curta | HTML no repo: edição ilimitada |
| Write frágil via API | Código = fonte de verdade |
| Formato fechado | Penpot MCP (open, `execute_code`) |

---

## Pipeline híbrido (ordem obrigatória)

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│ 1. Intake   │ →  │ 2. HTML v1   │ →  │ 3. Loop     │ →  │ 4. Aprovação │
│ refs/prints │    │ preview/     │    │ owner+IA    │    │ owner OK     │
└─────────────┘    └──────────────┘    └─────────────┘    └──────┬───────┘
                                                                  │
┌─────────────┐    ┌──────────────┐    ┌─────────────┐           │
│ 7. Gate     │ ←  │ 6. Port Next │ ←  │ 5. Penpot   │ ←─────────┘
│ visual-gate │    │ shadcn+Framer│    │ tokens/sync │  (opcional)
└─────────────┘    └──────────────┘    └─────────────┘
```

### Fase 1 — Intake (5–15 min)

- 2–3 referências fortes → `design-system-intake.md`
- Gravar em `.lucy/design-intake/notes.md` o que copiar/evitar
- Se já existe Penpot: ler arquivo aberto via MCP (read-only primeiro)

### Fase 2 — HTML v1 (agente)

| Regra | Detalhe |
|-------|---------|
| Local | `preview/<projeto>-<pagina>.html` |
| Stack | HTML + CSS + GSAP CDN; sem build |
| Densidade | Mocks interativos (tabs, kanban, charts), não placeholders vazios |
| Motion | `gsap-premium-protocol.md` |
| Servir | `bash scripts/html-preview-serve.sh` (porta 8765) |

### Fase 3 — Loop de edição (até aprovar)

**Critério de saída:** owner diz explicitamente que está bom (ou checklist abaixo).

| Quem | Ação |
|------|------|
| Owner | Abre preview, manda prints ou feedback textual |
| Agente | Edita HTML/CSS/JS; **não** toca Next nesta fase |
| Owner | DevTools opcional → agente replica no arquivo |

**Proibido:** port prematuro para Next “para ver como fica”.

### Fase 4 — Penpot (opcional, paralelo ou pós-HTML)

Quando design system visual precisa viver fora do código:

1. Arquivo Penpot aberto no browser
2. MCP habilitado no menu do arquivo (Status: enabled)
3. Agente usa MCP: tokens, componentes base, wireframes
4. Export CSS/tokens → `DESIGN_SYSTEM.md` + `globals.css`

**Modo read-only primeiro:** “audite tokens deste frame” antes de edits.

### Fase 5 — Port Next (só após aprovação HTML)

| HTML | Next |
|------|------|
| Seções | `app/.../page.tsx` + `components/marketing/` |
| GSAP | Framer Motion + GSAP em ilhas `use client` |
| `:root` tokens | `globals.css` + shadcn theme |
| Mocks | Tremor / shadcn Card |

Comando: `/lucy refazer-frontend --escopo /landing` ou `/lucy nova-pagina`.

### Fase 6 — Puck (opcional, pós-port)

Para o owner ajustar blocos sem código: Puck ou Builder em cima do React já aprovado. **Não** substitui fase HTML.

### Fase 7 — Visual gate

`visual-gate` na URL Next final — HTML preview não substitui gate de produção.

---

## Penpot MCP — setup e rotação de token

**Secrets:** token **nunca** no repo, brain versionado, ou chat arquivado em git.

| Artefato | Local | Git |
|----------|-------|-----|
| Token | `~/.config/penpot/mcp-token` (chmod 600) | **Nunca** |
| Cursor MCP | `~/.cursor/mcp.json` → `penpot.url` | **Nunca** (user-level) |
| Script | `scripts/penpot-mcp-configure.sh` | Sim (sem token) |

### Instalação inicial

```bash
# 1. Penpot → Settings → Integrations → Enable MCP → Generate key
# 2. Salvar token (colar uma vez):
mkdir -p ~/.config/penpot
chmod 700 ~/.config/penpot
# colar token no arquivo (editor local, não commitar):
nano ~/.config/penpot/mcp-token

# 3. Aplicar no Cursor:
bash scripts/penpot-mcp-configure.sh

# 4. Reiniciar Cursor → Settings → Tools & MCPs → Penpot verde
# 5. Abrir arquivo Penpot → menu → MCP enabled + connected
```

### Regenerar token (owner rotacionou chave)

1. Penpot → Settings → Integrations → **Delete** chave antiga → **Generate** nova
2. Substituir conteúdo de `~/.config/penpot/mcp-token` (só a string do token, sem URL)
3. `bash scripts/penpot-mcp-configure.sh`
4. Reiniciar Cursor
5. No arquivo Penpot aberto: verificar MCP **connected**

O agente **não** precisa do token no prompt: lê de `~/.config/penpot/mcp-token` via script ou MCP já configurado.

### Troubleshooting

| Sintoma | Fix |
|---------|-----|
| MCP vermelho no Cursor | `penpot-mcp-configure.sh` + restart |
| Agente não vê arquivo | Arquivo Penpot aberto + MCP enabled no menu |
| Token vazou | Delete no Penpot, gere novo, reconfigure |
| Edits não aplicam | Plugin MCP desconectado — reconnect no Penpot |

---

## Checklist “HTML aprovado” (gate antes do port)

- [ ] Hero + CTAs sem flash de loading
- [ ] ≥1 mock interativo denso (não painel vazio)
- [ ] Motion com `prefers-reduced-motion`
- [ ] Owner confirmou copy e hierarquia
- [ ] `preview/*.html` commitado como referência (sem secrets)
- [ ] Tokens anotados em `DESIGN_SYSTEM.md` se existirem

---

## Roteamento de ferramentas

| Momento | Ferramenta |
|---------|------------|
| Iterar landing | **HTML** `preview/` |
| Design system visual | **Penpot MCP** |
| Referência estática | Prints / Figma export (intake only) |
| Produção | **Next** + shadcn + visual-gate |
| Ajuste humano pós-port | Puck (opcional) |

Ver `premium-tool-orchestration.md` R3 (HTML-first) atualizado.

---

## Anti-padrões

- Portar para Next antes da aprovação HTML
- Colocar `userToken` em repo, `.env` commitado, ou `lucy-progress.json`
- Depender de Figma MCP para edição em loop
- Penpot MCP sem arquivo aberto no browser
- Pular visual-gate na URL Next após port

---

## Comandos relacionados

| Comando | Uso |
|---------|-----|
| `/lucy aprenda` | Evoluir este protocolo |
| `/lucy regra` | Regra visual só do projeto |
| `/lucy nova-pagina --tipo landing` | Port pós-HTML |
| `/lucy refazer-frontend --escopo /landing` | Substituir landing |
| `/lucy visual-gate` | QA URL Next |
