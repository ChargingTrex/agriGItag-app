// The sync engine: decides when to sync (app open/resume, 500 ms after a save, connectivity change, backoff timer,
// background task, "send now"), runs one sync at a time (push → pull → photos → bundles) for the signed-in user only,
// and makes a killed run safe to repeat.
// Requirement: FR4 (offline capture, later sync); Arch §Offline-first "When it syncs", "Outbox queue"; PLAN §13
//   A1–A6, B3–B5, C2, F1; mobile-design.md §3; backend-design.md §3; D-005, D-011, D-029.
// Callers: lib/core/providers/sync_providers.dart (syncServiceProvider; the app starts it), background_scheduler.dart
//   (runOnce in the WorkManager / BGAppRefresh isolate); test/sync/*.

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

import '../api/api_client.dart';
import '../db/database.dart';
import 'bundle_fetcher.dart';
import 'connectivity.dart';
import 'outbox_processor.dart';
import 'photo_uploader.dart';
import 'pull_service.dart';
import 'sync_context.dart';

/// App version sent in every push envelope; release builds pass `--dart-define=APP_VERSION=<pubspec version>`.
///
/// shortcut: a compile-time define instead of package_info_plus (not an allowed dependency for M02); CI must pass
/// it, or every phone reports the default.
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '0.1.0');

/// Wait after a save before a run, so a burst of saves goes out in one push (mobile-design.md §3).
const saveDebounce = Duration(milliseconds: 500);

/// Wait before probing once more after a failed probe: when the signal returns, the link often comes up before DNS
/// and the route do, and connectivity_plus reports the change only once (PLAN §13 A1).
const probeRetry = Duration(seconds: 10);

/// SyncState key holding the user the stored pull cursor and reference bundles belong to (D-029).
const syncUserKey = 'sync_user_id';

/// The one sync engine of the app.
///
/// DECISION D-029: a run reads the signed-in user from the Session row and sends only that user's outbox rows; with
///   nobody signed in it does nothing. Rows of other users stay on the phone until their owner signs in again.
///   ADV: a shared family phone never sends one person's entries with another person's token.
///   COMPROMISE: stranded rows wait; strandedCount (sync_providers.dart) lets the officer screen (M10) show them.
class SyncService {
  /// Creates the engine.
  ///
  /// [db] is the offline store; [api] the shared API dio (base URL, 10 s / 30 s timeouts, M06 auth interceptor);
  /// [uploads] the dio for presigned PUTs (default: a bare dio with the same timeouts and [api]'s adapter);
  /// [networkType] and [networkChanges] default to connectivity_plus; [reachable] to `HEAD /v1/healthz` on [api];
  /// [now] to the UTC clock; [random] to a fresh `Random` (jitter). Tests pass fakes. Throws nothing.
  SyncService({
    required this.db,
    required this.api,
    Dio? uploads,
    Future<String> Function()? networkType,
    Stream<Object?>? networkChanges,
    Future<bool> Function()? reachable,
    DateTime Function()? now,
    Random? random,
  }) : uploads =
           uploads ??
           (Dio(
             BaseOptions(
               connectTimeout: ApiClient.connectTimeout,
               sendTimeout: ApiClient.requestTimeout,
               receiveTimeout: ApiClient.requestTimeout,
             ),
           )..httpClientAdapter = api.httpClientAdapter),
       networkType = networkType ?? currentNetworkType,
       _networkChanges = networkChanges,
       _reachable = reachable,
       now = now ?? (() => DateTime.now().toUtc()),
       random = random ?? Random();

  /// The offline store.
  final AppDatabase db;

  /// The shared API dio.
  final Dio api;

  /// The dio used for presigned PUTs (no base URL, no auth).
  final Dio uploads;

  /// Reads the current network type (`wifi`, `mobile`, …).
  final Future<String> Function() networkType;

  /// The clock (UTC).
  final DateTime Function() now;

  /// Jitter source for backoffs.
  final Random random;

  final Stream<Object?>? _networkChanges;
  final Future<bool> Function()? _reachable;
  final _subscriptions = <StreamSubscription<Object?>>[];
  AppLifecycleListener? _lifecycle;
  Timer? _debounce;
  Timer? _retry;
  Timer? _probeRetry;
  Future<void>? _running;
  bool _again = false;

