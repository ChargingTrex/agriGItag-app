// Riverpod providers of the sync engine: the one SyncService, the cloud-icon count (overrides M05's
// pendingSendCountProvider) and the count of rows stranded by other users on a shared phone.
// Requirement: mobile-design.md §3 ("Cloud icon = count(Outbox status != confirmed) as a stream"); PLAN §13 A2; D-013
//   (Riverpod providers, overridable in tests); D-029 (per-user outbox, stranded rows for the officer).
// Callers: lib/bootstrap.dart adds [syncOverrides] to the ProviderScope and starts [syncServiceProvider] (three
//   lines, outside M02's paths; see docs/agents/reports/M02.md "Merge wiring"); background_scheduler.dart reads [syncServiceProvider]; M05 CloudSyncIndicator watches the
//   overridden count; M10 officer screen watches [strandedCountProvider].

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../db/providers.dart';
import '../sync/sync_service.dart';
import '../widgets/cloud_sync_indicator.dart';

/// The app's sync engine on the app database and the shared API client (its dio carries the timeouts and M06's
/// bearer/refresh interceptor). Disposed with the scope; tests override it. Throws nothing on creation.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(db: ref.watch(appDatabaseProvider), api: ref.watch(apiClientProvider).dio);
  ref.onDispose(service.dispose);
  return service;
});

/// Overrides for the app's ProviderScope: M05's cloud icon counts the signed-in user's unconfirmed outbox rows
/// (D-029), re-emitted on every outbox or session change.
final syncOverrides = [
  pendingSendCountProvider.overrideWith((ref) => ref.watch(syncServiceProvider).db.outboxDao.pendingCount()),
];

/// Unconfirmed outbox rows of users other than the signed-in one (all rows when signed out), for the officer's
/// "entries waiting for another user" notice (D-029, M10).
final strandedCountProvider = StreamProvider<int>((ref) => ref.watch(syncServiceProvider).db.outboxDao.strandedCount());
