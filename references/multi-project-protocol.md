# Multi-project — mesmo repositório, loops paralelos

Quando um repositório hospeda **mais de um loop** (ex.: app em produção + evolução da skill pack), cada loop precisa de **progress JSON isolado**.

## Arquivos

| Loop | Progress file | Chat |
|------|---------------|------|
| App / produto | `.cursor/loop-master-progress.json` | Chat do app |
| Skill pack / meta | `.cursor/loop-master-progress.skill-pack.json` | Chat da skill |

## Campos no JSON

```json
{
  "progress_file": ".cursor/loop-master-progress.skill-pack.json",
  "app_progress_file": ".cursor/loop-master-progress.json"
}
```

No JSON do app, use `skill_pack_progress_file` apontando para o arquivo da skill.

## Regras obrigatórias

1. **Hidratação:** ler o `progress_file` indicado no chat ou em `LOOP_MASTER_PROGRESS_FILE`
2. **Nunca** sobrescrever o JSON do outro projeto sem AskQuestion explícito
3. **`/loop-master init` com novo objetivo:** perguntar se é novo arquivo ou continuar existente
4. **Loops shell:** sentinel único por projeto (`AGENT_LOOP_WAKE_IMPECCABLE_REIMAGINE` vs `AGENT_LOOP_WAKE_LOOPMASTER_PACK`)
5. **init.sh / update.sh:** passar `--progress-file .cursor/loop-master-progress.skill-pack.json` quando aplicável

## Env

```bash
export LOOP_MASTER_PROGRESS_FILE=.cursor/loop-master-progress.skill-pack.json
bash .cursor/skills/loop-master/scripts/init.sh --preserve-context
```

## Anti-padrão

Substituir `loop-master-progress.json` do app ao fazer init da skill pack no mesmo repo — **usar arquivo separado**.
