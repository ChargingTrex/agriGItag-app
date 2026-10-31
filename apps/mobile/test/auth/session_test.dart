// SessionNotifier: restore matrix on app open, OTP/PIN sign-in storage (tokens in secure storage, never in SQLite),
//   portal-only accounts, device_in_use recovery and sign-out keeping the outbox.
// Requirement: UserFlows §Log in once, §When things go wrong "Phone lost or changed", §Who uses what (shared phones);
//   D-024 contract; D-027 (tokens in the platform keystore). Callers: flutter test (CI mobile job).

import 'dart:async';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/db/providers.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../db/db_fixtures.dart';
import 'harness.dart';

/// Secure storage of a signed-in phone whose access token expires at [expires].
Map<String, String> _tokens(DateTime expires) => {
  'device_id': 'dev-1',
  'access_token': fakeJwt(nonce: 1),
  'refresh_token': 'r1',
  'access_expires_at': expires.toIso8601String(),
};

/// Writes a farmer Session row into [db]. Returns when written; throws nothing.
Future<void> _row(AppDatabase db) =>
    db.sessionDao.save(userId: 'user-1', role: Role.farmer, fpoId: 'fpo-1', deviceId: 'dev-1', locale: 'en');

/// Restore matrix, sign-in and sign-out.
void main() {
  const refresh = 'POST /v1/auth/refresh', verify = 'POST /v1/auth/otp/verify', logout = 'POST /v1/auth/logout';
  final later = DateTime.now().add(const Duration(minutes: 10));
  final earlier = DateTime.now().subtract(const Duration(minutes: 1));

  group('restore', () {
    test('nothing stored → signed out, no network', () async {
      final api = FakeApi();
      final container = authContainer(api);
      await container.read(sessionProvider.notifier).restore();
      expect(container.read(sessionProvider).role, isNull);
      expect(api.requests, isEmpty);
    });

    test('row + valid access token → signed in at once with the stored language, no network', () async {
      final api = FakeApi();
      final db = memoryDb();
      await _row(db);
      final container = authContainer(api, db: db, stored: _tokens(later));
      await container.read(sessionProvider.notifier).restore();
      expect(container.read(sessionProvider).role, Role.farmer);
      expect(container.read(sessionProvider).locale, english);
      expect(container.read(sessionProvider.notifier).accessToken, fakeJwt(nonce: 1));
      expect(api.requests, isEmpty);
    });

    test('row + expired access token → signed in, refreshed in the background', () async {
      final api = FakeApi({
        refresh: [(200, sessionJson(nonce: 2))],
      });
      final db = memoryDb();
      await _row(db);
      final container = authContainer(api, db: db, stored: _tokens(earlier));
      await container.read(sessionProvider.notifier).restore();
      expect(container.read(sessionProvider).role, Role.farmer);
      await pumpEventQueue();
      expect(api.to(refresh), hasLength(1));
      expect(container.read(sessionProvider.notifier).accessToken, fakeJwt(nonce: 2));
    });

    test('expired + refresh_reused → signed out with an explanation', () async {
      final api = FakeApi({
        refresh: [(401, apiError('refresh_reused'))],
      });
      final db = memoryDb();
      await _row(db);
      final container = authContainer(api, db: db, stored: _tokens(earlier));
      await container.read(sessionProvider.notifier).restore();
      await pumpEventQueue();
      expect(container.read(sessionProvider).role, isNull);
      expect(container.read(sessionProvider).sessionEnded, isTrue);
      expect(await db.sessionDao.read(), isNull);
    });

    test('expired + no signal → stays signed in (offline first)', () async {
      final db = memoryDb();
      await _row(db);
      final container = authContainer(FakeApi(), db: db, stored: _tokens(earlier));
      await container.read(sessionProvider.notifier).restore();
      await pumpEventQueue();
      expect(container.read(sessionProvider).role, Role.farmer);
      expect((await storedValues())['refresh_token'], 'r1');
    });

    test('row without tokens (keystore wiped) → signed out, row removed', () async {
      final db = memoryDb();
      await _row(db);
      final container = authContainer(FakeApi(), db: db, stored: {'device_id': 'dev-1'});
      await container.read(sessionProvider.notifier).restore();
      expect(container.read(sessionProvider).role, isNull);
      expect(await db.sessionDao.read(), isNull);
    });

    test('tokens without a row (Keychain outlived a reinstall) → signed out, tokens removed, device id kept', () async {
      final container = authContainer(FakeApi(), stored: _tokens(later));
      await container.read(sessionProvider.notifier).restore();
      expect(container.read(sessionProvider).role, isNull);
      expect(await storedValues(), {'device_id': 'dev-1'});
    });
  });

  group('sign-in', () {
    test('farmer OTP → Session row without tokens, tokens in secure storage', () async {
      final api = FakeApi({
        verify: [(200, sessionJson())],
      });
      final container = authContainer(api);
      final step = await container.read(sessionProvider.notifier).verifyOtp('+919876543210', '123456');

      expect(step, isNull);
      expect(container.read(sessionProvider).role, Role.farmer);
      final body = api.to(verify).single.data as Map;
      expect(body['phone'], '+919876543210');
      expect(body['platform'], 'android');
      final stored = await storedValues();
      expect(body['device_id'], stored['device_id']);
      expect(stored['refresh_token'], 'r1');
      final row = (await container.read(appDatabaseProvider).sessionDao.read())!;
      expect((row.userId, row.fpoId, row.deviceId), ('user-1', 'fpo-1', stored['device_id']));
      expect((row.accessToken, row.refreshToken), ('', ''), reason: 'D-027: no tokens in SQLite');
    });

    test('officer OTP → PIN step; PIN verify sends the pin token and signs in as field officer', () async {
      final api = FakeApi({
        verify: [
          (200, {'kind': 'pin_required', 'pin_token': 'pt', 'expires_in': 300, 'pin_set': true}),
        ],
        'POST /v1/auth/pin/verify': [(200, sessionJson(role: 'field_officer'))],
      });
      final container = authContainer(api);
      final notifier = container.read(sessionProvider.notifier);
      final step = (await notifier.verifyOtp('+919876543210', '123456'))!;
      expect((step.pinToken, step.pinSet), ('pt', true));
      expect(container.read(sessionProvider).role, isNull, reason: 'no session before the PIN');

      await notifier.verifyPin(step.pinToken, '4321');
      expect(api.to('POST /v1/auth/pin/verify').single.headers['Authorization'], 'Bearer pt');
      expect(container.read(sessionProvider).role, Role.fieldOfficer);
    });

    test('portal-only account → portal_only, signed out again on the server', () async {
      final api = FakeApi({
        verify: [(200, sessionJson(role: 'fpo_admin'))],
        logout: [(204, null)],
      });
      final container = authContainer(api);
      await expectLater(
        container.read(sessionProvider.notifier).verifyOtp('+919876543210', '123456'),
        throwsA(isA<AuthFailure>().having((f) => f.code, 'code', 'portal_only')),
      );
      expect(api.to(logout), hasLength(1));
      expect(container.read(sessionProvider).role, isNull);
      expect((await storedValues()).containsKey('refresh_token'), isFalse);
    });

    test('device_in_use → forgetDevice → the retry sends a new device id', () async {
      final api = FakeApi({
        verify: [(409, apiError('device_in_use')), (200, sessionJson())],
      });
      final container = authContainer(api);
      final notifier = container.read(sessionProvider.notifier);
      await expectLater(
        notifier.verifyOtp('+919876543210', '123456'),
        throwsA(predicate((Object e) => AuthFailure.from(e).code == 'device_in_use')),
      );

      await notifier.forgetDevice();
      await notifier.verifyOtp('+919876543210', '123456');
      final ids = api.to(verify).map((r) => (r.data as Map)['device_id']).toList();
      expect(ids[0], isNot(ids[1]));
      expect(container.read(sessionProvider).role, Role.farmer);
    });

    test('AuthFailure.from maps envelopes, missing answers and other errors', () {
      final options = RequestOptions(path: '/x');
      final envelope = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 422,
          data: apiError('pin_invalid', {'attempts_left': 2}),
        ),
      );
      expect(AuthFailure.from(envelope).details, {'attempts_left': 2});
      expect(AuthFailure.from(DioException.connectionError(requestOptions: options, reason: 'x')).code, 'network');
      expect(AuthFailure.from(StateError('x')).code, 'unknown');
    });
  });

  group('sign-out', () {
    test('calls logout, clears tokens and row, keeps the device id and every outbox row', () async {
      final api = FakeApi({
        logout: [(204, null)],
      });
      final container = await signedIn('farmer', api: api);
      final db = container.read(appDatabaseProvider);
      await db.entriesDao.save(entryAt(), []);

      await container.read(sessionProvider.notifier).signOut();

      expect(api.to(logout).single.headers['Authorization'], 'Bearer ${fakeJwt(nonce: 1)}');
      expect(container.read(sessionProvider).role, isNull);
      expect(container.read(sessionProvider).sessionEnded, isFalse);
      expect(await db.sessionDao.read(), isNull);
      expect((await storedValues()).keys, ['device_id']);
      expect(await db.outboxDao.pendingCount().first, 1, reason: 'unsent entries are never deleted');
    });

    test('a refresh answer arriving after sign-out is discarded', () async {
      final api = FakeApi({
        refresh: [(200, sessionJson(nonce: 2))],
        logout: [(204, null)],
      });
      final gate = Completer<void>();
      api.gates[refresh] = gate.future;
      final container = await signedIn('farmer', api: api);
      final notifier = container.read(sessionProvider.notifier);

      final pending = notifier.refreshAccessToken();
      await notifier.signOut();
      gate.complete();

      expect(await pending, isNull);
      expect(notifier.accessToken, isNull);
      expect((await storedValues()).keys, ['device_id'], reason: 'no tokens written back after sign-out');
      expect(container.read(sessionProvider).role, isNull);
      expect(container.read(sessionProvider).sessionEnded, isFalse);
    });

    test('no signal → signed out on the phone anyway', () async {
      final container = await signedIn('farmer');
      await container.read(sessionProvider.notifier).signOut();
      expect(container.read(sessionProvider).role, isNull);
      expect((await storedValues()).containsKey('access_token'), isFalse);
    });
  });
}
