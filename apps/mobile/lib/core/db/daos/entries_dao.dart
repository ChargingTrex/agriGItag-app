// Entries DAO: save an entry with its media and outbox rows, move it through its sync states, list the latest
// versions of a lot's events, and undo within the undo window.
// Requirement: mobile-design.md §2 (Entries append-only, version chain) and §3 (ack → confirmed, other 4xx →
//   needs_attention); Arch §Offline-first "Permanent ID at creation", "Outbox queue", "Append-only facts"; FR4;
//   CLAUDE.md §6 (corrections and undo add versions).
// Callers: capture/feature screens (save, undo, latestVersions), M02 outbox_processor.dart (mark*), tests.

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

part 'entries_dao.g.dart';

/// Entry type of the row written by [EntriesDao.undo]; the server records it as `change_kind = undo`.
const undoEntryType = 'undo';

/// Saves and tracks entries. Entries are append-only: no method here changes a saved entry's facts.
@DriftAccessor(tables: [Entries, Media, Outbox])
class EntriesDao extends DatabaseAccessor<AppDatabase> with _$EntriesDaoMixin {
  /// Creates the DAO on [db]; use `db.entriesDao` instead of calling this.
  EntriesDao(super.db);

  /// Saves [entry] with its [media] in one transaction and queues them for sending.
  ///
  /// Writes the entry with status `saved`, each media row with upload status `pending`, then one outbox row for the
  /// entry (priority 0) and one per media file (priority 1), all due at `entry.createdAt`. For a correction, pass
  /// the same `rootId`, `version` + 1 and `supersedesEntryId`; the unique (rootId, version) index refuses a fork.
  /// Throws `SqliteException` when an id already exists, the version is taken or a media row names a missing entry
  /// (foreign key); nothing is written then. Side effect: the outbox pending count stream emits.
  Future<void> save(EntriesCompanion entry, List<MediaCompanion> media) {
    final due = entry.createdAt.value;
    // A Drift batch runs every insert in one transaction with a single round trip to the database.
    return batch((b) {
      b.insert(entries, entry.copyWith(status: const Value(EntryStatus.saved)));
      b.insertAll(this.media, [for (final m in media) m.copyWith(uploadStatus: const Value(UploadStatus.pending))]);
      b.insertAll(outbox, [
        _queue(OutboxKind.entry, entry.entryId.value, 0, due),
        for (final m in media) _queue(OutboxKind.media, m.mediaId.value, 1, due),
      ]);
    });
  }

  /// Marks [entryId] as sent (request out, no acknowledgement yet) and its outbox row as `sent`.
  ///
  /// Only a `saved` entry changes status. Returns when done; throws nothing for an unknown id (no rows match).
  Future<void> markSent(String entryId) => transaction(() async {
    await _setStatus(entryId, EntryStatus.sent, from: [EntryStatus.saved]);
    await _setOutbox(entryId, const OutboxCompanion(status: Value(OutboxStatus.sent)));
  });

  /// Records the server acknowledgement of [entryId]: stores [serverReceivedAt] and confirms the entry and its
  /// outbox row.
  ///
  /// An entry undone meanwhile keeps status `undone` (its undo row is queued behind it) but still gets
  /// [serverReceivedAt]. Throws nothing for an unknown id. Side effect: the pending count stream emits.
  Future<void> markConfirmed(String entryId, DateTime serverReceivedAt) => transaction(() async {
    await (update(
      entries,
    )..where((e) => e.entryId.equals(entryId))).write(EntriesCompanion(serverReceivedAt: Value(serverReceivedAt)));
    await _setStatus(entryId, EntryStatus.confirmed, from: [EntryStatus.saved, EntryStatus.sent]);
    await _setOutbox(entryId, const OutboxCompanion(status: Value(OutboxStatus.confirmed)));
  });

  /// Records a server rejection of [entryId]: status `rejected`, outbox row `needsAttention` with [error] (the
  /// server error code, e.g. `stale_version`). Entries never die; an officer resolves it. Throws nothing for an
  /// unknown id.
  Future<void> markRejected(String entryId, String error) => transaction(() async {
    await _setStatus(entryId, EntryStatus.rejected, from: [EntryStatus.saved, EntryStatus.sent]);
    await _setOutbox(
      entryId,
      OutboxCompanion(status: const Value(OutboxStatus.needsAttention), lastError: Value(error)),
    );
  });

