// Proof of the 15-min background sync without a device: the task registered at start-up has the right name, period,
// network constraint, update policy and input, and an OS wake-up restores the session and runs exactly one sync.
// Requirement: PLAN §7.2 M13 ("WorkManager 15-min job fires": the registration half; the firing itself is the Q01
//   device check `adb shell cmd jobscheduler run -f in.agritrace.agritrace <job id>`); PLAN §13 A1;
//   mobile-design.md §3.
// Callers: `flutter test test/sync`.

import 'package:agritrace/bootstrap.dart';
import 'package:agritrace/core/db/providers.dart';
import 'package:agritrace/core/providers/sync_providers.dart';
import 'package:agritrace/core/sync/background_scheduler.dart';
import 'package:agritrace/core/sync/sync_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workmanager/workmanager.dart';

import '../db/db_fixtures.dart';

/// Records every call made to the plugin instead of reaching the platform.
class _RecordingWorkmanager implements Workmanager {
  /// Every call, in order.
  final calls = <Invocation>[];

  /// Records [invocation]. Returns a completed future (every recorded method is async); throws nothing.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    calls.add(invocation);
    return Future<void>.value();
  }
}

/// A sync engine that only records what the background run asks of it; [fail] makes [runOnce] throw.
class _RecordingSync implements SyncService {
  /// Creates the fake; [fail] true makes [runOnce] throw a [StateError].
  _RecordingSync({this.fail = false});

  /// When true, [runOnce] throws.
  final bool fail;

  /// Names of the calls, in order.
  final calls = <String>[];

  /// Records the kill-safety reset. Returns when recorded; throws nothing.
  @override
  Future<void> resetAfterKill() async => calls.add('resetAfterKill');

  /// Records one run. Returns when recorded; throws [StateError] when [fail].
  @override
  Future<void> runOnce() async {
    calls.add('runOnce');
    if (fail) throw StateError('offline');
  }

  /// Any other member is not used by the background run. Throws [NoSuchMethodError].
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('start-up registers one periodic sync: 15 min, network connected, update policy, flavor input', () async {
    final wm = _RecordingWorkmanager();
    await scheduleBackgroundSync(
      const AppConfig(flavor: Flavor.prod, apiBaseUrl: 'https://api.example.org'),
      workmanager: wm,
    );

    expect(wm.calls.map((c) => c.memberName), [#initialize, #registerPeriodicTask]);
    expect(wm.calls.first.positionalArguments, [syncCallbackDispatcher]);
    final register = wm.calls.last;
    expect(register.positionalArguments, [syncTaskName, syncTaskName]);
    expect(register.namedArguments[#frequency], const Duration(minutes: 15));
    expect(register.namedArguments[#constraints], Constraints(networkType: NetworkType.connected));
    expect(register.namedArguments[#existingWorkPolicy], ExistingPeriodicWorkPolicy.update);
    expect(register.namedArguments[#inputData], {'flavor': 'prod', 'apiBaseUrl': 'https://api.example.org'});
  });

  test('an OS wake-up resets killed rows, then calls runOnce once, and reports the outcome to WorkManager', () async {
    for (final fail in [false, true]) {
      FlutterSecureStorage.setMockInitialValues({});
      final sync = _RecordingSync(fail: fail);
      final ok = await runBackgroundSync(
        {'flavor': 'dev', 'apiBaseUrl': 'http://api.test'},
        overrides: [appDatabaseProvider.overrideWithValue(memoryDb()), syncServiceProvider.overrideWithValue(sync)],
      );
      expect(sync.calls, ['resetAfterKill', 'runOnce']);
      expect(ok, !fail, reason: 'a failed run returns false so WorkManager backs off');
    }
  });
}
