#!/usr/bin/env bash
# Print AskQuestion spec for the NEXT quiz round only (v2.9.9+ — 7 rounds)
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

if [[ "$CURRENT" -ge 7 ]]; then
  echo "QUIZ_COMPLETE — quiz_round=$CURRENT. Proceed to plan + arm loop."
  exit 0
fi

NEXT=$((CURRENT + 1))

MCP_STATUS_JSON="{}"
if [[ "$NEXT" -eq 3 ]] && [[ -x "$SCRIPT_DIR/mcp-setup-status.sh" ]]; then
  MCP_STATUS_JSON="$("$SCRIPT_DIR/mcp-setup-status.sh" --json --project "$PROJECT_ROOT" 2>/dev/null || echo '{}')"
fi
export MCP_STATUS_JSON

python3 << PY
import json, os

next_round = int("$NEXT")
mcp_status = {}
try:
    mcp_status = json.loads(os.environ.get("MCP_STATUS_JSON", "{}"))
except json.JSONDecodeError:
    pass

missing = mcp_status.get("missing_slugs", [])
missing_labels = {c["slug"]: c["label"] for c in mcp_status.get("integrations", [])}

def mcp_opt(slug, base):
    if slug in missing:
        return f"{base} — cadastrar (detectado: falta)"
    return f"{base} — OK"

rounds = {
  1: {
    "title": "Round 1/7 — Produto & North Star",
    "persist_key": "round_1",
    "questions": [
      {"id": "r1_goal", "prompt": "Qual o objetivo north-star deste loop?", "options": ["MVP funcional", "Production-ready 100% (Recommended)", "Go-live com deploy", "Other"]},
      {"id": "r1_users", "prompt": "Quem usa o produto?", "options": ["Equipe interna", "Clientes B2B", "Consumidor final", "Devs/API", "Other"]},
      {"id": "r1_delivery", "prompt": "Barra de entrega?", "options": ["Production-ready 100% (Recommended)", "MVP funcional", "Go-live imediato"]},
      {"id": "r1_success", "prompt": "Como sabemos que terminou?", "options": ["Inferir do repo (Recommended)", "E2E verde", "Deploy OK + audit", "Other"]},
    ],
  },
  2: {
    "title": "Round 2/7 — Escopo técnico",
    "persist_key": "round_2",
    "questions": [
      {"id": "r2_scope", "prompt": "Escopo principal?", "options": ["Backend", "Frontend", "Full-stack (Recommended se app+API)", "Infra", "Docs-only"]},
      {"id": "r2_stack", "prompt": "Stack detectada — confirmar?", "options": ["Inferir de package.json/Makefile (Recommended)", "Next.js + FastAPI", "Outro"]},
      {"id": "r2_integrations", "prompt": "Integrações críticas?", "options": ["DB", "Auth", "API externa", "Pagamentos", "Nenhuma", "Other"], "allow_multiple": True},
      {"id": "r2_constraints", "prompt": "Restrições técnicas?", "options": ["Não quebrar prod", "Zero downtime", "Sem migrations", "Nenhuma", "Other"], "allow_multiple": True},
    ],
  },
  3: {
    "title": "Round 3/7 — MCP, integrações & design pipeline",
    "persist_key": "round_3",
    "preflight": [
      "RUN: bash scripts/mcp-setup-status.sh --json",
      "SHOW owner missing vs OK before AskQuestion",
      "IF r3m_guidance=guide_now: run mcp-setup-guide.sh per missing slug",
    ],
    "questions": [
      {"id": "r3m_priority", "prompt": "Quais integrações priorizar neste projeto?", "options": [
        mcp_opt("html-first", "HTML preview local (preview/)"),
        mcp_opt("penpot", "Penpot MCP (design editável)"),
        mcp_opt("visual-gate", "Visual gate Playwright"),
        mcp_opt("firecrawl", "Firecrawl scrape"),
        mcp_opt("claude-mem", "claude-mem L2"),
      ], "allow_multiple": True},
      {"id": "r3m_guidance", "prompt": "Como configurar o que falta?", "options": [
        "Guiar setup agora — passo a passo (Recommended)" if missing else "Já configurado — seguir",
        "Marcar para tick 1 (configuro depois)",
        "Pular — não preciso destas ferramentas",
      ]},
      {"id": "r3m_pipeline", "prompt": "Pipeline de design?", "options": [
        "HTML-first até aprovar → depois Next (Recommended)",
        "Penpot + HTML híbrido (Caminho C)",
        "Direto Next (design já aprovado)",
      ]},
      {"id": "r3m_optional", "prompt": "MCPs opcionais (Cursor plugins)?", "options": [
        "Vercel", "Supabase", "Stripe", "Sentry", "Linear", "Notion", "Nenhum",
      ], "allow_multiple": True},
    ],
  },
  4: {
    "title": "Round 4/7 — Design & UX",
    "persist_key": "round_4",
    "questions": [
      {"id": "r4_surface", "prompt": "Superfície visual?", "options": ["Product app — dashboard/chat (Recommended)", "Marketing/landing", "Nenhuma (BE only)"]},
      {"id": "r4_register", "prompt": "Register visual?", "options": ["Product restrained (Recommended)", "Marketing expressivo", "Seguir DESIGN.md"]},
      {"id": "r4_priority_pages", "prompt": "Páginas prioritárias?", "options": ["Inferir de src/app (Recommended)", "Home/dashboard", "Other"], "allow_multiple": True},
      {"id": "r4_design_skills", "prompt": "Skills design a usar?", "options": ["impeccable", "ui-ux-pro-max", "taste-skill", "design-system", "motion", "gsap-premium"], "allow_multiple": True},
    ],
  },
  5: {
    "title": "Round 5/7 — Qualidade & gates",
    "persist_key": "round_5",
    "questions": [
      {"id": "r5_gate", "prompt": "Gate por fase?", "options": ["100% + zero critical/high (Recommended)", "MVP happy-path", "Medium com waiver"]},
      {"id": "r5_tests", "prompt": "Verificação obrigatória?", "options": ["npm test/build", "pytest", "e2e playwright", "impeccable detect"], "allow_multiple": True},
      {"id": "r5_security", "prompt": "Audit de segurança?", "options": ["security-review + bugbot (Recommended)", "Só bugbot", "Pular"]},
      {"id": "r5_docs", "prompt": "Docs versionados?", "options": ["plan + INDEX + COMPLETE (Recommended)", "Só plan", "Mínimo"]},
    ],
  },
  6: {
    "title": "Round 6/7 — Autonomia & loop",
    "persist_key": "round_6",
    "questions": [
      {"id": "r6_mode", "prompt": "Modo de loop?", "options": ["Dinâmico chain ~45s (Recommended)", "Fixo (ex. 4m)", "Manual"]},
      {"id": "r6_interval", "prompt": "Fallback seconds?", "options": ["45s (Recommended)", "90s", "240s"]},
      {"id": "r6_memory", "prompt": "Second Brain + claude-mem?", "options": ["Sim — sync cada sessão (Recommended)", "Só JSON L1"]},
      {"id": "r6_parallel", "prompt": "Workers paralelos?", "options": ["4 workers + 2 verifiers (Recommended)", "Conservador", "Sequencial"]},
      {"id": "r6_stop", "prompt": "Quando parar?", "options": ["Só 100% ou 'pare o loop' (Recommended)", "Pausar após fase"]},
    ],
  },
  7: {
    "title": "Round 7/7 — Kickoff contextual",
    "persist_key": "round_7",
    "questions": [
      {"id": "r7_start_phase", "prompt": "Por onde começar?", "options": ["Maior gap no repo (Recommended)", "Página mais visível", "P0 audit", "Completar MCP faltante", "Other"]},
      {"id": "r7_first_tasks", "prompt": "1–3 tasks do primeiro tick?", "options": ["Inferir do git status (Recommended)", "Other"]},
      {"id": "r7_read_first", "prompt": "Arquivos para ler antes?", "options": ["Inferir do repo (Recommended)", "mcp-integrations-setup-guide.md", "Other"], "allow_multiple": True},
      {"id": "r7_blockers", "prompt": "Blockers humanos?", "options": ["Credenciais MCP", "Deploy", "Decisão produto", "Nenhum", "Other"], "allow_multiple": True},
      {"id": "r7_confirm", "prompt": "Confirmar init completo?", "options": ["Sim — fases + arm loop + tick 1 (Recommended)", "Revisar quiz"]},
    ],
  },
}

