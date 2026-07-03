# Manual do Usuário — Lucy

> **O cérebro definitivo para orquestração autônoma, design premium e inteligência competitiva no Cursor Agent.**
> 
> *Versão:* **v2.9.3** · *Autor:* **Thales Calgarotto**

---

<div align="center">
  <img src="assets/lucy-hero-18x9-4k.png" alt="Lucy" width="480" style="border-radius: 12px; margin-bottom: 10px;" />
  <p><i>"Nós humanos normais usamos 10% das capacidades do nosso cérebro. Imagina se usássemos 100%."</i></p>
</div>

---

## 1. O que é o Lucy?

O **Lucy** transforma o Cursor Agent em um desenvolvedor autônomo de nível máximo, integrando:

- **100% do Cérebro**: Loops de execução autônomos que avançam até 100% de conclusão.
- **Segundo Cérebro**: Lembrança persistente de decisões de projeto, preferências e contexto entre sessões.
- **Inteligência Competitiva**: Ferramentas para analisar o mercado e fechar gaps de funcionalidades automaticamente.
- **Director de Design**: Seleção e roteamento das melhores ferramentas estéticas do ecossistema.

---

## 2. Pré-requisitos

| Requisito | Como verificar |
|-----------|----------------|
| Cursor com **Agent Skills** ON | Settings → Rules → Agent Skills |
| Git + Node.js + jq | `node -v`, `jq --version` |
| Projeto com código ativo | Qualquer repositório Git |

---

## 3. Instalação e Configuração

### 3.1 Clone do Repositório

```bash
git clone https://github.com/tcalgarotto/loop-master.git ~/.cursor/skills/lucy
cd seu-projeto
```

> **Já tinha a Lucy v1 instalada?** Faça backup e substitua:
> `mv ~/.cursor/skills/lucy ~/.cursor/skills/lucy-v1-backup && git clone ...`

### 3.2 Migração loop-master → Lucy (projetos existentes)

Se o projeto ainda usa caminhos legados (`loop-master-progress.json`, `loop-master-brain/`), rode **uma vez**:

```bash
bash ~/.cursor/skills/lucy/scripts/migrate-loop-master-to-lucy.sh
```

Ou no Cursor: `/lucy update` (a migração roda automaticamente antes do pull).

O script renomeia arquivos, cria backup em `.cursor/lucy-migration-backup-*` e **não apaga dados**.

### 3.3 Inicialização Automática

No chat do Cursor Agent, execute o seguinte comando:

```
/lucy init
```

Esse comando realiza os seguintes passos de forma automática:
1. Executa o script de inicialização (`scripts/init.sh`).
2. Configura e inicializa o **Second Brain** local.
3. Inicia o **Quiz de 6 rodadas** para definir o contexto do seu projeto.
4. Gera o plano inicial e as tarefas em fases.

---

## 4. Guia de Comandos

O Lucy vem com um conjunto completo de comandos para cada etapa do ciclo de desenvolvimento:

### 4.1 Orquestração

| Comando | Descrição |
|---------|-----------|
| `/lucy init` | Inicializa o ambiente, instala as dependências e roda o quiz de 6 rodadas. |
| `/lucy` | Executa o próximo "tick" de trabalho autônomo. |
| `/lucy update` | Atualiza a skill para a última versão sem perder o contexto do projeto. |
| `pare o loop` | Interrompe o loop recorrente de execução. |

### 4.2 Análise Competitiva

| Comando | Descrição |
|---------|-----------|
| `/lucy @url` | Analisa a URL de referência, mapeia gaps e cria um plano de implementação. |
| `/lucy --auto @url` | Executa a análise competitiva e a implementação sem pausas para aprovação. |
| `/lucy analise @url` | Realiza apenas o mapeamento de gaps (análise pura, sem alterar código). |
| `/lucy build` | Executa o plano competitivo gerado. |
| `/lucy audit` | Reaudita a fase atual em busca de conformidade e gaps. |
| `/lucy continuar` | Retoma o progresso do pipeline competitivo após reinicialização. |

### 4.3 Qualidade e Entrega

| Comando | Descrição |
|---------|-----------|
| `/lucy test` | Cria e executa testes unitários, de integração e testes E2E (Playwright). |
| `/lucy test --ci` | Executa a suíte de testes de forma silenciosa para integrações CI. |
| `/lucy perf` | Realiza auditoria completa de performance (Core Web Vitals, bundle, N+1 queries). |
| `/lucy perf --fix` | Analisa a performance e aplica otimizações automáticas de baixo risco. |
| `/lucy deploy` | Executa build, pré-validações, deploy real e monitoramento pós-deploy. |
| `/lucy deploy --rollback` | Reverte o último deploy caso o health check pós-deploy falhe. |

