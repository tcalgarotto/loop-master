---
name: loop-master
description: >-
  Alias legado para Lucy v2.8 — mesmo orquestrador. Use /loop-master ou /lucy
  intercambiavelmente. Preserva contexto, quiz, brain e loop autônomo.
version: "2.8.0"
---
# loop-master → alias Lucy

**Skill canônica:** leia e siga `.cursor/skills/lucy/SKILL.md` (ou `~/.cursor/skills/lucy/SKILL.md`).

| Comando legado | Comando novo | Ação |
|----------------|--------------|------|
| `/loop-master init` | `/lucy init` | Bootstrap + quiz |
| `/loop-master update` | `/lucy update` | Pull + migrate + preserve |
| `/loop-master` | `/lucy` | Próximo tick |
| `/loop-master @url` | `/lucy @url` | Gap analysis |

**Scripts:** `bash .cursor/skills/lucy/scripts/*.sh` (fallback: `.agents/skills/lucy/` ou paths legados `loop-master`).

**Progress:** `.cursor/lucy-progress.json` (após migrate; legado `loop-master-progress.json` até rodar `migrate-loop-master-to-lucy.sh`).

Ao invocar `/loop-master`, executar **exatamente** o protocolo Lucy v2.8 documentado em `SKILL.md` do pacote `lucy`.
