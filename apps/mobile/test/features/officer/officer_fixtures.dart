// Shared seed data for the M10 officer tests: the M07 farm (farmer-1 Murugan, plot-1, lot-1, history) plus a farmer
//   without a phone, a harvest task due today, four flags (warn on the seeded harvest, hold, warn without a local entry,
//   one already cleared) and two moisture meters (one calibrated to 1 Mar, one that ran out on 10 Feb).
// Requirement: plan §7.2 M10 tests (widget tests per screen state, scripted assist flow, goldens, accessibility sweep).
// Callers: test/features/officer/*_test.dart.

import 'dart:convert';

import 'package:agritrace/core/db/database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

import '../harness.dart';

/// Flag ids seeded by [seedOfficer].
const warnFlag = 'flag-warn', holdFlag = 'flag-hold', remoteFlag = 'flag-remote', clearedFlag = 'flag-cleared';

/// Meter ids seeded by [seedOfficer]: in date (to 1 Mar 2026) and past due (10 Feb 2026, the clock is 14 Feb).
const goodMeter = 'meter-good', expiredMeter = 'meter-old';

/// Signs in a field officer on [h], seeds the farm and [seedOfficer], and opens [location] (default the officer home).
/// [tester] runs the app. Returns when settled; throws what the app throws.
Future<void> startOfficer(WidgetTester tester, FlowHarness h, {String location = '/officer'}) async {
  await h.seedOfficerData();
  await h.start(tester, role: 'field_officer', location: location);
}

/// Officer seed data on top of [FlowHarness.seedFarm].
extension OfficerSeed on FlowHarness {
  /// Writes the second farmer, the task, the flags and the meters. [start] seeds the farm afterwards, so the flags'
  /// entry is looked up lazily. Returns when written; throws nothing.
  Future<void> seedOfficerData() async {
    await db
        .into(db.farmers)
        .insert(
          FarmersCompanion.insert(
            farmerId: 'farmer-2',
            fpoId: 'fpo-1',
            name: 'Selvi',
            village: 'Aruppukottai',
            hasSmartphone: false,
            language: 'ta',
            status: 'active',
            json: '{}',
          ),
        );
    await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            taskId: 'task-1',
            farmerId: 'farmer-1',
            lotId: const Value('lot-1'),
            eventType: 'harvest',
            dueDate: flowNow,
            promptId: 'taskHarvest',
            source: 'schedule',
          ),
        );
    for (final (id, due) in [(goodMeter, DateTime(2026, 3, 1)), (expiredMeter, DateTime(2026, 2, 10))]) {
      await db
          .into(db.instruments)
          .insert(
            InstrumentsCompanion.insert(
              instrumentId: id,
              kind: 'moisture_meter',
              label: id == goodMeter ? 'Wile 55' : 'Old meter',
              calibrationDueDate: due,
            ),
          );
    }
  }

  /// Seeds the flags; call after [FlowHarness.start] so the seeded harvest exists. The warn flag names the harvest's
  /// root id (`Flags.entryId` is the server event id). Returns the harvest entry; throws when it is missing.
  Future<Entry> seedFlags() async {
    final harvest = (await (db.select(db.entries)..where((e) => e.entryType.equals('harvest'))).get()).single;
    for (final (id, type, severity, status, entry) in [
      (warnFlag, 'yield_over_ceiling', 'warn', 'open', harvest.rootId),
      (holdFlag, 'plot_outside_gi_region', 'hold', 'open', harvest.rootId),
      (remoteFlag, 'event_off_plot', 'warn', 'open', 'not-on-this-phone'),
      (clearedFlag, 'gps_poor_accuracy', 'info', 'cleared', null),
    ]) {
      await db
          .into(db.flags)
          .insert(
            FlagsCompanion.insert(
              flagId: id,
              farmerId: 'farmer-1',
              entryId: Value(entry),
              type: type,
              severity: severity,
              status: status,
              detailJson: jsonEncode({
                'harvested': {'value': 650, 'unit': 'kg'},
                'ceiling': {'value': 500, 'unit': 'kg'},
              }),
              updatedAt: flowNow,
            ),
          );
    }
    return harvest;
  }
}

/// Entries of [type] written by the officer in the test (any device time), in outbox order. Throws nothing.
Future<List<Entry>> queued(FlowHarness h, String type) async {
  final rows = await (h.db.select(h.db.outbox)..orderBy([(o) => OrderingTerm.asc(o.seq)])).get();
  final out = <Entry>[];
  for (final o in rows) {
    final e = await (h.db.select(h.db.entries)..where((e) => e.entryId.equals(o.refId))).getSingleOrNull();
    if (e != null && e.entryType == type && e.createdAt == flowNow) out.add(e);
  }
  return out;
}

/// Entry types queued in the test, in outbox order (media rows and the seeded history left out). Throws nothing.
Future<List<String>> queuedTypes(FlowHarness h) async {
  final rows = await (h.db.select(h.db.outbox)..orderBy([(o) => OrderingTerm.asc(o.seq)])).get();
  final out = <String>[];
  for (final o in rows) {
    final e = await (h.db.select(h.db.entries)..where((e) => e.entryId.equals(o.refId))).getSingleOrNull();
    if (e != null && e.createdAt == flowNow) out.add(e.entryType);
  }
  return out;
}

/// The payload of [e] as a map. Throws a [FormatException] for a broken payload.
Map<String, Object?> payloadOf(Entry e) => (jsonDecode(e.payloadJson) as Map).cast<String, Object?>();
