// App start-up shared by the three flavor entry points: config from --dart-define, crash hooks, runApp.
// Requirement: plan §7.2 M00 (flavors dev/staging/prod, crash reporting init placeholder), M13 (crash hooks log);
//   plan §13 D2
//   (cold start < 3 s: only local reads happen here); M06 session restore (UserFlows §Log in once); M02 sync engine
//   start and 15-min background task (mobile-design.md §3, PLAN §13 A1); M12 local reminders and the push seam (FR7,
//   UserFlows §Alerts, help and feature phones).
// Callers: lib/main_dev.dart, lib/main_staging.dart, lib/main_prod.dart.

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/sync_providers.dart';
import 'core/router/session.dart';
import 'core/sync/background_scheduler.dart';
import 'features/notifications/push.dart';
import 'features/notifications/reminders.dart';

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
/// The stored session is read before the first frame, so a signed-in user opens straight on their home screen
/// (UserFlows §Log in once); that read is local only (SQLite + keystore), any token refresh runs in the background.
/// Side effects: installs the crash hooks, binds Flutter, restores the session, runs [AgriTraceApp], then starts the
/// sync engine, registers the 15-min background sync, starts the reminders and the push registration (errors from any
/// of them reach the crash hooks). Throws [StateError] (from [AppConfig.fromEnvironment]) when a staging or prod build
/// lacks API_BASE_URL.
Future<void> bootstrap(Flavor flavor) async {
  final config = AppConfig.fromEnvironment(flavor);
  WidgetsFlutterBinding.ensureInitialized();
  initCrashReporting();
  final container = ProviderContainer(overrides: [appConfigProvider.overrideWithValue(config), ...syncOverrides]);
  await container.read(sessionProvider.notifier).restore();
  runApp(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
  // Not awaited: the first sync and the task registration must not hold up the first frame (plan §13 D2).
  unawaited(container.read(syncServiceProvider).start());
  unawaited(scheduleBackgroundSync(config));
  unawaited(startReminders(container));
  unawaited(registerPush(container));
}

/// Installs global error hooks so uncaught errors reach one place: framework errors and every uncaught async error,
/// including the unawaited futures of [bootstrap] and of the sync engine's timers and listeners (they run in the root
/// zone, so [PlatformDispatcher.onError] receives them and the app keeps running).
///
/// shortcut: errors go to the `agritrace.crash` log only (no crash vendor, no upload, so no crash-free rate yet);
/// plug a vendor (with a LIBRARIES.md row) into [_report] when one is chosen (TODO.md); nothing else needs to change.
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

/// Sends one uncaught [error] with its [stack] (may be null) to the crash sink. Returns nothing; throws nothing.
/// Side effects: one `agritrace.crash` entry in the developer log (DevTools / IDE in debug and profile builds, the Go
/// AVD perf runs included; a release build has no log reader), and a console line in debug builds. Nothing goes to
/// logcat, so nothing an exception message carries is readable on a farmer's phone.
void _report(Object error, StackTrace? stack) {
  if (kDebugMode) debugPrint('Uncaught: $error\n$stack');
  developer.log('Uncaught: $error', name: 'agritrace.crash', error: error, stackTrace: stack, level: 1000);
}
