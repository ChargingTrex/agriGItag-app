# AgriTrace mobile (`apps/mobile`)

One Flutter app for farmers, field officers and QC officers (Material 3, Riverpod, go_router; Android 8+ / iOS 13+).
Design contract: `docs/agents/specs/mobile-design.md`. Plan: `docs/agents/plan-summary.md` §7.2.

| Task | Command (from `apps/mobile`) |
|---|---|
| Run (dev, Android emulator to host API at 10.0.2.2:8000) | `flutter run -t lib/main_dev.dart` |
| Run against another API | `flutter run -t lib/main_staging.dart --dart-define=API_BASE_URL=https://...` |
| Release build (prod) | `flutter build appbundle -t lib/main_prod.dart --split-debug-info=build/symbols --dart-define=API_BASE_URL=https://...` |
| Analyze / test | `flutter analyze` / `flutter test` |
| Update goldens (macOS, then review the PNGs) | `flutter test --update-goldens` |
| Regenerate the API client after `make openapi` | `tool/gen_api.sh` (needs Node and Java 11+; set `JAVA_HOME`) |
| Farmer no-free-text lint | `tool/no_textfield_lint.sh` |
| Size budget (arm64 APK; `MAX_MB=15` for the M00 gate) | `tool/size_check.sh`, then `flutter clean` |

- `packages/agritrace_api/` is generated from `packages/openapi/openapi.json`. Never edit it by hand (D-003).
- Strings live in `lib/core/l10n/app_ta.arb` (default, template) and `app_en.arb`; `flutter gen-l10n` runs on `pub get`.
- `assets/fonts/NotoSansTamil-sub.ttf` is a Tamil-block subset of Noto Sans Tamil Regular (SIL OFL 1.1, see `NotoSansTamil-OFL.txt`).
