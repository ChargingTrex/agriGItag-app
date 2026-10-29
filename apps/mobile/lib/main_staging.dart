// Entry point of the staging flavor: `flutter build apk -t lib/main_staging.dart --dart-define=API_BASE_URL=...`.
// Requirement: plan §7.2 M00 (flavors dev/staging/prod). Callers: the Flutter tool.

import 'bootstrap.dart';

/// Starts the app in the staging flavor. Side effects: see [bootstrap].
/// Throws [StateError] when API_BASE_URL is not defined.
void main() => bootstrap(Flavor.staging);
