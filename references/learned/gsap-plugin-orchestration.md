# GSAP Cursor Plugin — orquestração Lucy (aprendido via `/lucy aprenda`)

**Origem:** owner · 2026-07-05 · `/lucy aprenda`  
**Escopo:** plugin oficial GSAP no Cursor — **8 skills**, **não** é MCP.

> Protocolo canônico de motion: `references/gsap-premium-protocol.md`  
> Scroll storytelling brand: `references/premium-motion-scroll-protocol.md`  
> Pirâmide Lucy: `references/html-native-light-protocol.md`

---

## Vocabulário Lucy (P0)

| Termo correto | Errado / ambíguo |
|---------------|------------------|
| **GSAP Cursor plugin** (8 skills) | "GSAP MCP", "servidor GSAP" |
| **Skill** `gsap-react`, `gsap-scrolltrigger`, … | "tool GSAP" genérico |
| **`npm:gsap`** + `@gsap/react` no app | Confundir plugin Cursor com pacote npm |
| Auto-load pelo agente quando o pedido casa com `description` da skill | Assumir que Lucy "chama MCP" |

O plugin vive em `~/.cursor/plugins/cache/cursor-public/gsap-skills/…/skills/<nome>/SKILL.md`. Lucy **lê** a skill relevante antes de implementar — mesmo padrão de impeccable/taste, não CallMcpTool.

---

## As 8 skills — mapa rápido

| Skill | Quando Lucy carrega |
|-------|---------------------|
| **gsap-core** | Tweens (`to`/`from`/`fromTo`), stagger, easing, `gsap.matchMedia()`, recomendar GSAP vs CSS |
| **gsap-timeline** | Sequências multi-step, labels, position parameter, timelines aninhadas |
| **gsap-scrolltrigger** | Scroll-linked, pin, scrub, batch, horizontal fake scroll, `ScrollTrigger.create` |
| **gsap-react** | React/Next.js: `useGSAP`, `gsap.context`, scope, cleanup, SSR guard |
| **gsap-frameworks** | Vue/Nuxt/Svelte — `onMounted` + `ctx.revert()` (não React) |
| **gsap-plugins** | Flip, Draggable, SplitText, DrawSVG, ScrollTo, ScrollSmoother, CustomEase, etc. |
| **gsap-performance** | Jank, 60fps, `will-change`, `quickTo`, evitar layout thrashing |
| **gsap-utils** | `mapRange`, `clamp`, `snap`, `selector(scope)`, scroll progress → valor |

**Regra:** carregar **no máximo 2** skills GSAP por tick (ex.: `gsap-react` + `gsap-scrolltrigger` numa landing Next com pin).

---

## Árvore de decisão — qual skill invocar

```
Pedido envolve animação JS?
├─ Não → html-native-light (CSS view/scroll/hover) primeiro
└─ Sim
   ├─ Framework?
   │  ├─ React/Next → gsap-react (OBRIGATório antes de codar)
   │  ├─ Vue/Nuxt/Svelte → gsap-frameworks
   │  └─ HTML preview / vanilla → gsap-core (+ scrolltrigger se scroll)
   ├─ Tipo de motion
   │  ├─ 1 tween ou stagger simples → gsap-core
   │  ├─ 2+ passos coreografados → gsap-timeline (+ gsap-core)
   │  ├─ Scroll pin/scrub/parallax/storytelling → gsap-scrolltrigger (+ premium-motion-scroll se brand)
   │  ├─ Flip layout / drag / SplitText / SVG draw → gsap-plugins
   │  ├─ FPS / jank / muitos elementos → gsap-performance
   │  └─ Mapear scroll→valor, snap grid → gsap-utils
   └─ Register (PRODUCT.md)
      ├─ brand (landing, pricing, portfolio) → motion completo; sugerir premium-motion-scroll
      └─ product (CRM, dashboard, tabelas) → motion funcional 150–250 ms; recusar pin/scrub salvo exceção
```

---

## Integração com a pirâmide Lucy

```
1. html-native-light   → view(), scroll(), dialog, hover CSS
2. GSAP plugin skills  → timelines, stagger 20+, ScrollTrigger, pin+scrub
3. Framer Motion       → layoutId, AnimatePresence, DnD React (último recurso)
```

