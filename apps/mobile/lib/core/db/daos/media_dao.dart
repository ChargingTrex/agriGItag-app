// Media DAO: list photos ready to upload, record an upload, and free phone storage once a photo is safe on the server.
// Requirement: mobile-design.md §3 ("push media for confirmed entries"; "delete full-size file on confirm; keep
//   ~10 KB thumbnail"; "Phone is full" purge); Arch §Offline-first "Small first, photos second", "Photos made light".
// Callers: M02 photo_uploader.dart (pendingUploads, markUploaded, purgeFullSize), M07 storage prompt (purgeFullSize).

import 'dart:io';

import 'package:drift/drift.dart';

import '../database.dart';

part 'media_dao.g.dart';

/// Reads and updates media rows.
@DriftAccessor(tables: [Media, Entries])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  /// Creates the DAO on [db]; use `db.mediaDao` instead of calling this.
  MediaDao(super.db);

  /// Up to [limit] media rows still to upload (`pending` or `failed`, file not purged) whose entry the server has
  /// confirmed, so an upload URL can exist; oldest first. Returns an empty list when none; throws nothing.
  Future<List<MediaFile>> pendingUploads(int limit) {
    final query = select(media).join([innerJoin(entries, entries.entryId.equalsExp(media.entryId))])
      ..where(
        media.uploadStatus.isInValues([UploadStatus.pending, UploadStatus.failed]) &
            media.purgedAt.isNull() &
            entries.serverReceivedAt.isNotNull(),
      )
      ..orderBy([OrderingTerm.asc(media.rowId)])
      ..limit(limit);
    return query.map((r) => r.readTable(media)).get();
  }

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
}
