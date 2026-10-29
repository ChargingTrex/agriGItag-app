// Tests for OutboxDao: the pending-count stream, batch ordering and caps, backoff, and kill-safety reset.
// Requirement: M01 acceptance ("pendingCount stream emits on insert/confirm"); mobile-design.md §3 (oldest-first,
//   entries before media, ≤ 50 rows or ≤ 256 KB, sending older than 5 min → waiting on start).
// Callers: `flutter test test/db`.

import 'dart:async';

import 'package:agritrace/core/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'db_fixtures.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  test('pendingCount emits on insert and on confirm', () async {
    final counts = StreamIterator(db.outboxDao.pendingCount());
    Future<int> next() async {
      expect(await counts.moveNext(), isTrue);
      return counts.current;
    }

    expect(await next(), 0);
    final entry = entryAt();
    await db.entriesDao.save(entry, [photoOf(entry.entryId.value)]);
    expect(await next(), 2);
    await db.entriesDao.markConfirmed(entry.entryId.value, t0);
    expect(await next(), 1);
    final media = (await db.select(db.outbox).get()).where((o) => o.kind == OutboxKind.media);
    await db.outboxDao.markConfirmed([media.single.seq]);
    expect(await next(), 0);
    await counts.cancel();
  });

  test('nextBatch: due waiting rows only, entries before media, oldest first', () async {
    final a = entryAt(at: t0);
    final b = entryAt(at: t0.add(const Duration(seconds: 1)));
    final later = entryAt(at: t0.add(const Duration(hours: 1)));
    await db.entriesDao.save(a, [photoOf(a.entryId.value)]);
    await db.entriesDao.save(b, [photoOf(b.entryId.value)]);
    await db.entriesDao.save(later, const []);

    final batch = await db.outboxDao.nextBatch(now: t0.add(const Duration(minutes: 1)), maxBytes: 1 << 20);
    final ids = [a.entryId.value, b.entryId.value];
    expect(batch.map((i) => (i.row.kind, i.entry?.entryId ?? i.media!.entryId)), [
      (OutboxKind.entry, ids[0]),
      (OutboxKind.entry, ids[1]),
      (OutboxKind.media, ids[0]),
      (OutboxKind.media, ids[1]),
    ]);
    expect(await db.outboxDao.nextBatch(now: t0.add(const Duration(minutes: 1)), limit: 1), hasLength(1));
    // Default 256 KB cap: the two small entries fit, the first ~300 KB photo would not.
    expect(await db.outboxDao.nextBatch(now: t0.add(const Duration(minutes: 1))), hasLength(2));
  });

  test('nextBatch respects the byte cap but always returns the first row', () async {
    final big = '{"note":"${'x' * 100 * 1024}"}'; // ≈ 100 KB payload
    for (var i = 0; i < 3; i++) {
      await db.entriesDao.save(
        entryAt(
          at: t0.add(Duration(seconds: i)),
          payload: big,
        ),
        const [],
      );
    }
    expect(await db.outboxDao.nextBatch(now: t0.add(const Duration(minutes: 1))), hasLength(2)); // 256 KB cap
    expect(await db.outboxDao.nextBatch(now: t0.add(const Duration(minutes: 1)), maxBytes: 10), hasLength(1));
  });

  test('markWaiting delays a row by its backoff; markNeedsAttention takes it out of batches', () async {
    final a = entryAt();
    final b = entryAt();
    await db.entriesDao.save(a, const []);
    await db.entriesDao.save(b, const []);
    final rows = await db.select(db.outbox).get();

    await db.outboxDao.markSending([rows[0].seq], t0);
    await db.outboxDao.markWaiting(rows[0].seq, backoff: const Duration(seconds: 8), now: t0, error: 'timeout');
    await db.outboxDao.markNeedsAttention(rows[1].seq, 'validation_error');

    expect(await db.outboxDao.nextBatch(now: t0.add(const Duration(seconds: 7))), isEmpty);
    final due = await db.outboxDao.nextBatch(now: t0.add(const Duration(seconds: 8)));
    expect((due.single.row.seq, due.single.row.attempts, due.single.row.lastError), (rows[0].seq, 1, 'timeout'));
  });

  test('resetStaleSending puts rows sending for more than 5 min back to waiting', () async {
    await db.entriesDao.save(entryAt(), const []);
    final seq = (await db.select(db.outbox).getSingle()).seq;
    await db.outboxDao.markSending([seq], t0);

    expect(await db.outboxDao.resetStaleSending(now: t0.add(const Duration(minutes: 4))), 0);
    expect((await db.select(db.outbox).getSingle()).status, OutboxStatus.sending);
    expect(await db.outboxDao.resetStaleSending(now: t0.add(const Duration(minutes: 6))), 1);
    expect((await db.select(db.outbox).getSingle()).status, OutboxStatus.waiting);
  });
}
