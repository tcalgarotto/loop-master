# React list keys — href não basta

**Origem:** `/lucy aprenda` — HubFU footer duplicate keys (2026-07-03).

## Sintoma

Console React em dev:

```
Encountered two children with the same key, `Recursos-/#produto`
Encountered two children with the same key, `Empresa-/suporte`
```

## Causa

Vários links legítimos apontam para o **mesmo `href`** (âncoras `#produto`, rotas `/suporte`, `/signup`). Chave só com `column.title + href` colide.

```tsx
// ❌ Errado — href repetido quebra reconciliação
<li key={`${column.title}-${link.href}`}>

// ✅ Correto — label é único por coluna; href pode repetir
<li key={`${column.title}-${link.label}`}>
```

## Regra de produção (Lucy FE)

1. **Nunca** usar só `href` (ou `id` externo) como `key` em listas de nav/footer/menus quando labels ou destinos podem repetir.
2. Preferir **`${scope}-${label}`** ou **`${scope}-${label}-${href}`** — padrão já usado em `ContextualSidebar.tsx`.
3. Se label também puder repetir (improvável em footer), acrescentar índice estável: `` `${scope}-${link.label}-${index}` ``.
4. Ao gerar footer/nav em JSON (`landing-puck.json`, defaults no componente), **não deduplicar hrefs** — vários itens podem ir ao mesmo destino; corrigir a **key**, não os dados.
5. **Visual gate / audit FE:** grep antes do gate:
   ```bash
   rg 'key=\{.*\.href' frontend/src --glob '*.{tsx,jsx}'
   rg 'key=\{link\.href\}' frontend/src
   ```
   Revisar cada match; trocar por label ou composto único.

## Anti-padrões

| Padrão | Risco |
|--------|--------|
| `key={link.href}` | Colisão em links legais, footer, CTAs repetidos |
| `key={\`${title}-${href}\`}` | Colisão quando vários labels → mesma rota/âncora |
| `key={index}` sozinho | OK só se lista estática e nunca reordenada |

## Referência no repo HubFU

- Fix: `frontend/src/lib/landing/blocks/footer-section.tsx`
- Dados: `frontend/src/data/landing-puck.json` — colunas Recursos/Empresa com hrefs compartilhados **intencionais**
