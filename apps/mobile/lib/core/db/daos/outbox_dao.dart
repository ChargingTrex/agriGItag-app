// Outbox DAO: pick the next batch to send, record attempt outcomes, recover from a killed app, and count what is
// still pending for the cloud icon.
// Requirement: mobile-design.md §3 (oldest-first entry batches ≤ 50 rows or ≤ 256 KB, backoff, needs_attention,
//   kill-safety "sending older than 5 min → waiting on start", cloud icon = count(status != confirmed));
//   Arch §Offline-first "Outbox queue", "Small first, photos second"; FR4.
// Callers: M02 outbox_processor.dart, photo_uploader.dart and sync_service.dart (start-up reset);
//   M05 cloud_sync_indicator (pendingCount); tests.

import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';

part 'outbox_dao.g.dart';

/// One entry outbox row picked by [OutboxDao.nextBatch], with the entry it sends.
typedef OutboxBatchItem = ({OutboxItem row, Entry entry});

/// Reads and updates the send queue.
@DriftAccessor(tables: [Outbox, Entries])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  /// Creates the DAO on [db]; use `db.outboxDao` instead of calling this.
  OutboxDao(super.db);

  /// The next entries to push at [now]: `waiting` entry rows due at or before [now], oldest first.
  ///
  /// Media rows are not returned: photos go through `MediaDao.pendingUploads`, which waits for the entry's
  /// confirmation (the presigned URL comes with it). Takes at most [limit] rows and stops before the row that would
  /// push the total payload size (UTF-8 bytes) over [maxBytes]. The first row is always returned, so one oversized
  /// entry cannot block the queue. Returns an empty list when nothing is due; throws nothing.
  Future<List<OutboxBatchItem>> nextBatch({required DateTime now, int limit = 50, int maxBytes = 256 * 1024}) async {
    final query = select(outbox).join([innerJoin(entries, entries.entryId.equalsExp(outbox.refId))])
      ..where(
        outbox.kind.equalsValue(OutboxKind.entry) &
            outbox.status.equalsValue(OutboxStatus.waiting) &
            outbox.nextAttemptAt.isSmallerOrEqualValue(now),
      )
      ..orderBy([OrderingTerm.asc(outbox.seq)])
      ..limit(limit);
    final batch = <OutboxBatchItem>[];
    var total = 0;
    for (final r in await query.get()) {
      final item = (row: r.readTable(outbox), entry: r.readTable(entries));
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

  /// Number of outbox rows not yet confirmed, re-emitted whenever the outbox changes (the grey cloud icon).
  /// Emits 0 when everything is confirmed; never errors on its own.
  Stream<int> pendingCount() {
    final count = outbox.seq.count();
    final query = selectOnly(outbox)
      ..addColumns([count])
      ..where(outbox.status.equalsValue(OutboxStatus.confirmed).not());
    return query.map((r) => r.read(count) ?? 0).watchSingle();
  }
}
