# Libraries ledger

Every dependency in `apps/api/pyproject.toml`, `apps/public-page/pyproject.toml`, `apps/mobile/pubspec.yaml`,
`apps/portal/package.json` and `qa/robot/requirements.txt` must have a row here (`infra/scripts/libraries-check.py`
fails CI otherwise). Licence must be permissive (MIT, BSD, Apache-2.0, ISC); GPL, AGPL, LGPL and non-commercial licences
are rejected for linked libraries (D-018). Separate services (databases, emulators) are not ledger rows.

| Library | Version | Licence | Used in (paths) | What for | Why this one | Alternative rejected |
|---|---|---|---|---|---|---|
| jinja2 | 3.1.6 | BSD-3-Clause | apps/public-page/agritrace_page/render.py, templates/batch.html.j2 | Renders the static public batch page with autoescaping | De-facto Python HTML templating; autoescape and StrictUndefined built in; already the stack choice (CLAUDE.md §1) | Hand-built f-strings (no escaping, XSS risk); Mako (smaller community) |
| markupsafe | 3.0.4 | BSD-3-Clause | apps/public-page/agritrace_page/render.py | Declared directly (>=3) because render.py imports Markup; also pulled in by jinja2 | Jinja2's own escaping type; no extra install | `html.escape` + manual safe-marking (easy to double-escape) |
| pydantic | 2.14.1 | MIT | apps/public-page/agritrace_page/schema.py, render.py | `PublicBatchRecord` allow-list, privacy validator, `data.json` serialisation | Stack choice (CLAUDE.md §1); `extra="forbid"` and `hide_input_in_errors` give the privacy guarantees | dataclasses + jsonschema (two libraries, no validators) |
| html5lib | 1.1 | MIT | apps/public-page/tests/test_render.py (dev) | Strict HTML5 parse of the rendered page (fails on any parse error) and element queries | Pure-Python WHATWG parser with a strict mode; no compiled deps | lxml (`recover=False` is not an HTML5 conformance check); html-validate is Node (W02 adds it) |
| pytest | 9.2.0 | MIT | apps/public-page/tests/ (dev) | Test runner | De-facto Python test runner; fixtures and parametrize keep tests short | unittest (more boilerplate) |
| ruff | 0.17.3 | MIT | apps/public-page/pyproject.toml (dev) | Lint incl. pydocstyle Google convention and D417 (CLAUDE.md §5) | One fast tool for lint and format | flake8 + pydocstyle + isort (three tools) |
| interrogate | 1.7.0 | MIT | apps/public-page/pyproject.toml (dev) | Enforces 100 % docstring coverage (CLAUDE.md §5) | The docstring-coverage tool CLAUDE.md names | docstr-coverage (less used) |
| hatchling | >=1.25 (build-only) | MIT | apps/public-page/pyproject.toml `[build-system]` | Builds the `agritrace_page` wheel so apps/api (B10) can depend on it by path | PyPA-maintained, zero config for a flat package, ships templates and JSON automatically | setuptools (needs package-data config) |
| robotframework | 7.5 | Apache-2.0 | qa/robot/**/*.robot, qa/robot/resources/common.resource | Acceptance suites run by Verifiers and CI (plan §9.1); built-in Process/OperatingSystem/Collections libraries | Keyword-driven suites read like the acceptance tables; one runner for API, browser, DB and adb | pytest-bdd (needs Gherkin glue per step; weaker reporting for Verifiers) |
| robotframework-requests | 0.9.7 | MIT | qa/robot/resources/common.resource, qa/robot/api/*.robot | HTTP keywords for the /v1 API (healthz, auth, error envelope) | De-facto Robot HTTP library on top of requests | Custom keywords over requests (more code) |
| robotframework-browser | 20.6.0 | Apache-2.0 | qa/robot/portal/portal.robot, qa/robot/public/page.robot (later) | Playwright-driven portal and public-page checks, screenshots | Playwright engine with auto-wait; maintained by the Robot Framework Foundation | SeleniumLibrary (needs browser drivers, flakier waits) |
| robotframework-databaselibrary | 2.5.0 | Apache-2.0 | qa/robot/resources/common.resource | PostGIS row assertions (e.g. one row after duplicate push) | Standard Robot DB library, any DB-API 2.0 driver | Raw SQL through Process + psql (no assertions, harder to read) |
| pg8000 | 1.31.6 | BSD-3-Clause | qa/robot/resources/common.resource (DatabaseLibrary driver) | Postgres DB-API driver for DatabaseLibrary | Pure Python, permissive licence, no libpq on Verifier machines | psycopg / psycopg-binary (LGPL-3.0, copyleft, rejected by D-018) |
| pyyaml | 6.0.3 | MIT | qa/robot/lib/agritrace_keywords.py, qa/scripts/network.sh, infra/scripts/benchmarks/collect.py, infra/scripts/libraries-check.py (pubspec) | Read profiles.yaml, thresholds.yaml, pubspec.yaml | The standard YAML parser for Python | ruamel.yaml (round-trip features not needed) |
| pre-commit | 4.7.0 | MIT | .pre-commit-config.yaml | Runs ruff, checklist-progress and libraries-check before commits | Standard multi-language hook manager | Husky (Node-only, repo is mostly Python/Dart) |
