// Sync metrics DAO: record per-entry send timings and hand the unshipped ones to the next push envelope.
// Requirement: mobile-design.md §3 ("SyncMetrics rows shipped in the next push envelope (`metrics[]`)"); plan §13
//   D2 / BM benchmarks ("Sent" ≤ 5 s on normal 4G); backend-design.md §2 sync_metrics.
// Callers: M02 metrics.dart (record) and outbox_processor.dart (unshipped, markShipped).

import 'package:drift/drift.dart';

import '../database.dart';

part 'sync_metrics_dao.g.dart';

/// Reads and writes sync metrics.
@DriftAccessor(tables: [SyncMetrics])
class SyncMetricsDao extends DatabaseAccessor<AppDatabase> with _$SyncMetricsDaoMixin {
  /// Creates the DAO on [db]; use `db.syncMetricsDao` instead of calling this.
  SyncMetricsDao(super.db);

  /// Inserts [metric], or updates it when its `id` is present and exists (e.g. to add `ackedAt` later).
  /// Returns the row id; throws nothing.
  Future<int> record(SyncMetricsCompanion metric) => into(syncMetrics).insertOnConflictUpdate(metric);

  /// Metrics not yet shipped, oldest first, at most [limit]. Throws nothing.
  Future<List<SyncMetric>> unshipped({int limit = 100}) =>
      (select(syncMetrics)
            ..where((m) => m.shipped.not())
            ..orderBy([(m) => OrderingTerm.asc(m.id)])
            ..limit(limit))
          .get();

  /// Marks [ids] as shipped after the push that carried them was accepted. Returns when written; throws nothing.
  Future<void> markShipped(List<int> ids) =>
      (update(syncMetrics)..where((m) => m.id.isIn(ids))).write(const SyncMetricsCompanion(shipped: Value(true)));
}
