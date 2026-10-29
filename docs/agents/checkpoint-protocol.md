# Checkpoint protocol

## Per work package
1. Orchestrator spawns the Worker (Opus) in a worktree on `wp/<id>` with the acceptance file.
2. Worker finishes, writes `docs/agents/reports/<WP>.md` (done / skipped / risks / files changed).
3. Orchestrator spawns the Reviewer (Opus) for that domain. The Reviewer:
   - runs `/ponytail-review branch` (or reads the diff with the Ponytail checklist when the plugin is unavailable),
   - runs every acceptance test command,
   - checks the Documentation Standard: headers, function docs (interrogate / dart doc / eslint-jsdoc), DECISION comments exist in DECISIONS.md, LIBRARIES.md rows, error codes registered,
   - writes `docs/agents/reviews/<WP>-r<n>.md` with PASS or FAIL and concrete findings (what the code does, what goes wrong, how to fix, what happens if skipped).
4. FAIL → back to the same Worker (SendMessage) with the review file; maximum two rounds, then Architect-Gate.
5. PASS → Orchestrator spawns a Verifier (Opus) who follows `qa-rubric.md` and writes `docs/agents/qa/<WP>.md`.
6. Verifier PASS → Orchestrator merges `wp/<id>` into `main`, runs `codegraph sync`, ticks CHECKLIST.md, appends CHANGELOG.md, updates TODO.md, runs `checklist-progress.py`.

## Per wave
- After the last merge of a wave the Reviewer runs `/ponytail-audit` on `main` and files `docs/agents/audits/wave-<n>.md`. P1 findings block the next wave.
- Robot suites for the finished WPs must be green; results archived in `qa/robot/results/`.

## Per gate (G0–G5)
`docs/agents/gates/G<n>.md` lists: WPs included, acceptance evidence links, audit file, Robot report, benchmark numbers against thresholds, LIBRARIES.md check, error-codes regeneration, and the signatures (Architect-Gate and/or QA Lead) with an `APPROVED` line.
