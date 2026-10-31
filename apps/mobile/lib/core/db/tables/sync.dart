// Drift tables for sync bookkeeping: reference bundles, key/value sync state and send-latency metrics.
// Requirement: mobile-design.md §2 (RefBundles, SyncState, SyncMetrics) and §3 (cursor pull, clock skew, metrics in
//   the next push); Arch §Offline-first "Reference data travels to the phone"; backend-design.md §3 bundles.
// Callers: database.dart (table list), daos/ref_bundles_dao.dart, daos/sync_state_dao.dart,
//   daos/sync_metrics_dao.dart; M02 sync and lib/core/refdata read them.

import 'package:drift/drift.dart';

/// Reference bundles downloaded from `GET /v1/sync/bundle/{part}` (plots, crops, standards, gi_region, ...).
@DataClassName('RefBundle')
class RefBundles extends Table {
  /// Bundle part name (`crops`, `standards`, `gi_region`, `fields`, ...).
  TextColumn get bundleType => text()();

  /// Server version of the part; `GET /v1/sync/reference?since=` compares against it.
  IntColumn get version => integer()();

  /// HTTP ETag of the part, sent back as `If-None-Match`.
  TextColumn get etag => text()();

  /// When the part was last downloaded.
  DateTimeColumn get fetchedAt => dateTime()();

  /// The part's JSON body.
  TextColumn get bodyJson => text()();

  /// Directory of unpacked assets (images, voice clips); null for JSON-only parts.
  TextColumn get assetDir => text().nullable()();

  /// Primary key: [bundleType].
  @override
  Set<Column<Object>> get primaryKey => {bundleType};
}

/// Small sync values: `pull_cursor`, `last_sync_at`, `clock_skew_ms`, `pending_count_cache`.
@DataClassName('SyncStateEntry')
class SyncState extends Table {
  /// Key name.
  TextColumn get key => text()();

  /// Value as text (numbers and times serialised by the caller).
  TextColumn get value => text()();

  /// Primary key: [key].
  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Per-entry sync timings, shipped to the server in the next push envelope (`metrics[]`).
@DataClassName('SyncMetric')
class SyncMetrics extends Table {
  /// Local row id.
  IntColumn get id => integer().autoIncrement()();

  /// Entry the metric is about.
  TextColumn get entryId => text()();

  /// When the entry was saved on the phone.
  DateTimeColumn get savedAt => dateTime()();

  /// When the server acknowledged it; null until then.
  DateTimeColumn get ackedAt => dateTime().nullable()();

  /// Total photo upload time in milliseconds; null without photos or before upload.
  IntColumn get photoUploadMs => integer().nullable()();

  /// Failed send attempts before success.
  IntColumn get failures => integer().withDefault(const Constant(0))();

  /// Network type at send (`wifi`, `lte`, `3g`, `2g`, `none`).
  TextColumn get networkType => text()();

  /// True once the metric was included in an accepted push.
  BoolColumn get shipped => boolean().withDefault(const Constant(false))();
}
