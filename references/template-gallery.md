# Template Gallery — Layouts Premium Prontos

Biblioteca de layouts prontos para copiar, baseados nos padrões do premium-ui-stack.md e ux-design-intelligence.md.
Use como ponto de partida — nunca como produto final sem refinamento.

---

## Como usar

```
/lucy init → Lucy detecta surface → sugere template desta galeria como ponto de partida
/lucy analise → após gap matrix, Lucy usa template mais próximo para acelerar build
```

Ou referencie diretamente no prompt:
```
"Use o template Dashboard Analytics desta galeria como base"
```

---

## 1. Dashboard Analytics (CRM/ERP)

**Superfície:** Dashboard principal de sistema SaaS
**Stack:** Next.js + shadcn/ui + Tremor + TanStack Query

### Estrutura de layout

```
┌─────────────────────────────────────────────────────┐
│ [mini 64px] │ [sidebar 240px] │ [conteúdo principal] │
│             │                 │                       │
│  📊 ○       │ VISÃO GERAL     │  [KPI Cards Row]      │
│  📋 ○       │  Dashboard      │  ┌────┬────┬────┐    │
│  👥 ○       │  Analytics      │  │ R$ │ #  │ %  │    │
│  ⚙️ ○       │                 │  └────┴────┴────┘    │
│             │ PIPELINE        │                       │
│             │  Negócios       │  [Gráfico Tremor]     │
│             │  Leads          │                       │
│             │  Relatórios     │  [Tabela de dados]    │
│  [avatar]   │                 │                       │
└─────────────────────────────────────────────────────┘
```

### Código base

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { AreaChart, BarChart } from '@tremor/react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'