**Ordem obrigatória:** tentar CSS scroll-driven **antes** de ScrollTrigger em reveals simples. GSAP quando CSS não cobre (acts coreografados, pin longo, scrub vídeo, stagger 50+).

**Conflito proibido:** `transition-*` Tailwind no **mesmo elemento** que GSAP anima — só hover/active em **outro** nó ou estado estático.

---

## Auto-seleção vs invocação manual

| Modo | Comportamento |
|------|---------------|
| **Auto** | Cursor injeta skill quando `description` da skill casa (ex.: "ScrollTrigger" → `gsap-scrolltrigger`) |
| **Manual** | Owner digita `/gsap-react` ou menciona skill no prompt |
| **Lucy** | Em ticks de landing/refazer-frontend: **declarar** qual skill GSAP será seguida; ler SKILL.md antes de implementar |

Lucy **não** espera o owner instalar skills — assume plugin GSAP presente se Cursor marketplace instalou. Se skill ausente, seguir `gsap-premium-protocol.md` (conhecimento embutido no skill pack).

---

## Register HubFU — brand vs product

| Register | GSAP permitido | Skills típicas |
|----------|----------------|----------------|
| **brand** | Hero timeline, ScrollTrigger acts, pin+scrub vídeo, SplitText headline, stagger seções | core + timeline + scrolltrigger; plugins se SplitText/Flip |
| **product** | Stagger entrada lista (1×), micro feedback; **sem** pin/scrub/sandwich | core + react; performance se lista grande |
| **ambíguo** | Inferir de `PRODUCT.md` `## Register` ou perguntar | — |

**prefers-reduced-motion:** usar `gsap.matchMedia()` (gsap-core) — `duration: 0` ou skip; nunca só `window.matchMedia` solto sem revert no unmount.

```javascript
const mm = gsap.matchMedia();
mm.add("(prefers-reduced-motion: reduce)", () => {
  gsap.set(".reveal", { opacity: 1, y: 0 });
});
// cleanup: mm.revert()
```

Em React: preferir `useGSAP` com condição ou matchMedia dentro do hook scope.

---

## Routing por superfície — exemplos de prompt Lucy

| Superfície | Skills | Exemplo de ação |
|------------|--------|-----------------|
| Landing hero Next | gsap-react + gsap-timeline | Intro timeline sidebar→headline→CTA; `useGSAP({ scope })` |
| Landing scroll story | gsap-scrolltrigger + premium-motion-scroll | Pin vídeo + scrub; 3 acts |
| CRM lista 50 clientes | gsap-react + gsap-core | `from` stagger 0.05; sem ScrollTrigger |
| Dashboard métricas | gsap-core ou CSS view() | Product: preferir CSS view(); GSAP só se stagger chart |
| HTML preview kanban | gsap-core | Snap on drop; vanilla context |
| Pricing headline brand | gsap-plugins (SplitText) + gsap-timeline | Chars stagger; registrar SplitText |
| Mouse follower / perf | gsap-performance + gsap-utils | `quickTo` + `mapRange` |
| Vue admin (raro) | gsap-frameworks + gsap-core | onMounted context |

---

## Anti-padrões (Lucy P0)

- Chamar GSAP "MCP" ou usar `CallMcpTool` para animação
- `useEffect` sem `ctx.revert()` quando `@gsap/react` disponível — preferir **useGSAP**
- ScrollTrigger em tween **filho** de timeline — só no timeline top-level
- `scrub` + `toggleActions` no mesmo trigger
- Pin + animar o próprio elemento pinado — animar **filhos**
- GSAP + Framer + `transition-all` no mesmo nó
- ScrollTrigger em dashboard denso (product) "por premium"
- `markers: true` em produção
- Registrar plugins dentro de componente que re-renderiza
- Ignorar `ScrollTrigger.refresh()` após layout async (imagens, fonts)

---

## Cross-links

- `references/gsap-premium-protocol.md` — regras Lucy + exemplos HubFU
- `references/premium-motion-scroll-protocol.md` — pin/scrub/sandwich/imagery
- `references/premium-tool-orchestration.md` — momento certo no tick
- `references/design-skills-routing-table.md` — tabela 8 skills
- Plugin paths: `gsap-core`, `gsap-timeline`, `gsap-scrolltrigger`, `gsap-react`, `gsap-frameworks`, `gsap-plugins`, `gsap-performance`, `gsap-utils`
