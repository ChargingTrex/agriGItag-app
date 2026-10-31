// Tests for MediaDao: uploads wait for the entry's confirmation, and full-size files are purged only after upload.
// Requirement: mobile-design.md §3 ("push media for confirmed entries"; "delete full-size file on confirm; keep
//   ~10 KB thumbnail"); CLAUDE.md §4 "Never cut: error handling that prevents data loss".
// Callers: `flutter test test/db`.

import 'dart:io';

import 'package:agritrace/core/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'db_fixtures.dart';

void main() {
  late AppDatabase db;
  late Directory dir;
  setUp(() {
    db = memoryDb();
    dir = Directory.systemTemp.createTempSync('m01_media');
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  test('pendingUploads lists media only once the entry is confirmed', () async {
    final entry = entryAt();
    await db.entriesDao.save(entry, [photoOf(entry.entryId.value, id: 'm1')]);
    expect(await db.mediaDao.pendingUploads(3), isEmpty);
    await db.entriesDao.markConfirmed(entry.entryId.value, t0);
    expect((await db.mediaDao.pendingUploads(3)).single.mediaId, 'm1');
    await db.mediaDao.markUploaded('m1', 'evidence/fpo/2026/e/m1.jpg');
    expect(await db.mediaDao.pendingUploads(3), isEmpty);
  });

  test('purgeFullSize refuses before upload, then deletes the full file and keeps the thumbnail', () async {
    final photo = File('${dir.path}/p.jpg')..writeAsBytesSync([1, 2, 3]);
    final thumb = File('${photo.path}.thumb.jpg')..writeAsBytesSync([4]);
    final entry = entryAt();
    await db.entriesDao.save(entry, [photoOf(entry.entryId.value, id: 'm1', path: photo.path)]);

    await expectLater(db.mediaDao.purgeFullSize('m1', now: t0), throwsStateError);
    expect(photo.existsSync(), isTrue);

    await db.mediaDao.markUploaded('m1', 'key');
    await db.mediaDao.purgeFullSize('m1', now: t0);
    expect((photo.existsSync(), thumb.existsSync()), (false, true));
    expect((await db.select(db.media).getSingle()).purgedAt, isNotNull);
  });
}
