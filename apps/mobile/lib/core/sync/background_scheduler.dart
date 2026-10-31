// Background sync: a periodic task every 15 min (Android WorkManager; iOS BGAppRefresh, best effort, when iOS
// decides) that runs one sync in a background isolate.
// Requirement: PLAN §13 A1 (15-min fallback); mobile-design.md §3 ("WorkManager 15 min (Android), BGAppRefresh
//   (iOS, best effort)"); Arch §Offline-first "When it syncs"; FR4.
// Callers: lib/bootstrap.dart calls scheduleBackgroundSync once after start-up; the OS calls
//   syncCallbackDispatcher; test/sync/background_test.dart (M13 proof of the registration and the run). iOS needs `in.agritrace.sync` in BGTaskSchedulerPermittedIdentifiers
//   (ios/Runner/Info.plist).

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:workmanager/workmanager.dart';

import '../../bootstrap.dart' show AppConfig, Flavor, appConfigProvider;
import '../providers/sync_providers.dart';
import '../router/session.dart' show sessionProvider;

/// Unique name of the periodic sync task; also the iOS BGTaskScheduler identifier.
const syncTaskName = 'in.agritrace.sync';

/// Registers the periodic sync for [config]. Re-registration keeps the timing but refreshes the input, so an app
/// update with a new API URL reaches the background task.
///
/// Android runs it every 15 min (WorkManager's minimum) when a network is connected; iOS treats the period as a hint.
/// [workmanager] defaults to the plugin; tests pass a recording fake. Returns when registered. Throws
/// [PlatformException] when the plugin is missing. Side effect: an OS-scheduled task that survives app restarts.
Future<void> scheduleBackgroundSync(AppConfig config, {Workmanager? workmanager}) async {
  final wm = workmanager ?? Workmanager();
  await wm.initialize(syncCallbackDispatcher);
  await wm.registerPeriodicTask(
    syncTaskName,
    syncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    inputData: {'flavor': config.flavor.name, 'apiBaseUrl': config.apiBaseUrl},
  );
}

/// Entry point of the background isolate: hands every OS wake-up to [runBackgroundSync].
///
/// Throws nothing. Side effect: registers the task handler with the plugin.
@pragma('vm:entry-point')
void syncCallbackDispatcher() => Workmanager().executeTask((task, input) => runBackgroundSync(input!));

/// One background run: builds the providers for the flavor in [input] (the task's `inputData`: `flavor`,
/// `apiBaseUrl`), restores the session (tokens from the keystore), makes a killed run safe and runs one sync.
///
/// [overrides] are extra provider overrides (tests replace the database, keystore and engine). Returns true on
/// success, false on any error, so WorkManager applies its own backoff; throws nothing. Side effects: a whole sync
/// run; the database is shared with the foreground isolate (drift_flutter `shareAcrossIsolates`).
Future<bool> runBackgroundSync(Map<String, dynamic> input, {List<Override> overrides = const []}) async {
  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(
        AppConfig(flavor: Flavor.values.byName(input['flavor'] as String), apiBaseUrl: input['apiBaseUrl'] as String),
      ),
      ...overrides,
    ],
  );
  try {
    // Loads the tokens from the keystore into this isolate's session, as bootstrap does in the foreground.
    await container.read(sessionProvider.notifier).restore();
    final sync = container.read(syncServiceProvider);
    await sync.resetAfterKill();
    await sync.runOnce();
    return true;
  } catch (_) {
    return false;
  } finally {
    container.dispose();
  }
}
