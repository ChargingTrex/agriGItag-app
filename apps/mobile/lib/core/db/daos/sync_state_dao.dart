// Sync state DAO: key/value store for the pull cursor, last sync time, clock skew and the pending-count cache.
// Requirement: mobile-design.md §2 (SyncState keys) and §3 (pull with cursor; clock skew > 10 min recorded).
// Callers: M02 pull_service.dart, sync_service.dart and metrics.dart.

import 'package:drift/drift.dart';

import '../database.dart';

part 'sync_state_dao.g.dart';

/// Reads and writes sync key/value pairs.
@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase> with _$SyncStateDaoMixin {
  /// Creates the DAO on [db]; use `db.syncStateDao` instead of calling this.
  SyncStateDao(super.db);

  /// The value stored under [key] (`pull_cursor`, `last_sync_at`, `clock_skew_ms`, `pending_count_cache`), or null
  /// when unset. Throws nothing.
  Future<String?> get(String key) async =>
      (await (select(syncState)..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  /// Stores [value] under [key], replacing any previous value. Returns when written; throws nothing.
  Future<void> set(String key, String value) =>
      into(syncState).insertOnConflictUpdate(SyncStateCompanion.insert(key: key, value: value));
}
