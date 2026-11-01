# B10-1 (P2): a plot without `farming_type` makes every batch with its lots unpublishable

<!-- Purpose: defect found live while verifying P04 (docs/agents/qa/P04.md). Serves: docs/agents/qa-rubric.md.
Readers: Orchestrator, BE Reviewer, owners of B10 (publishing builder) and W01 (page schema). -->

**Found by:** WEB Verifier, 2026-11-01, image built from `main` `6e99f1f` (includes B18), isolated compose stack.
**Severity:** P2. Publishing is blocked (no wrong data goes out; the build fails closed). Any FPO whose plots were
captured without the optional farming type cannot publish those batches until each plot is corrected.
**Owner:** B10 (`publishing/builder.py:484`) / W01 (`agritrace_page/schema.py:329`); D-017 says the YAML decides.

## Reproduction
1. As FPO admin, `POST /v1/plots` without `farming_type` (the schema allows null; `/v1/config/fields` lists plot
   `farming_type` as `required: false`, saved in [P08/config-fields.json](../P08/config-fields.json)).
2. Lots on that plot → received → batch (100/200/20 kg) → grading approved → packed → Publish (202).
3. The worker fails build 1: `PublicRecordInvalidError`, details `lots › 0 › farming_type: Input should be 'irrigated'
   or 'rainfed'` (×3). The portal shows it correctly: [P04/shots/B10-1-plot-without-farming-type-build-failed_en.png](../P04/shots/B10-1-plot-without-farming-type-build-failed_en.png) (log: [portal-live/logs/05-repro-run1.txt](../portal-live/logs/05-repro-run1.txt)).

## Cause
`builder.assemble` sends `"farming_type": None` when the plot has none; the page schema declares
`farming_type: Literal["irrigated", "rainfed"]` with no `None`. Fix in one place: make the page field optional (and
omit the line on the page) or have the builder drop the key; CLAUDE.md §1 forbids making it mandatory in code when the
YAML says optional. The Verifier's later runs set `farming_type: rainfed` on QA plots to get past it.
