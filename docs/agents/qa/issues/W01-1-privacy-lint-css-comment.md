# W01-1 (P3, handoff): privacy lint flags the word "Mobile" in the inlined CSS comment

**Found by:** W01 Verifier, 2026-10-29, commit fb5dea7 (worktree agent-aa4178c93bf08ffdf)
**Severity:** P3. The text is not personal data. But every built page fails the BM-09 / G4 "privacy lint zero hits" check until one side changes.
**Owner:** Orchestrator. Route it to Q00 (linter) or W03 (page CSS).

## Reproduction
```
cd apps/public-page
uv run python -m agritrace_page build fixtures/batch_sample.json /tmp/w01v/out
python3 infra/scripts/privacy-lint.py /tmp/w01v/out      # linter from the Q00 worktree agent-a1e874f99a5c27fbd
/tmp/w01v/out/index.html:8:4: sensitive_label: Mobile
privacy-lint: 1 hit(s) in 2 file(s) scanned
exit=1
```
Source: `apps/public-page/agritrace_page/templates/page.css` line 2, `Mobile-first; system fonts only ...`. The CSS is inlined into every page. The linter's `sensitive_label` rule is `\b(?:survey|patta|chitta|aadhaar|phone|mobile)`, case-insensitive, and it matches any text. TODO.md:40 already lists this false-positive bias.

## Fix options (pick one)
- Page: reword the CSS comment, or strip comments from `page.css`/`page.js` when they are inlined. Stripping also saves bytes.
- Linter: skip `<style>`/`<script>` bodies and comments, or require the label to be followed by a number or separator (`mobile\s*(no|number|:)`).

Evidence: `docs/agents/qa/W01/logs/10-privacy-lint.txt`, `docs/agents/qa/W01/out/index.html` line 8.
