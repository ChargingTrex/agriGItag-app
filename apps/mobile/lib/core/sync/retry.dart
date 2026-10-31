// Retry policy of the sync engine: which failures are retried, and after how long.
// Requirement: PLAN §13 A6 (retry only on network errors, 5xx and 429; backoff 2, 4, 8 … s with jitter, capped at
//   5 min; other 4xx → needs_attention), mobile-design.md §3, backend-design.md §3; FR4; Arch §Offline-first.
// Callers: outbox_processor.dart (push), photo_uploader.dart (PUT, confirm), pull_service.dart, bundle_fetcher.dart;
//   test/sync/sync_service_test.dart.

import 'dart:math';

import 'package:dio/dio.dart';

/// Longest wait between two attempts (PLAN §13 A6).
const maxBackoff = Duration(minutes: 5);

/// What to do after a failed request.
enum FailureAction {
  /// Try again later (network error, timeout, 5xx, 429): the row waits for its backoff.
  retry,

  /// Not the entry's fault and not fixable by retrying it now (401/403: the session is renewed or ended by M06):
  /// the row waits for its backoff without being marked.
  wait,

  /// The server refused the request itself (other 4xx): the row goes to `needs_attention` and is never retried
  /// unless someone acts.
  attention,
}

/// Classifies [error]. Returns [FailureAction.retry] for errors without a response (connection, timeout, cancel)
/// and for 5xx/429; [FailureAction.wait] for 401/403; [FailureAction.attention] for any other 4xx. Any error that is
/// not a [DioException] (e.g. a `TypeError` from an unexpected body) counts as a server fault and is retried.
/// Throws nothing.
FailureAction classify(Object error) {
  final status = error is DioException ? error.response?.statusCode : null;
  if (status == null || status >= 500 || status == 429) return FailureAction.retry;
  if (status == 401 || status == 403) return FailureAction.wait;
  return FailureAction.attention;
}

/// Delay before attempt number [attempts] + 1, after [attempts] failed ones (1 → 2 s, 2 → 4 s, 3 → 8 s …),
/// multiplied by a jitter between 0.8 and 1.2 drawn from [random], capped at [maxBackoff].
///
/// A server hint in [error] wins: the `Retry-After` header (seconds) or `error.details.retry_after_s` in the body
/// (still capped). Returns the delay; throws nothing.
Duration backoff(int attempts, Random random, [Object? error]) {
  final hinted = error is DioException ? _retryAfter(error.response) : null;
  if (hinted != null) return hinted > maxBackoff ? maxBackoff : hinted;
  // Exponent clamped at 8 (2 s × 2^8 = 512 s, already over the cap): an int power wraps past 2^63 after ~54 failures.
  final base = 2000 * pow(2, min(max(attempts, 1) - 1, 8));
  final ms = min(base * (0.8 + 0.4 * random.nextDouble()), maxBackoff.inMilliseconds.toDouble());
  return Duration(milliseconds: ms.round());
}

/// The server's retry hint in [response], or null when none. Throws nothing.
Duration? _retryAfter(Response<Object?>? response) {
  final header = int.tryParse(response?.headers.value('retry-after') ?? '');
  if (header != null) return Duration(seconds: header);
  final data = response?.data;
  final details = data is Map && data['error'] is Map ? (data['error'] as Map)['details'] : null;
  final seconds = details is Map ? details['retry_after_s'] : null;
  return seconds is num ? Duration(milliseconds: (seconds * 1000).round()) : null;
}

/// The server's error code in [error] (`validation_error`, `payload_too_large` …), else `http_<status>`, else the
/// dio error type (`connectionError`, `receiveTimeout` …), else the error's runtime type. Returns it; throws nothing.
String errorCode(Object error) {
  if (error is! DioException) return error.runtimeType.toString();
  final data = error.response?.data;
  final code = data is Map && data['error'] is Map ? (data['error'] as Map)['code'] : null;
  if (code is String) return code;
  final status = error.response?.statusCode;
  return status != null ? 'http_$status' : error.type.name;
}
