# Pricing & landing integrity — `/lucy aprenda` (2026-07-03)

Regras globais para seções de preços e rodapé em landings SaaS premium (origem: auditoria HubFU vs cópia Kommo).

## Anti-padrões (nunca)

1. **Badges de desconto inventados** — ex.: "Economize até 25%" sem calcular `(mensal − anual) / mensal` por plano. Se o math não bater, **remover o hint**.
2. **Hints genéricos** — "Melhor valor" no toggle sem política comercial clara → remover.
3. **Matriz copiada do concorrente** — features de pricing devem cruzar `docs/HUBFU-PRODUCT-CONTEXT.md`, `plan_limits.py` / billing seed e rotas reais do app. Marcar roadmap vs entregue.
4. **Prometer SSO / SLA / agentes N** se não existir no produto — usar linguagem honesta ("sob consulta", "conforme contrato").
5. **CTAs desalinhados** — botões com classes ou alturas diferentes entre colunas (filled vs outline só por `featured` quebra grid).
6. **Hierarquia invertida** — "Tudo do X +" não pode ser mais visível que o nome do plano.
7. **Sufixo de preço em linha separada** — `/usuário/mês` deve ficar **inline**, baseline alinhado ao valor.
8. **FAQ one-liner** — respostas < 2 frases em landing premium; elaborar benefício, limite e próximo passo.
9. **Footer minimal** — copyright + 2 links não passa visual gate premium; usar colunas + tagline + legal.

## Padrão correto — pricing cards

```
Ordem visual (head):
  1. Nome do plano — maior peso (h3, sem uppercase agressivo)
  2. Stack line — menor, muted ("Inclui Starter + …")
  3. Preço + sufixo inline (flex baseline)
  4. Tagline (1 linha, min-height fixo entre colunas)
  5. Badge opcional ("Mais popular") — NÃO substituir label do CTA
  6. CTA — mesma classe, width 100%, min-height fixo em todas as colunas
```

## Padrão correto — billing toggle

- Apenas labels: Mensal | Anual | Bianual
- Sem hints embaixo dos pills
- Segmented control alinhado a `landing-premium.css` (track suave, pill branco ativo)

## Checklist antes de gate FE (pricing)

- [ ] Features auditadas vs backend/plan_limits
- [ ] CTAs mesma altura em 4 colunas (desktop)
- [ ] Nome do plano domina tier line
- [ ] Preço + sufixo inline
- [ ] FAQ ≥ 5 itens, respostas 2–4 frases
- [ ] Footer ≥ 3 colunas + legal row

## Routing

| Superfície | Skill / protocolo |
|------------|-------------------|
| Landing pricing | `premium-ui-stack.md`, `ux-design-intelligence.md`, este doc |
| Dados de plano | código + `docs/HUBFU-PLANS-SEATS.md` — não só JSON marketing |
| Visual gate | `#precos`, `#faq`, `footer` obrigatórios em `/lucy visual-gate --escopo /` |
