# UX Design Intelligence — Knowledge Base v2.7

Conhecimento destilado das maiores referências mundiais de design aplicado a produtos de software.
**Usar em toda tarefa com superfície visual.** Ler antes de qualquer implementação de UI.

Fontes: UX Planet, Laws of UX, Refactoring UI, Apple HIG, shadcn Studio, Component Gallery, ScreensDesign, Design+Code, Frontend Masters, Badaro Experience.

---

## 1. As Leis Psicológicas do Design (Laws of UX)

Estas leis governam como o cérebro humano processa interfaces. **Violá-las = fricção invisível.**

| Lei | Princípio | Aplicação prática |
|-----|-----------|-------------------|
| **Aesthetic-Usability Effect** | Design bonito parece mais usável | Invista em visual premium — usuários toleram mais bugs em interfaces belas |
| **Hick's Law** | + opções = + tempo de decisão | Máximo 7 itens por nível de menu na sidebar; agrupe o resto |
| **Miller's Law** | Memória de trabalho = 7 ± 2 itens | Nunca mostrar mais de 7 itens em listas, menus ou KPIs por bloco |
| **Fitts's Law** | Alvos maiores e mais próximos = + rápido de clicar | CTAs primários: mínimo 44px altura; agrupar ações relacionadas |
| **Jakob's Law** | Usuários preferem que seu produto funcione como os que já conhecem | Seguir padrões estabelecidos (sidebar esq, header top, modal centro) |
| **Law of Proximity** | Elementos próximos parecem relacionados | Agrupar campos de formulário relacionados; espaço entre grupos ≥ 2× o interno |
| **Law of Common Region** | Elementos em área delimitada = grupo | Cards, painéis e seções devem ter bordas/fundo próprio |
| **Cognitive Load** | Menos esforço mental = melhor UX | Simplificar; remover qualquer elemento decorativo sem função |
| **Doherty Threshold** | Resposta < 400ms = usuário produtivo | Skeleton loaders + TanStack Query para eliminar espera percebida |
| **Serial Position Effect** | Usuários lembram o primeiro e o último item | Coloque ações críticas no topo E no fundo da sidebar |
| **Peak-End Rule** | Experiência julgada pelo pico e pelo fim | O onboarding e o estado vazio devem ser impecáveis |
| **Von Restorff Effect** | O elemento diferente é lembrado | Use 1 cor de destaque para o CTA principal em toda página |
| **Zeigarnik Effect** | Tarefas incompletas ficam na memória | Progress bars, etapas de formulário e % de conclusão aumentam engajamento |
| **Pareto Principle** | 80% do uso vem de 20% das features | As 20% features mais usadas devem estar a 1 clique na sidebar |
| **Choice Overload** | Excesso de opções paralisa o usuário | Nunca mais de 3 CTAs primários por tela |

---

## 2. Regras Matemáticas e Físicas do Design Premium

### 2.1 A Regra dos 8px (Ritmo Visual)
Todos os espaçamentos, tamanhos e posições devem ser múltiplos de 8px:
```
4px  → p-0.5 (micro detalhes — separadores internos)
8px  → p-2  (padding de badges, chips)
12px → p-3  (padding de inputs)
16px → p-4  (padding padrão de cards)
24px → p-6  (padding generoso — cards de destaque)
32px → p-8  (seções principais)
48px → p-12 (separação entre blocos de página)
64px → p-16 (espaço de hero/landing)
```
**Proibido:** padding 5px, 7px, 10px, 13px, 15px, 20px.

### 2.2 A Morte do Preto e Branco Puros
| Contexto | ❌ Proibido | ✅ Correto |
|----------|------------|----------|
| Fundo dark | #000000 | `#09090b` (`bg-zinc-950`) |
| Fundo light | #ffffff puro em dark mode | `#fafafa` (`bg-zinc-50`) |
| Texto em dark | #ffffff puro | `#fafafa` ou `text-white/90` |
| Texto secundário | gray-400 fixo | `text-white/60` (absorve o fundo) |

### 2.3 Hierarquia de Opacidade (em vez de cinzas fixos)
```tsx
// Título: 100% opacidade
<h1 className="text-white">Receita Total</h1>

// Subtítulo: 60% opacidade — absorve o fundo automaticamente
<p className="text-white/60">vs mês anterior</p>

// Hint/label: 40% opacidade
<span className="text-white/40">última atualização: agora</span>
```
Isso garante harmonia perfeita em qualquer cor de fundo, sem precisar definir cinzas manuais.

