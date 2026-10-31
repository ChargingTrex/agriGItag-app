// Sign-in screens through the real app: phone → code request, OTP error sentences, SMS auto-fill, device_in_use
//   sheet with sign-out, PIN lockout and attempts, first PIN chosen twice, forced sign-out notice, settings sign-out.
// Requirement: FR1, UserFlows §Log in once, §Onboarding a farmer steps 1 and 9, §Who uses what (shared phones),
//   §When things go wrong (one sentence, never a code); D-024 error codes. Callers: flutter test (CI mobile job).

import 'package:agritrace/app.dart';
import 'package:agritrace/core/db/providers.dart';
import 'package:agritrace/core/router/app_router.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/features/auth/otp_screen.dart';
import 'package:agritrace_api/agritrace_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/harness.dart';
import '../db/db_fixtures.dart';

/// Pumps the app in English on [container], optionally at [location] with [extra]. Returns the current-path reader.
Future<String Function()> _pump(
  WidgetTester tester,
  ProviderContainer container, {
  String? location,
  Object? extra,
  Locale locale = english,
}) async {
  container.read(sessionProvider.notifier).setLocale(locale);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
  await tester.pumpAndSettle();
  final router = container.read(routerProvider);
  if (location != null) {
    router.push(location, extra: extra);
    await tester.pumpAndSettle();
  }
  return () => router.routerDelegate.currentConfiguration.uri.path;
}

/// Taps [digits] on the sign-in keypad, letting requests finish after each key. Returns when done.
Future<void> _type(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.widgetWithText(FilledButton, d));
    await tester.runAsync(pumpEventQueue);
    await tester.pumpAndSettle();
  }
}

/// A container on [api] whose SMS reader returns [sms] (null: no SMS read).
ProviderContainer _container(FakeApi api, {String? sms}) =>
    authContainer(api, overrides: [smsCodeProvider.overrideWithValue(() async => sms)]);

/// The PIN step answer with [pinSet].
PinRequiredOut _pinStep({required bool pinSet}) => PinRequiredOut(
  (b) => b
    ..kind = PinRequiredOutKindEnum.pinRequired
    ..pinToken = 'pt'
    ..expiresIn = 300
    ..pinSet = pinSet,
);

/// Farmer tap-target rule: every tappable control at least 56 x 56 dp (UserFlows §Design rules "Big targets").
const _farmerTapTarget = MinimumTapTargetGuideline(
  size: Size(56, 56),
  link: 'docs/source/AgriTrace — User Flows.md §Design rules',
);

