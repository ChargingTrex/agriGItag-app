Test fixtures for the preview rules (M03, D-006). JSON cannot carry a header, so the origin is stated here.

- `grade_cases.json` — byte-identical copy of `apps/api/tests/fixtures/grade_cases.json` (the shared grade-engine cases).
- `dry_chilli_agmark_v1.json` — copy of `apps/api/agritrace/modules/quality/profiles/dry_chilli_agmark_v1.json`.
- `gi_region_fixture.geojson` — copy of `apps/api/agritrace/seed/fixtures/gi_region_fixture.geojson` (non-official test polygon).
- `reference_bundle.json` — phone-only: crops (event schema) and inputs bundle parts in the shape B07 is expected to send.

Never edit the three copies here: change the server file, then `cp` it over. `tool/check_shared_fixtures.sh` (CI) fails
when they differ.
