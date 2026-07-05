# Aprendizado: padrões premium motion & scroll

**Data:** 2026-07-05  
**Slug:** `premium-motion-patterns`  
**Comando:** `/lucy aprenda`  
**Protocolo canônico:** `references/premium-motion-scroll-protocol.md`

---

## O que o owner pediu

Lucy ainda não cobria uma classe de padrões web premium que o owner quer **implementar bem** e **sugerir proativamente** em sites:

- Fotografia / imagem como elemento de design de primeira classe
- Transições elegantes seção-a-seção (scroll-driven reveals)
- Vídeo sincronizado com scroll em seção pinada (estilo Apple AirPods)
- Morphism (glass/clay/neu) com bom gosto, não slop
- Layouts sandwich / sticky-stacking
- Scroll storytelling premium em geral

---

## O que foi adicionado

| Artefato | Conteúdo |
|----------|----------|
| `premium-motion-scroll-protocol.md` | Referência mestre: 6 famílias de padrão, WHEN/WHEN NOT, a11y, budget, receitas CSS + GSAP + Next.js |
| `gsap-premium-protocol.md` | Cross-links pin/scrub/sandwich (sem duplicar receitas) |
| `premium-tool-orchestration.md` | Gatilhos **sugerir** (brand) vs **restringir** (product) |
| `design-skills-routing-table.md` | Rotas por superfície |
| `template-gallery.md` | Templates editorial hero, pin-scrub, sandwich |

---

## Por quê (decisão de produto)

1. **Separar register** — impeccable já distingue brand (motion como voz) de product (150–250 ms funcional). Lucy agora **propõe** storytelling só onde design IS the product.
2. **CSS antes de GSAP** — scroll-driven nativo (2026) cobre reveals e sandwich sem JS; GSAP reservado para pin+scrub e acts complexos.
3. **Anti-slop explícito** — bans de morphism em grid inteiro, fade-on-scroll uniforme, neu em ERP; alinhado a `animate.md` e detector impeccable.
4. **Sugestão proativa** — landing “plana” dispara lista de 2–3 padrões; owner pode recusar.

---

## Como usar em ticks futuros

- Landing nova → ler `premium-motion-scroll-protocol.md` § Registro + sugerir padrões
- `critique` sem vida → pin-scrub OU sandwich OU editorial hero (escolher 1, não os 3)
- CRM/dashboard → **não** abrir este protocolo salvo header `scroll()` já documentado em html-native
- URLs de referência do owner → `/lucy analise @url` para extrair implementação exata

---

## Fontes consultadas

- [Chrome scroll-driven animations](https://developer.chrome.com/docs/css-ui/scroll-driven-animations)
- [MDN scroll-driven timelines](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_scroll-driven_animations/Timelines)
- [Stacking cards CSS demo](https://scroll-driven-animations.style/demos/stacking-cards/css/)
- [Codrops OPTIKKA frame sequences](https://tympanus.net/codrops/2025/10/16/creating-smooth-scroll-synchronized-animation-for-optikka-from-html5-video-to-frame-sequences/)
- Impeccable `animate.md` / `delight.md` — motion com propósito, reduced motion obrigatório
