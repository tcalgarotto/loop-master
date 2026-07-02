# `/loop-master update` — atualizar skill pack sem perder contexto

Atualiza o **pacote loop-master** (git pull) e re-sincroniza deps/skills
**sem apagar** `.cursor/loop-master-progress.json` nem `quiz_answers`.

---

## Trigger

```
/loop-master update
```

Equivalente CLI:

```bash
.cursor/skills/loop-master/scripts/update.sh
# ou
~/.cursor/skills/loop-master/scripts/update.sh
```

---

## Fluxo (ordem obrigatória)

### 1. Backup do contexto do projeto

Copiar para `.cursor/loop-master-progress.json.bak` (timestamp no nome se já existir bak recente).

**Nunca** sobrescrever o JSON de progresso no update.

### 2. Pull do skill pack

Se `SKILL_ROOT` é git repo:

```bash
cd <skill-root> && git pull --ff-only
```

Se submodule no projeto:

```bash
git submodule update --remote .agents/skills/loop-master
```

Se cópia sem git: avisar usuário — re-copy manual ou clone.

### 3. Registrar versão

Ler `SKILL.md` frontmatter `version` → gravar em JSON:

```json
"skill_pack_version": "2.2.0",
"skill_pack_updated_at": "ISO8601"
```

### 4. Re-run init em modo preserve

```bash
scripts/init.sh --preserve-context --skills <skills_installed from JSON>
```

Flags init em update:

| Flag | Efeito |
|------|--------|
| `--preserve-context` | Não recriar JSON; não resetar fases/tick_count |
| `--update-mode` | Alias de preserve-context |
| `--skills` | Reinstalar/atualizar deps opcionais |

### 5. Re-scan skills instaladas

Atualizar `skills_installed[]` via scan de `.cursor/skills/`.

### 6. AskQuestion leve (opcional)

Uma pergunta se `skill_pack_version` mudou major:

- "Skill pack atualizado. Continuar loop de onde parou? (Recommended: Sim)"

Se não major: **não** quiz — continuar com `next_prompt` existente.

### 7. Confirmar ao usuário

- Versão antiga → nova
- `tick_count`, `current_phase`, `overall_pct` preservados
- Próximo tick: usar `next_prompt` ou `/loop-master`

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

## Integração com `/loop-master init`

| Comando | JSON existente |
|---------|----------------|
| `init` (primeira vez) | Cria stub |
| `init` (JSON existe) | AskQuestion: Continuar / Reset fases / Novo objetivo |
| `update` | **Sempre preserva** contexto |
