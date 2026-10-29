// Thin HTTP layer: one configured dio shared by the generated agritrace_api client.
// Requirement: plan §13 A6 (timeouts connect 10 s / request 30 s), mobile-design.md §1 core/api
//   (dio + auth interceptor, X-Device-Id), D-003 (generated client, never hand-edited), D-020 (/v1 routes).
// Callers: test/unit/api_client_test.dart in M00; the sync engine (M02) and auth (M06) via a provider.

import 'package:agritrace_api/agritrace_api.dart';
import 'package:dio/dio.dart';

/// Returns the current access token, or null when signed out.
typedef AccessTokenReader = String? Function();

/// Owns the dio instance and the generated API facade.
///
/// DECISION D-003: call the API only through the generated `agritrace_api` package; this class only
/// configures transport (timeouts, headers, interceptors).
///   ADV: request and response types always match packages/openapi/openapi.json; no hand-written models.
///   COMPROMISE: generated method names are long (`healthzV1HealthzGet`); thin wrappers here rename them.
class ApiClient {
  /// Creates the client.
  ///
  /// [baseUrl] is the API origin without `/v1` (the generated paths carry `/v1`, D-020); [deviceId] is
  /// sent as `X-Device-Id` on every request; [accessToken] supplies the bearer token (null = none);
  /// [httpClientAdapter] replaces the network layer in tests. Throws nothing.
  ApiClient({
    required String baseUrl,
    required String deviceId,
    AccessTokenReader? accessToken,
    HttpClientAdapter? httpClientAdapter,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: requestTimeout,
           sendTimeout: requestTimeout,
           headers: {'X-Device-Id': deviceId},
         ),
       ) {
    if (httpClientAdapter != null) dio.httpClientAdapter = httpClientAdapter;
    dio.interceptors.add(AuthInterceptor(accessToken ?? () => null));
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

/// Adds `Authorization: Bearer <token>` when a token is available.
///
/// shortcut: no refresh-on-401 yet; M06 adds token refresh and sign-out on refresh failure.
class AuthInterceptor extends Interceptor {
  /// Creates the interceptor. [accessToken] is read on every request so a new token applies at once.
  AuthInterceptor(this.accessToken);

  /// Reads the current access token; null means send no Authorization header.
  final AccessTokenReader accessToken;

  /// Adds the bearer header to [options] when a token exists, then passes the request to [handler].
  /// Returns nothing; throws nothing. Side effect: mutates [options.headers].
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = accessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
