#!/usr/bin/env bash
# Print AskQuestion spec for the NEXT quiz round only (v2.5.2+)
# Usage: quiz-next.sh [--json]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"
PROJECT_ROOT="$(lucy_detect_project_root "$(pwd)")"

PROGRESS="$(lucy_progress_file "$PROJECT_ROOT")"
[[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"
AS_JSON=false
[[ "${1:-}" == "--json" ]] && AS_JSON=true
export AS_JSON=$([[ "$AS_JSON" == true ]] && echo 1 || echo 0)

if [[ ! -f "$PROGRESS" ]]; then
  CURRENT=0
else
  CURRENT=$(jq -r '.quiz_round // 0' "$PROGRESS" 2>/dev/null || echo 0)
fi

if [[ "$CURRENT" -ge 6 ]]; then
  echo "QUIZ_COMPLETE — quiz_round=$CURRENT. Proceed to plan + arm loop."
  exit 0
fi

NEXT=$((CURRENT + 1))

python3 << PY
import json, os

next_round = int("$NEXT")
rounds = {
  1: {
    "title": "Round 1/6 — Produto & North Star",
    "persist_key": "round_1",
    "questions": [
      {"id": "r1_goal", "prompt": "Qual o objetivo north-star deste loop?", "options": ["MVP funcional", "Production-ready 100% (Recommended)", "Go-live com deploy", "Other"]},
      {"id": "r1_users", "prompt": "Quem usa o produto?", "options": ["Equipe interna", "Clientes B2B", "Consumidor final", "Devs/API", "Other"]},
      {"id": "r1_delivery", "prompt": "Barra de entrega?", "options": ["Production-ready 100% (Recommended)", "MVP funcional", "Go-live imediato"]},
      {"id": "r1_success", "prompt": "Como sabemos que terminou?", "options": ["Inferir do repo (Recommended)", "E2E verde", "Deploy OK + audit", "Other"]},
    ],
  },
  2: {
    "title": "Round 2/6 — Escopo técnico",
    "persist_key": "round_2",
    "questions": [
      {"id": "r2_scope", "prompt": "Escopo principal?", "options": ["Backend", "Frontend", "Full-stack (Recommended se app+API)", "Infra", "Docs-only"]},
      {"id": "r2_stack", "prompt": "Stack detectada — confirmar?", "options": ["Inferir de package.json/Makefile (Recommended)", "Next.js + FastAPI", "Outro"]},
      {"id": "r2_integrations", "prompt": "Integrações críticas?", "options": ["DB", "Auth", "API externa", "Pagamentos", "Nenhuma", "Other"], "allow_multiple": True},
      {"id": "r2_constraints", "prompt": "Restrições técnicas?", "options": ["Não quebrar prod", "Zero downtime", "Sem migrations", "Nenhuma", "Other"], "allow_multiple": True},
    ],
  },
  3: {
    "title": "Round 3/6 — Design & UX",
    "persist_key": "round_3",
    "questions": [
      {"id": "r3_surface", "prompt": "Superfície visual?", "options": ["Product app — dashboard/chat (Recommended)", "Marketing/landing", "Nenhuma (BE only)"]},
      {"id": "r3_register", "prompt": "Register visual?", "options": ["Product restrained (Recommended)", "Marketing expressivo", "Seguir DESIGN.md"]},
      {"id": "r3_priority_pages", "prompt": "Páginas prioritárias?", "options": ["Inferir de src/app (Recommended)", "Home/dashboard", "Other"], "allow_multiple": True},
      {"id": "r3_design_skills", "prompt": "Skills design a usar?", "options": ["impeccable", "ui-ux-pro-max", "taste-skill", "design-system", "motion"], "allow_multiple": True},
    ],
  },
  4: {
    "title": "Round 4/6 — Qualidade & gates",
    "persist_key": "round_4",
    "questions": [
      {"id": "r4_gate", "prompt": "Gate por fase?", "options": ["100% + zero critical/high (Recommended)", "MVP happy-path", "Medium com waiver"]},
      {"id": "r4_tests", "prompt": "Verificação obrigatória?", "options": ["npm test/build", "pytest", "e2e playwright", "impeccable detect"], "allow_multiple": True},
      {"id": "r4_security", "prompt": "Audit de segurança?", "options": ["security-review + bugbot (Recommended)", "Só bugbot", "Pular"]},
      {"id": "r4_docs", "prompt": "Docs versionados?", "options": ["plan + INDEX + COMPLETE (Recommended)", "Só plan", "Mínimo"]},
    ],
  },
  5: {
    "title": "Round 5/6 — Autonomia & loop",
    "persist_key": "round_5",
    "questions": [
      {"id": "r5_mode", "prompt": "Modo de loop?", "options": ["Dinâmico chain ~45s (Recommended)", "Fixo (ex. 4m)", "Manual"]},
      {"id": "r5_interval", "prompt": "Fallback seconds?", "options": ["45s (Recommended)", "90s", "240s"]},
      {"id": "r5_memory", "prompt": "Second Brain + claude-mem?", "options": ["Sim — sync cada sessão (Recommended)", "Só JSON L1"]},
      {"id": "r5_parallel", "prompt": "Workers paralelos?", "options": ["4 workers + 2 verifiers (Recommended)", "Conservador", "Sequencial"]},
      {"id": "r5_stop", "prompt": "Quando parar?", "options": ["Só 100% ou 'pare o loop' (Recommended)", "Pausar após fase"]},
    ],
  },
  6: {
    "title": "Round 6/6 — Kickoff contextual",
    "persist_key": "round_6",
    "questions": [
      {"id": "r6_start_phase", "prompt": "Por onde começar?", "options": ["Maior gap no repo (Recommended)", "Página mais visível", "P0 audit", "Other"]},
      {"id": "r6_first_tasks", "prompt": "1–3 tasks do primeiro tick?", "options": ["Inferir do git status (Recommended)", "Other"]},
      {"id": "r6_read_first", "prompt": "Arquivos para ler antes?", "options": ["Inferir do repo (Recommended)", "Other"], "allow_multiple": True},
      {"id": "r6_blockers", "prompt": "Blockers humanos?", "options": ["Credenciais", "Deploy", "Decisão produto", "Nenhum", "Other"], "allow_multiple": True},
      {"id": "r6_confirm", "prompt": "Confirmar init completo?", "options": ["Sim — fases + arm loop + tick 1 (Recommended)", "Revisar quiz"]},
    ],
  },
}

r = rounds[next_round]
out = {
  "quiz_round_current": int("$CURRENT"),
  "quiz_round_next": next_round,
  "quiz_complete_after": next_round == 6,
  "round": r,
  "agent_rules": [
    "Use AskQuestion tool ONLY for questions in this round",
    "Do NOT use legacy flat quiz (q_goal/q_scope/q_skills in one turn)",
    "After answers: persist quiz_answers." + r["persist_key"] + " and set quiz_round=" + str(next_round),
    "If round 6 confirmed: set quiz_complete=true, create phases, arm loop",
  ],
}

if os.environ.get("AS_JSON") == "1":
    print(json.dumps(out, ensure_ascii=False, indent=2))
else:
    print("=" * 60)
    print(r["title"])
    print("Persist: quiz_answers." + r["persist_key"])
    print("=" * 60)
    for q in r["questions"]:
        multi = " [multi]" if q.get("allow_multiple") else ""
        print(f"\n  {q['id']}{multi}: {q['prompt']}")
        for o in q["options"]:
            print(f"    - {o}")
    print("\n--- Agent rules ---")
    for rule in out["agent_rules"]:
        print(f"  • {rule}")
PY
