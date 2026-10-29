// Entry point of the dev flavor: `flutter run -t lib/main_dev.dart [--dart-define=API_BASE_URL=...]`.
// Requirement: plan §7.2 M00 (flavors dev/staging/prod). Callers: the Flutter tool.

import 'bootstrap.dart';

/// Starts the app in the dev flavor. Side effects: see [bootstrap]. Throws nothing for dev.
void main() => bootstrap(Flavor.dev);
