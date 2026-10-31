// Shared fixtures for the Drift store tests: an in-memory database and entry/media companions with sane defaults.
// Requirement: WP-M01 tests (mobile-design.md §2); keeps each test focused on the behaviour it checks.
// Callers: test/db/*_test.dart, test/sync/*_test.dart.

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/router/session.dart' show Role;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

/// A fresh in-memory database. Returns it open; the caller closes it in `tearDown`. Throws nothing.
AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Fixed test clock origin (UTC) so deadlines and backoffs are deterministic.
final t0 = DateTime.utc(2026, 3, 4, 8, 12, 10);

/// A version-1 harvest entry on [lotId] saved at [at] (default [t0]) with a 24 h undo window.
///
/// [id] defaults to a new UUIDv7; [payload] defaults to a small harvest JSON. For a correction pass [rootId],
/// [version] and [supersedes]. Returns the insert companion; throws nothing.
EntriesCompanion entryAt({
  String? id,
  String lotId = 'lot-1',
  DateTime? at,
  String payload = '{"quantity":{"value":195,"unit":"kg"},"bags":13}',
  String? rootId,
  int version = 1,
  String? supersedes,
}) {
  final entryId = id ?? const Uuid().v7();
  final when = at ?? t0;
  return EntriesCompanion.insert(
    entryId: entryId,
    rootId: rootId ?? entryId,
    version: version,
    supersedesEntryId: Value(supersedes),
    entryType: 'harvest',
    lotId: Value(lotId),
    plotId: const Value('plot-1'),
    farmerId: 'farmer-1',
    instanceNo: 1,
    payloadJson: payload,
    deviceTime: when,
    locationStatus: LocationStatus.ok,
    enteredByUserId: 'user-1',
    status: EntryStatus.saved,
    undoDeadline: when.add(const Duration(hours: 24)),
    createdAt: when,
  );
}

/// A ~300 KB photo of [entryId] with id [id] (default a new UUIDv7) at [path]. Returns the companion; throws nothing.
MediaCompanion photoOf(String entryId, {String? id, String path = '/tmp/photo.jpg', int bytes = 300 * 1024}) =>
    MediaCompanion.insert(
      mediaId: id ?? const Uuid().v7(),
      entryId: entryId,
      kind: 'photo',
      localPath: path,
      bytes: bytes,
      sha256: 'ab' * 32,
      width: 1600,
      height: 1200,
      capturedAt: t0,
      uploadStatus: UploadStatus.pending,
      thumbPath: '$path.thumb.jpg',
    );

/// Signs [userId] in on [db]: writes the singleton Session row that the sync engine and the D-029 per-user counts
/// read, with [wifiOnlyPhotos] as the photo setting. Returns when written; throws nothing.
Future<void> signIn(AppDatabase db, String userId, {bool wifiOnlyPhotos = false}) => db
    .into(db.sessionTable)
    .insertOnConflictUpdate(
      SessionTableCompanion.insert(
        // `id` is the rowid: left out, SQLite would pick 2 and the CHECK (id = 1) would refuse the second sign-in.
        id: const Value(1),
        userId: userId,
        role: Role.farmer,
        fpoId: 'fpo-1',
        deviceId: '0190f0c4-0000-7000-8000-000000000001',
        accessToken: '',
        refreshToken: '',
        wifiOnlyPhotos: Value(wifiOnlyPhotos),
      ),
    );
