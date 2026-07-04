# Firefox Profiler — tracks de outros domínios não são embeds

**Origem:** `/lucy aprenda` — HubFU `/fluxos/[id]/editor` profile share, suspeita de "attio.com" rodando dentro do app (2026-07-04).

## Sintoma

Owner captura um profile no Firefox Profiler (`profiler.firefox.com`, link `share.firefox.dev/...`) enquanto usa uma rota do app (ex: `hubfu.vercel.app/fluxos/1/editor`) e vê **duas tracks de processo separadas no topo da timeline**, cada uma com seu próprio gráfico de Network/Memory:

```
hubfuvercel.app (3/3)   PID 2036461
atcio.com (?/?)         PID 1979092   ← domínio de um concorrente/SaaS não relacionado
```

Reação natural: "por que o site do concorrente está rodando dentro do nosso app? bug de embed/iframe/script?"

## Causa real

O **Firefox Profiler captura TODOS os processos abertos no navegador no momento da gravação** (`about:profiling` → "Capture Profile" ou o botão da toolbar), não só a aba ativa. Cada aba/site em processo de conteúdo separado (arquitetura multi-processo / Fission do Firefox) vira uma track própria na timeline, rotulada pelo domínio da página carregada naquele processo.

**Evidência que confirma "aba irmã", não iframe/embed real:**

1. **PIDs diferentes** nas duas tracks (`PID 2036461` vs `PID 1979092`). Um iframe cross-origin *também* pode ganhar processo próprio sob Fission, então o PID sozinho não é 100% conclusivo — mas combinado com o resto, é o sinal mais forte de "processo de tab", não "subframe".
2. **Timeline completa e independente** (Network + Memory próprios, sem relação temporal óbvia de carregamento aninhado) — comportamento típico de "outra aba aberta em paralelo", não de um recurso carregado pela página.
3. **Grep no código-fonte da aplicação** (`grep -rin "attio" frontend/src backend --include="*.tsx" --include="*.ts" --include="*.py"`) não encontra nenhum `<script src="attio...">`, `<iframe src="attio...">`, import de SDK, dependência npm ou variável de ambiente relacionada — só menções em **documentação de design** (Attio citado como referência visual de UI, ex: "canvas estilo n8n/Attio", "craft Linear/Attio").
4. A árvore de chamadas mostrando tempo em `parseRuleDeclarations`/`nextToken`/`cssCalcParseFunction` dentro de `resource://devtools/...` é o **próprio DevTools do Firefox fazendo parsing de CSS para o inspetor de estilos** (comum quando o DevTools Inspector está aberto durante a gravação do profile) — não é overhead do app sendo perfilado.

## Regra de produção (Lucy — leitura de profiles)

1. **Nunca assumir que uma track com domínio desconhecido = bug de embed** sem antes checar:
   - PIDs das tracks (`Firefox → about:processes` ou o próprio painel de threads do profiler mostra PID ao lado do nome do processo);
   - se o domínio suspeito tinha uma aba própria aberta no navegador do usuário no momento da captura (perguntar ao dono do profile antes de investigar código);
   - grep exaustivo no código-fonte por scripts/iframes/SDKs do domínio suspeito, cobrindo `.tsx`, `.ts`, `.jsx`, `.js`, backend `.py`, e configs (`next.config.*`, CSP headers) — não só um grep solto.
2. **Overhead de `resource://devtools/...` na árvore de chamadas é do próprio Firefox DevTools** (inspetor de estilos/regras CSS, Debugger pausado em breakpoint), não da aplicação. Se o profile foi capturado com o DevTools aberto (comum — devs deixam o painel aberto), reportar isso explicitamente e não contabilizar esse tempo como gargalo real do app.
3. **Ação recomendada ao investigar um profile compartilhado:** tentar abrir o link real (`share.firefox.dev/...` → `profiler.firefox.com/...`) via browser MCP e inspecionar a aba "Threads"/processos antes de tirar conclusões só a partir de screenshots — screenshots + grep de código são um bom fallback quando o browser MCP não está disponível na sessão, mas são evidência circunstancial, não definitiva.
4. **Se o grep de código não encontrar nada e os PIDs forem diferentes:** é seguro concluir "aba irmã do navegador" e não inventar um fix para um problema inexistente.

## Referência do caso HubFU

- Profile: `share.firefox.dev/4y4VeWe`, rota `/fluxos/1/editor`
- Grep de confirmação: `grep -rn "attio" frontend/src backend --include="*.tsx" --include="*.ts" --include="*.py" -i` → 0 matches de código real
- Menções de design (não-bug): `DESIGN.md`, `.lucy/frontend-design-audit.md`, `docs/hubfu-design-system/INDEX.md`, `docs/hubfu-design-system/components.md`, `docs/HUBFU-DESIGN-V3-PHASED-PLAN.md`
