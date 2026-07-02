# Skills que você pode usar com Loop Master v2.4

O Loop Master instala e roteia **automaticamente** no `/loop-master init`.

---

## Zero-config — você não instala manualmente

```
/loop-master init
```

Bootstrap shell instala tudo. Ver [init-protocol.md](init-protocol.md).

---

## Pacote Design (instalado + roteado)

| Skill | Use quando |
|-------|------------|
| **impeccable** | Product UI: shape, craft, layout, polish, critique |
| **ui-ux-pro-max** | Design system inicial |
| **taste-skill** | Landing, marketing, anti-slop |
| **design** | Router: logo, CIP, ícones, social |
| **design-system** | Tokens 3 camadas, component specs |
| **ui-styling** | shadcn/Tailwind polish |
| **brand** | Identidade, voz |
| **banner-design** | Social, ads |
| **slides** | Apresentações |
| **motion** | Animações React |

Mapa completo: [design-skills-routing-table.md](design-skills-routing-table.md)

---

## Memória & handoff

| Skill | Use quando |
|-------|------------|
| **claude-mem** | Cross-session (obrigatório v2.4) |
| **caveman** | Comprimir JSON, commits |

---

## Nativos Cursor

security-review · bugbot · explore · shell · deployment-expert · performance-optimizer

---

## Por fase

```
discover  → claude-mem, ui-ux-pro-max, explore
plan      → ui-ux-pro-max, impeccable shape, design-system
implement → impeccable, taste, motion, ui-styling, generalPurpose
verify    → shell, build, lint
audit     → security-review, bugbot, impeccable critique
fix       → generalPurpose, impeccable
gate      → polish, INDEX ✅, docs
```

---

## Verificar

```bash
bash .cursor/skills/loop-master/scripts/verify-pack.sh
cat .cursor/loop-master-progress.json | jq '.skills_installed, .memory_sync'
```