export default function DashboardPage() {
  return (
    <div className="flex flex-col gap-6 p-8 bg-zinc-50 min-h-screen">
      {/* KPI Row */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Suspense fallback={<Skeleton className="h-32 rounded-xl" />}>
          <KPICard title="Receita Total" />
        </Suspense>
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <Card className="rounded-xl shadow-sm">
          <CardHeader><CardTitle className="text-sm font-medium text-zinc-500">Evolução mensal</CardTitle></CardHeader>
          <CardContent>
            <Suspense fallback={<Skeleton className="h-48" />}>
              <RevenueChart />
            </Suspense>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
```

```tsx
// components/KPICard.tsx
'use client'
import { useQuery } from '@tanstack/react-query'
import { motion } from 'framer-motion'
import { TrendingUp } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'

export function KPICard({ title, queryKey, queryFn }) {
  const { data, isLoading } = useQuery({ queryKey, queryFn, staleTime: 30_000 })

  if (isLoading) return <Skeleton className="h-32 rounded-xl" />

  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
    >
      <Card className="rounded-xl shadow-sm bg-white">
        <CardContent className="p-6">
          <p className="text-sm font-medium text-zinc-500">{title}</p>
          <p className="text-3xl font-semibold text-zinc-900 mt-2">{data?.value}</p>
          <div className="flex items-center gap-1 mt-1">
            <TrendingUp className="size-4 text-emerald-600" />
            <span className="text-sm text-emerald-600">{data?.change}%</span>
            <span className="text-sm text-zinc-400">vs mês anterior</span>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  )
}
```

---

## 2. Double Sidebar (CRM/ERP)

**Superfície:** Layout base para sistemas complexos
**Stack:** Next.js + shadcn/ui + framer-motion + Zustand/Context

```tsx
// components/layout/AppShell.tsx
'use client'
import { useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip'

const miniNavItems = [
  { icon: BarChart2, label: 'Dashboard', section: 'dashboard' },
  { icon: Users, label: 'CRM', section: 'crm' },
  { icon: Settings, label: 'Configurações', section: 'settings' },
]

export function AppShell({ children }) {
  const [activeSection, setActiveSection] = useState('dashboard')
  const [isSidebarOpen, setIsSidebarOpen] = useState(true)

  return (
    <div className="flex h-screen bg-zinc-950 overflow-hidden">
      {/* Mini Sidebar — 64px */}
      <nav className="w-16 bg-zinc-950 flex flex-col items-center py-4 gap-2 border-r border-zinc-800/50 shrink-0">
        {miniNavItems.map(({ icon: Icon, label, section }) => (
          <Tooltip key={section}>
            <TooltipTrigger asChild>
              <button
                onClick={() => setActiveSection(section)}
                className={`p-3 rounded-lg transition-colors ${
                  activeSection === section
                    ? 'text-white bg-zinc-800'
                    : 'text-zinc-400 hover:text-white hover:bg-zinc-800/50'
                }`}
              >
                <Icon className="size-5" />
              </button>
            </TooltipTrigger>
            <TooltipContent side="right" className="text-xs">
              {label}
            </TooltipContent>
          </Tooltip>
        ))}
      </nav>

      {/* Expandable Sidebar — 240px */}
      <AnimatePresence>
        {isSidebarOpen && (
          <motion.aside
            key="sidebar"
            initial={{ opacity: 0, x: -16 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -16 }}
            transition={{ type: 'spring', stiffness: 300, damping: 30 }}
            className="w-60 bg-zinc-900 border-r border-zinc-800/50 flex flex-col py-4 shrink-0"
          >
            <SidebarContent section={activeSection} />
          </motion.aside>
        )}
      </AnimatePresence>

      {/* Main Content */}
      <main className="flex-1 overflow-auto bg-zinc-950">
        {children}
      </main>
    </div>
  )
}
```

---

## 3. Settings Page

**Superfície:** Página de configurações com tabs laterais
**Stack:** Next.js + shadcn/ui

```tsx
// app/settings/layout.tsx
const settingsSections = [
  { label: 'Geral', href: '/settings/general' },
  { label: 'Equipe', href: '/settings/team' },
  { label: 'Integrações', href: '/settings/integrations' },
  { label: 'Faturamento', href: '/settings/billing' },
  { label: 'Segurança', href: '/settings/security' },
]

export default function SettingsLayout({ children }) {
  return (
    <div className="flex gap-8 p-8 max-w-5xl mx-auto">
      {/* Nav lateral */}
      <nav className="w-48 shrink-0">
        <p className="text-[10px] font-semibold text-zinc-500 uppercase tracking-wider mb-3">
          Configurações
        </p>
        {settingsSections.map(({ label, href }) => (
          <Link
            key={href}
            href={href}
            className="flex items-center px-3 py-2 rounded-lg text-sm font-medium
              text-zinc-400 hover:text-zinc-100 hover:bg-zinc-800/50 transition-colors"
          >
            {label}
          </Link>
        ))}
      </nav>

      {/* Conteúdo */}
      <div className="flex-1 min-w-0">
        {children}
      </div>
    </div>
  )
}
```

---

## 4. Data Table com Filtros

**Superfície:** Tabela de listagem com busca, filtros e ações em lote
**Stack:** shadcn/ui DataTable + TanStack Table + TanStack Query

```tsx
// Padrão: busca + filtro de status + paginação + ações em lote
// Ver shadcn.com/docs/components/data-table para implementação base
// Personalizar com:
// - Skeleton loading (isLoading)
// - Empty state com CTA
// - Row actions com DropdownMenu
// - Bulk actions na toolbar quando rows selecionadas
```

---

## 5. Modal de Criação/Edição

**Superfície:** Modal com formulário (ex: criar negócio, adicionar contato)
**Stack:** shadcn Dialog + react-hook-form + zod

```tsx
// components/CreateDealModal.tsx
'use client'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

const schema = z.object({
  title: z.string().min(1, 'Título obrigatório'),
  value: z.number().min(0),
})

export function CreateDealModal({ open, onOpenChange }) {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm({
    resolver: zodResolver(schema)
  })

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md rounded-2xl">
        <DialogHeader>
          <DialogTitle className="font-semibold">Novo negócio</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4 pt-2">
          <div className="flex flex-col gap-1.5">
            <Label className="text-sm font-medium text-zinc-500">Título</Label>
            <Input {...register('title')} placeholder="Ex: Proposta ABC" className="rounded-lg" />
            {errors.title && <p className="text-xs text-red-500">{errors.title.message}</p>}
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <Button type="button" variant="ghost" onClick={() => onOpenChange(false)}>Cancelar</Button>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Salvando...' : 'Criar negócio'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  )
}
```

---

## 6. Estado Vazio (Empty State)

**Superfície:** Tabelas, listas e seções sem dados
**Stack:** shadcn + lucide-react

```tsx
// components/EmptyState.tsx
export function EmptyState({ icon: Icon, title, description, action }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
      <div className="rounded-2xl bg-zinc-100 p-4 mb-4">
        <Icon className="size-8 text-zinc-400" />
      </div>
      <h3 className="font-semibold text-zinc-900 mb-1">{title}</h3>
      <p className="text-sm text-zinc-500 max-w-xs mb-6">{description}</p>
      {action}
    </div>
  )
}

// Uso
<EmptyState
  icon={Package}
  title="Nenhum negócio ainda"
  description="Crie seu primeiro negócio para começar a acompanhar seu pipeline."
  action={<Button onClick={() => setCreateOpen(true)}>Criar negócio</Button>}
/>
```

---

## Checklist antes de usar um template

- [ ] Substituir dados mockados por dados reais (TanStack Query)
- [ ] Aplicar paleta Zinc do projeto (`DESIGN_SYSTEM.md`)
- [ ] Adicionar skeleton loading em todas as seções async
- [ ] Verificar acessibilidade: aria-labels, roles, focus management
- [ ] Testar dark mode (se aplicável)
- [ ] Rodar `npx impeccable detect` antes de commitar
