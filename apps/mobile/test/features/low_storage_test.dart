// Tests for the low-storage rule: below 100 MB free the files of confirmed photos are deleted and unconfirmed ones
// kept; the farmer home opens the "Phone is full" sheet at app start; with room or an unknown size nothing happens.
// Requirement: PLAN §7.2 M13 ("storage < 100 MB → prompt + purge confirmed photos"); mobile-design.md §3.
// Callers: `flutter test test/features`.

import 'dart:io';

import 'package:agritrace/core/capture/free_space.dart';
import 'package:agritrace/core/db/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../db/db_fixtures.dart';
import 'harness.dart';

void main() {
  const mib = 1024 * 1024;

  group('purgeIfLow', () {
    late AppDatabase db;
    late Directory dir;
    setUp(() async {
      db = memoryDb();
      dir = Directory.systemTemp.createTempSync('m13_storage');
      final entry = entryAt();
      await db.into(db.entries).insert(entry);
      for (final (id, status) in [('confirmed', UploadStatus.done), ('waiting', UploadStatus.pending)]) {
        final path = '${dir.path}/$id.jpg';
        File(path).writeAsBytesSync([1, 2, 3]);
        File('$path.thumb.jpg').writeAsBytesSync([1]);
        await db
            .into(db.media)
            .insert(photoOf(entry.entryId.value, id: id, path: path).copyWith(uploadStatus: Value(status)));
      }
    });
    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    /// The photo files still on disk, by name.
    List<String> files() => [for (final f in dir.listSync()) f.uri.pathSegments.last]..sort();

    test('below 100 MiB: confirmed photo files deleted (full and thumbnail), unconfirmed kept, true', () async {
      final full = await purgeIfLow(freeBytes: () async => 99 * mib, db: db, now: t0);
      expect(full, isTrue);
      expect(files(), ['waiting.jpg', 'waiting.jpg.thumb.jpg']);
      final confirmed = await (db.select(db.media)..where((m) => m.mediaId.equals('confirmed'))).getSingle();
      expect(confirmed.purgedAt, t0);
    });

    test('100 MiB or more, or an unknown size: nothing deleted, false', () async {
      for (final free in [100 * mib, null]) {
        expect(await purgeIfLow(freeBytes: () async => free, db: db, now: t0), isFalse);
        expect(files(), hasLength(4));
      }
    });
  });

  testWidgets('a full phone at app start: the farmer home opens "Phone is full" with Send now', (tester) async {
    final h = FlowHarness(freeBytes: () async => 50 * mib);
    await h.start(tester);
    expect(find.text('Phone is full. Send your entries now?'), findsOneWidget);
    await tester.tap(find.text('Send now'));
    await tester.pumpAndSettle();
    expect(h.kicks, 1);
    await h.dispose(tester);
  });
}
