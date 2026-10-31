// Reference bundles DAO: store and read the versioned bundles (crops, standards, GI region, fields, prompts).
// Requirement: mobile-design.md §3 (`GET /v1/sync/reference?since=`, ETag 304); Arch §Offline-first "Reference data
//   travels to the phone"; backend-design.md §3 Reference bundles.
// Callers: M02 pull_service.dart (upsert, versions), lib/core/refdata/bundle_repository.dart (get).

import 'package:drift/drift.dart';

import '../database.dart';

part 'ref_bundles_dao.g.dart';

/// Reads and writes reference bundles.
@DriftAccessor(tables: [RefBundles])
class RefBundlesDao extends DatabaseAccessor<AppDatabase> with _$RefBundlesDaoMixin {
  /// Creates the DAO on [db]; use `db.refBundlesDao` instead of calling this.
  RefBundlesDao(super.db);

  /// Inserts [bundle] or replaces the stored bundle of the same type. Returns when written; throws nothing.
  Future<void> upsert(RefBundlesCompanion bundle) => into(refBundles).insertOnConflictUpdate(bundle);

  /// The stored bundle of [bundleType], or null when it was never downloaded. Throws nothing.
  Future<RefBundle?> get(String bundleType) =>
      (select(refBundles)..where((b) => b.bundleType.equals(bundleType))).getSingleOrNull();

  /// Stored version per bundle type, for the `since` / `If-None-Match` checks. Empty on first run; throws nothing.
  Future<Map<String, int>> versions() async => {
    for (final b in await select(refBundles).get()) b.bundleType: b.version,
  };
}
