# VPS Live Mode — playbook do owner

**Quando usar:** owner pede `/impeccable live` ou "abrir live mode" com projeto aberto via **Cursor Remote SSH** na VPS.

**Lucy:** guia passo a passo — **não** encerrar com "não funciona". Detalhe: `impeccable-live-mode.md` § "Quando o owner pede Live Mode no VPS".

---

## Checklist rápido

- [ ] Entendi: agente VPS **não** controla browser interativo (MCP `toolCount=0`)
- [ ] Dev server HMR rodando (ex. `cd frontend && npm run dev` → **:3000**)
- [ ] Escolhi caminho: **A** Desktop local | **B** SSH tunnel | **C** Cursor Ports | **D** bind+firewall
- [ ] Helper Live (:8400 típico) acessível se usar tunnel/Ports
- [ ] `PRODUCT.md` + `DESIGN.md` na raiz; `.impeccable/live/config.json` ok
- [ ] Browser aberto na rota certa antes do poll loop

---

## Opção A — Desktop local (recomendada)

1. Clone/sync repo no laptop
2. `cd frontend && npm install && npm run dev`
3. Cursor **Desktop** (não SSH) → `/impeccable live`
4. `check-browser-mcp.sh` exit 0

---

## Opção B — SSH tunnel

**VPS:** `npm run dev` (frontend, porta 3000)

**Laptop:**

```bash
ssh -L 3000:127.0.0.1:3000 -L 8400:127.0.0.1:8400 user@VPS
```

Browser laptop → `http://localhost:3000`

---

## Opção C — Cursor Forwarded Ports

1. Dev server na VPS (:3000)
2. Cursor → Ports → Forward **3000** (+ **8400** se live helper ativo)
3. Abrir URL forwarded no browser **local**

---

## Opção D — 0.0.0.0 + firewall (dev only)

```bash
npm run dev -- -H 0.0.0.0 -p 3000
```

Firewall: allow **só seu IP**. Nunca `:3000` público em prod.

---

## HubFU (hermes-crm)

| Item | Valor |
|------|-------|
| Frontend dev | `cd frontend && npm run dev` → **3000** |
| Docker frontend | Sem host port — **não** usar nginx:80 para Live |
| Backend API | docker :8000 — configurar `NEXT_PUBLIC_API_URL` se dev local |
| Regra P0 projeto | `.cursor/lucy-brain/rules/live-mode-vps-guide.md` |

---

## Se nada disso agora

Lucy usa **polish/layout** + detect + visual-gate Playwright. Live fica para quando tunnel ou Desktop estiver pronto.

---

## Cross-links

- `impeccable-live-mode.md` — workflow completo
- `vps-headless-browser-default.md` — por que MCP falha na VPS
- `impeccable-lucy-integration.md` — gatilhos de frase
