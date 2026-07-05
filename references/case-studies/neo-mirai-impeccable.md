# Case Study #001 — Neo Mirai (Impeccable)

**Register:** brand  
**Tags:** retro-futurist, editorial, conference, warm palette, japanese-influenced, craft-pipeline  
**Status:** reference for site suggestions — **not** a CRM/dashboard template

---

## Metadata

| Campo | Valor |
|-------|-------|
| **ID** | `#001` |
| **Nome** | Neo Mirai AI Design Conference |
| **Contexto** | Landing de conferência fictícia (Tokyo 2042) — showcase Impeccable |
| **North-star mock** | https://impeccable.style/assets/openai_image_2_hifi.jpg |
| **Live build** | https://impeccable.style/neo-mirai/ |
| **Craft docs** | https://impeccable.style/docs/craft |
| **Pipeline owner** | GPT Image 2 hi-fi mock → brand toolkit → `/impeccable craft` → live site |
| **Adicionado** | 2026-07-05 via `/lucy aprenda` |

---

## Visual DNA

### Paleta (warm paper)

| Token | Uso | Notas |
|-------|-----|-------|
| **Cream / off-white** | Background principal, respiro editorial | Textura grain sutil — papel impresso, não flat digital |
| **Charcoal / deep black** | Texto primário, blocos AGENDA e footer | Contraste alto; nunca preto `#000` puro |
| **Burnt orange / terracotta** | Sols, CTAs, manifesto band, highlights de data | Motif recorrente — círculos sol/lua |
| **Mid tan** | Transições, overlays quentes | Aparece no brand toolkit (shape phase) |

### Tipografia

| Papel | Estilo | Aplicação |
|-------|--------|-----------|
| **Display / headings** | Serif high-contrast (Didot/Bodoni-adjacent) | Hero "NEO MIRAI AI DESIGN CONFERENCE", títulos de seção |
| **UI / body** | Sans minimal, letter-spacing generoso | Nav small-caps, datas, labels, pricing |
| **Accent** | Vertical Japanese (`writing-mode: vertical-rl`) | Margens decorativas + labels culturais — **não** tradução funcional |

### Composição

- **Asymmetric rhythm** — grid com larguras variáveis; evitar stack centrado simétrico
- **Full-bleed hero** — ilustração painterly ocupa viewport; headline top-left
- **Dark agenda sidebar** — bloco charcoal vertical à esquerda vs ilustração cream à direita
- **Horizontal bands** — manifesto (orange block + landscape), tickets (colunas + CTA vertical)
- **Overlapping accents** — círculos laranja semi-transparentes, texto JP sobre cream
- **Grain texture** — overlay sutil em blocos grandes e imagens

### Image language

- Ilustrações grainy, painterly — fusão arquitetura tradicional japonesa + skyline futurista
- Motifs: sol/lua laranja gigante, silhuetas humanas pequenas, Mt. Fuji, bonsai/pine overlay
- Portraits: profile-view estilizado, fundo circular laranja
- Installations: grids quadrados, paisagens abstratas minimalistas com portal circular

---

## Section anatomy

### 1. Header & navigation

- Logo "NEO MIRAI" + ícone circular (city/sun motif)
- Links: HOME, AGENDA, SPEAKERS, INSTALLATIONS, EXPERIENCE, PRACTICALS
- CTA: "GET TICKETS" — box fino charcoal ou fill laranja

### 2. Hero

- Full-bleed illustration (futuristic Tokyo walkway / skyline)
- Headline serif grande, left-aligned
- Sub: "Tokyo 2042" em laranja + tagline "Illustration, interfaces, machines, optimism"
- Meta: MAY 20–22, 2042 · Tokyo International Forum
- Badge/stamp JP no canto superior direito
- Vertical JP text na margem esquerda

### 3. Agenda (split)

- **Left:** bloco charcoal ~40% — "AGENDA", DAY 01–03 com datas e temas (orange accents)
- **Right:** ilustração vertical — figura solitária, círculos laranja, estrutura monolítica
- CTA secundário: "View full agenda"

