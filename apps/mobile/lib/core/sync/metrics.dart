// Per-entry sync telemetry: save → acknowledgement time, photo upload time, failed attempts, network type; written
// locally and shipped in the next push envelope (`metrics[]`).
// Requirement: PLAN §13 F1 (per-entry telemetry for the P06 "Sync health" tile), mobile-design.md §3 ("SyncMetrics
//   rows shipped in the next push envelope"), backend-design.md §3 (`SyncMetricIn`); BM-11/12 measure against it.
// Callers: outbox_processor.dart (recordAck at acknowledgement, metricToWire in the envelope),
//   photo_uploader.dart (recordPhotoTime after confirm).

import 'dart:math';

import 'package:drift/drift.dart';

import '../db/daos/outbox_dao.dart';
import '../db/database.dart';
import 'sync_context.dart';

/// Records the acknowledgement of [item] at `c.now()`: saved at the entry's `createdAt`, failures = attempts before
/// this one, network type of the run. Returns when written; throws nothing.
Future<void> recordAck(SyncContext c, OutboxBatchItem item) => c.db.syncMetricsDao.record(
  SyncMetricsCompanion.insert(
    entryId: item.entry.entryId,
    savedAt: item.entry.createdAt,
    ackedAt: Value(c.now()),
    failures: Value(item.row.attempts),
    networkType: c.networkType,
  ),
);

/// Records [ms] of photo upload time (and [failures] failed PUTs, never below 0) for [entryId]: added to its
/// unshipped metric row if one exists (the push failures stay counted), else on a new row (the acknowledgement row
/// already went out with an earlier push). Returns when written; throws nothing.
Future<void> recordPhotoTime(SyncContext c, String entryId, int ms, int failures) async {
  final updated = await (c.db.update(c.db.syncMetrics)..where((m) => m.entryId.equals(entryId) & m.shipped.not()))
      .write(
        SyncMetricsCompanion.custom(
          photoUploadMs: Variable(ms),
          failures: c.db.syncMetrics.failures + Variable(max(0, failures)),
        ),
      );
  if (updated > 0) return;
  final entry = await (c.db.select(c.db.entries)..where((e) => e.entryId.equals(entryId))).getSingle();
  await c.db.syncMetricsDao.record(
    SyncMetricsCompanion.insert(
      entryId: entryId,
      savedAt: entry.createdAt,
      photoUploadMs: Value(ms),
      failures: Value(max(0, failures)),
      networkType: c.networkType,
    ),
  );
}

/// The wire form of [m] (`SyncMetricIn`). Returns the JSON map; throws nothing.
Map<String, Object?> metricToWire(SyncMetric m) => {
  'entry_client_id': m.entryId,
  'saved_at': m.savedAt.toUtc().toIso8601String(),
  'acked_at': m.ackedAt?.toUtc().toIso8601String(),
  'photo_upload_ms': m.photoUploadMs,
  'failures': m.failures,
  'network_type': m.networkType,
};
