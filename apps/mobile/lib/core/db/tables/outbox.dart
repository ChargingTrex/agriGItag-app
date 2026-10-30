// Drift table for the outbox: the queue of entries and media waiting to reach the server.
// Requirement: mobile-design.md §2 (Outbox) and §3 (oldest-first, backoff, needs_attention, kill-safety, cloud icon);
//   Arch §Offline-first "Outbox queue" and "Small first, photos second"; FR4 (offline capture with later sync).
// Callers: database.dart (table list), daos/entries_dao.dart (enqueue on save), daos/outbox_dao.dart; M02 sync.

import 'package:drift/drift.dart';

/// What an outbox row sends.
enum OutboxKind {
  /// An entry (JSON in the push batch).
  entry,

  /// A media file (presigned PUT).
  media,
}

/// Life cycle of an outbox row.
enum OutboxStatus {
  /// Ready to send at or after `nextAttemptAt`.
  waiting,

  /// A send is in flight; reset to waiting on start if older than 5 min (kill-safety).
  sending,

  /// Sent; waiting for the server to confirm (media: PUT done, confirm pending).
  sent,

  /// The server confirmed it; no longer counted by the cloud icon.
  confirmed,

  /// A non-retryable error (4xx other than 429); an officer must look. Stored as `needsAttention`.
  needsAttention,
}

/// Outbox: one row per entry or media file to send, processed oldest-first with entries before media.
@DataClassName('OutboxItem')
@TableIndex(name: 'outbox_status_next', columns: {#status, #nextAttemptAt})
class Outbox extends Table {
  /// Queue position; autoincrement, so a lower number was enqueued earlier.
  IntColumn get seq => integer().autoIncrement()();

  /// Whether [refId] is an entry or a media file.
  TextColumn get kind => textEnum<OutboxKind>()();

  /// `Entries.entryId` or `Media.mediaId` of the row to send.
  TextColumn get refId => text()();

  /// Idempotency key sent with the request; the client UUID of the entry or media (D-005).
  TextColumn get idempotencyKey => text()();

  /// 0 for entries, 1 for media: small facts go first (Arch §Offline-first "Small first, photos second").
  IntColumn get priority => integer()();

  /// Number of send attempts so far.
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Earliest time of the next attempt while waiting; the attempt start time while sending.
  DateTimeColumn get nextAttemptAt => dateTime()();

  /// Last error code or message; null after a clean send.
  TextColumn get lastError => text().nullable()();

  /// Life-cycle state.
  TextColumn get status => textEnum<OutboxStatus>().withDefault(const Constant('waiting'))();

  /// When the row was enqueued.
  DateTimeColumn get createdAt => dateTime()();
}
