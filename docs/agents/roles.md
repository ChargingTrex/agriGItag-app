# Agent roles and hierarchy

```
                 ORCHESTRATOR (session lead)
   owns CHECKLIST / CHANGELOG / TODO, spawns agents, merges, resolves ties
        │                     │                        │
  ARCHITECT-GATE          REVIEWERS (Opus)          QA LEAD (Opus)
  (Opus)                  BE · MOB · WEB · SEC · DOCS   benchmarks, Robot suites,
  approves interfaces,    review every WP,           assigns Verifiers, signs gates
  schemas, ADRs           audit every wave                │
        │                     │                      VERIFIERS (Opus)
        └──────────── WORKERS (Opus), one per WP ────── run acceptance, attach evidence
```

| Role | Model | May do | May not do | Deliverable |
|---|---|---|---|---|
| Orchestrator | session lead | Spawn and sequence agents, merge `wp/*` branches, update CHECKLIST/CHANGELOG/TODO, run gate scripts, `codegraph sync` | Write feature code | Running project, green gates |
| Architect-Gate | Opus | Review and approve the OpenAPI spec, DB schema, Drift schema, module boundaries, every ADR; arbitrate design disputes | Write code | `APPROVED` line in the gate file; signed ADRs |
| Worker | Opus | Implement exactly one WP on `wp/<id>` inside its declared paths; write its tests, ADR stubs, LIBRARIES rows, CHANGELOG line, report | Touch other paths; add a dependency without a ledger row; skip tests; merge | Branch + `docs/agents/reports/<WP>.md` |
| Reviewer (BE/MOB/WEB/SEC/DOCS) | Opus | `/ponytail-review branch`, run acceptance tests, check the Documentation Standard, reject with concrete findings; `/ponytail-audit` at the end of each wave | Fix code | `docs/agents/reviews/<WP>-r<n>.md` PASS/FAIL; `docs/agents/audits/wave-<n>.md` |
| QA Lead | Opus | Own `infra/scripts/benchmarks/` and `qa/robot/`; set thresholds; assign Verifiers; sign gates | Write feature code | Gate report, Robot suites |
| Verifier | Opus | Execute acceptance tests and benchmarks on the docker stack / emulator, capture logs and screenshots, fill the rubric | Modify code or tests | `docs/agents/qa/<WP>.md` with evidence paths |

## Escalation
Worker → its Reviewer → Architect-Gate (design) or QA Lead (test/benchmark) → Orchestrator (ties; outcome recorded in DECISIONS.md).
A WP gets at most two review rounds before escalation.

## Spawn prompt skeleton (Orchestrator pastes this for every Worker)
1. Role card row above.  2. `CLAUDE.md` is binding.  3. The WP acceptance file verbatim.  4. ADRs named in it.
5. "Run `codegraph explore` before grep."  6. "Finish with `docs/agents/reports/<WP>.md`."
