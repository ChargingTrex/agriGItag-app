// Entry point of the prod flavor: `flutter build appbundle -t lib/main_prod.dart --dart-define=API_BASE_URL=...`.
// Requirement: plan §7.2 M00 (flavors dev/staging/prod). Callers: the Flutter tool, tool/size_check.sh.

import 'bootstrap.dart';

/// Starts the app in the prod flavor. Side effects: see [bootstrap].
/// Throws [StateError] when API_BASE_URL is not defined.
void main() => bootstrap(Flavor.prod);
