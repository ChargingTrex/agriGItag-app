# AgriTrace mobile (`apps/mobile`)

One Flutter app for farmers, field officers and QC officers (Material 3, Riverpod, go_router; Android 8+ / iOS 13+).
Design contract: `docs/agents/specs/mobile-design.md`. Plan: `docs/agents/plan-summary.md` §7.2.

| Task | Command (from `apps/mobile`) |
|---|---|
| Run (dev, Android emulator to host API at 10.0.2.2:8000) | `flutter run -t lib/main_dev.dart` |
| Run against another API | `flutter run -t lib/main_staging.dart --dart-define=API_BASE_URL=https://...` |
| Release build (prod) | `flutter build appbundle -t lib/main_prod.dart --split-debug-info=build/symbols --dart-define=API_BASE_URL=https://...` |
| Analyze / test | `flutter analyze` / `flutter test` |
| Goldens (tag `golden`; macOS only until Q01 re-records them on Linux, skipped elsewhere) | update: `flutter test --update-goldens test/widget/farmer_button_golden_test.dart`, review the PNGs; exclude: `flutter test -x golden` |
| Regenerate the API client after `make openapi` | `tool/gen_api.sh` (needs Node and Java 11+; set `JAVA_HOME`) |
| Farmer no-free-text lint (farmer features + core/widgets) | `tool/no_textfield_lint.sh` |
| Size budget in MiB: arm64 APK warn > 40, fail > 100; AAB per-device download fail > 30 when bundletool is installed | `tool/size_check.sh`, then `flutter clean` |

- `packages/agritrace_api/` is generated from `packages/openapi/openapi.json`. Never edit it by hand (D-003).
- Strings live in `lib/core/l10n/app_ta.arb` (default, template) and `app_en.arb`; `flutter gen-l10n` runs on `pub get`.
- `assets/fonts/NotoSansTamil-sub.ttf` is a Tamil-block subset of Noto Sans Tamil Regular (SIL OFL 1.1, see `NotoSansTamil-OFL.txt`).

## Offline store (`lib/core/db`, WP-M01)

Drift (SQLite) database `AppDatabase` with the tables of `mobile-design.md` §2 and one DAO per job
(`db.entriesDao`, `db.outboxDao`, `db.mediaDao`, `db.refBundlesDao`, `db.syncStateDao`, `db.syncMetricsDao`,
`db.tasksDao`, `db.flagsDao`, `db.fieldConfigDao`). The app opens it with `AppDatabase.open()`; tests use
`AppDatabase(NativeDatabase.memory())`.

- **Entries are append-only.** `EntriesDao.save` writes the entry, its media and their outbox rows in one batch.
  A correction is a new row with the same `rootId`, `version + 1` and `supersedesEntryId`; `undo` adds an `undo`
  version. Triggers in `tables/append_only.drift` reject any update of an entry's facts and any delete; only
  `status` and `serverReceivedAt` change after save.
- **Times** are stored as ISO-8601 text with milliseconds (`build.yaml`: `store_date_time_values_as_text`).
  Drift compares them through `julianday()`; order by `column.julianday`, not by the raw column.
- **Generated code is committed.** `lib/core/db/**/*.g.dart` and `test/db/generated/` carry do-not-edit headers.

| Task | Command (from `apps/mobile`) |
|---|---|
| Regenerate after editing `lib/core/db/**` | `tool/schema_dump.sh` (build_runner, schema dump, test helpers, format) |
| Schema change | edit the tables, bump `AppDatabase.schemaVersion`, add the `onUpgrade` step, run `tool/schema_dump.sh`, add a migration test to `test/db/schema_test.dart` |
| Store tests | `flutter test test/db` (`schema_test.dart` fails while the tables differ from the committed dump) |

Run build_runner with the Flutter SDK's `dart` (a Homebrew `dart` first on PATH cannot resolve `flutter_test`);
`tool/schema_dump.sh` finds it and passes `--force-jit`, because the AOT-compiled build script failed on the dev host.
