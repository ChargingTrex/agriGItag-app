// App start-up shared by the three flavor entry points: config from --dart-define, crash hooks, runApp.
// Requirement: plan §7.2 M00 (flavors dev/staging/prod, crash reporting init placeholder); plan §13 D2
//   (cold start < 3 s: nothing slow happens here).
// Callers: lib/main_dev.dart, lib/main_staging.dart, lib/main_prod.dart.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Build flavor, chosen by the entry point (`flutter run -t lib/main_dev.dart`).
enum Flavor {
  /// Local development against the docker stack.
  dev,

  /// Shared staging API.
  staging,

  /// Production API.
  prod,
}

/// Immutable build configuration.
@immutable
class AppConfig {
  /// Creates a config. [flavor] is the build flavor; [apiBaseUrl] the API origin without `/v1`.
  const AppConfig({required this.flavor, required this.apiBaseUrl});

  /// Reads the config for [flavor] from `--dart-define=API_BASE_URL=https://...`.
  ///
  /// dev falls back to `http://10.0.2.2:8000` (the host's docker stack as seen from the Android emulator).
  /// Returns the config. Throws [StateError] for staging and prod when API_BASE_URL is not defined, so a
  /// release can never silently talk to a developer machine.
  factory AppConfig.fromEnvironment(Flavor flavor) {
    const url = String.fromEnvironment('API_BASE_URL');
    if (url.isNotEmpty) return AppConfig(flavor: flavor, apiBaseUrl: url);
    if (flavor == Flavor.dev) return AppConfig(flavor: flavor, apiBaseUrl: 'http://10.0.2.2:8000');
    throw StateError('--dart-define=API_BASE_URL=... is required for the ${flavor.name} flavor');
  }

  /// Build flavor.
  final Flavor flavor;

  /// API origin, e.g. `https://api.example.org` (routes add `/v1/...`).
  final String apiBaseUrl;
}

/// The build configuration; overridden in [bootstrap]. Read by the API client provider from M02/M06 on.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw StateError('appConfigProvider is overridden in bootstrap()'),
);

/// Starts the app for [flavor].
///
/// Side effects: installs the crash hooks, binds Flutter and runs [AgriTraceApp]. Throws [StateError]
/// (from [AppConfig.fromEnvironment]) when a staging or prod build lacks API_BASE_URL.
void bootstrap(Flavor flavor) {
  final config = AppConfig.fromEnvironment(flavor);
  WidgetsFlutterBinding.ensureInitialized();
  initCrashReporting();
  runApp(ProviderScope(overrides: [appConfigProvider.overrideWithValue(config)], child: const AgriTraceApp()));
}

/// Installs global error hooks so uncaught errors reach one place.
///
/// shortcut: errors only go to the debug console; no crash vendor is chosen yet. M13 plugs the vendor
/// (with a LIBRARIES.md row) into [_report]; nothing else needs to change.
/// Side effects: replaces [FlutterError.onError] and [PlatformDispatcher.onError]. Throws nothing.
void initCrashReporting() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _report(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    _report(error, stack);
    return true;
  };
}

/// Sends one uncaught [error] with its [stack] (may be null) to the crash sink. Returns nothing; throws
/// nothing. Side effect: prints to the debug console.
void _report(Object error, StackTrace? stack) {
  debugPrint('Uncaught: $error\n$stack');
}
