# Premium UI Stack — Design Intelligence v2.7

Conhecimento destilado sobre como criar interfaces de **qualidade máxima** em Next.js.
**Usar em toda tarefa com superfície visual.** Ler antes de qualquer implementação de UI.

> 🧠 Leis psicológicas, sidebar research, Refactoring UI e Apple HIG: `references/ux-design-intelligence.md`
> 📚 Routing de skills por superfície: `references/design-skills-routing-table.md`

---

## Filosofia

> Design premium = **limitação criativa** + **sistema** + **espelho** (preview) + **leis psicológicas**.
> Não invente CSS. Use o ecossistema correto e restrinja a IA a ele.

Inspiração obrigatória: estudar os sistemas de design de referência do mercado de SaaS premium (godly.website, bentogrids.xyz, shadcnstudio.com).

---

## Stack Canônica (Next.js + App Router)

| Camada | Biblioteca | Custo | Papel |
|--------|-----------|-------|-------|
| Estrutura | **Next.js** (App Router) | Free | Motor SSR/SSG, Server Actions |
| Estilo | **Tailwind CSS** | Free | Tokens utilitários, paleta controlada |
| Componentes | **shadcn/ui** | Free | Estrutura visual pronta e acessível |
| Ícones | **Lucide React** | Free | Incluído no shadcn — 1 cor neutra |
| Animações | **Framer Motion** | Free | Springs, transições de aba, micro-animações |
| Gráficos | **Tremor Raw** | Free | Dashboards financeiros leves e limpos |
| Efeitos IA | **Magic UI** | Free | Dot Pattern, Bento Grid, texto digitado |
| Efeitos premium | **Aceternity UI** | Free/Paid | Spotlight, skeletons avançados |
| Cache de dados | **TanStack Query** | Free | Cache SWR, atualização invisível em BG |

**Instalar em projetos Next.js:**
```bash
npx shadcn@latest init           # configura shadcn (paleta Zinc, dark mode)
npm install framer-motion         # animações
npm install @tremor/react         # gráficos
npm install @tanstack/react-query # cache
npm install lucide-react          # ícones (geralmente já incluído pelo shadcn)
```

---

## Paleta de Cores Premium (Regra obrigatória)