### 2.4 Arredondamento Geométrico (Encaixe Perfeito)
Elementos aninhados devem usar raios decrescentes:
```
Container externo: rounded-2xl (16px)
  └─ Card interno: rounded-xl (12px)
       └─ Botão: rounded-lg (8px)
            └─ Badge/chip: rounded-md (6px) ou rounded-full
```
**Regra**: o elemento filho NUNCA pode ter border-radius ≥ ao pai.

### 2.5 Glassmorphism (Estilo premium — modais sobre fundo)
Para elementos flutuantes (modais, tooltips, painéis sobre imagem):
```tsx
className="bg-white/5 backdrop-blur-md border border-white/10 rounded-2xl"
// Dark mode premium — igual macOS
```
Para elementos sobre fundo claro:
```tsx
className="bg-white/80 backdrop-blur-sm border border-zinc-200/50 rounded-xl shadow-sm"
```

### 2.6 Sombras com Intenção (Profundidade Semântica)
```
shadow-xs → elementos ao nível da página (badges)
shadow-sm → cards de conteúdo
shadow-md → dropdowns, popovers
shadow-lg → drawers, painéis flutuantes
shadow-xl → modais sobre overlay
```
**Proibido:** `shadow-xl` em cards de dashboard.

---

## 3. Sidebar — Referência Definitiva UX

### 3.1 Dimensões Validadas por Research (UX Planet)
| Estado | Largura | Referência |
|--------|---------|----------|
| Mini (ícones) | 48–64px | SaaS premium de referência |
| Expandida normal | 240–260px | Padrão SaaS |
| Expandida larga | 280–300px | Sistemas complexos / ERP |
| Recolhida (mobile) | 0px (off-screen) | com overlay |

### 3.2 Os 12 Padrões Obrigatórios de Sidebar (UX Planet Research)
1. **Largura ótima validada**: 240–300px expandida, 48–64px recolhida
2. **Navegação dinâmica por contexto**: sidebar de Settings ≠ sidebar principal — troca contextualmente
3. **Account switcher**: dropdown no topo com avatar, nome, email
4. **Subitens expansíveis**: chevron direito → roda para baixo; transição suave (framer-motion)
5. **Área de updates no rodapé**: espaço fixo para anúncios de features (não misturar com nav)
6. **Toggle dark/light mode**: dentro da sidebar, com detecção de sistema
7. **Highlight do item ativo**: fundo zinc-200/50 + texto bold + ícone em cor primária
8. **Priorização de informação**: 80/20 — features mais usadas no topo
9. **Largura ajustável pelo usuário**: drag handle visual na borda direita
10. **Quick search na sidebar**: Cmd+K / Ctrl+K, atalho visível no campo
11. **Ações diretas nos itens**: botão "+" aparece no hover de seções
12. **Sidebar secundária**: mini (64px) + expansível (240px) para sistemas complexos

### 3.3 Estados de Item de Sidebar (Implementação)
```tsx
// Base
"flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors"

// Default (inativo)
"text-zinc-400 hover:text-zinc-100 hover:bg-zinc-800/50"

// Ativo
"text-white bg-zinc-800 shadow-sm"

// Grupo label
"px-3 py-1.5 text-[10px] font-semibold text-zinc-500 uppercase tracking-wider"

// Divider entre grupos
"my-2 border-t border-zinc-800/50" // não usar border colorida
```

### 3.4 Tooltip em sidebar recolhida (obrigatório)
```tsx
<Tooltip>
  <TooltipTrigger asChild>
    <Button variant="ghost" size="icon">
      <Icon className="size-5" />
    </Button>
  </TooltipTrigger>
  <TooltipContent side="right" className="text-xs">
    Nome da Seção <kbd className="ml-2 opacity-50">⌘1</kbd>
  </TooltipContent>
</Tooltip>
```

---

## 4. Refactoring UI — Regras de Ouro

As regras mais impactantes do guia sagrado de Wathan & Schoger:

### 4.1 Nunca use cinza em texto sobre fundo colorido
Em backgrounds coloridos, use branco com opacidade em vez de cinza:
```tsx
// ❌ Errado: cinza sobre azul
<p className="text-gray-400">Subtítulo</p>

// ✅ Correto: branco com opacidade
<p className="text-white/70">Subtítulo</p>
```

### 4.2 Crie espaço, não bordas
Quando sentir vontade de adicionar uma borda para separar elementos, tente primeiro:
1. Adicionar espaço (gap/margin)
2. Usar fundo diferente (bg-zinc-50 vs bg-white)
3. Só então usar borda (border-zinc-100, nunca colorida)

