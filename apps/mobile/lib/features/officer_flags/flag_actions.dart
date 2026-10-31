// Flags the officer clears, and what clearing one writes: "Fix it" (a correction version of the flagged entry with a
//   reason code, CLAUDE.md §6 append-only; the server's rule re-run closes the flag), "Looks fine" and "Escalate" (a
//   `flag_resolution` entry), all queued for the sync push.
// Requirement: UserFlows §Field officer flows "Clearing a flag" (open it, see what triggered it; "Looks fine", "Fix it"
//   or "Escalate to FPO admin"; a reason from a short picture list; the log keeps the reason), §When things go wrong
//   ("After 24 hours only the field officer can correct, with a reason"); FR6, FR70; B08 (`flag_resolution` push kind,
//   officers may resolve warn/info flags that are open, holds are admin-only); events schemas (a correction is the
//   next version with `change_kind=correct` and a mandatory `reason_code`); D-005, D-014, D-029.
// Callers: flags_screen.dart (list, detail, action screens), officer_home_screen.dart (flags count); tests.

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/daos/entries_dao.dart' show undoEntryType;
import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../event_log/farm_event.dart';
import '../onboarding_farmer/onboarding_notifier.dart' show assistSessionKey;

/// Entry type of an officer's flag outcome; M02 sends it as push kind `flag_resolution` with the payload as `data`.
const flagResolutionEntryType = 'flag_resolution';

/// The three outcomes of UserFlows "Clearing a flag", with the server's `resolution` value.
enum FlagAction {
  /// "Fix it": correct the entry. Its server value `fixed` is never sent: the server closes the flag itself
  /// (`rule_passed`) when the correction passes the rule.
  fix('fixed'),

  /// "Looks fine": nothing wrong; resolution `looks_fine`.
  fine('looks_fine'),

  /// "Escalate to FPO admin": resolution `escalated`.
  escalate('escalated');

  const FlagAction(this.resolution);

  /// Server `Resolution` value.
  final String resolution;

  /// The action named [name] (`fix`, `fine`, `escalate`), or null for anything else. Throws nothing.
  static FlagAction? fromName(String? name) => values.where((a) => a.name == name).firstOrNull;
}

/// One flag of the list with the farmer's name (null when the phone does not hold that farmer).
typedef OfficerFlag = ({Flag flag, String? farmerName});

/// Whether the officer may resolve [flag] (B08 `check_resolution`): open and not a hold. Holds and escalated flags are
/// the FPO admin's; the officer can still fix the entry behind them. Returns the answer; throws nothing.
bool officerMayResolve(Flag flag) => flag.status == 'open' && flag.severity != 'hold';

/// `flag_id` of a `flag_resolution` entry's payload, in SQL.
const _resolvedFlagId = CustomExpression<String>(r"json_extract(payload_json, '$.flag_id')");

/// Open and escalated flags of the officer's farmers (the mirrored Flags table), holds first, then warnings, then
/// notes, newest first within each. A flag this phone resolved is left out only while that `flag_resolution` entry
/// is unsent (saved or sent): once the server answered, the pulled flag status wins, so a flag the server reopens under
/// the same id (B08 `reopens()`) shows again (review M10-r1 P2-1). Re-emitted when flags, farmers or entries change.
final officerFlagsProvider = StreamProvider<List<OfficerFlag>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final resolved = db.selectOnly(db.entries)
    ..addColumns([_resolvedFlagId])
    ..where(
      db.entries.entryType.equals(flagResolutionEntryType) &
          db.entries.status.isInValues([EntryStatus.saved, EntryStatus.sent]),
    );
  final query = db.select(db.flags).join([leftOuterJoin(db.farmers, db.farmers.farmerId.equalsExp(db.flags.farmerId))])
    ..where(db.flags.status.isIn(['open', 'escalated']) & db.flags.flagId.isNotInQuery(resolved))
    ..orderBy([OrderingTerm.desc(db.flags.updatedAt)]);
  const rank = {'hold': 0, 'warn': 1};
  return query.watch().map(
    (rows) =>
        [for (final r in rows) (flag: r.readTable(db.flags), farmerName: r.readTableOrNull(db.farmers)?.name)]
          ..sort((a, b) => (rank[a.flag.severity] ?? 2).compareTo(rank[b.flag.severity] ?? 2)),
  );
});