### 4. Speakers

- Heading: "SPEAKERS" + "Pioneers shaping tomorrow"
- Row horizontal: 3 portraits estilizados (Yumi Nakamura, Keisuke Tanaka, Sophia Lee)
- Grid lines + círculos laranja semi-transparentes no background
- CTA: "View full speakers"

### 5. Installations

- Grid 3 colunas, thumbnails quadrados
- Titles: Harmonic Flux, Dream Compiler, Echoes of Tomorrow
- CTA: "Explore installations"

### 6. Manifesto band

- **Left:** bloco laranja sólido — "We believe the future is something we design together."
- **Right:** landscape wide — Mt. Fuji + city futurista + red sun
- Full-width horizontal band — quebra visual forte

### 7. Tickets

- 4 colunas: Attendee ¥49,000 · Student ¥19,000 · Supporter ¥99,000 · Group (contact)
- Botões "Select" circulares escuros
- CTA primário: bloco laranja vertical "GET YOUR TICKET" com ícone circular
- Decorative: bonsai/pine branch overlapping bottom-left (variant)

### 8. Footer

- Barra charcoal slim
- Logo, links secundários (About, Partners, News…), toggle EN / 日本語, social icons

---

## Motion hints

**Protocolo:** `premium-motion-scroll-protocol.md`

| Seção | Motion sugerido | Prioridade |
|-------|-----------------|------------|
| Hero | Parallax sutil no sol/camadas da ilustração (CSS ou GSAP, max 2 layers) | Média |
| Entre seções | `animation-timeline: view()` stagger — headline → sub → CTA | Alta |
| Agenda split | Reveal lateral: bloco dark slide-in + ilustração fade-up | Média |
| Speakers | Stagger horizontal nos portraits (150–300 ms, spring leve) | Média |
| Manifesto band | Scroll reveal no texto; parallax leve no landscape | Baixa |
| Tickets | Hover nos "Select" — scale 1.02 + shadow; CTA pulse mínimo | Baixa |

**Evitar:** pin+scrub vídeo (não há vídeo), sandwich stack (layout editorial já denso), glassmorphism decorativo, fade-on-scroll uniforme em todas as seções.

**Reduced motion:** hero estático + reveals desligados; CTAs permanecem visíveis.

---

## Craft pipeline mapping

### Pipeline Impeccable (4 fases — non-skippable)

| Fase | O que aconteceu no Neo Mirai | Lucy propõe quando |
|------|------------------------------|-------------------|
| **01 Shape discovery** | Brief: conferência AI design, Tokyo 2042, retro-futurist warm | Owner pede landing **do zero** sem brief claro |
| **02 Load references** | Brand toolkit: logo, palette, type, icons, merch mockups, image language | Após mock hi-fi ou intake de referências |
| **03 Build** | Structure → hierarchy → type → color → states → motion → responsive | Implementação com brief + toolkit locked |
| **04 Visual iteration** | Browser check após cada pass; refine até match brief + anti-pattern zero | **Sempre** — first working ≠ shipped |

### Fluxo completo (visualize → shape → craft → ship)

```
GPT Image 2 hi-fi mock (north star)
        ↓
Brand toolkit extraction (shape)
        ↓
/impeccable craft <brief>
        ↓
Asset regeneration (portraits, manifesto city, pine overlay)
        ↓
Browser iteration (each pass)
        ↓
Live site (semantic HTML, responsive, real states)
```

### Quando Lucy deve propor este fluxo

| Sinal do owner | Proposta Lucy |
|----------------|---------------|
| "Landing de conferência do zero" | Case #001 + `/impeccable craft retro-futurist AI design conference website` |
| "Quero um site editorial premium" | Neo Mirai como referência visual + craft pipeline |
| Mock hi-fi anexado (PNG/JPG) | Shape toolkit a partir do mock → craft build |
| Brief vago ("algo bonito para evento") | Sugerir visualize mock primeiro, depois craft |

### Quando NÃO propor craft completo

