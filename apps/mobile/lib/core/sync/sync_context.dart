// What one sync run needs, handed to each phase function (push, photos, pull, bundles).
// Requirement: mobile-design.md §3 (one mutex-guarded run), PLAN §13 A1–A6, F1 (network type per metric), D-029 (the
//   run belongs to the signed-in user); FR4; Arch §Offline-first.
// Callers: sync_service.dart builds it per run; outbox_processor.dart, photo_uploader.dart, pull_service.dart,
//   bundle_fetcher.dart and metrics.dart read it; tests build it through SyncService.

import 'dart:math';

import 'package:dio/dio.dart';

import '../db/database.dart';

/// The inputs of one sync run. Immutable; a new one is built for every run.
class SyncContext {
  /// Creates the context: [db] the offline store, [api] the shared API dio (base URL, auth, timeouts), [uploads] a
  /// bare dio for presigned PUTs, [userId] and [deviceId] from the Session row, [appVersion] for the envelope,
  /// [networkType] at run start (`wifi`, `mobile`, `ethernet`, `none`, `other`), [now] the clock, [random] the
  /// jitter source. Throws nothing.
  const SyncContext({
    required this.db,
    required this.api,
    required this.uploads,
    required this.userId,
    required this.deviceId,
    required this.appVersion,
    required this.networkType,
    required this.now,
    required this.random,
  });

  /// The offline store.
  final AppDatabase db;

  /// The shared API client's dio: base URL, timeouts (10 s / 30 s, PLAN §13 A6) and the M06 auth interceptor.
  final Dio api;

  /// A dio without base URL or auth for presigned storage URLs (an Authorization header would break the signature).
  final Dio uploads;

  /// The signed-in user; only their outbox rows are sent (D-029).
  final String userId;

  /// This install's device id (`device_id` in the push envelope).
  final String deviceId;

  /// App version sent in the push envelope (`app_version`).
  final String appVersion;

  /// Network type at the start of the run, recorded with each metric and checked by the Wi-Fi-only rule.
  final String networkType;

  /// The clock (UTC); a fake in tests.
  final DateTime Function() now;

  /// Jitter source for the backoff.
  final Random random;

  /// Options for calls to secured API operations: the M06 auth interceptor adds the bearer token (and refreshes it
  /// on a 401) only when `extra['secure']` names `AccessToken`, as the generated client marks its operations.
  static final authed = Options(
    contentType: Headers.jsonContentType,
    extra: const {
      'secure': [
        {'type': 'http', 'scheme': 'bearer', 'name': 'AccessToken'},
      ],
    },
  );
}
