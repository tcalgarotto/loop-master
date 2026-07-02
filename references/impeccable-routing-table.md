# Impeccable routing table — UI refinement no loop-master

Mapeia **15 comandos Impeccable** permitidos no ciclo minor
(`plan` → `implement` → `audit` → `fix` → `gate`).

**Pré-requisito:** skill Impeccable instalada no projeto (`npx impeccable install`).
**Complementar:** `design-stack-protocol.md`, `ui-ux-pro-max`, `taste-skill`.

---

## Regras do orchestrator

1. **Escopo:** só invocar Impeccable em fases **frontend** ou full-stack com superfície UI — nunca em backend-only, migrations puras, ou ticks só de infra.
2. **Limite:** máximo **1–2 comandos Impeccable por step** do minor cycle.
3. **Pré-requisito:** worker lê `SKILL.md` + `reference/<cmd>.md` do Impeccable.
4. **Sequência recomendada** (vários ticks):  
   `shape` → `layout` → `colorize` → `typeset` → `clarify`/`distill` → `animate` → `polish` → `critique` → `harden` → `optimize`
5. **Uma superfície por tick** (rota, página ou componente) — não o repo inteiro.

---

## 15 comandos permitidos

| Comando | Step típico | Quando usar |
|---------|-------------|-------------|
| `shape` | plan | UX não definida; antes de codar |
| `craft` | implement | Página/componente novo |
| `layout` | implement, fix | Grid, spacing, rhythm |
| `colorize` | implement | Paleta monocromática, CTAs |
| `typeset` | fix | Hierarquia tipográfica |
| `clarify` | fix | Copy confusa, empty states |
| `distill` | fix | UI densa demais |
| `quieter` / `bolder` | fix | Tom visual |
| `adapt` | implement | Responsive / mobile |
| `animate` | implement | Motion (pair com biblioteca motion) |
| `critique` | audit | Review UX adversarial pré-gate |
| `harden` | audit, fix | Edge cases, a11y, erros |
| `polish` | gate | Pass final design system |
| `optimize` | gate | Performance FE |

---

## Roteamento por `minor_cycle.step`

| Step | Comandos (max 2) |
|------|------------------|
| `plan` | `shape` |
| `implement` | `craft`, `layout`, `colorize`, `adapt`, `animate` |
| `audit` | `critique`, `harden` |
| `fix` | `typeset`, `bolder`, `quieter`, `distill`, `clarify`, `layout` |
| `gate` | `polish`, `optimize` |

---

## Comandos EXCLUÍDOS no loop automatizado

| Excluído | Motivo |
|----------|--------|
| `init` | Setup one-time — fazer manualmente ou no init do projeto |
| `document`, `extract` | Ownership do design system do projeto |
| `audit` | Loop-master já tem audit + verifiers |
| `onboard`, `delight`, `overdrive` | Fora do escopo típico de produto |
| `live`, `pin`, `unpin`, `hooks` | Gestão harness — manual |

---

## Anti-padrões

- `polish` repetido no mesmo tick
- `craft` sem `shape` em superfície ambígua
- `bolder` + `colorize` no mesmo step
- Impeccable em tick só backend
- Mais de 2 comandos por step
