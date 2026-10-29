// Tests for EntriesDao: bulk save speed, the version chain, undo inside and outside the 24 h window, and the
// append-only guard.
// Requirement: M01 acceptance ("500 entries + 500 media insert < 2 s", "version-chain query returns latest");
//   mobile-design.md §2; CLAUDE.md §6 (append-only farm events).
// Callers: `flutter test test/db`.

import 'package:agritrace/core/db/daos/entries_dao.dart';
import 'package:agritrace/core/db/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'db_fixtures.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  test('500 entries + 500 media save in under 2 s (host)', () async {
    Future<void> saveMany(int n, int from) async {
      for (var i = from; i < from + n; i++) {
        final entry = entryAt(at: t0.add(Duration(seconds: i)));
        await db.entriesDao.save(entry, [photoOf(entry.entryId.value)]);
      }
    }

    // Warm-up outside the timing: the test VM JIT-compiles Drift on first use; the release app is AOT-compiled.
    await saveMany(20, 0);
    final watch = Stopwatch()..start();
    await saveMany(500, 20);
    watch.stop();
    // Host figure only; the Go-emulator figure is recorded by Q01.
    // ignore: avoid_print
    print('M01 perf: 500 saves (500 entries + 500 media + 1000 outbox rows) in ${watch.elapsedMilliseconds} ms');
    expect(await db.select(db.entries).get(), hasLength(520));
    expect(await db.select(db.media).get(), hasLength(520));
    expect(await db.select(db.outbox).get(), hasLength(1040));
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test('save writes status saved, media pending, and outbox rows entry first then media', () async {
    final entry = entryAt().copyWith(status: const Value(EntryStatus.confirmed));
    await db.entriesDao.save(entry, [photoOf(entry.entryId.value)]);
    final saved = await db.select(db.entries).getSingle();
    expect(saved.status, EntryStatus.saved);
    expect((await db.select(db.media).getSingle()).uploadStatus, UploadStatus.pending);
    final rows = await (db.select(db.outbox)..orderBy([(o) => OrderingTerm.asc(o.seq)])).get();
    expect(rows.map((r) => (r.kind, r.priority, r.status)), [
      (OutboxKind.entry, 0, OutboxStatus.waiting),
      (OutboxKind.media, 1, OutboxStatus.waiting),
    ]);
    expect(rows.first.idempotencyKey, saved.entryId);
  });

  test('a failed save writes nothing (transaction)', () async {
    final entry = entryAt();
    await db.entriesDao.save(entry, const []);
    final again = entryAt(id: 'other');
    // The media points at an entry id that does not exist: the foreign key fails after the entry insert.
    await expectLater(db.entriesDao.save(again, [photoOf('missing')]), throwsA(isA<SqliteException>()));
    expect(await db.select(db.entries).get(), hasLength(1));
    expect(await db.select(db.outbox).get(), hasLength(1));
  });

  test('latestVersions returns the latest non-superseded row per event', () async {
    final first = entryAt();
    await db.entriesDao.save(first, const []);
    final firstId = first.entryId.value;
    final correction = entryAt(rootId: firstId, version: 2, supersedes: firstId, payload: '{"bags":14}');
    await db.entriesDao.save(correction, const []);
    final other = entryAt();
    await db.entriesDao.save(other, const []);
    await db.entriesDao.save(entryAt(lotId: 'lot-2'), const []);

    final latest = await db.entriesDao.latestVersions('lot-1');
    expect(latest.map((e) => e.entryId), [correction.entryId.value, other.entryId.value]);
    expect(latest.first.payloadJson, '{"bags":14}');
  });

  test('a second version 2 of the same event is refused (no forks)', () async {
    final first = entryAt();
    await db.entriesDao.save(first, const []);
    final id = first.entryId.value;
    await db.entriesDao.save(entryAt(rootId: id, version: 2, supersedes: id), const []);
    await expectLater(
      db.entriesDao.save(entryAt(rootId: id, version: 2, supersedes: id), const []),
      throwsA(isA<SqliteException>()),
    );
  });

  test('undo before the 24 h deadline writes an undo version and marks the original undone', () async {
    final entry = entryAt();
    await db.entriesDao.save(entry, const []);
    final id = entry.entryId.value;

    final undoId = await db.entriesDao.undo(id, now: t0.add(const Duration(hours: 23, minutes: 59)));

    final original = await (db.select(db.entries)..where((e) => e.entryId.equals(id))).getSingle();
    expect(original.status, EntryStatus.undone);
    final undo = await (db.select(db.entries)..where((e) => e.entryId.equals(undoId))).getSingle();
    expect((undo.entryType, undo.rootId, undo.version, undo.supersedesEntryId), (undoEntryType, id, 2, id));
    expect(await db.select(db.outbox).get(), hasLength(2));
    expect((await db.entriesDao.latestVersions('lot-1')).single.entryId, undoId);
    await expectLater(db.entriesDao.undo(undoId, now: t0), throwsStateError);
  });

  test('undo at or after the deadline throws and writes nothing', () async {
    final entry = entryAt();
    await db.entriesDao.save(entry, const []);
    final id = entry.entryId.value;

    await expectLater(db.entriesDao.undo(id, now: t0.add(const Duration(hours: 24))), throwsStateError);
    await expectLater(db.entriesDao.undo('missing', now: t0), throwsStateError);
    expect((await db.select(db.entries).getSingle()).status, EntryStatus.saved);
    expect(await db.select(db.outbox).get(), hasLength(1));
  });

  test('status moves saved → sent → confirmed and confirm keeps undone', () async {
    final entry = entryAt();
    await db.entriesDao.save(entry, const []);
    final id = entry.entryId.value;
    Future<Entry> row() => (db.select(db.entries)..where((e) => e.entryId.equals(id))).getSingle();

    await db.entriesDao.markSent(id);
    expect((await row()).status, EntryStatus.sent);
    await db.entriesDao.undo(id, now: t0);
    final ack = t0.add(const Duration(seconds: 3));
    await db.entriesDao.markConfirmed(id, ack);
    expect((await row()).status, EntryStatus.undone);
    expect((await row()).serverReceivedAt!.isAtSameMomentAs(ack), isTrue);
  });

  test('markRejected sets rejected and puts the outbox row in needsAttention with the error', () async {
    final entry = entryAt();
    await db.entriesDao.save(entry, const []);
    await db.entriesDao.markRejected(entry.entryId.value, 'stale_version');
    expect((await db.select(db.entries).getSingle()).status, EntryStatus.rejected);
    final row = await db.select(db.outbox).getSingle();
    expect((row.status, row.lastError), (OutboxStatus.needsAttention, 'stale_version'));
  });

  test('append-only guard: updating a saved payload or deleting an entry throws', () async {
    final entry = entryAt();
    await db.entriesDao.save(entry, const []);
    final byId = db.update(db.entries)..where((e) => e.entryId.equals(entry.entryId.value));

    await expectLater(
      byId.write(const EntriesCompanion(payloadJson: Value('{"bags":99}'))),
      throwsA(isA<SqliteException>().having((e) => e.message, 'message', contains('append-only'))),
    );
    await expectLater(db.delete(db.entries).go(), throwsA(isA<SqliteException>()));
    expect((await db.select(db.entries).getSingle()).payloadJson, entry.payloadJson.value);
  });
}
