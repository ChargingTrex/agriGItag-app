# Libraries ledger

Every dependency in `apps/api/pyproject.toml`, `apps/public-page/pyproject.toml`, `apps/mobile/pubspec.yaml`,
`apps/portal/package.json` and `qa/robot/requirements.txt` must have a row here (`infra/scripts/libraries-check.py`
fails CI otherwise). Licence must be permissive (MIT, BSD, Apache-2.0, ISC, MPL-2.0 file-level); copyleft or
non-commercial licences are rejected (D-018).

| Library | Version | Licence | Used in (paths) | What for | Why this one | Alternative rejected |
|---|---|---|---|---|---|---|
| jinja2 | 3.1.6 | BSD-3-Clause | apps/public-page/agritrace_page/render.py, templates/batch.html.j2 | Renders the static public batch page with autoescaping | De-facto Python HTML templating; autoescape and StrictUndefined built in; already the stack choice (CLAUDE.md §1) | Hand-built f-strings (no escaping, XSS risk); Mako (smaller community) |
| markupsafe | 3.0.4 | BSD-3-Clause | apps/public-page/agritrace_page/render.py | `Markup` for escaped bilingual label spans (installed with jinja2) | Jinja2's own escaping type; no extra install | `html.escape` + manual safe-marking (easy to double-escape) |
| pydantic | 2.14.1 | MIT | apps/public-page/agritrace_page/schema.py, render.py | `PublicBatchRecord` allow-list, privacy validator, `data.json` serialisation | Stack choice (CLAUDE.md §1); `extra="forbid"` and `hide_input_in_errors` give the privacy guarantees | dataclasses + jsonschema (two libraries, no validators) |
| html5lib | 1.1 | MIT | apps/public-page/tests/test_render.py (dev) | Strict HTML5 parse of the rendered page (fails on any parse error) and element queries | Pure-Python WHATWG parser with a strict mode; no compiled deps | lxml (`recover=False` is not an HTML5 conformance check); html-validate is Node (W02 adds it) |
| pytest | 9.2.0 | MIT | apps/public-page/tests/ (dev) | Test runner | De-facto Python test runner; fixtures and parametrize keep tests short | unittest (more boilerplate) |
| ruff | 0.17.3 | MIT | apps/public-page/pyproject.toml (dev) | Lint incl. pydocstyle Google convention and D417 (CLAUDE.md §5) | One fast tool for lint and format | flake8 + pydocstyle + isort (three tools) |
| interrogate | 1.7.0 | MIT | apps/public-page/pyproject.toml (dev) | Enforces 100 % docstring coverage (CLAUDE.md §5) | The docstring-coverage tool CLAUDE.md names | docstr-coverage (less used) |
| hatchling | latest (build-only) | MIT | apps/public-page/pyproject.toml `[build-system]` | Builds the `agritrace_page` wheel so apps/api (B10) can depend on it by path | PyPA-maintained, zero config for a flat package, ships templates and JSON automatically | setuptools (needs package-data config) |
