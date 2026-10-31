// Drift tables for what a farmer or officer records on the phone: entries (event versions) and their media.
// Requirement: mobile-design.md §2 (Entries, Media, indexes); Arch §Offline-first "Permanent ID at creation",
//   "Append-only facts", "Three clocks", "Photos made light"; backend-design.md §2 event_versions and
//   evidence_photos (the server rows these become); CLAUDE.md §6 (farm events are append-only).
// Callers: database.dart (table list), append_only.drift (trigger), daos/entries_dao.dart, daos/media_dao.dart,
//   daos/outbox_dao.dart (joins for batch sizes).

import 'package:drift/drift.dart';

/// Sync state of an entry, in the order it normally moves.
enum EntryStatus {
  /// Saved on the phone, not yet sent.
  saved,

  /// Sent to the server, no acknowledgement yet.
  sent,

  /// The server accepted it (`accepted` or `duplicate`).
  confirmed,

  /// The server rejected it (validation, stale version, ...); needs an officer.
  rejected,

  /// Undone by a later `undo` entry within the undo window.
  undone,
}

/// Quality of the GPS fix taken with an entry.
enum LocationStatus {
  /// Fix within the accuracy limit.
  ok,

  /// Fix taken but less accurate than the limit.
  lowAccuracy,

  /// No fix (GPS off, indoors, timed out).
  none,
}

/// Upload state of one media file.
enum UploadStatus {
  /// Waiting for an upload URL or a turn.
  pending,

  /// PUT in progress.
  uploading,

  /// Uploaded and confirmed by the server.
  done,

  /// Last attempt failed; will be retried.
  failed,
}

