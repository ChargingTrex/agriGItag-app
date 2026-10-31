// Riverpod providers of the sync engine: the one SyncService, the cloud-icon count (overrides M05's
// pendingSendCountProvider) and the count of rows stranded by other users on a shared phone.
// Requirement: mobile-design.md §3 ("Cloud icon = count(Outbox status != confirmed) as a stream"); PLAN §13 A2; D-013
//   (Riverpod providers, overridable in tests); D-029 (per-user outbox, stranded rows for the officer).
// Callers: lib/bootstrap.dart adds [syncOverrides] to the ProviderScope and starts [syncServiceProvider] (wired at
//   the M06 merge); background_scheduler.dart reads [syncServiceProvider]; M05 CloudSyncIndicator watches the
//   overridden count; M10 officer screen watches [strandedCountProvider].

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_service.dart';
import '../widgets/cloud_sync_indicator.dart';

/// The app's sync engine.
///
/// Throws [StateError] until bootstrap wires it, because the database and API client providers arrive with M06
/// (`appDatabaseProvider`, `apiClientProvider`). The M06 merge replaces the body with
/// `SyncService(db: ref.watch(appDatabaseProvider), api: ref.watch(apiClientProvider).dio)` plus
/// `ref.onDispose(service.dispose)`; tests override it.
final syncServiceProvider = Provider<SyncService>(
  (ref) => throw StateError('syncServiceProvider is wired to the database and API client providers at bootstrap'),
);

/// Overrides for the app's ProviderScope: M05's cloud icon counts the signed-in user's unconfirmed outbox rows
/// (D-029), re-emitted on every outbox or session change.
final syncOverrides = [
  pendingSendCountProvider.overrideWith((ref) => ref.watch(syncServiceProvider).db.outboxDao.pendingCount()),
];

/// Unconfirmed outbox rows of users other than the signed-in one (all rows when signed out), for the officer's
/// "entries waiting for another user" notice (D-029, M10).
final strandedCountProvider = StreamProvider<int>((ref) => ref.watch(syncServiceProvider).db.outboxDao.strandedCount());
