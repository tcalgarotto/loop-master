# Visual Gate Protocol — screenshots + vision QA antes do gate

**Objetivo:** em fases com superfície FE, **capturar prints** (desktop + mobile) via Playwright e **só liberar `gate_passed`** após análise visual no Cursor (modelo multimodal) sem findings critical/high de design.

**Origem:** `/lucy aprenda` — browser IA + evidência pixel antes de entregar qualidade premium.

---

## Padrão automático (init + update)

Desde **v2.9.4**, visual gate é **ligado por padrão** — não precisa configurar manualmente.

| Momento | O que acontece |
|---------|----------------|
| `/lucy init` | `init.sh` instala Playwright + chromium **só se faltar**; grava `quality_gates` no JSON |
| `/lucy update` | Modo **incremental** — pula skills/deps já instalados; garante `quality_gates` ativos |
| Loop autônomo | Se `quality_gates.visual_gate_on_fe_phase === true` → capture + vision **antes** do gate |

```json
"quality_gates": {
  "visual_gate_auto": true,
  "visual_gate_on_fe_phase": true,
  "require_vision_before_gate": true
}
```

Desligar (raro): editar JSON → `"visual_gate_on_fe_phase": false`.

---

## Comando

```
/lucy visual-gate
/lucy visual-gate --capture-only
/lucy visual-gate --base-url http://localhost:3000
/lucy visual-gate --escopo /crm,/inbox
/lucy visual-gate --tick 42
```

Equivalente CLI:

```bash
# 1. Subir dev server (outro terminal)
npm run dev

# 2. Capturar
bash .cursor/skills/lucy/scripts/visual-gate-capture.sh \
  --base-url http://localhost:3000 \
  --project .
```

---

## Pipeline obrigatório (fase com UI)

### 0. Pré-requisitos

| Item | Ação |
|------|------|
| Dev server | `npm run dev` (ou URL de preview/staging) |
| Playwright | `npm install -D @playwright/test && npx playwright install chromium` |
| Inventário | `frontend-inventory.sh` (auto se ausente) |
| Auth | Rotas protegidas: login manual + `--auth-state` futuro; ou testar em staging com sessão |

### 1. Capture (shell — sem julgamento visual)

```bash
bash .cursor/skills/lucy/scripts/visual-gate-capture.sh \
  --base-url http://localhost:3000 \
  --tick "$(jq -r .tick_count .cursor/lucy-progress.json)"
```

Saída:

```
.lucy/visual-gates/tick-N/
├── manifest.json
├── root__desktop.png
├── root__mobile.png
├── crm__desktop.png
├── crm__mobile.png
└── ...
```

Atualiza `last_visual_audit` no progress JSON com `status: captured_pending_vision`.

### 2. Vision audit (agente Cursor — multimodal)

**Obrigatório:** abrir cada PNG do manifest (Read tool / anexar no chat) e pontuar.

Checklist cruzado com `ux-design-intelligence.md` + `premium-ui-stack.md`:

| ID | Critério | O que olhar | Severidade se falhar |
|----|----------|-------------|----------------------|
| V1 | **Ritmo 8px** | Padding/margin ímpar, elementos desalinhados | medium |
| V2 | **Hierarquia zinc** | Título vs corpo vs meta — opacidade, não 5 cinzas iguais | high |
| V3 | **Anti-slop** | Gradiente roxo/azul genérico, sombra pesada, copy “Welcome to…” | high |
| V4 | **CTA** | Ação primária óbvia (Von Restorff) | high |
| V5 | **Sidebar/nav** | Item ativo, largura, ícones lucide consistentes | medium |
| V6 | **Densidade** | Respiração vs clutter (Hick, Miller) | medium |
| V7 | **Mobile** | Overflow, tap targets, menu | critical se inutilizável |
| V8 | **Motion** | Sem jitter; `prefers-reduced-motion` se animado | low |

**Score por rota/viewport:** 0–10 em cada ID + `overall` (média).

### 3. Registrar findings

Para cada problema visual:

```json
{
  "id": "VG-crm-01",
  "severity": "high",
  "category": "design",
  "check": "V3",
  "note": "Hero gradient purple-500 — AI slop",
  "route": "/crm",
  "viewport": "desktop",
  "screenshot": ".lucy/visual-gates/tick-42/crm__desktop.png"
}
```

Merge em `last_audit.findings[]` **e** `last_visual_audit.routes[].findings[]`.

### 4. Gate decision

| Condição | `last_visual_audit.gate_passed` |
|----------|--------------------------------|
| Zero critical/high em vision + audit funcional | `true` |
| medium com waiver em `waived[]` | `true` com nota |
| critical/high aberto | `false` → `step=fix` → recapture |

**Regra:** `last_audit.gate_passed: true` em fase FE **somente se** `last_visual_audit.gate_passed === true`.

### 5. Handoff

- `brain-sync capture --paths ".lucy/visual-gates/tick-N/"`
- `next_prompt` inclui rotas com score < 7 se gate falhou
- Re-arm loop se incompleto

---

## JSON — `last_visual_audit`

```json
{
  "at": "2026-07-03T08:44:00Z",
  "tick": 42,
  "phase_id": "D7-gate-complete",
  "capture_dir": ".lucy/visual-gates/tick-42",
  "manifest": ".lucy/visual-gates/tick-42/manifest.json",
  "base_url": "http://localhost:3000",
  "status": "vision_complete",
  "routes": [
    {
      "route": "/crm",
      "screenshots": {
        "desktop": ".lucy/visual-gates/tick-42/crm__desktop.png",
        "mobile": ".lucy/visual-gates/tick-42/crm__mobile.png"
      },
      "scores": {
        "V1_spacing": 8,
        "V2_hierarchy": 7,
        "V3_anti_slop": 9,
        "V4_cta": 8,
        "V5_sidebar": 9,
        "V6_density": 8,
        "V7_mobile": 8,
        "V8_motion": 10,
        "overall": 8.4
      },
      "findings": [],
      "passed": true
    }
  ],
  "gate_passed": true,
  "waived": []
}
```

`status` values: `captured_pending_vision` → `vision_complete` | `failed`.

---

## Integração com outros fluxos

| Fluxo | Quando rodar visual gate |
|-------|--------------------------|
| Loop autônomo (`/lucy`) | Fase com `acceptance_criteria` UI → antes de `gate` |
| `/lucy refazer-frontend` | Após polish de cada página (1 rota) ou lote no fim do escopo |
| `/lucy audit` | Se fase atual tem superfície FE |
| `/lucy deploy` | Opcional smoke visual em staging URL |

---

## Browser IA / OpenRouter (futuro)

Hoje: **Cursor multimodal** lê PNGs locais (custo zero extra se já no plano).

Futuro: script `visual-gate-vision.sh` com OpenRouter vision model → preenche scores automaticamente; agente só valida e fixa.

---

## Anti-padrões

- `gate_passed: true` sem screenshots na fase FE
- Julgar só pelo código (impeccable) sem olhar pixel
- Capturar com dev server parado
- Ignorar viewport mobile
- Waivar critical/high visual sem owner