/// Screen states.
void main() {
  const phone = '+919876543210', verify = 'POST /v1/auth/otp/verify', pinVerify = 'POST /v1/auth/pin/verify';

  // Each step as it is really reached (OTP and PIN are pushed, so an implied back arrow would show), in Tamil.
  for (final (location, extra) in [
    ('/auth', null),
    ('/auth/otp', phone),
    ('/auth/pin', _pinStep(pinSet: true)),
    ('/settings', null),
  ]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('$location: every control is at least 56 dp at text scale $scale', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final container = location == '/settings'
            ? (await tester.runAsync(() => signedIn('farmer')))!
            : _container(FakeApi());
        await _pump(tester, container, location: location == '/auth' ? null : location, extra: extra, locale: tamil);
        await tester.runAsync(pumpEventQueue);
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), location == '/settings' ? findsOneWidget : findsNothing);
        await expectLater(tester, meetsGuideline(_farmerTapTarget));
        if (location == '/settings') {
          // Leave the screen inside the test so Drift's outbox-count stream closes its zero-delay timer.
          await tester.pumpWidget(const SizedBox());
          for (var i = 0; i < 3; i++) {
            await tester.runAsync(pumpEventQueue);
            await tester.pump(const Duration(milliseconds: 1));
          }
        }
      });
    }
  }

  testWidgets('phone: 10 digits → Get code → OTP step', (tester) async {
    final api = FakeApi({
      'POST /v1/auth/otp/request': [(204, null)],
    });
    await _pump(tester, _container(api));
    expect(find.text('Enter mobile number'), findsOneWidget);
    final getCode = find.ancestor(of: find.text('Get code'), matching: find.bySubtype<ButtonStyleButton>());
    expect(tester.widget<ButtonStyleButton>(getCode).enabled, isFalse, reason: 'needs all 10 digits');

    await _type(tester, '9876543210');
    await tester.tap(find.text('Get code'));
    await tester.runAsync(pumpEventQueue);
    await tester.pumpAndSettle();

    expect((api.to('POST /v1/auth/otp/request').single.data as Map)['phone'], phone);
    expect(find.text('Enter the 6-digit code from the SMS'), findsOneWidget);
  });

  testWidgets('phone: rate_limited → one wait sentence in whole minutes', (tester) async {
    final api = FakeApi({
      'POST /v1/auth/otp/request': [
        (429, apiError('rate_limited', {'retry_after_s': 90})),
      ],
    });
    await _pump(tester, _container(api));
    await _type(tester, '9876543210');
    await tester.tap(find.text('Get code'));
    await tester.runAsync(pumpEventQueue);
    await tester.pumpAndSettle();
    expect(find.text('Please wait 2 min before asking for a new code.'), findsOneWidget);
  });

  testWidgets('phone: after a forced sign-out the step says why', (tester) async {
    final api = FakeApi({
      'POST /v1/auth/refresh': [(401, apiError('refresh_reused'))],
    });
    final container = await tester.runAsync(() => signedIn('farmer', api: api));
    await tester.runAsync(container!.read(sessionProvider.notifier).refreshAccessToken);
    await _pump(tester, container);
    expect(find.text('You were signed out. Please sign in again.'), findsOneWidget);
  });

  testWidgets('OTP: wrong code → sentence from otp_invalid, code cleared', (tester) async {
    final api = FakeApi({
      verify: [(422, apiError('otp_invalid'))],
    });
    await _pump(tester, _container(api), location: '/auth/otp', extra: phone);
    await _type(tester, '123456');
    expect(find.text('Wrong code. Check the SMS and try again.'), findsOneWidget);
    expect(find.text('– – – – – –'), findsOneWidget);
    expect(api.to(verify), hasLength(1));
  });

  testWidgets('OTP: the code read from the SMS is filled in and signs a farmer in', (tester) async {
    final api = FakeApi({
      verify: [(200, sessionJson())],
    });
    final path = await _pump(
      tester,
      _container(api, sms: '654321'),
      location: '/auth/otp',
      extra: phone,
    );
    await tester.runAsync(pumpEventQueue);
    await tester.pumpAndSettle();
    expect((api.to(verify).single.data as Map)['code'], '654321');
    expect(path(), '/home');
  });

  testWidgets('OTP: device_in_use → sheet → Sign out → same code retried with a new device id', (tester) async {
    final api = FakeApi({
      verify: [(409, apiError('device_in_use')), (200, sessionJson())],
    });
    final path = await _pump(tester, _container(api), location: '/auth/otp', extra: phone);
    await _type(tester, '123456');
    expect(find.text('This phone is signed in as someone else. Sign out first.'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.runAsync(pumpEventQueue);
    await tester.pumpAndSettle();
    await tester.runAsync(pumpEventQueue);
    await tester.pumpAndSettle();

    final ids = api.to(verify).map((r) => (r.data as Map)['device_id']).toList();
    expect(ids, hasLength(2));
    expect(ids[0], isNot(ids[1]));
    expect(path(), '/home');
  });

  testWidgets('PIN: pin_locked → wait sentence from locked_until', (tester) async {
    final until = DateTime.now().toUtc().add(const Duration(minutes: 4, seconds: 50));
    final api = FakeApi({
      pinVerify: [
        (409, apiError('pin_locked', {'locked_until': until.toIso8601String()})),
      ],
    });
    await _pump(tester, _container(api), location: '/auth/pin', extra: _pinStep(pinSet: true));
    expect(find.text('Enter your 4-digit PIN'), findsOneWidget);
    await _type(tester, '1234');
    expect(find.text('Too many wrong PINs. Try again in 5 min.'), findsOneWidget);
    expect(find.text('1'), findsOneWidget, reason: 'the PIN itself is never shown, only the key');
  });

  testWidgets('PIN: pin_invalid → tries left', (tester) async {
    final api = FakeApi({
      pinVerify: [
        (422, apiError('pin_invalid', {'attempts_left': 2})),
      ],
    });
    await _pump(tester, _container(api), location: '/auth/pin', extra: _pinStep(pinSet: true));
    await _type(tester, '1234');
    expect(find.text('Wrong PIN. 2 tries left.'), findsOneWidget);
  });

  testWidgets('PIN: first sign-in chooses the PIN twice; a mismatch starts over', (tester) async {
    final api = FakeApi({
      pinVerify: [(200, sessionJson(role: 'field_officer'))],
    });
    final path = await _pump(tester, _container(api), location: '/auth/pin', extra: _pinStep(pinSet: false));
    expect(find.text('Choose a 4-digit PIN'), findsOneWidget);
    await _type(tester, '1234');
    expect(find.text('Enter the same PIN again'), findsOneWidget);
    await _type(tester, '1235');
    expect(find.text('The two PINs are different. Choose again.'), findsOneWidget);
    expect(find.text('Choose a 4-digit PIN'), findsOneWidget);
    expect(api.to(pinVerify), isEmpty);

    await _type(tester, '1234');
    await _type(tester, '1234');
    expect((api.to(pinVerify).single.data as Map)['pin'], '1234');
    expect(path(), '/officer');
  });

  testWidgets('settings: unsent reminder, then Sign out → /auth with the entry kept', (tester) async {
    final api = FakeApi({
      'POST /v1/auth/logout': [(204, null)],
    });
    final container = (await tester.runAsync(() => signedIn('farmer', api: api)))!;
    final db = container.read(appDatabaseProvider);
    await tester.runAsync(() => db.entriesDao.save(entryAt(), []));
    final path = await _pump(tester, container, location: '/settings');
    await tester.runAsync(pumpEventQueue);
    await tester.pumpAndSettle();
    expect(find.text('Entries not sent yet: 1. They stay on this phone; get signal to send them.'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.runAsync(pumpEventQueue);
    await tester.pumpAndSettle();
    expect(path(), '/auth');
    expect(await tester.runAsync(() => db.outboxDao.pendingCount().first), 1);
  });
}
