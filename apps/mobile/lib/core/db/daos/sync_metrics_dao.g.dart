// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_metrics_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncMetricsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncMetricsTable get syncMetrics => attachedDatabase.syncMetrics;
  SyncMetricsDaoManager get managers => SyncMetricsDaoManager(this);
}

class SyncMetricsDaoManager {
  final _$SyncMetricsDaoMixin _db;
  SyncMetricsDaoManager(this._db);
  $$SyncMetricsTableTableManager get syncMetrics =>
      $$SyncMetricsTableTableManager(_db.attachedDatabase, _db.syncMetrics);
}
