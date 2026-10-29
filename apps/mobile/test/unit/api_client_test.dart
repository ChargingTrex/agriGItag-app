// ApiClient: timeouts, X-Device-Id and bearer headers, and a healthz call through the generated client.
// Requirement: plan §13 A6 (connect 10 s / request 30 s), D-003 (generated client), mobile-design.md §1.
// Callers: flutter test (CI mobile job).

import 'dart:convert';
import 'dart:typed_data';

import 'package:agritrace/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Network stand-in: records the last request and answers with [status] and [body].
class _FakeAdapter implements HttpClientAdapter {
  /// Creates an adapter answering every request with [status] and the JSON-encoded [body].
  _FakeAdapter(this.status, this.body);

  /// HTTP status to answer with.
  final int status;

  /// JSON body to answer with.
  final Object body;

  /// The last request seen, for assertions.
  RequestOptions? last;

  /// Records [options] and returns the canned response. Throws nothing.
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
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

/// Healthz success and failure through [ApiClient].
void main() {
  const healthy = {'db': 'ok', 'redis': 'ok', 's3': 'ok'};

  test('healthz parses Health and sends device, auth headers and timeouts', () async {
    final adapter = _FakeAdapter(200, healthy);
    final client = ApiClient(
      baseUrl: 'http://api.test',
      deviceId: 'device-1',
      accessToken: () => 'tok',
      httpClientAdapter: adapter,
    );

    final health = await client.healthz();

    expect(health.db, 'ok');
    expect(health.s3, 'ok');
    final request = adapter.last!;
    expect(request.uri.toString(), 'http://api.test/v1/healthz');
    expect(request.method, 'GET');
    expect(request.headers['X-Device-Id'], 'device-1');
    expect(request.headers['Authorization'], 'Bearer tok');
    expect(request.connectTimeout, const Duration(seconds: 10));
    expect(request.receiveTimeout, const Duration(seconds: 30));
    expect(request.sendTimeout, const Duration(seconds: 30));
  });

  test('no Authorization header when signed out; 503 surfaces as DioException', () async {
    final adapter = _FakeAdapter(503, {'db': 'error: OperationalError', 'redis': 'ok', 's3': 'ok'});
    final client = ApiClient(baseUrl: 'http://api.test', deviceId: 'device-1', httpClientAdapter: adapter);

    await expectLater(client.healthz(), throwsA(isA<DioException>()));
    expect(adapter.last!.headers.containsKey('Authorization'), isFalse);
  });
}