**Proibido:** azul puro (#0000ff), preto puro (#000000), branco puro (#ffffff em dark), bordas coloridas fortes.

**Padrão Zinc/Slate:**
| Elemento | Token Tailwind | Hex |
|----------|---------------|-----|
| Fundo dark premium | `bg-zinc-950` | #09090b |
| Fundo página light | `bg-zinc-50` | #fafafa |
| Cards/painéis | `bg-white` | — |
| Sidebar escura | `bg-zinc-950` | #09090b |
| Sidebar expansível | `bg-zinc-50` | — |
| Texto principal dark | `text-white/90` | — |
| Texto secundário | `text-white/60` | — |
| Texto hint/label | `text-white/40` | — |
| Ícones sidebar inativos | `text-zinc-400` | — |
| Ícone ativo | `text-white` | — |
| Hover de item menu | `bg-zinc-800/50 rounded-lg` | — |
| Item ativo | `bg-zinc-800 text-white` | — |
| Badge "Conectado" | `bg-emerald-50 text-emerald-700` | — |
| Badge "Erro" | `bg-red-50 text-red-700` | — |
| Badge "Warning" | `bg-amber-50 text-amber-700` | — |

**Hierarquia de opacidade** (Refactoring UI — regra de ouro):
```tsx
// Em vez de cinzas diferentes, use opacidade — absorve o fundo automaticamente
<h2 className="text-white">Título</h2>           {/* 100% */}
<p className="text-white/60">Subtítulo</p>        {/* 60% */}
<span className="text-white/40">Label/hint</span>  {/* 40% */}
```

**Glassmorphism** (estilo premium — para modais e painéis flutuantes):
```tsx
// Sobre fundo escuro
className="bg-white/5 backdrop-blur-md border border-white/10 rounded-2xl"
// Sobre fundo claro
className="bg-white/80 backdrop-blur-sm border border-zinc-200/50 rounded-xl shadow-sm"
```

---

## Tipografia e Espaçamento (Regras obrigatórias)

- **Regra do 8px:** toda margem/padding múltiplo de 8px (`p-4`, `p-8`, `gap-4`).
- **Arredondamento moderno:** `rounded-xl` (cards), `rounded-2xl` (modais), `rounded-lg` (botões, badges, hover itens).
- **Sombras sutis:** `shadow-sm` em cards. **Nunca** `shadow-xl` em elementos internos.
- **Grupos de menu:** `<span className="text-[10px] font-bold text-zinc-400 tracking-wider uppercase">PIPELINE</span>`
- **Links:** `text-zinc-900 font-medium` + hover `underline` — nunca azul puro.

---

## Double Sidebar — Padrão CRM/ERP/Dashboard (12 Padrões UX)

O padrão definitivo para sistemas complexos (SaaS premium de referência no mercado).
Baseado em research do UX Planet (n=12 padrões validados por usuários reais).

```
[Mini-sidebar 48–64px fixo] | [Sidebar expansível 240–300px] | [Painel principal]
```

### Mini-Sidebar (Seções globais)
```tsx
// Especificações validadas por UX research
width: "w-16" // 64px
bg: "bg-zinc-950"
// Ícone inativo
"text-zinc-400 hover:text-white transition-colors"
// Ícone ativo
"text-white"
// Tooltip obrigatório (Fitts's Law + acessibilidade)
<Tooltip side="right">{nome} <kbd>⌘{n}</kbd></Tooltip>
```

### Sidebar Expansível (Menus internos)
```tsx
width: "w-60" // 240px
bg: "bg-zinc-50" // ou bg-zinc-900 em dark
// AnimatePresence obrigatório
initial={{ opacity: 0, x: -16 }}
animate={{ opacity: 1, x: 0 }}
exit={{ opacity: 0, x: -16 }}
transition={{ type: "spring", stiffness: 300, damping: 30 }}
```

### Estados de Item de Menu
```tsx
// Base
"flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors"
// Default: text-zinc-400 hover:text-zinc-100 hover:bg-zinc-800/50
// Ativo:   text-white bg-zinc-800 shadow-sm
// Group label: text-[10px] font-semibold text-zinc-500 uppercase tracking-wider
// Divider: my-2 border-t border-zinc-800/50 (nunca colorida)
```

### 12 Padrões UX Obrigatórios
1. Largura: 240–300px expandida, 48–64px mini
2. Navegação dinâmica: sidebar de Settings ≠ sidebar principal
3. Account switcher no topo (dropdown: avatar, nome, email)
4. Subitens expansíveis com chevron + spring animation
5. Área de updates no rodapé (anúncios não intrusivos)
6. Toggle dark/light mode na sidebar
7. Highlight ativo: fundo + texto bold (WCAG contrast ✓)
8. Features mais usadas no topo (Pareto 80/20)
9. Largura ajustável pelo usuário (drag handle)
10. Quick search: Cmd+K com atalho visível no campo
11. Botões de ação nos itens (aparecem no hover)
12. Sidebar secundária para sistemas complexos

**Implementação base:**
```bash
npx shadcn@latest add sidebar  # adiciona o componente sidebar do shadcn
```

---

## Prompt-Mestre para Refatoração Visual (copiar e adaptar)

```
Cursor, veja a estrutura desse dashboard. Refatore o visual para padrão shadcn/Vercel premium,
aplicando Laws of UX e regras do Refactoring UI:

1. Elimine bordas coloridas. Cards: bg-white, rounded-xl, shadow-sm, sobre bg-zinc-50.
2. Aplique regra dos 8px em todo espaçamento (p-4, p-6, p-8, gap-4, gap-6).
3. Substitua cinzas fixos por hierarquia de opacidade (text-white/60, text-white/40).
4. Padronize ícones: lucide-react, text-zinc-500, size-5.
5. Badges: bg-emerald-50/text-emerald-700 (ok), bg-red-50/text-red-700 (erro).
6. Links: text-zinc-900 font-medium hover:underline — nunca azul puro.
7. Sidebar double panel: mini 64px (bg-zinc-950) + expansível 240px (bg-zinc-50).
   AnimatePresence + spring (stiffness:300, damping:30) + tooltip com atalho.
   Máx 7 itens por grupo (Miller's Law).
8. Máximo 3 CTAs por tela: 1 primário, 1 secundário, 1 ghost (Choice Overload).
9. Skeleton loading em todas as áreas de dados assíncronos.
10. Targets de clique mín 44px para ícones interativos (Apple HIG).
```

---

## Prompt-Mestre para Gráficos Premium (Tremor)

```
Cursor, substitua os gráficos atuais por componentes Tremor Raw.
Use paleta baseada em zinc/slate, sem cores saturadas.
Gráficos devem carregar com animação de entrada suave via framer-motion.
Skeleton de loading deve aparecer antes dos dados chegarem (shadcn skeleton).
```

---

## Animações (Framer Motion — padrões)

```tsx
import { AnimatePresence, motion } from "framer-motion"

// Spring padrão — NUNCA usar duration fixo para movimentos
const spring = { type: "spring", stiffness: 400, damping: 30 }
// Para modais/sidebars pesadas: stiffness:260, damping:28
// Para micro-interações (badges, chips): stiffness:600, damping:40

// Fade-in de cards
<motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={spring} />

// AnimatePresence (obrigatório para elementos que entram/saem do DOM)
<AnimatePresence>
  {isOpen && (
    <motion.div
      key="panel"
      initial={{ opacity: 0, x: -16 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -16 }}
      transition={{ type: "spring", stiffness: 300, damping: 30 }}
    />
  )}
</AnimatePresence>

// layoutId — card que expande para modal (efeito mágico, como apps premium fazem)
<motion.div layoutId={`card-${id}`} /> // mesma id no card E no modal

// Stagger — itens de lista entrando em sequência
const container = { show: { transition: { staggerChildren: 0.05 } } }
const item = { hidden: { opacity: 0, y: 8 }, show: { opacity: 1, y: 0, transition: spring } }

// prefers-reduced-motion SEMPRE
import { useReducedMotion } from "framer-motion"
const reduce = useReducedMotion()
const transition = reduce ? { duration: 0 } : spring
```

---

## Performance — TanStack Query

```tsx
// Cache de dados: atualiza em background, sem tela branca
import { useQuery } from "@tanstack/react-query"

const { data, isLoading } = useQuery({
  queryKey: ["dashboard-metrics"],
  queryFn: fetchMetrics,
  staleTime: 30_000,       // cache válido por 30s
  refetchOnWindowFocus: true
})

// Mostrar skeleton enquanto isLoading === true
```

---

## Stack de IA para Geração de Design

| Ferramenta | Força | Quando usar |
|-----------|-------|-----------|
| **v0.dev** | Gera React/Next.js + Tailwind visual premium instantaneamente | Gerar 5 variações de componente para escolher a melhor |
| **Canvas com modelo de IA** | Canvas interativo, fluxos de UX | Debater UX/UI, wireframes de fluxos complexos |
| **IA de layout em design tool** | Layouts profissionais em ferramentas de design | Mockups pré-código para aprovação de stakeholders |
| **Open Design (nexu-io)** | Open-source para geração de design | Self-hosted com OpenRouter híbrido |

**Fluxo recomendado:** v0.dev (5 variações) → escolher melhor → Cursor/Loop Master (polish) → impeccable (audit)

## Estratégia de Modelo

| Fase | Modelo | Por quê |
|------|--------|---------|
| Geração inicial da UI | Claude Sonnet 5 (OpenRouter) | Melhor "gosto estético" |
| Iterações, bugs, páginas internas | DeepSeek V4 Pro | 50x mais barato |
| Sistemas complexos do zero | Claude Fable 5 | 1M tokens, raciocínio profundo |
| Uso diário / rotina | Modo Auto do Cursor | Rápido, incluído no plano |

**Regra:** Sonnet 5 para casca visual → DeepSeek para páginas internas.

---

## Checklist de Design Premium (pré-gate)

### Fundações visuais
- [ ] Escala 8px respeitada em todo espaçamento
- [ ] #000000 / #ffffff puro eliminados — usando zinc/slate
- [ ] Hierarquia de opacidade (text-white/60, /40) em vez de cinzas fixos
- [ ] Arredondamento geométrico: pai ≥ filho sempre
- [ ] 1 cor de acento por tela, o resto neutro
- [ ] Sombras semânticas (shadow-sm cards, shadow-xl modais)
- [ ] Glassmorphism em modais e painéis flutuantes

### Sidebar
- [ ] Largura 240–300px (expandida) e 48–64px (mini)
- [ ] 12 padrões UX implementados (seção Double Sidebar acima)
- [ ] Tooltip com nome + atalho em modo recolhido
- [ ] AnimatePresence em abertura/fechamento
- [ ] Máx 7 itens por grupo (Miller's Law)
- [ ] Features mais usadas no topo (Pareto 80/20)

### Interações
- [ ] Spring physics em TODA animação de movimento
- [ ] AnimatePresence em todo elemento que entra/sai do DOM
- [ ] layoutId em cards que expandem para modal
- [ ] Stagger em listas de itens
- [ ] prefers-reduced-motion respeitado
- [ ] Feedback visual < 100ms em cliques (Apple HIG)
- [ ] Targets de toque ≥ 44px para ícones (Apple HIG)

### Laws of UX aplicadas
- [ ] Máx 7 itens por grupo/menu (Miller's Law)
- [ ] Máx 3 CTAs por tela (Choice Overload)
- [ ] CTA primário destacado visualmente (Von Restorff)
- [ ] Skeleton antes de qualquer spinner (Doherty < 400ms)
- [ ] Progress indicators em fluxos de mútiplos passos (Zeigarnik)
- [ ] Padrões familiares seguidos (Jakob's Law)

### Dados e performance
- [ ] TanStack Query com staleTime configurado
- [ ] Zero useEffect + fetch manual para dados de servidor
- [ ] Skeleton (shadcn) em todas áreas assíncronas
- [ ] Gráficos com Tremor Raw
- [ ] `npx impeccable detect <path>` — zero critical

---

## Referências externas

| Recurso | URL | O que estudar |
|---------|-----|---------------|
| shadcn/ui | https://ui.shadcn.com | Componentes base |
| Framer Motion | https://www.framer.com/motion/ | AnimatePresence, layoutId, spring |
| Tremor Raw | https://raw.tremor.so | Gráficos de dashboard |
| Magic UI | https://magicui.design | Efeitos IA |
| Aceternity UI | https://ui.aceternity.com | Spotlight, hover |
| TanStack Query | https://tanstack.com/query | Cache SWR |
| Lucide React | https://lucide.dev | Ícones |
| Laws of UX | https://lawsofux.com | Leis psicológicas |
| Refactoring UI | https://refactoringui.com | Regras práticas de design |
| v0.dev | https://v0.dev | Geração de componentes premium |
| Godly | https://godly.website | Referência de animações |
| Bento Grids | https://bentogrids.xyz | Dashboard Bento Box |
| Open Design | https://github.com/nexu-io/open-design | Claude Design open-source |
| Component Gallery | https://component.gallery | Referência de componentes reais |
| ScreensDesign | https://screensdesign.com | Flows iOS premium |
