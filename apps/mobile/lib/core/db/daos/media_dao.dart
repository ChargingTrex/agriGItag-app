// Media DAO: list photos ready to upload, record an upload, and free phone storage once a photo is safe on the server.
// Requirement: mobile-design.md §3 ("push media for confirmed entries"; "delete full-size file on confirm; keep
//   ~10 KB thumbnail"; "Phone is full" purge); Arch §Offline-first "Small first, photos second", "Photos made light".
// Callers: M02 photo_uploader.dart (pendingUploads, awaitingConfirm, setUploadState, markUploaded, purgeFullSize),
//   M02 pull_service.dart (setUploadState for `photo_pending`), M13 core/capture/free_space.dart (purgeConfirmed).

import 'dart:io';

import 'package:drift/drift.dart';

import '../database.dart';

part 'media_dao.g.dart';

/// One media row with the outbox row that sends it.
typedef MediaUpload = ({OutboxItem row, MediaFile media});

/// Reads and updates media rows.
@DriftAccessor(tables: [Media, Entries, Outbox])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  /// Creates the DAO on [db]; use `db.mediaDao` instead of calling this.
  MediaDao(super.db);

  /// Up to [limit] media rows of user [ownerUserId] still to upload at [now], oldest first: the outbox row is
  /// `waiting` and due, the file is not uploaded or purged, and the server has confirmed the entry, so an upload
  /// URL can exist (D-029: other users' media are never returned). A row the app was killed during (`uploading`,
  /// outbox reset by `resetStaleSending`) is returned again. Returns an empty list when none; throws nothing.
  Future<List<MediaUpload>> pendingUploads({required String ownerUserId, required DateTime now, int limit = 50}) {
    final query =
        select(media).join([
            innerJoin(entries, entries.entryId.equalsExp(media.entryId)),
            innerJoin(outbox, outbox.refId.equalsExp(media.mediaId) & outbox.kind.equalsValue(OutboxKind.media)),
          ])
          ..where(
            outbox.ownerUserId.equals(ownerUserId) &
                outbox.status.equalsValue(OutboxStatus.waiting) &
                outbox.nextAttemptAt.isSmallerOrEqualValue(now) &
                media.uploadStatus.equalsValue(UploadStatus.done).not() &
                media.purgedAt.isNull() &
                entries.serverReceivedAt.isNotNull(),
          )
          ..orderBy([OrderingTerm.asc(outbox.seq)])
          ..limit(limit);
    return query.map((r) => (row: r.readTable(outbox), media: r.readTable(media))).get();
  }

  /// Media rows of user [ownerUserId] whose PUT succeeded but whose `/sync/photos/confirm` is still owed (outbox
  /// `sent`), oldest first. Returns an empty list when none; throws nothing.
  Future<List<MediaUpload>> awaitingConfirm(String ownerUserId) {
    final query =
        select(
            media,
          ).join([innerJoin(outbox, outbox.refId.equalsExp(media.mediaId) & outbox.kind.equalsValue(OutboxKind.media))])
          ..where(outbox.ownerUserId.equals(ownerUserId) & outbox.status.equalsValue(OutboxStatus.sent))
          ..orderBy([OrderingTerm.asc(outbox.seq)]);
    return query.map((r) => (row: r.readTable(outbox), media: r.readTable(media))).get();
  }

  /// Writes [change] (upload URL and expiry, upload status) to [mediaId]. Returns when written; throws nothing for
  /// an unknown id.
  Future<void> setUploadState(String mediaId, MediaCompanion change) =>
      (update(media)..where((m) => m.mediaId.equals(mediaId))).write(change);

  /// Records that [mediaId] was uploaded to [objectKey]: upload status `done`. Returns when written; throws nothing
  /// for an unknown id.
  Future<void> markUploaded(String mediaId, String objectKey) =>
      (update(media)..where((m) => m.mediaId.equals(mediaId))).write(
        MediaCompanion(uploadStatus: const Value(UploadStatus.done), objectKey: Value(objectKey)),
      );

  /// Deletes the full-size file of uploaded [mediaId] and records [now] as `purgedAt`.
  ///
  /// With [keepThumb] false the thumbnail file is deleted too ("Phone is full"); screens then show a placeholder.
  /// The row is updated before the files are deleted, so a crash in between only leaves a stray file behind.
  /// Missing files are ignored. Throws [StateError] when the media does not exist or is not uploaded yet: deleting
  /// it then would lose evidence. Side effect: deletes files on disk.
  Future<void> purgeFullSize(String mediaId, {required DateTime now, bool keepThumb = true}) async {
    final row = await (select(media)..where((m) => m.mediaId.equals(mediaId))).getSingleOrNull();
    if (row == null) throw StateError('No media $mediaId');
    if (row.uploadStatus != UploadStatus.done) throw StateError('Media $mediaId is not uploaded yet');
    await (update(media)..where((m) => m.mediaId.equals(mediaId))).write(MediaCompanion(purgedAt: Value(now)));
    for (final path in [row.localPath, if (!keepThumb) row.thumbPath]) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
  }

  /// "Phone is full" (M13): deletes the full-size and thumbnail files of every photo the server has confirmed
  /// (upload status `done`) and records [now] as `purgedAt`. A photo not yet confirmed is never touched: it is the
  /// only copy of that evidence. Full-size files are normally gone already (deleted on confirm), so this mostly
  /// frees thumbnails and files a crash left behind.
  ///
  /// Returns the number of media rows swept. Throws [FileSystemException] when a file cannot be deleted. Side
  /// effect: deletes files on disk.
  Future<int> purgeConfirmed({required DateTime now}) async {
    final done = await (select(media)..where((m) => m.uploadStatus.equalsValue(UploadStatus.done))).get();
    for (final m in done) {
      await purgeFullSize(m.mediaId, now: now, keepThumb: false);
    }
    return done.length;
  }
}
