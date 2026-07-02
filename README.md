# Loop Master v2.4

> **Zero-config autonomous orchestrator** for Cursor Agent.

[Guia rápido (PT)](references/getting-started.md) · [Quiz 6 rodadas](references/quiz-protocol.md) · [Design routing](references/design-skills-routing-table.md)

---

## Quick start

```bash
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/loop-master
cd seu-projeto
```

No Cursor Agent:

```
/loop-master init
```

**That's it.** Bootstrap installs all skills, runs 6-round quiz, creates plan + INDEX, arms dynamic loop.

---

## What init installs (automatic)

| Skill | Purpose |
|-------|---------|
| impeccable | Product UI refinement |
| ui-ux-pro-max | Design system |
| taste-skill | Marketing / anti-slop |
| caveman | Handoff compression |
| claude-mem | Cross-session memory |
| motion | React animations |

Plus: symlinks for design, design-system, ui-styling, brand, slides, banner-design if present.

---

## Commands

| Command | Action |
|---------|--------|
| `/loop-master init` | Full bootstrap + 6-round quiz + arm loop |
| `/loop-master` | One autonomous tick |
| `/loop-master update` | Update pack preserving progress |
| `pare o loop` | Stop loop |

---

## Autonomous mode

- **Dynamic loop:** re-arm 45s after each tick until 100%
- **Self-correction:** implement → verify → audit → fix ↺ → gate
- **Design director:** routes all design skills automatically
- **Memory:** L1 JSON + L2 claude-mem + L3 PLAN/INDEX (✅⏳🔮👤)

---

## Scripts

| Script | Function |
|--------|----------|
| `init.sh` | Full zero-config bootstrap (default) |
| `update.sh` | Update preserving context |
| `link-ecosystem-skills.sh` | Symlinks |
| `arm-dynamic-loop.sh` | Chain next tick |
| `verify-pack.sh` | Pre-publish smoke test |

---

## Version

**2.4.0** — zero-config init, 6-round quiz, mandatory claude-mem, design routing map, INDEX emojis.

MIT License
