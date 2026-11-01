// Thin HTTP layer: one configured dio shared by the generated agritrace_api client, with bearer auth and
//   refresh-on-401.
// Requirement: plan §13 A6 (timeouts connect 10 s / request 30 s), mobile-design.md §1 core/api (dio + auth
//   interceptor), D-003 (generated client, never hand-edited), D-020 (/v1 routes), D-024 contract (bearer access
//   token, refresh rotation, `refresh_reused`; docs/api/conventions.md "Authentication"), UserFlows §Log in once.
// Callers: SessionNotifier (lib/core/router/session.dart) and, through apiClientProvider, the sync engine (M02) and
//   feature screens; test/unit/api_client_test.dart, test/auth/*.

import 'package:agritrace_api/agritrace_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bootstrap.dart' show appConfigProvider;
import '../router/session.dart';

/// Returns the current access token, or null when signed out.
typedef AccessTokenReader = String? Function();

/// Obtains a new access token (one refresh at a time); completes with null when the session cannot be renewed.
typedef TokenRefresher = Future<String?> Function();

/// Owns the dio instance and the generated API facade.
///
/// DECISION D-003: call the API only through the generated `agritrace_api` package; this class only
/// configures transport (timeouts, headers, interceptors).
///   ADV: request and response types always match packages/openapi/openapi.json; no hand-written models.
///   COMPROMISE: generated method names are long (`healthzV1HealthzGet`); thin wrappers here rename them.
class ApiClient {
  /// Creates the client.
  ///
  /// [baseUrl] is the API origin without `/v1` (the generated paths carry `/v1`, D-020); [accessToken] supplies the
  /// bearer token (null = none); [refresh] renews it after a 401 (null = never retry); [httpClientAdapter] replaces
  /// the network layer in tests. No `X-Client` header is sent: mobile keeps the refresh token in the body (D-024).
  /// Throws nothing.
  ApiClient({
    required String baseUrl,
    AccessTokenReader? accessToken,
    TokenRefresher? refresh,
    HttpClientAdapter? httpClientAdapter,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: requestTimeout,
           sendTimeout: requestTimeout,
         ),
       ) {
    if (httpClientAdapter != null) dio.httpClientAdapter = httpClientAdapter;
    dio.interceptors.add(AuthInterceptor(dio, accessToken ?? () => null, refresh ?? () async => null));
    // Empty list: our dio already carries the interceptors; the generator's own auth interceptors are unused.
    api = AgritraceApi(dio: dio, interceptors: const []);
  }

  /// Time allowed to open a connection (plan §13 A6).
  static const connectTimeout = Duration(seconds: 10);

  /// Time allowed for sending or receiving a request body (plan §13 A6).
  ///
  /// In dio 5 `receiveTimeout` and `sendTimeout` limit the gap between chunks, not the whole request: a
  /// response that keeps dripping bytes can run past 30 s in total. M02 adds a total deadline (e.g. a
  /// `CancelToken` timer) if the network-profile benchmarks need one.
  static const requestTimeout = Duration(seconds: 30);

  /// The configured transport. Exposed for the sync engine's retry interceptor (M02).
  final Dio dio;

  /// The generated API facade bound to [dio].
  late final AgritraceApi api;

  /// Calls `GET /v1/healthz`.
  ///
  /// Returns the per-dependency [Health] when the API answers 200. Throws [DioException] on a network
  /// error, a timeout, a 503 (some dependency down; the body is on `exception.response`) or an
  /// unparseable body. A 200 with an empty body (the API never sends one) throws a [TypeError] from the
  /// null check instead, so callers that classify errors (M02) must treat it as a server fault.
  Future<Health> healthz() async {
    final response = await api.getHealthApi().healthzV1HealthzGet();
    return response.data!;
  }
}

/// Adds `Authorization: Bearer <access token>` to operations the contract secures with `AccessToken`, and on a 401
/// renews the token once and retries the request once.
///
/// Requests to public operations (healthz, OTP, refresh), raw URLs (presigned photo PUTs) and requests that carry
/// their own Authorization header (PIN verify with the pin token) are left untouched, so the refresh call itself can
/// never trigger another refresh.
class AuthInterceptor extends Interceptor {
  /// Creates the interceptor. [dio] re-sends the retried request; [accessToken] is read on every request so a new
  /// token applies at once; [refresh] renews the token (the caller makes it single-flight).
  AuthInterceptor(this.dio, this.accessToken, this.refresh);

  /// The dio the retried request goes through (its interceptors run again).
  final Dio dio;

  /// Reads the current access token; null means send no Authorization header.
  final AccessTokenReader accessToken;

  /// Renews the access token after a 401; null result means signed out or offline.
  final TokenRefresher refresh;

  static const _sentKey = 'agritrace.bearer';
  static const _retriedKey = 'agritrace.retried';

  /// Adds the bearer header to [options] when the operation needs it and a token exists, then passes the request to
  /// [handler]. Returns nothing; throws nothing. Side effect: mutates [options.headers] and [options.extra].
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // The generator lists each operation's security schemes in `extra['secure']`.
    final secure = options.extra['secure'];
    final needsAccess = secure is List && secure.any((s) => s is Map && s['name'] == 'AccessToken');
    final token = accessToken();
    if (needsAccess && token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_sentKey] = token;
    }
    handler.next(options);
  }

  /// On a 401 for a request this interceptor authorised, gets a fresh token and retries once.
  ///
  /// [err] is the failed request; [handler] receives the retried response or the original (or retry) error.
  /// If another request already rotated the token, the retry uses the current token without a second refresh
  /// (the API treats two racing refreshes as reuse, D-024), unless that token belongs to another user (D-029).
  /// Returns nothing; throws nothing (errors go to [handler]). Side effect: may call [refresh], which stores new
  /// tokens or signs the phone out.
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final sent = options.extra[_sentKey];
    if (err.response?.statusCode != 401 || sent == null || options.extra[_retriedKey] == true) {
      return handler.next(err);
    }
    final current = accessToken();
    // D-029: another user signed in on this shared phone meanwhile; their token never re-sends this user's request.
    if (current != null && current != sent && jwtSub(current) != jwtSub(sent as String)) return handler.next(err);
    final token = current != null && current != sent ? current : await refresh();
    if (token == null) return handler.next(err);
    options
      ..extra[_retriedKey] = true
      ..extra[_sentKey] = token
      ..headers['Authorization'] = 'Bearer $token';
    try {
      handler.resolve(await dio.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}

/// The app's API client, bound to the session's tokens. Built on first use; tests override it.
final apiClientProvider = Provider<ApiClient>((ref) {
  final session = ref.read(sessionProvider.notifier);
  return ApiClient(
    baseUrl: ref.read(appConfigProvider).apiBaseUrl,
    accessToken: () => session.accessToken,
    refresh: session.refreshAccessToken,
  );
});
