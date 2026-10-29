# Libraries ledger

Every dependency in `apps/api/pyproject.toml`, `apps/public-page/pyproject.toml`, `apps/mobile/pubspec.yaml`,
`apps/portal/package.json` and `qa/robot/requirements.txt` must have a row here (`infra/scripts/libraries-check.py`
fails CI otherwise). Licence must be permissive (MIT, BSD, Apache-2.0, ISC); GPL, AGPL, LGPL and non-commercial licences
are rejected for linked libraries (D-018). Separate services (databases, emulators) are not ledger rows.

| Library | Version | Licence | Used in (paths) | What for | Why this one | Alternative rejected |
|---|---|---|---|---|---|---|