### 4.3 Alinhe com grade, não com olhômetro
Toda decisão de layout = múltiplo de 4px ou 8px. Use `gap-4`, `gap-6`, `gap-8`.

### 4.4 Limite o peso visual de labels
Labels de formulário não precisam de bold e dark:
```tsx
// ❌ Muito peso visual — compete com o input
<label className="font-bold text-zinc-900">Nome completo</label>

// ✅ Label discreta — o input é a estrela
<label className="text-sm font-medium text-zinc-500">Nome completo</label>
```

### 4.5 Use cor com moderação (1 cor de acento)
Cada tela deve ter no máximo 1 cor de acento verdadeira (não zinc/slate).
Todo o resto deve ser neutro. A cor de acento deve aparecer apenas em:
- CTA primário
- Ícone de item ativo na sidebar
- Indicador de progresso

### 4.6 Eleve os elementos, não a página inteira
Em vez de colocar sombra em tudo, use sombra apenas nos elementos que flutuam acima da página (dropdown, modal, tooltip).

---

## 5. Apple HIG — Princípios de Fluidez

### 5.1 Movimento com Propósito
- Animações devem comunicar relações entre estados
- Duração padrão Apple: 250–350ms para transições de tela, 150–200ms para micro-interações
- Curva: `ease-out` para entradas, `ease-in` para saídas

### 5.2 Hierarquia Visual Consistente
- Títulos: font-semibold ou font-bold
- Corpo: font-normal
- Labels: font-medium
- Nunca: font-black em interfaces de software (apenas marketing)

### 5.3 Toque/Click Targets
- Mínimo 44×44px para qualquer elemento interativo (botão, ícone clicável)
- Em ícones de 16px: adicionar padding para atingir 44px de área de toque

### 5.4 Feedback Imediato
- Todo clique deve ter resposta visual em < 100ms (press state, active state)
- Skeleton antes de spinner — nunca página em branco

---

## 6. Galeria de Referências de Alto Padrão

Para calibrar o olhar antes de projetar. Estudar ativamente:

| Característica visual | O que estudar | URL |
|----------------------|---------------|-----|
| **Modo escuro premium** | Bordas com gradiente sutil, atalhos de teclado, tipografia ultra-refinada | godly.website |
| **Minimalismo geométrico** | Tons de cinza cirúrgicos, contraste extremo, tipografia como elemento visual | — |
| **Gradientes fluidos em dados** | Tabelas ricas em dados como obras de arte, checkout fluido | — |
| **Animações narrativas** | Sites mais animados e fluidos da internet | godly.website |
| **Design Bento Box** | Divisão em blocos geométricos perfeitos para dashboards e ERPs | bentogrids.xyz |
| **Sidebar patterns** | 10 variações de sidebar em shadcn | shadcnstudio.com/blog |
| **Flows de onboarding** | Flows iOS premium e paywalls | screensdesign.com |
| **Componentes reais** | Como sistemas líder resolvem tabelas, buscas e configurações | component.gallery |

---

## 7. Framer Motion — Padrões Avançados

### 7.1 AnimatePresence (Elemento que aparece/desaparece)
```tsx
import { AnimatePresence, motion } from "framer-motion"

<AnimatePresence>
  {isOpen && (
    <motion.div
      key="sidebar-panel"
      initial={{ opacity: 0, x: -16 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -16 }}
      transition={{ type: "spring", stiffness: 300, damping: 30 }}
    >
      {children}
    </motion.div>
  )}
</AnimatePresence>
```

### 7.2 layoutId (Card que expande para modal — efeito "mágico")
```tsx
// Card (lista)
<motion.div layoutId={`card-${item.id}`} className="cursor-pointer">
  <h3>{item.title}</h3>
</motion.div>

// Modal expandido (mesmo layoutId)
<AnimatePresence>
  {selected && (
    <motion.div layoutId={`card-${selected.id}`} className="fixed inset-0 z-50">
      {/* conteúdo expandido */}
    </motion.div>
  )}
</AnimatePresence>
// Framer Motion anima automaticamente a transição entre os dois
```

### 7.3 Spring Physics (nunca usar duration fixo para movimentos)
```tsx
// ❌ Animação morta — parece robô
transition={{ duration: 0.3 }}

// ✅ Animação viva — simula física real
transition={{ type: "spring", stiffness: 400, damping: 30 }}

// Para elementos pesados (modais, sidebars)
transition={{ type: "spring", stiffness: 260, damping: 28 }}

// Para micro-interações (badges, chips)
transition={{ type: "spring", stiffness: 600, damping: 40 }}
```