### 4.4 Internacionalização (i18n) e Docs

| Comando | Descrição |
|---------|-----------|
| `/lucy i18n` | Escaneia strings fixas, monta arquivos de tradução e configura internacionalização. |
| `/lucy i18n --scan` | Apenas faz o levantamento de strings fixas sem realizar alterações. |
| `/lucy docs` | Gera documentação de APIs, componentes e changelogs. |
| `/lucy docs --adr` | Cria e registra um Architecture Decision Record (ADR) para o projeto. |

### 4.5 Frontend premium

| Comando | Descrição |
|---------|-----------|
| `/lucy refazer-frontend` | Audita todo o frontend (slop, órfãs, duplicatas), quiz de design (4 rodadas), refina visual com impeccable — **sem mudar URLs**. |
| `/lucy refazer-frontend --escopo /crm` | Mesmo fluxo, só nas rotas indicadas ou mencionadas no prompt. |
| `/lucy refazer-frontend --audit-only` | Inventário + relatório — não altera código. |
| `/lucy nova-pagina <nome> --tipo landing` | Cria landing page do zero (taste-skill + template gallery). |
| `/lucy nova-pagina <nome> --tipo app` | Cria página de produto dentro do shell existente. |
| `/lucy visual-gate` | Captura prints desktop+mobile (Playwright) e exige análise visual no Cursor antes do gate. |
| `/lucy visual-gate --capture-only` | Só gera PNGs em `.lucy/visual-gates/tick-N/`. |

Ver: `references/lucy-refazer-frontend-protocol.md`, `references/visual-gate-protocol.md`, `references/lucy-nova-pagina-protocol.md`

### 4.6 Aprendizado e regras do projeto

| Comando | Escopo | Descrição |
|---------|--------|-----------|
| `/lucy aprenda` + conteúdo | **Global (GitHub)** | Transforma tema em habilidade/regra de produção — todos recebem no `/lucy update`. |
| `/lucy regra` + pedido | **Só este projeto** | Regra P0 imutável em `.cursor/lucy-brain/rules/` — sobrevive ao update. |

Ver: `references/lucy-aprenda-protocol.md`, `references/lucy-regra-protocol.md`

### 4.7 Disciplina de documentação (Hermes-style)

Toda mudança em **comando, script ou protocolo** exige, antes de encerrar o turno:

1. `grep` nos docs por termos afetados  
2. Atualizar README, MANUAL, SKILL, `references/README.md`, CHANGELOG  
3. Bump patch em `SKILL.md`  
4. Registrar em `references/learned/INDEX.md` (se via `/lucy aprenda`)

Ver: `references/docs-sync-discipline.md`

---

## 5. Second Brain (Estrutura de Memória)

O Lucy gerencia sua própria persistência de memória em quatro camadas:

1. **L0 (Brain Local)**: `.cursor/lucy-brain/` — preferências, decisões, `rules/` (regras P0), `learned/`.
2. **L1 (Progress)**: `.cursor/lucy-progress.json` — Handoff do estado atual entre os ticks do loop.
3. **L2 (claude-mem)**: Busca semântica local baseada em banco de dados SQLite.
4. **L3 (Documentação)**: `docs/LUCY-PLAN.md` e `docs/LUCY-INDEX.md` legíveis por humanos.

---

## 6. O Ecossistema de Skills

Durante o `/lucy init`, a stack padrão é automaticamente instalada:
- **impeccable**: Otimização estática de CSS, tipografia e layout de UI.
- **ui-ux-pro-max**: Design systems padronizados por indústria.
- **taste-skill**: Prevenção de interfaces estilo "template genérico".
- **caveman**: Compressão de texto para economizar até 75% em tokens de entrada.
- **nextjs-premium-stack**: (Auto-detectada) Instala e configura shadcn/ui, framer-motion, Tremor e TanStack Query.

---

## 7. Integração Contínua (CI/CD)

O Lucy pode ser acionada por eventos de Git/CI através do hook em `scripts/ci-hook.sh`:
- PRs abertos ou atualizados disparam auditorias automáticas.
- Notificações de falha no pipeline local despertam o assistente com contexto do erro.

---

## 8. Resolução de Problemas (Troubleshooting)

### Os ganchos (hooks) não estão rodando
1. Verifique se o arquivo `.cursor/hooks.json` foi criado.
2. Certifique-se de que a opção de Agent Skills está ativa em seu editor.
3. Reinicie o Cursor.

### O loop parou de rodar antes de 100%
Execute `/lucy` no chat para forçar a hidratação e rearmar a fila.

---

## Licença

MIT License. Copyright (c) 2026 Thales Calgarotto.
Descubra como desenvolver mais rápido com 100% de capacidade. 🍌