/// Entries: every farm or processing event version recorded on the phone, append-only.
///
/// A correction or an undo is a new row with the same [rootId], [version] + 1 and [supersedesEntryId] set;
/// the row it supersedes is never edited (a trigger in append_only.drift rejects updates of its facts).
///
/// DECISION D-014: one append-only Entries table for all eleven event types with a typed JSON payload.
///   ADV: one save, sync, undo and correction path for every event type; per-crop payload changes need no migration.
///   COMPROMISE: payload fields are not columns (no column typing or indexing); a hot payload key is promoted to a
///   column by migration when a query needs it.
@DataClassName('Entry')
@TableIndex(name: 'entries_lot_status', columns: {#lotId, #status})
@TableIndex(name: 'entries_root_version', columns: {#rootId, #version}, unique: true)
class Entries extends Table {
  /// Entry id (UUIDv7) generated on the phone; also the push `client_id` and idempotency key.
  ///
  /// DECISION D-005: client-generated UUIDv7 as primary and idempotency key.
  ///   ADV: the id exists offline, a retried push is deduplicated by the server, and v7 sorts by creation time.
  ///   COMPROMISE: a foreign-owned id is rejected server-side (`client_id_conflict`) instead of being impossible.
  TextColumn get entryId => text()();

  /// Entry id of version 1 of this event; shared by every version (the server's `event_id`).
  TextColumn get rootId => text()();

  /// Version number within [rootId], starting at 1 (the server's `version_no`).
  IntColumn get version => integer()();

  /// Entry id of the version this row replaces; null for version 1.
  TextColumn get supersedesEntryId => text().nullable()();

  /// Event type (`harvest`, `drying`, ..., or `undo`); selects the payload schema (D-014).
  TextColumn get entryType => text()();

  /// Lot the event belongs to; null for plot-level events.
  TextColumn get lotId => text().nullable()();

  /// Plot the event belongs to; null when not tied to a plot.
  TextColumn get plotId => text().nullable()();

  /// Farmer the event is about (the farmer themselves, or the one an officer assists).
  TextColumn get farmerId => text()();

  /// Repetition number of this event type on the lot (second picking = 2).
  IntColumn get instanceNo => integer()();

  /// Event payload as JSON; quantities carry units (`{"value": 195, "unit": "kg"}`).
  TextColumn get payloadJson => text()();

  /// Phone clock at save time (may be wrong; compared with [serverReceivedAt]).
  DateTimeColumn get deviceTime => dateTime()();

  /// GPS satellite time at save; null without a fix.
  DateTimeColumn get gpsTime => dateTime().nullable()();

  /// Server receive time from the push acknowledgement; null until confirmed.
  DateTimeColumn get serverReceivedAt => dateTime().nullable()();

  /// Latitude in decimal degrees (WGS 84); null without a fix.
  RealColumn get lat => real().nullable()();

  /// Longitude in decimal degrees (WGS 84); null without a fix.
  RealColumn get lng => real().nullable()();

  /// GPS accuracy radius in metres; null without a fix.
  RealColumn get accuracyM => real().nullable()();

  /// Quality of the GPS fix.
  TextColumn get locationStatus => textEnum<LocationStatus>()();

  /// User who entered it (the farmer, or the officer in assist mode). The server takes it from the token.
  TextColumn get enteredByUserId => text()();

  /// True when an officer entered it for the farmer (CLAUDE.md §6: assist mode is recorded on every entry).
  BoolColumn get assistMode => boolean().withDefault(const Constant(false))();

  /// True when entered away from the farm (e.g. by phone call), so location checks do not apply.
  BoolColumn get enteredRemotely => boolean().withDefault(const Constant(false))();

  /// Reason code for a correction or undo; null for version 1.
  TextColumn get reasonCode => text().nullable()();

  /// Sync state; the only fact-free column besides [serverReceivedAt] that may change after save.
  TextColumn get status => textEnum<EntryStatus>()();

  /// Last moment the farmer may undo this entry (save time + 24 h).
  DateTimeColumn get undoDeadline => dateTime()();

  /// When the row was written on the phone.
  DateTimeColumn get createdAt => dateTime()();

  /// Primary key: [entryId].
  @override
  Set<Column<Object>> get primaryKey => {entryId};
}

/// Media: photos (and voice notes) attached to an entry, compressed on the phone before saving.
@DataClassName('MediaFile')
@TableIndex(name: 'media_entry', columns: {#entryId})
class Media extends Table {
  /// Media id (UUIDv7) generated on the phone; the photo `client_id` in the push.
  ///
  /// DECISION D-005: client-generated UUIDv7, so a retried upload or confirm is idempotent.
  ///   ADV: the photo has a permanent id before any network call.
  ///   COMPROMISE: same as for entries; the server rejects a foreign-owned id.
  TextColumn get mediaId => text()();

  /// Entry this file belongs to.
  TextColumn get entryId => text().references(Entries, #entryId)();

  /// Media kind (`photo`, `voice`).
  TextColumn get kind => text()();

  /// Local path of the full-size file; the file is deleted after upload (see [purgedAt]).
  TextColumn get localPath => text()();

  /// Size of the full-size file in bytes.
  IntColumn get bytes => integer()();

  /// SHA-256 of the full-size file, lowercase hex; the server checks it on upload.
  TextColumn get sha256 => text()();

  /// Image width in pixels (0 for audio).
  IntColumn get width => integer()();

  /// Image height in pixels (0 for audio).
  IntColumn get height => integer()();

  /// When the photo was taken (EXIF DateTimeOriginal or capture time).
  DateTimeColumn get capturedAt => dateTime()();

  /// Latitude at capture in decimal degrees; null without a fix.
  RealColumn get lat => real().nullable()();

  /// Longitude at capture in decimal degrees; null without a fix.
  RealColumn get lng => real().nullable()();

  /// GPS accuracy at capture in metres; null without a fix.
  RealColumn get accuracyM => real().nullable()();

  /// Presigned PUT URL from the push acknowledgement; null until the entry is confirmed.
  TextColumn get uploadUrl => text().nullable()();

  /// When [uploadUrl] expires (15 min after issue, D-011).
  DateTimeColumn get uploadUrlExpiresAt => dateTime().nullable()();

  /// Upload state.
  TextColumn get uploadStatus => textEnum<UploadStatus>()();

  /// Object key in the evidence bucket once uploaded.
  TextColumn get objectKey => text().nullable()();

  /// Local path of the ~10 KB thumbnail kept after the full-size file is purged.
  TextColumn get thumbPath => text()();

  /// When the full-size file was deleted from the phone; null while it still exists.
  DateTimeColumn get purgedAt => dateTime().nullable()();

  /// Primary key: [mediaId].
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}
