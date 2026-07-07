# HubFU Design System v1.9 — aprendizado global

**Data:** 2026-07-07  
**Versão Lucy:** v2.9.37+  
**Origem:** `/lucy aprenda` — sessão HubFU workflow + motion + shadcn

---

## Resumo

HubFU DS evoluiu de catálogo estático para **showcase interativo HTML-first**: workflow canvas Attio, motion controller, specimens shadcn e integrações v2 — tudo em `preview/` antes de port Next.

## Protocolo HTML-first → port

```
preview/hubfu-design-system.html (owner aprova visual)
  → references/design-system/hubfu/*.md (contrato markdown)
  → Penpot MCP (tokens)
  → port Next.js (shadcn + Framer Motion)
```

**Nunca** portar componente sem specimen aprovado no HTML.

## Novidades v1.9

| Área | Artefato | Nota |
|------|----------|------|
| Workflow | `hubfu-workflow.js`, `#workflow` | Canvas claro, pan/zoom CTRL+scroll 50–150%, drag-drop nós, paths Bézier |
| Motion | `hubfu-motion.js`, `#motion` | Pirâmide CSS → GSAP → Framer; um elemento = um dono |
| shadcn | `hubfu-ds-shadcn-section.html`, `#shadcn` | Mapping tokens → componentes; dark mode sem forçar branco |
| Integrações | `#integracoes` | Grid v2 canônico em `#int-v2-showcase`; cards sólidos (zero glass) |
| Planilha | `hubfu-sheet.js` | HubfuSheet save otimista + toasts |

## Cross-links

- `references/design-system/hubfu/INDEX.md` — índice canônico
- `references/design-system/hubfu/motion-shadcn-guide.md` — guia motion + shadcn
- `references/html-first-design-protocol.md` — Caminho C
- `references/design-editable-hybrid-protocol.md` — loop HTML → Penpot → Next

## Anti-padrões

- Portar workflow para React sem validar pan/zoom/drag no HTML
- Glass/backdrop-filter em cards de integração (P0: superfícies sólidas)
- Misturar `transition-*` Tailwind no mesmo nó que GSAP anima