  /// Latest version of every event on [lotId]: rows that no other row supersedes, oldest event first.
  ///
  /// A root whose latest row has `entryType == undoEntryType` was undone; callers hide or grey it.
  /// Returns an empty list for an unknown lot; throws nothing.
  Future<List<Entry>> latestVersions(String lotId) {
    final newer = alias(entries, 'newer');
    final query = select(entries)
      ..where(
        (e) =>
            e.lotId.equals(lotId) &
            notExistsQuery(select(newer)..where((n) => n.supersedesEntryId.equalsExp(e.entryId))),
      )
      // UUIDv7 ids sort by creation time, so ordering by rootId lists events in the order they were first logged.
      ..orderBy([(e) => OrderingTerm.asc(e.rootId)]);
    return query.get();
  }

  /// Undoes [entryId] at [now]: writes an `undo` version that supersedes it, queues that for sending and marks
  /// the original `undone`, in one transaction.
  ///
  /// The undo row copies the original's subject and author, has an empty payload, no location and an undo
  /// deadline of [now] (an undo cannot itself be undone). Returns the new undo entry id (UUIDv7).
  /// Throws [StateError] when the entry does not exist, is already undone or rejected, is itself an undo, has a
  /// newer version, or [now] is not before its `undoDeadline` (24 h after save); nothing is written then.
  Future<String> undo(String entryId, {required DateTime now}) => transaction(() async {
    final original = await (select(entries)..where((e) => e.entryId.equals(entryId))).getSingleOrNull();
    if (original == null) throw StateError('No entry $entryId');
    if (original.entryType == undoEntryType) throw StateError('An undo cannot be undone');
    if (original.status == EntryStatus.undone || original.status == EntryStatus.rejected) {
      throw StateError('Entry $entryId is ${original.status.name}');
    }
    if (!now.isBefore(original.undoDeadline)) throw StateError('Undo window for $entryId closed');
    final superseded = await (select(entries)..where((e) => e.supersedesEntryId.equals(entryId))).get();
    if (superseded.isNotEmpty) throw StateError('Entry $entryId has a newer version');

    final undoId = const Uuid().v7();
    await save(
      EntriesCompanion.insert(
        entryId: undoId,
        rootId: original.rootId,
        version: original.version + 1,
        supersedesEntryId: Value(entryId),
        entryType: undoEntryType,
        lotId: Value(original.lotId),
        plotId: Value(original.plotId),
        farmerId: original.farmerId,
        instanceNo: original.instanceNo,
        payloadJson: '{}',
        deviceTime: now,
        locationStatus: LocationStatus.none,
        enteredByUserId: original.enteredByUserId,
        assistMode: Value(original.assistMode),
        enteredRemotely: Value(original.enteredRemotely),
        status: EntryStatus.saved,
        undoDeadline: now,
        createdAt: now,
      ),
      const [],
    );
    await (update(
      entries,
    )..where((e) => e.entryId.equals(entryId))).write(const EntriesCompanion(status: Value(EntryStatus.undone)));
    return undoId;
  });

  /// Builds the outbox row for [refId] of [kind] at [priority], due at [due]; the idempotency key is the client id
  /// (D-005). Returns the companion; throws nothing.
  OutboxCompanion _queue(OutboxKind kind, String refId, int priority, DateTime due) => OutboxCompanion.insert(
    kind: kind,
    refId: refId,
    idempotencyKey: refId,
    priority: priority,
    nextAttemptAt: due,
    createdAt: due,
  );

  /// Sets [entryId]'s status to [to] when it is currently one of [from]. Returns when written; throws nothing.
  Future<void> _setStatus(String entryId, EntryStatus to, {required List<EntryStatus> from}) => (update(
    entries,
  )..where((e) => e.entryId.equals(entryId) & e.status.isInValues(from))).write(EntriesCompanion(status: Value(to)));

  /// Writes [change] to the entry outbox row of [entryId]. Returns when written; throws nothing.
  Future<void> _setOutbox(String entryId, OutboxCompanion change) =>
      (update(outbox)..where((o) => o.kind.equalsValue(OutboxKind.entry) & o.refId.equals(entryId))).write(change);
}
