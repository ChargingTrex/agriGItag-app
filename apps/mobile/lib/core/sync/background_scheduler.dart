// Background sync: a periodic task every 15 min (Android WorkManager; iOS BGAppRefresh, best effort, when iOS
// decides) that runs one sync in a background isolate.
// Requirement: PLAN §13 A1 (15-min fallback); mobile-design.md §3 ("WorkManager 15 min (Android), BGAppRefresh
//   (iOS, best effort)"); Arch §Offline-first "When it syncs"; FR4.
// Callers: lib/bootstrap.dart calls scheduleBackgroundSync once after start-up (wired at the M06 merge); the OS calls
//   syncCallbackDispatcher. iOS needs `in.agritrace.sync` in BGTaskSchedulerPermittedIdentifiers
//   (ios/Runner/Info.plist).

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../../bootstrap.dart' show AppConfig, Flavor, appConfigProvider;
import '../providers/sync_providers.dart';
import '../router/session.dart' show sessionProvider;

/// Unique name of the periodic sync task; also the iOS BGTaskScheduler identifier.
const syncTaskName = 'in.agritrace.sync';

/// Registers the periodic sync for [config] (kept on re-registration, so app restarts do not reset the period).
///
/// Android runs it every 15 min (WorkManager's minimum) when a network is connected; iOS treats the period as a hint.
/// Returns when registered. Throws [PlatformException] when the plugin is missing (tests do not call this).
/// Side effect: an OS-scheduled task that survives app restarts.
Future<void> scheduleBackgroundSync(AppConfig config) async {
  await Workmanager().initialize(syncCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    syncTaskName,
    syncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    inputData: {'flavor': config.flavor.name, 'apiBaseUrl': config.apiBaseUrl},
  );
}

/// Entry point of the background isolate: builds the providers for the flavor the task was registered with, restores
/// the session (tokens from the keystore), makes a killed run safe, runs one sync and reports success to the OS.
///
/// Throws nothing (a failed run returns false, so WorkManager applies its own backoff). Side effects: a whole sync
/// run; the database is shared with the foreground isolate (drift_flutter `shareAcrossIsolates`).
@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig(
            flavor: Flavor.values.byName(input!['flavor'] as String),
            apiBaseUrl: input['apiBaseUrl'] as String,
          ),
        ),
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
  });
}
