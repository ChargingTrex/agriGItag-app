// Router redirect through the real app and the real session (M06: OTP/PIN results stored by SessionNotifier):
// signed out -> /auth, each role lands on its home, a farmer cannot open officer routes, a field officer can open
// the assist scope, sign-out returns to /auth.
// Requirement: plan §7.2 M00 (role redirect) and M06 ("farmer never reaches officer routes"); D-013, D-024.
// Callers: flutter test (CI mobile job).

import 'package:agritrace/app.dart';
import 'package:agritrace/core/router/app_router.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/harness.dart';

/// Drives the session through every role and checks the visible screen and location.
void main() {
  testWidgets('role redirect', (tester) async {
    final container = authContainer(FakeApi());
    final session = container.read(sessionProvider.notifier);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);
    String path() => router.routerDelegate.currentConfiguration.uri.path;

    // Default: signed out, Tamil.
    expect(path(), '/auth');
    expect(find.text('உள்நுழை'), findsOneWidget);

    await tester.runAsync(() => session.openSession(sessionOut()));
    await tester.pumpAndSettle();
    expect(path(), '/home');
    expect(find.text('விவசாயி'), findsOneWidget);

    for (final forbidden in ['/officer', '/qc', '/assist/F-7', '/auth']) {
      router.go(forbidden);
      await tester.pumpAndSettle();
      expect(path(), '/home', reason: 'farmer opening $forbidden');
    }

    await tester.runAsync(session.signOut);
    await tester.pumpAndSettle();
    expect(path(), '/auth');

    await tester.runAsync(() => session.openSession(sessionOut(role: 'field_officer')));
    await tester.pumpAndSettle();
    expect(path(), '/officer');
    expect(find.text('கள அலுவலர்'), findsOneWidget);
    router.go('/assist/F-7');
    await tester.pumpAndSettle();
    expect(path(), '/assist/F-7');
    expect(find.text('உதவி: F-7'), findsOneWidget);
    router.go('/home');
    await tester.pumpAndSettle();
    expect(path(), '/officer');

    await tester.runAsync(() async {
      await session.signOut();
      await session.openSession(sessionOut(role: 'qc_officer'));
    });
    await tester.pumpAndSettle();
    expect(path(), '/qc');
    expect(find.text('தர ஆய்வாளர்'), findsOneWidget);
  });
}
