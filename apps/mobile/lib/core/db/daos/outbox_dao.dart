// Outbox DAO: pick the next batch to send, record attempt outcomes, recover from a killed app, and count what is
// still pending for the cloud icon.
// Requirement: mobile-design.md §3 (oldest-first entry batches ≤ 50 rows or ≤ 256 KB, backoff, needs_attention,
//   kill-safety "sending older than 5 min → waiting on start", cloud icon = count(status != confirmed));
//   Arch §Offline-first "Outbox queue", "Small first, photos second"; FR4.
// Callers: M02 outbox_processor.dart, photo_uploader.dart and sync_service.dart (start-up reset);
//   M02 lib/core/providers/sync_providers.dart (pendingCount for the M05 cloud indicator, strandedCount);
//   features/settings/settings_screen.dart (pendingCount, oldestPending: the 7-day warning, M08); tests.
// D-029 (schema v2): every query that sends or counts filters by the row's owner.

import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';

part 'outbox_dao.g.dart';

/// One entry outbox row picked by [OutboxDao.nextBatch], with the entry it sends.
typedef OutboxBatchItem = ({OutboxItem row, Entry entry});

/// Reads and updates the send queue.
@DriftAccessor(tables: [Outbox, Entries, SessionTable])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  /// Creates the DAO on [db]; use `db.outboxDao` instead of calling this.
  OutboxDao(super.db);

  /// The next entries of user [ownerUserId] to push at [now]: `waiting` entry rows in queue order (`seq`), up to
  /// but not including the first one not yet due at [now]. Other users' rows are never returned (D-029).
  ///
  /// The queue is strictly first in, first out: a row in backoff holds back every later row, because the server
  /// needs a farmer before its consent and plot, an assist session before its entries and version 1 before an undo
  /// (D-031). `needs_attention` rows are not `waiting`, so they never block.
  ///
  /// Media rows are not returned: photos go through `MediaDao.pendingUploads`, which waits for the entry's
  /// confirmation (the presigned URL comes with it). Takes at most [limit] rows and stops before the row that would
  /// push the total payload size (UTF-8 bytes) over [maxBytes]. The first row is always returned, so one oversized
  /// entry cannot block the queue. Returns an empty list when nothing is due; throws nothing.
  Future<List<OutboxBatchItem>> nextBatch({
    required String ownerUserId,
    required DateTime now,
    int limit = 50,
    int maxBytes = 256 * 1024,
  }) async {
    final query = select(outbox).join([innerJoin(entries, entries.entryId.equalsExp(outbox.refId))])
      ..where(
        outbox.kind.equalsValue(OutboxKind.entry) &
            outbox.ownerUserId.equals(ownerUserId) &
            outbox.status.equalsValue(OutboxStatus.waiting),
      )
      ..orderBy([OrderingTerm.asc(outbox.seq)])
      ..limit(limit);
    final batch = <OutboxBatchItem>[];
    var total = 0;
    for (final r in await query.get()) {
      final item = (row: r.readTable(outbox), entry: r.readTable(entries));
      if (item.row.nextAttemptAt.isAfter(now)) break;
      total += utf8.encode(item.entry.payloadJson).length;
      if (batch.isNotEmpty && total > maxBytes) break;
      batch.add(item);
    }
    return batch;
  }

  /// Marks [seqs] as `sending` at [now] and counts an attempt; [now] is kept in `nextAttemptAt` so
  /// [resetStaleSending] can find rows a killed app left behind. Returns when written; throws nothing.
  Future<void> markSending(List<int> seqs, DateTime now) => (update(outbox)..where((o) => o.seq.isIn(seqs))).write(
    OutboxCompanion.custom(
      status: Constant(OutboxStatus.sending.name),
      attempts: outbox.attempts + const Constant(1),
      nextAttemptAt: Variable(now),
    ),
  );

  /// Puts [seq] back to `waiting` after a retryable failure (network error, 5xx, 429), due at [now] + [backoff].
  ///
  /// [error] is kept as `lastError` for diagnostics. The backoff schedule (2, 4, 8 s … with jitter, capped at
  /// 5 min) is computed by the caller. Returns when written; throws nothing.
  Future<void> markWaiting(int seq, {required Duration backoff, required DateTime now, String? error}) =>
      (update(outbox)..where((o) => o.seq.equals(seq))).write(
        OutboxCompanion(
          status: const Value(OutboxStatus.waiting),
          nextAttemptAt: Value(now.add(backoff)),
          lastError: Value(error),
        ),
      );

  /// Marks media rows [seqs] as `sent`: the PUT succeeded and `/sync/photos/confirm` is still owed.
  /// Returns when written; throws nothing.
  Future<void> markSent(List<int> seqs) =>
      (update(outbox)..where((o) => o.seq.isIn(seqs))).write(const OutboxCompanion(status: Value(OutboxStatus.sent)));

  /// Marks [seqs] as `confirmed` (server acknowledged; for media rows after `/sync/photos/confirm`).
  /// Side effect: the pending count stream emits. Returns when written; throws nothing.
  Future<void> markConfirmed(List<int> seqs) => (update(outbox)..where((o) => o.seq.isIn(seqs))).write(
    const OutboxCompanion(status: Value(OutboxStatus.confirmed), lastError: Value(null)),
  );

  /// Marks [seq] as `needsAttention` with [error] after a non-retryable failure (4xx other than 429).
  /// It stays in the pending count. Returns when written; throws nothing.
  Future<void> markNeedsAttention(int seq, String error) => (update(outbox)..where((o) => o.seq.equals(seq))).write(
    OutboxCompanion(status: const Value(OutboxStatus.needsAttention), lastError: Value(error)),
  );

  /// Kill-safety on start: rows `sending` or `sent` (no acknowledgement) since before [now] − [olderThan] go back to
  /// `waiting`, due at [now]. `nextAttemptAt` still holds the attempt start written by [markSending].
  ///
  /// A send the app was killed during is retried; the server deduplicates it by its client id (D-005).
  /// Returns the number of rows reset; throws nothing.
  Future<int> resetStaleSending({required DateTime now, Duration olderThan = const Duration(minutes: 5)}) =>
      (update(outbox)..where(
            (o) =>
                o.status.isInValues([OutboxStatus.sending, OutboxStatus.sent]) &
                o.nextAttemptAt.isSmallerOrEqualValue(now.subtract(olderThan)),
          ))
          .write(OutboxCompanion(status: const Value(OutboxStatus.waiting), nextAttemptAt: Value(now)));

  /// The earliest future `nextAttemptAt` (after [now]) of user [ownerUserId]'s waiting rows: when the foreground
  /// engine should run again for a backoff. Rows already due are ignored (they were just tried, or they wait for
  /// something else, such as their entry's confirmation). Returns null when none; throws nothing.
  Future<DateTime?> nextDue({required String ownerUserId, required DateTime now}) {
    final first = outbox.nextAttemptAt.min();
    final query = selectOnly(outbox)
      ..addColumns([first])
      ..where(
        outbox.ownerUserId.equals(ownerUserId) &
            outbox.status.equalsValue(OutboxStatus.waiting) &
            outbox.nextAttemptAt.isBiggerThanValue(now),
      );
    return query.map((r) => r.read(first)).getSingle();
  }

  /// Number of the signed-in user's outbox rows not yet confirmed, re-emitted whenever the outbox or the session
  /// changes (the grey cloud icon). Emits 0 when everything is confirmed or nobody is signed in (D-029); never
  /// errors on its own.
  Stream<int> pendingCount() => _count(outbox.ownerUserId.isInQuery(_signedInUser()));

  /// When the signed-in user's oldest unconfirmed outbox row was queued, re-emitted on outbox or session changes; null
  /// when everything is confirmed or nobody is signed in. The Settings screen turns it into the 7-day "unsent"
  /// warning (mobile-design.md §3). Never errors on its own.
  Stream<DateTime?> oldestPending() {
    final first = outbox.createdAt.min();
    final query = selectOnly(outbox)
      ..addColumns([first])
      ..where(outbox.status.equalsValue(OutboxStatus.confirmed).not() & outbox.ownerUserId.isInQuery(_signedInUser()));
    return query.map((r) => r.read(first)).watchSingle();
  }

  /// Number of unconfirmed outbox rows that belong to users other than the signed-in one (all rows when signed
  /// out): entries stranded on a shared phone until their owner signs in again, for the officer notice (D-029,
  /// M10). Re-emitted on outbox or session changes; never errors on its own.
  Stream<int> strandedCount() => _count(outbox.ownerUserId.isNotInQuery(_signedInUser()));

  /// Counts unconfirmed rows matching [owner] as a stream. Returns the stream; throws nothing.
  Stream<int> _count(Expression<bool> owner) {
    final count = outbox.seq.count();
    final query = selectOnly(outbox)
      ..addColumns([count])
      ..where(outbox.status.equalsValue(OutboxStatus.confirmed).not() & owner);
    return query.map((r) => r.read(count) ?? 0).watchSingle();
  }

  /// The signed-in user's id as a subquery (empty when signed out). Returns the query; throws nothing.
  BaseSelectStatement<TypedResult> _signedInUser() => selectOnly(sessionTable)..addColumns([sessionTable.userId]);
}
