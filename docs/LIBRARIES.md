# Libraries ledger

Every dependency in `apps/api/pyproject.toml`, `apps/public-page/pyproject.toml`, `apps/mobile/pubspec.yaml`,
`apps/portal/package.json` and `qa/robot/requirements.txt` must have a row here (`infra/scripts/libraries-check.py`
fails CI otherwise). Licence must be permissive (MIT, BSD, Apache-2.0, ISC, MPL-2.0 file-level); copyleft or
non-commercial licences are rejected (D-018).

| Library | Version | Licence | Used in (paths) | What for | Why this one | Alternative rejected |
|---|---|---|---|---|---|---|