### 7.4 Stagger — itens de lista entrando em sequência
```tsx
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.05 }
  }
}

const item = {
  hidden: { opacity: 0, y: 8 },
  show: { opacity: 1, y: 0, transition: { type: "spring", stiffness: 400, damping: 30 } }
}

<motion.ul variants={container} initial="hidden" animate="show">
  {items.map(i => (
    <motion.li key={i.id} variants={item}>{i.name}</motion.li>
  ))}
</motion.ul>
```

---

## 8. Stack de IA para Geração de Design

| Ferramenta | Força | Quando usar |
|-----------|-------|-------------|
| **v0.dev** | Gera código React/Next.js + Tailwind visual premium instantâneo | Gerar 5 variações de componentes para escolher a melhor |
| **Canvas com modelo de IA** | Canvas interativo, fluxos de UX, cópias elegantes | Debater UX/UI, criar wireframes de fluxos complexos |
| **IA de layout em design tool** | Layouts profissionais direto em ferramentas de design | Mockups pré-código para aprovação de stakeholders |
| **Open Design (nexu-io)** | Alternativa open-source | Self-hosted com OpenRouter |

**Fluxo recomendado:** v0.dev (variações) → escolher melhor → Cursor/Loop Master (polish + integração) → impeccable (audit)

---

## 9. Checklist Unificado Pré-Gate de Design

### Fundações Visuais
- [ ] Escala 8px respeitada em todo espaçamento
- [ ] #000000 / #ffffff puro eliminados — usando zinc/slate
- [ ] Hierarquia de opacidade (text-white/60, /40) em vez de cinzas fixos
- [ ] Arredondamento geométrico: pai ≥ filho sempre
- [ ] 1 cor de acento apenas por tela, o resto neutro
- [ ] Sombras semânticas (shadow-sm cards, shadow-md dropdowns, shadow-xl modais)

### Sidebar
- [ ] Largura entre 240–300px (expandida) e 48–64px (mini)
- [ ] 12 padrões UX implementados (ver seção 3.2)
- [ ] Tooltip em modo recolhido com nome + atalho de teclado
- [ ] Estados definidos: default, hover, ativo, grupo label, divider
- [ ] Quick search (Cmd+K) disponível
- [ ] Dark/light toggle presente

### Interações
- [ ] Spring physics em toda animação de movimento
- [ ] AnimatePresence em todo elemento que entra/sai do DOM
- [ ] prefers-reduced-motion respeitado
- [ ] Feedback visual em < 100ms para todo clique (active state)
- [ ] Targets de toque ≥ 44px para ícones clicáveis

### Psicologia UX
- [ ] Máx 7 itens por grupo de menu (Miller's Law)
- [ ] Features mais usadas a ≤ 1 clique (Pareto)
- [ ] Skeleton loading antes de qualquer spinner (Doherty Threshold)
- [ ] CTA primário destacado por Von Restorff (1 elemento diferente)
- [ ] Zeigarnik: progress indicators em fluxos de múltiplos passos

### Dados e Performance
- [ ] TanStack Query com staleTime configurado
- [ ] Zero `useEffect` + `fetch` manual para dados de servidor
- [ ] Skeleton (shadcn) em todas as áreas de dados assíncronos
- [ ] Gráficos com Tremor Raw
- [ ] LCP < 2.5s verificado

---

## 10. Anti-Padrões Absolutamente Proibidos

| Anti-padrão | Por quê mata o design | Correção |
|-------------|----------------------|----------|
| Bordas coloridas em cards | Ruído visual / parece sistema dos anos 2000 | border-zinc-200 max, ou sem borda |
| Spinner em vez de skeleton | Percepção de lentidão amplificada | shadcn Skeleton + framer fade-in |
| Texto em azul para links internos | Parece hyperlink de 1995 | text-zinc-900 font-medium + hover underline |
| Ícones de bibliotecas misturadas | Inconsistência visual imediata | lucide-react exclusivamente |
| Animações com duration fixo | Parecem robóticas | Spring physics sempre |
| Mais de 3 CTAs primários por tela | Choice Overload — paralisia | Hierarquia: 1 primário, 1 secundário, ghost |
| Modal abrindo sem AnimatePresence | Aparece/desaparece abruptamente | AnimatePresence obrigatório |
| Padding ímpar (5px, 15px) | Quebra o ritmo visual | Múltiplos de 8 sempre |
| font-black em UI de software | Peso excessivo, não é marketing | font-semibold máximo |
| bg-zinc e text-blue misturados | Paleta inconsistente | 1 cor de acento + rest neutro |
