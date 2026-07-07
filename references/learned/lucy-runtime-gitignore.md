# `.lucy/` — runtime local, não skill pack

**Data:** 2026-07-07  
**Versão Lucy:** v2.9.37+  
**Origem:** `/lucy aprenda` — política gitignore runtime

---

## Regra

| Caminho | Papel | Git |
|---------|-------|-----|
| `SKILL.md`, `references/`, `scripts/` | Skill pack **público** (loop-master) | ✅ commit |
| `.cursor/lucy-brain/` | Segundo cérebro L0/L1 por projeto | ❌ gitignored |
| `.lucy/` | Runtime efêmero: visual gates, caches, browser captures, handoffs locais | ❌ gitignored |

**`.lucy/` nunca entra no commit** — mesmo que o agente gere screenshots, JSON de gate ou handoffs markdown lá.

## Conteúdo típico de `.lucy/`

- `headless-browser-ready.json` — status Playwright
- `browser/capture.png` — screenshots de scrape
- `html-preview-gate/` — node_modules Playwright local do gate
- `*-handoff.md` — rascunhos longos de tick (versão curta vai no brain)

## Onde publicar aprendizado

Se algo em `.lucy/` virou regra global → `/lucy aprenda` → `references/learned/` + `INDEX.md` + CHANGELOG — **não** copiar a pasta inteira.

## Cross-links

- `references/second-brain-protocol.md` — L0 brain em `.cursor/lucy-brain/`
- `references/docs-sync-discipline.md` — sync após mudanças no skill pack
- `.gitignore` — entrada `.lucy/`
