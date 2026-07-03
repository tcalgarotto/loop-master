# `/lucy update` — atualizar skill pack sem perder contexto

Atualiza o **pacote Lucy** (git pull), **migra caminhos legados loop-master** se necessário,
e re-sincroniza deps/skills **sem apagar** `.cursor/lucy-progress.json` nem `quiz_answers`.

---

## Trigger

```
/lucy update
```

Equivalente CLI:

```bash
.cursor/skills/lucy/scripts/update.sh
# ou
~/.cursor/skills/lucy/scripts/update.sh
```

---

## Fluxo (ordem obrigatória)

### 0. Migrar legado (se existir)

Se o projeto ainda tiver `loop-master-progress.json` ou `loop-master-brain/`:

```bash
bash .cursor/skills/lucy/scripts/migrate-loop-master-to-lucy.sh
```

O `/lucy update` executa este passo **automaticamente**.

### 1. Backup do contexto do projeto

Copiar para `.cursor/lucy-progress.json.bak` (timestamp no nome se já existir bak recente).

**Nunca** sobrescrever o JSON de progresso no update.

### 2. Pull do skill pack

Se `SKILL_ROOT` é git repo:

```bash
cd <skill-root> && git pull --ff-only
```

Se submodule no projeto:

```bash
git submodule update --remote .agents/skills/lucy
```

Se cópia sem git: avisar usuário — re-copy manual ou clone.

### 3. Registrar versão

Ler `SKILL.md` frontmatter `version` → gravar em JSON:

```json
"skill_pack_version": "2.2.0",
"skill_pack_updated_at": "ISO8601"
```

### 4. Re-run init em modo preserve + incremental

```bash
scripts/init.sh --preserve-context --update-mode --skills <skills_installed from JSON>
```

**v2.9.4+:** `--update-mode` instala **somente o que falta** — não re-baixa skills, não reinstala claude-mem/hooks/playwright se já OK.

Flags init em update:

| Flag | Efeito |
|------|--------|
| `--preserve-context` | Não recriar JSON; não resetar fases/tick_count |
| `--update-mode` | Skip deps já instalados; fast path |
| `--skills` | Lista de skills a verificar (só instala ausentes) |

O que o update **pula** quando já presente:

| Componente | Check |
|------------|-------|
| impeccable, uipro, taste, caveman | `SKILL.md` existe |
| claude-mem | plugin instalado + worker running |
| Playwright | `@playwright/test` + chromium cache |
| brain | `.cursor/lucy-brain/STATE.json` |
| hooks | hash igual ao skill pack |

`git pull` só baixa commits novos; init incremental evita reinstalar tudo.

### 5. Re-scan skills instaladas

Atualizar `skills_installed[]` via scan de `.cursor/skills/`.

### 6. AskQuestion leve (opcional)

Uma pergunta se `skill_pack_version` mudou major:

- "Skill pack atualizado. Continuar loop de onde parou? (Recommended: Sim)"

Se não major: **não** quiz — continuar com `next_prompt` existente.

### 7. Confirmar ao usuário

- Versão antiga → nova
- `tick_count`, `current_phase`, `overall_pct` preservados
- Próximo tick: usar `next_prompt` ou `/lucy`

---

## O que o update NÃO faz

- Não reseta `phases` nem `delivery_contract`
- Não mata sentinel em execução (a menos que `--restart-loop`)
- Não commita `.env`
- Não apaga `archive_summaries` nem `quiz_answers`

---

## Flag `--restart-loop`

Re-arma sentinel após update com `next_prompt` atualizado. Útil se loop morreu.

---

## Integração com `/lucy init`

| Comando | JSON existente |
|---------|----------------|
| `init` (primeira vez) | Cria stub |
| `init` (JSON existe) | AskQuestion: Continuar / Reset fases / Novo objetivo |
| `update` | **Sempre preserva** contexto |

---

## Comandos novos (v2.9+)

Após `git pull`, o `update.sh` entrega protocolos para:

| Comando | Doc |
|---------|-----|
| `/lucy refazer-frontend` | `lucy-refazer-frontend-protocol.md` |
| `/lucy nova-pagina` | `lucy-nova-pagina-protocol.md` |
| `/lucy aprenda` | `lucy-aprenda-protocol.md` |
| `/lucy regra` | `lucy-regra-protocol.md` |
| `/lucy visual-gate` | `visual-gate-protocol.md` (auto em init/update) |

**Preservado no update:** `.cursor/lucy-brain/rules/` (regras P0 do projeto) — nunca sobrescrito pelo pull.
