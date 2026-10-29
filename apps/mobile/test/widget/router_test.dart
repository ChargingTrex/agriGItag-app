// Router redirect through the real app: signed out -> /auth, each role lands on its home, a farmer cannot
// open officer routes, a field officer can open the assist scope.
// Requirement: plan §7.2 M00 (role redirect) and M06 ("farmer never reaches officer routes"); D-013.
// Callers: flutter test (CI mobile job).

import 'package:agritrace/app.dart';
import 'package:agritrace/core/router/app_router.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives the session through every role and checks the visible screen and location.
void main() {
  testWidgets('role redirect', (tester) async {
    final container = ProviderContainer.test();
    final session = container.read(sessionProvider.notifier);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);
    String path() => router.routerDelegate.currentConfiguration.uri.path;

    // Default: signed out, Tamil.
    expect(path(), '/auth');
    expect(find.text('உள்நுழை'), findsOneWidget);

    session.signIn(Role.farmer);
    await tester.pumpAndSettle();
    expect(path(), '/home');
    expect(find.text('விவசாயி'), findsOneWidget);

    for (final forbidden in ['/officer', '/qc', '/assist/F-7', '/auth']) {
      router.go(forbidden);
      await tester.pumpAndSettle();
      expect(path(), '/home', reason: 'farmer opening $forbidden');
    }

    session.signOut();
    await tester.pumpAndSettle();
    expect(path(), '/auth');

    session.signIn(Role.fieldOfficer);
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

    session.signOut();
    session.signIn(Role.qc);
    await tester.pumpAndSettle();
    expect(path(), '/qc');
    expect(find.text('தர ஆய்வாளர்'), findsOneWidget);
  });
}