/// The latest version of the farm event [rootId] on this phone (Flags.entryId is the server event id, which is the
/// phone's root id, D-005), or null when the phone does not hold it, it was undone or rejected, or it is not a farm
/// event. Throws nothing beyond database errors.
final flaggedEntryProvider = FutureProvider.autoDispose.family<Entry?, String>((ref, rootId) async {
  final db = ref.watch(appDatabaseProvider);
  final latest =
      await (db.select(db.entries)
            ..where((e) => e.rootId.equals(rootId))
            ..orderBy([(e) => OrderingTerm.desc(e.version)])
            ..limit(1))
          .getSingleOrNull();
  final usable =
      latest != null &&
      latest.entryType != undoEntryType &&
      FarmEvent.fromWire(latest.entryType) != null &&
      latest.status != EntryStatus.undone &&
      latest.status != EntryStatus.rejected;
  return usable ? latest : null;
});

/// Writes the officer's [action] on [flag] with [reasonCode], at [now], in one transaction, and queues it.
///
/// [FlagAction.fix] writes a correction of [entry] (the flagged event's latest version): version + 1 superseding it,
/// the same event type, lot, plot, farmer and instance, `reasonCode`, and the payload with [bags] (harvest and
/// packing: kg = bags × [kBagKg]) when given; the officer is the author and assist mode is off (an officer correction
/// is the officer's own act, FR6), and nothing else: the server's rule re-run closes the flag as `rule_passed` only if
/// the correction cures it, and reopens it if the rule fires again. "Looks fine" and "Escalate", when
/// [officerMayResolve], queue a `flag_resolution` entry `{flag_id, resolution, reason_code}`. Returns when written.
/// Throws [StateError] when nobody is signed in, or [action] is fix without [entry]; `SqliteException` when the write
/// fails (nothing is written then, e.g. the version was taken). Side effects: Entries and Outbox rows.
Future<void> saveFlagAction(
  AppDatabase db, {
  required Flag flag,
  required FlagAction action,
  required String reasonCode,
  required DateTime now,
  Entry? entry,
  int? bags,
}) async {
  final officer = await db.sessionDao.read() ?? (throw StateError('signed out'));
  if (action == FlagAction.fix && entry == null) throw StateError('nothing to fix');
  await db.transaction(() async {
    // No resolution with a fix: a flag closed as `fixed` stays closed even when the correction still breaks the rule
    // (B08 `reopens()` only reopens `rule_passed` or a worse severity), e.g. 1,250 → 1,240 kg/acre over 1,200.
    if (action != FlagAction.fix && officerMayResolve(flag)) {
      final id = const Uuid().v7();
      await db.entriesDao.save(
        EntriesCompanion.insert(
          entryId: id,
          rootId: id,
          version: 1,
          entryType: flagResolutionEntryType,
          farmerId: flag.farmerId,
          instanceNo: 1,
          payloadJson: jsonEncode({'flag_id': flag.flagId, 'resolution': action.resolution, 'reason_code': reasonCode}),
          deviceTime: now,
          locationStatus: LocationStatus.none,
          enteredByUserId: officer.userId,
          status: EntryStatus.saved,
          undoDeadline: now,
          createdAt: now,
        ),
        const [],
      );
    }
    if (entry != null && action == FlagAction.fix) {
      final payload = (jsonDecode(entry.payloadJson) as Map).cast<String, Object?>()
        // An officer correction is not made in assist mode, even when the original was.
        ..remove(assistSessionKey)
        // Keep the event's day: without it the push would take the correction's device time as `occurred_on`.
        ..putIfAbsent('occurred_on', () => entry.deviceTime.toLocal().toIso8601String().substring(0, 10));
      if (bags != null) {
        payload['bags'] = bags;
        payload['quantity'] = {'value': bags * kBagKg, 'unit': 'kg'};
      }
      final id = const Uuid().v7();
      await db.entriesDao.save(
        EntriesCompanion.insert(
          entryId: id,
          rootId: entry.rootId,
          version: entry.version + 1,
          supersedesEntryId: Value(entry.entryId),
          entryType: entry.entryType,
          lotId: Value(entry.lotId),
          plotId: Value(entry.plotId),
          farmerId: entry.farmerId,
          instanceNo: entry.instanceNo,
          payloadJson: jsonEncode(payload),
          deviceTime: now,
          // The correction changes what was recorded, not where: the field fix stays the evidence (FR69 still
          // checks it). Its GPS time is dropped so the clock-skew rule does not compare it with today's clock.
          lat: Value(entry.lat),
          lng: Value(entry.lng),
          accuracyM: Value(entry.accuracyM),
          locationStatus: entry.locationStatus,
          enteredByUserId: officer.userId,
          reasonCode: Value(reasonCode),
          status: EntryStatus.saved,
          // Only the farmer may undo, and only their own entry: an officer correction has no undo window.
          undoDeadline: now,
          createdAt: now,
        ),
        const [],
      );
    }
  });
}
