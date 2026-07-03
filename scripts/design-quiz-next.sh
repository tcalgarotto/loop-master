#!/usr/bin/env bash
# Design quiz for /lucy refazer-frontend (4 rounds — separate from init quiz)
# Usage: design-quiz-next.sh [--json] [--project PATH]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/lucy-paths.sh
source "$SCRIPT_DIR/lib/lucy-paths.sh"
PROJECT_ROOT="$(lucy_detect_project_root "$(pwd)")"

PROGRESS="$(lucy_progress_file "$PROJECT_ROOT")"
[[ "$PROGRESS" != /* ]] && PROGRESS="$PROJECT_ROOT/$PROGRESS"
AS_JSON=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --json) AS_JSON=true; shift ;;
    -h|--help)
      echo "Usage: design-quiz-next.sh [--json] [--project PATH]"
      exit 0
      ;;
    *) shift ;;
  esac
done
export AS_JSON=$([[ "$AS_JSON" == true ]] && echo 1 || echo 0)

INVENTORY="$PROJECT_ROOT/.lucy/frontend-inventory.json"
ROUTES_HINT=""
if [[ -f "$INVENTORY" ]] && command -v jq &>/dev/null; then
  ROUTES_HINT=$(jq -r '[.pages[].route] | join(", ")' "$INVENTORY" 2>/dev/null | head -c 500)
fi

CURRENT=0
if [[ -f "$PROGRESS" ]] && command -v jq &>/dev/null; then
  CURRENT=$(jq -r '.design_refactor_quiz.round // 0' "$PROGRESS" 2>/dev/null || echo 0)
fi

if [[ "$CURRENT" -ge 4 ]]; then
  echo "DESIGN_QUIZ_COMPLETE — design_refactor_quiz.round=$CURRENT. Proceed to impeccable critique + refactor."
  exit 0
fi

NEXT=$((CURRENT + 1))

python3 << PY
import json, os

next_round = int("$NEXT")
routes_hint = """$ROUTES_HINT"""

rounds = {
  1: {
    "title": "Design Round 1/4 — Escopo",
    "persist_key": "round_1",
    "questions": [
      {"id": "d1_scope", "prompt": "O que refinar neste ciclo?", "options": [
        "Todo o frontend (Recommended se não especificou rotas)",
        "Só rotas que mencionei no prompt",
        "Só rotas com slop/duplicata no inventário",
        "Other"
      ]},
      {"id": "d1_preserve_routes", "prompt": "Rotas e URLs?", "options": [
        "Manter todas as URLs — só melhorar visual (Recommended)",
        "Pode renomear rotas se eu pedir depois",
        "Other"
      ]},
      {"id": "d1_depth", "prompt": "Profundidade por página?", "options": [
        "Impeccable critique → craft → polish (Recommended)",
        "Só polish visual rápido",
        "Critique + relatório sem codar ainda",
        "Other"
      ]},
    ],
  },
  2: {
    "title": "Design Round 2/4 — Anti-slop & premium",
    "persist_key": "round_2",
    "questions": [
      {"id": "d2_register", "prompt": "Register visual alvo?", "options": [
        "Product premium zinc/slate (Recommended)",
        "Seguir DESIGN_SYSTEM.md existente",
        "Marketing expressivo (taste-skill alto)",
        "Other"
      ]},
      {"id": "d2_slop_fix", "prompt": "O que atacar primeiro?", "options": [
        "Hierarquia tipográfica + espaçamento",
        "Cores genéricas (azul/roxo gradiente)",
        "Cards iguais sem hierarquia",
        "Sombras/bordas excessivas",
        "Copy genérica ('Welcome to…')",
        "Other"
      ], "allow_multiple": True},
      {"id": "d2_motion", "prompt": "Motion neste refactor?", "options": [
        "Sutil — CSS scrub + hover only (Recommended)",
        "GSAP stagger em listas",
        "Framer só onde já existe layoutId",
        "Quase zero motion",
        "Other"
      ]},
    ],
  },
  3: {
    "title": "Design Round 3/4 — Duplicatas & órfãos",
    "persist_key": "round_3",
    "questions": [
      {"id": "d3_duplicates", "prompt": "Rotas/páginas duplicadas no inventário?", "options": [
        "Unificar visualmente (mesmo layout) — manter URLs",
        "Documentar só — não mexer ainda",
        "Revisar caso a caso (Recommended)",
        "Other"
      ]},
      {"id": "d3_orphans", "prompt": "Páginas órfãs (sem link na nav)?", "options": [
        "Integrar na sidebar/nav",
        "Manter órfã mas polish visual",
        "Listar no relatório para decisão humana (Recommended)",
        "Other"
      ]},
      {"id": "d3_priority_routes", "prompt": "Rotas prioritárias?", "options": (
        ([f"Rota: {r}" for r in routes_hint.split(", ")[:12] if r.strip()] or ["Inferir do inventário (Recommended)"])
        + ["Other"]
      ), "allow_multiple": True},
    ],
  },
  4: {
    "title": "Design Round 4/4 — Impeccable & entrega",
    "persist_key": "round_4",
    "questions": [
      {"id": "d4_impeccable", "prompt": "Pipeline impeccable por página?", "options": [
        "critique → layout → typeset → colorize → polish (Recommended)",
        "critique → craft direto",
        "só polish",
        "Other"
      ]},
      {"id": "d4_gate", "prompt": "Gate visual?", "options": [
        "Zero critical impeccable + taste anti-slop (Recommended)",
        "MVP visual — sem waiver escrito",
        "Other"
      ]},
      {"id": "d4_pages_per_tick", "prompt": "Ritmo?", "options": [
        "1 página por tick (Recommended)",
        "1 superfície (ex: todas settings)",
        "2 páginas pequenas por tick",
        "Other"
      ]},
    ],
  },
}

r = rounds[next_round]
as_json = os.environ.get("AS_JSON") == "1"

if as_json:
    print(json.dumps({"round": next_round, **r}, ensure_ascii=False, indent=2))
else:
    print(f"DESIGN_QUIZ_ROUND={next_round}")
    print(f"PERSIST: design_refactor_quiz.{r['persist_key']}")
    print(f"TITLE: {r['title']}")
    print("")
    for q in r["questions"]:
        multi = " [multi]" if q.get("allow_multiple") else ""
        print(f"ID: {q['id']}{multi}")
        print(f"PROMPT: {q['prompt']}")
        for i, o in enumerate(q["options"], 1):
            print(f"  {i}. {o}")
        print("")
    print("Use AskQuestion com os IDs acima. Uma rodada por turno.")
    print("Após persistir: bash .cursor/skills/lucy/scripts/design-quiz-next.sh")
PY