- Touch-up em página existente → `polish` / `critique` / Live Mode
- CRM/dashboard/settings → register **product**, não este case study
- Owner já tem HTML aprovado → port Next, não re-craft do zero

---

## Asset regeneration (preserved vs regenerated)

| Elemento | Tratamento |
|----------|------------|
| Layout structure | **Preserved** — asymmetric rhythm, section order |
| Hero illustration | Regenerado/polished — mesmo estilo, composição similar |
| Agenda dark block | **Preserved** — CSS/HTML structure |
| Speaker portraits | **Regenerated** — raster, mesmo estilo profile-view |
| Installation thumbnails | Regenerados — abstract landscapes |
| Manifesto city landscape | **Regenerated** — Mt. Fuji + skyline |
| Pine/bonsai overlay (tickets) | **Regenerated** — decorative raster |
| UI chrome (nav, buttons, type) | **Built** — semantic HTML/CSS |

**Regra:** image-native pieces stay raster; structural/editorial patterns stay in code.

---

## Anti-patterns avoided

O que Impeccable detectaria se feito com sloppiness:

| Anti-pattern | Por quê Neo Mirai evita |
|--------------|-------------------------|
| Purple gradient slop | Paleta warm cream/charcoal/orange — zero SaaS gradient |
| Centered symmetric stack | Asymmetric grid editorial |
| Icon tile above heading | Hierarquia serif display + ilustração como argumento |
| Low contrast body text | Charcoal on cream — legível; ash só em labels ≥16px |
| Pure black/white | Tokens tinted (cream, charcoal) |
| Inter/Roboto default | Serif display + tracked sans — identidade editorial |
| Glassmorphism everywhere | Superfícies opacas; grain texture instead |
| Stock photo hero | Art-directed illustration full-bleed |
| Fade-on-scroll uniforme | Reveals por seção, não blanket opacity |
| Generic "Get Started" CTA | "GET TICKETS" / "GET YOUR TICKET" — contexto conferência |

---

## Suggestion triggers

Lucy deve considerar este case study quando o owner menciona:

| Trigger (PT-BR / EN) | Match strength |
|----------------------|----------------|
| "conference landing", "landing de evento" | **Alta** |
| "editorial brand", "marca editorial" | **Alta** |
| "retro-futurist", "retro-futurista" | **Alta** |
| "warm paper aesthetic", "estética papel quente" | **Alta** |
| "japanese influenced", "influência japonesa" | **Média** |
| "design conference", "summit landing" | **Alta** |
| "full design+build flow", "do zero com design" | **Alta** → propor craft pipeline |

### Template de sugestão Lucy

> Este estudo de caso combina com **[pedido do owner]** porque compartilha **[2–3 traits]**: paleta warm paper (cream/charcoal/laranja), composição editorial assimétrica, e pipeline visualize→shape→craft. Quer que eu use Neo Mirai (#001) como north star e proponha `/impeccable craft`?

---

## PT-BR — resumo para o owner

**Neo Mirai** é a referência canônica de landing **brand** feita com pipeline Impeccable completo: mock hi-fi (GPT Image 2) → brand toolkit → `/impeccable craft` → site live com assets regenerados e iteração no browser.

**O que copiar:** ritmo assimétrico, hero full-bleed ilustrado, bloco agenda escuro, band manifesto laranja, grid instalações, campo de tickets com CTA vertical, texto japonês vertical como accent.

**O que NÃO copiar em CRM:** esta estética é para storytelling e imersão de marca — dashboards e tabelas densas usam register **product** (zinc, motion funcional 150–250 ms).

**Comando exemplo:** `/impeccable craft retro-futurist AI design conference website`

---

## Cross-references

- `references/case-studies/INDEX.md` — catálogo
- `references/template-gallery.md` §10 — Neo Mirai conference template
- `references/learned/impeccable-lucy-integration.md` — craft routing
- `references/premium-motion-scroll-protocol.md` — motion hints
- `references/premium-tool-orchestration.md` — quando checar case studies
- `references/design-system-intake.md` — case study references section
