// Shared auth test harness: a scripted API, an in-memory database, mocked secure storage and session fixtures.
// Requirement: WP-M06 tests (interceptor, session restore matrix, screens, router with a real session); D-024 contract.
// Callers: test/auth/*_test.dart, test/widget/{auth_screens,auth_golden,router,locale_switch,text_scale}_test.dart.

import 'dart:convert';
import 'dart:typed_data';

import 'package:agritrace/bootstrap.dart';
import 'package:agritrace/core/api/api_client.dart';
import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/db/providers.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/voice/voice_player.dart';
import 'package:agritrace_api/agritrace_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../db/db_fixtures.dart';

/// One canned answer: HTTP [status] and JSON [body] (null = empty).
typedef Answer = (int status, Object? body);

/// Network stand-in: answers `'METHOD /path'` from per-route queues (the last answer repeats) and records requests.
/// A route with no answers behaves like no signal.
class FakeApi implements HttpClientAdapter {
  /// Creates the fake with [routes], e.g. `{'POST /v1/auth/refresh': [(200, sessionJson())]}`.
  FakeApi([Map<String, List<Answer>>? routes]) : routes = routes ?? {};

  /// Answers per route; tests may add routes later.
  final Map<String, List<Answer>> routes;

  /// Per-route gates: a request to a gated route waits until its future completes (to order races in tests).
  final Map<String, Future<void>> gates = {};

  /// Every request seen, in order, with its headers as sent.
  final List<RequestOptions> requests = [];

  /// Requests to [route] (`'METHOD /path'`). Returns them in order; throws nothing.
  List<RequestOptions> to(String route) => requests.where((r) => '${r.method} ${r.path}' == route).toList();

  /// Records [options] and returns the next answer for its route. Throws [DioException] (connection error) when the
  /// route has no answer.
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Snapshot: a retried request reuses and mutates the same RequestOptions.
    requests.add(options.copyWith(headers: Map.of(options.headers)));
    await gates['${options.method} ${options.path}'];
    final queue = routes['${options.method} ${options.path}'];
    if (queue == null || queue.isEmpty) {
      throw DioException.connectionError(requestOptions: options, reason: 'no signal (test)');
    }
    final (status, body) = queue.length > 1 ? queue.removeAt(0) : queue.first;
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  /// Nothing to release.
  @override
  void close({bool force = false}) {}
}

/// A JWT-shaped access token whose payload carries `sub` = [sub] and a [nonce] so rotated tokens differ.
/// Returns the token; throws nothing.
String fakeJwt({String sub = 'user-1', int nonce = 0}) =>
    'h.${base64Url.encode(utf8.encode(jsonEncode({'sub': sub, 'n': nonce}))).replaceAll('=', '')}.s';

/// The JSON of a `kind: session` answer for [role] with access token [nonce] and refresh token `r<nonce>`.
/// Returns the map; throws nothing.
Map<String, Object?> sessionJson({String role = 'farmer', int nonce = 1}) => {
  'kind': 'session',
  'access_token': fakeJwt(nonce: nonce),
  'refresh_token': 'r$nonce',
  'expires_in': 900,
  'roles': [role],
  'fpo_id': 'fpo-1',
};

/// The [SessionOut] of [sessionJson] for [role]. Returns it; throws nothing.
SessionOut sessionOut({String role = 'farmer', int nonce = 1}) => SessionOut(
  (b) => b
    ..kind = SessionOutKindEnum.session
    ..accessToken = fakeJwt(nonce: nonce)
    ..refreshToken = 'r$nonce'
    ..expiresIn = 900
    ..roles.add(role)
    ..fpoId = 'fpo-1',
);

/// The API error envelope for [code] with [details]. Returns the map; throws nothing.
Map<String, Object?> apiError(String code, [Map<String, Object?> details = const {}]) => {
  'error': {'code': code, 'message': code, 'details': details},
};

/// Asset paths of every clip the silent test player was asked to play, in order (M08: the language switch changes the
/// next prompt's language). Tests clear it before they assert.
final playedClips = <String>[];

/// A container wired like the app, but on [api], a fresh in-memory database ([db] to share one) and secure
/// storage pre-filled with [stored], plus [overrides]. Returns it; the caller disposes it (ProviderContainer.test does at test end).
ProviderContainer authContainer(
  FakeApi api, {
  Map<String, String> stored = const {},
  AppDatabase? db,
  List<Override> overrides = const [],
}) {
  FlutterSecureStorage.setMockInitialValues(Map.of(stored));
  final database = db ?? memoryDb();
  return ProviderContainer.test(
    overrides: [
      appConfigProvider.overrideWithValue(const AppConfig(flavor: Flavor.dev, apiBaseUrl: 'http://api.test')),
      appDatabaseProvider.overrideWithValue(database),
      // Silent voice: no platform audio player in tests, and no autoplay on screen entry.
      voicePlayerProvider.overrideWithValue(
        VoicePlayer(
          bundle: rootBundle,
          playClip: (path, onEnd) async {
            playedClips.add(path);
            onEnd();
          },
        ),
      ),
      voiceAutoplayProvider.overrideWithValue(false),
      apiClientProvider.overrideWith((ref) {
        final session = ref.read(sessionProvider.notifier);
        return ApiClient(
          baseUrl: 'http://api.test',
          accessToken: () => session.accessToken,
          refresh: session.refreshAccessToken,
          httpClientAdapter: api,
        );
      }),
      ...overrides,
    ],
  );
}

/// A container already signed in as [role] (`farmer`, `field_officer`, `qc_officer`) on [api] (default: no signal).
/// Returns it; throws what [SessionNotifier.openSession] throws.
Future<ProviderContainer> signedIn(String role, {FakeApi? api}) async {
  final container = authContainer(api ?? FakeApi());
  await container.read(sessionProvider.notifier).openSession(sessionOut(role: role));
  return container;
}

/// Reads every secure-storage value. Returns the map; throws nothing.
Future<Map<String, String>> storedValues() => const FlutterSecureStorage().readAll();
