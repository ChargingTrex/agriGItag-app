// AuthInterceptor through the real SessionNotifier: bearer only on secured operations, 401 → one refresh → one retry,
//   refresh shared by concurrent 401s, `refresh_reused` → signed out, no signal → stays signed in, no retry with
//   another user's token (M16, D-029).
// Requirement: D-024 contract (docs/api/conventions.md "Authentication": rotation, `refresh_reused`, never two
//   refreshes at once); UserFlows §Log in once. Callers: flutter test (CI mobile job).

import 'dart:async';

import 'package:agritrace/core/api/api_client.dart';
import 'package:agritrace/core/db/providers.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

/// Calls a secured operation (`POST /v1/auth/logout`, empty 204 answer, so no body parsing is involved) through
/// [container]'s client. Returns the response; throws [DioException].
Future<Response<void>> _me(ProviderContainer container) =>
    container.read(apiClientProvider).api.getIdentityApi().logoutV1AuthLogoutPost();

/// Interceptor cases.
void main() {
  const me = 'POST /v1/auth/logout', refresh = 'POST /v1/auth/refresh';
  const ok = (204, null);

  test('bearer goes to secured operations only', () async {
    final api = FakeApi({
      me: [ok],
      'GET /v1/healthz': [
        (200, {'db': 'ok', 'redis': 'ok', 's3': 'ok'}),
      ],
    });
    final container = await signedIn('farmer', api: api);
    await expectLater(_me(container), completes);
    await container.read(apiClientProvider).healthz();

    expect(api.to(me).single.headers['Authorization'], 'Bearer ${fakeJwt(nonce: 1)}');
    expect(api.to('GET /v1/healthz').single.headers.containsKey('Authorization'), isFalse);
    expect(
      api.requests.every((r) => !r.headers.containsKey('X-Client')),
      isTrue,
      reason: 'mobile never sends X-Client',
    );
  });

  test('401 → refresh with the stored refresh token → retry once with the new token', () async {
    final api = FakeApi({
      me: [(401, apiError('unauthorized')), ok],
      refresh: [(200, sessionJson(nonce: 2))],
    });
    final container = await signedIn('farmer', api: api);

    final response = await _me(container);

    expect(response.statusCode, 204);
    expect(api.to(refresh).single.data, {'refresh_token': 'r1'});
    expect(api.to(me).map((r) => r.headers['Authorization']), [
      'Bearer ${fakeJwt(nonce: 1)}',
      'Bearer ${fakeJwt(nonce: 2)}',
    ]);
    final stored = await storedValues();
    expect(stored['refresh_token'], 'r2', reason: 'rotated token stored');
    expect(stored['access_token'], fakeJwt(nonce: 2));
  });

  test('a retry that fails again is not retried a second time', () async {
    final api = FakeApi({
      me: [(401, apiError('unauthorized'))],
      refresh: [(200, sessionJson(nonce: 2))],
    });
    final container = await signedIn('farmer', api: api);

    await expectLater(_me(container), throwsA(isA<DioException>()));
    expect(api.to(me), hasLength(2));
    expect(api.to(refresh), hasLength(1));
  });

  test('concurrent 401s share one refresh call', () async {
    final api = FakeApi({
      me: [(401, apiError('unauthorized')), (401, apiError('unauthorized')), ok],
      refresh: [(200, sessionJson(nonce: 2))],
    });
    final container = await signedIn('farmer', api: api);

    final results = await Future.wait([_me(container), _me(container)]);

    expect(results.map((r) => r.statusCode), [204, 204]);
    expect(api.to(refresh), hasLength(1));
  });

  test('refresh_reused signs the phone out with an explanation, keeping the device id', () async {
    final api = FakeApi({
      me: [(401, apiError('unauthorized'))],
      refresh: [(401, apiError('refresh_reused'))],
    });
    final container = await signedIn('farmer', api: api);

    await expectLater(_me(container), throwsA(isA<DioException>()));

    final session = container.read(sessionProvider);
    expect(session.role, isNull);
    expect(session.sessionEnded, isTrue);
    expect(await container.read(appDatabaseProvider).sessionDao.read(), isNull);
    expect((await storedValues()).keys, ['device_id']);
  });

  test('no signal during refresh keeps the session', () async {
    final api = FakeApi({
      me: [(401, apiError('unauthorized'))],
    });
    final container = await signedIn('farmer', api: api);

    await expectLater(_me(container), throwsA(isA<DioException>()));

    expect(container.read(sessionProvider).role, Role.farmer);
    expect((await storedValues())['refresh_token'], 'r1');
  });

  test('M16: a 401 after another user signed in is not re-sent with their token (D-029)', () async {
    final api = FakeApi({
      me: [(401, apiError('unauthorized'))],
    });
    final gate = Completer<void>();
    api.gates[me] = gate.future;
    final container = await signedIn('farmer', api: api);
    final call = _me(container);
    await pumpEventQueue();
    final b = sessionOut(nonce: 7).rebuild((s) => s.accessToken = fakeJwt(sub: 'user-2', nonce: 7));
    await container.read(appDatabaseProvider).sessionDao.clear(); // user-1 signed out (offline) …
    await container.read(sessionProvider.notifier).openSession(b); // … and user-2 signs in while user-1's call is out
    gate.complete();

    await expectLater(call, throwsA(isA<DioException>()));
    expect(api.to(me), hasLength(1), reason: 'never retried with user-2\'s token');
    expect(api.to(refresh), isEmpty);
  });
}