r = rounds[next_round]
out = {
  "quiz_round_current": int("$CURRENT"),
  "quiz_round_next": next_round,
  "quiz_complete_after": next_round == 7,
  "mcp_status": mcp_status if next_round == 3 else None,
  "round": r,
  "agent_rules": [
    "Use AskQuestion tool ONLY for questions in this round",
    "Do NOT use legacy flat quiz (q_goal/q_scope in one turn)",
    "After answers: persist quiz_answers." + r["persist_key"] + " and set quiz_round=" + str(next_round),
    "Round 3: run mcp-setup-status.sh; if guide_now run mcp-setup-guide.sh; persist mcp_setup_status",
    "If round 7 confirmed: set quiz_complete=true, create phases, arm loop",
    "Setup guide: references/mcp-integrations-setup-guide.md",
  ],
}

if os.environ.get("AS_JSON") == "1":
    print(json.dumps(out, ensure_ascii=False, indent=2))
else:
    print("=" * 60)
    print(r["title"])
    print("Persist: quiz_answers." + r["persist_key"])
    if next_round == 3 and mcp_status:
        print("\n--- MCP status (rodar antes do AskQuestion) ---")
        for c in mcp_status.get("integrations", []):
            mark = "OK" if c.get("configured") else "FALTA"
            print(f"  [{mark}] {c.get('label')}")
        print("  Guia: references/mcp-integrations-setup-guide.md")
    if r.get("preflight"):
        print("\n--- Preflight ---")
        for p in r["preflight"]:
            print(f"  • {p}")
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