  /// Starts the foreground engine: makes a killed run safe, then syncs now (app open) and on resume, 500 ms after
  /// each save or sign-in, on every connectivity change and when the earliest backoff ends; each automatic run first
  /// checks that the API is reachable, and a failed check is tried once more after [probeRetry].
  ///
  /// Call once after the first frame (it registers an [AppLifecycleListener]). Returns after the kill-safety reset;
  /// throws only on database errors. Side effects: subscriptions and timers until [dispose].
  Future<void> start() async {
    await resetAfterKill();
    _subscriptions
      ..add((_networkChanges ?? networkTypeChanges()).listen((_) => unawaited(_probeThenRun())))
      // A save inserts outbox rows; the engine's own writes are updates, so they never trigger a run.
      ..add(
        db
            .tableUpdates(TableUpdateQuery.onTable(db.outbox, limitUpdateKind: UpdateKind.insert))
            .listen((_) => afterSave()),
      )
      // Sign-in writes the Session row: the first pull and bundles must not wait for a resume (a locale or Wi-Fi-only
      // change only adds a harmless run).
      ..add(db.tableUpdates(TableUpdateQuery.onTable(db.sessionTable)).listen((_) => afterSave()));
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_probeThenRun()));
    unawaited(_probeThenRun());
  }

  /// Kill-safety: outbox rows left `sending`/`sent` for over 5 min go back to `waiting` (the server deduplicates a
  /// repeated push or PUT by client id, D-005), and media left `uploading` become `pending` again.
  /// Returns when written; throws only on database errors.
  Future<void> resetAfterKill() async {
    final t = now();
    await db.outboxDao.resetStaleSending(now: t);
    await (db.update(db.media)..where((m) => m.uploadStatus.equalsValue(UploadStatus.uploading))).write(
      const MediaCompanion(uploadStatus: Value(UploadStatus.pending)),
    );
  }

  /// Schedules a run [saveDebounce] after the latest save, if the API is reachable then. Returns at once; throws
  /// nothing. Side effect: (re)starts the debounce timer.
  void afterSave() {
    _debounce?.cancel();
    _debounce = Timer(saveDebounce, () => unawaited(_probeThenRun()));
  }

  /// "Send now": runs immediately without the reachability probe (the person asked). Returns when the run, and any
  /// run requested meanwhile, has finished; throws only on database errors.
  Future<void> sendNow() => runOnce();

  /// Runs one sync for the signed-in user; if a run is already going, the current run is followed by one more and
  /// the returned future completes after it (one run at a time, nothing requested is lost).
  ///
  /// Returns when done. Throws only on database errors; HTTP failures are handled per row and per phase.
  /// Side effects: everything the phases do; afterwards a timer for the earliest backoff when started.
  Future<void> runOnce() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = _loop();
  }

  /// Stops timers, subscriptions and the lifecycle listener. Returns when done; throws nothing.
  Future<void> dispose() async {
    _debounce?.cancel();
    _retry?.cancel();
    _probeRetry?.cancel();
    _lifecycle?.dispose();
    for (final s in _subscriptions) {
      await s.cancel();
    }
  }

  /// Runs, schedules the next backoff wake-up, and repeats while another run was requested meanwhile.
  /// Returns when done. Side effect: clears the running marker in the same step that ends the loop, so a request
  /// arriving afterwards starts a new run instead of being folded into a finished one.
  Future<void> _loop() async {
    try {
      do {
        _again = false;
        await _run();
        await _scheduleRetry();
      } while (_again);
    } finally {
      _running = null;
    }
  }

  /// One run: push, pull, photos (unless Wi-Fi-only and not on Wi-Fi), bundles. A phase that throws is logged and the
  /// next phase still runs. Returns when done; throws only on database errors outside the phases.
  ///
  /// Pull goes before photos (mobile-design.md §3 lists it after) because B07 reports `photo_pending` in the pull:
  /// those photos are then re-requested and uploaded in the same run instead of 15 min later.
  Future<void> _run() async {
    // Also on every run, not only at start: an app reopened within 5 min of a kill must not leave rows `sending`.
    await db.outboxDao.resetStaleSending(now: now());
    final session = await db.select(db.sessionTable).getSingleOrNull();
    if (session == null) return;
    final previousUser = await db.syncStateDao.get(syncUserKey);
    if (previousUser != session.userId) {
      // DECISION D-029: the pull cursor, the reference bundles and the pulled rows belong to the user who fetched
      //   them; another user signing in on the same phone starts from scratch (the server cursor and the per-FPO
      //   plots version are not bound to a user).
      //   ADV: user B gets their own changes, plots, lots, flags and reminders, never A's.  COMPROMISE: a user switch
      //   re-downloads every bundle part once, and A's local drying reminders are gone when A signs in again.
      await db.transaction(() async {
        await (db.delete(db.syncState)..where((s) => s.key.equals(pullCursorKey))).go();
        await db.delete(db.refBundles).go();
        if (previousUser != null) await _forgetPulledRows();
        await db.syncStateDao.set(syncUserKey, session.userId);
      });
    }
    final c = SyncContext(
      db: db,
      api: api,
      uploads: uploads,
      userId: session.userId,
      deviceId: session.deviceId,
      appVersion: appVersion,
      networkType: await networkType(),
      now: now,
      random: random,
    );
    // Arch §Offline-first "Small first, photos second"; PLAN §13 B5: photos wait for Wi-Fi when the farmer asked.
    final photos = !session.wifiOnlyPhotos || c.networkType == 'wifi';
    for (final (name, phase) in [
      ('push', pushEntries),
      ('pull', pullChanges),
      if (photos) ('photos', uploadPhotos),
      ('bundles', fetchBundles),
    ]) {
      try {
        await phase(c);
      } catch (e, s) {
        developer.log('sync $name failed: $e', name: 'agritrace.sync', error: e, stackTrace: s);
      }
    }
    await db.syncStateDao.set('last_sync_at', now().toIso8601String());
  }

  /// User switch (D-029): deletes the previous user's Lots, Plots, Tasks and Flags; the fresh pull and plots bundle
  /// of the new user refill theirs. A lot or plot that an entry not yet confirmed (saved, sent or rejected) names is
  /// kept, so that entry can still be sent and shown. Farmers are kept: only M09's offline registration writes them,
  /// and nothing pulls them back. Returns when deleted; throws only on database errors. Side effect: M12 reminders
  /// are rescheduled from the emptied Tasks table.
  Future<void> _forgetPulledRows() async {
    final unconfirmed = db.entries.status.isNotInValues([EntryStatus.confirmed, EntryStatus.undone]);
    // The ids in [column] of unconfirmed entries.
    BaseSelectStatement<TypedResult> namedBy(GeneratedColumn<String> column) => db.selectOnly(db.entries)
      ..addColumns([column])
      ..where(unconfirmed & column.isNotNull());
    await (db.delete(db.lots)..where((l) => l.lotId.isInQuery(namedBy(db.entries.lotId)).not())).go();
    await (db.delete(db.plots)..where((p) => p.plotId.isInQuery(namedBy(db.entries.plotId)).not())).go();
    await db.delete(db.tasks).go();
    await db.delete(db.flags).go();
  }

  /// When started, wakes the engine at the earliest future backoff of the signed-in user (2, 4, 8 … s). Returns
  /// when scheduled; throws only on database errors.
  Future<void> _scheduleRetry() async {
    _retry?.cancel();
    if (_lifecycle == null) return;
    final session = await db.select(db.sessionTable).getSingleOrNull();
    if (session == null) return;
    final t = now();
    final due = await db.outboxDao.nextDue(ownerUserId: session.userId, now: t);
    if (due != null) _retry = Timer(due.difference(t), () => unawaited(_probeThenRun()));
  }

  /// Runs when the API answers the reachability probe. When it does not and the engine is started, probes once more
  /// after [probeRetry] ([retry] false for that second probe, so an offline phone is not probed in a loop).
  /// Returns when done; throws only on database errors.
  Future<void> _probeThenRun({bool retry = true}) async {
    if (await (_reachable ?? () => isReachable(api))()) {
      _probeRetry?.cancel();
      await runOnce();
    } else if (retry && _lifecycle != null) {
      _probeRetry?.cancel();
      _probeRetry = Timer(probeRetry, () => unawaited(_probeThenRun(retry: false)));
    }
  }
}
