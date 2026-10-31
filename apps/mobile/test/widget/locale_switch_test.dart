// Locale switch: one tap re-renders the sample screen in Tamil.
// Requirement: plan §7.2 M00 acceptance "locale switch re-renders sample screen in Tamil"; UserFlows
//   §Design rules "Language first" (switched with one button).
// Callers: flutter test (CI mobile job).

import 'package:agritrace/app.dart';
import 'package:agritrace/core/router/app_router.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/harness.dart';

/// Starts in English as a field officer, opens Settings (the language button moved there from the role homes in M07 and
/// M10), taps the language button, expects Tamil strings.
void main() {
  testWidgets('language button switches the app from English to Tamil', (tester) async {
    final container = await signedIn('field_officer');
    container.read(sessionProvider.notifier).setLocale(english);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
    await tester.pumpAndSettle();

    expect(find.text('Field officer'), findsOneWidget);
    container.read(routerProvider).push('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    container.read(routerProvider).pop();
    await tester.pumpAndSettle();
    expect(find.text('கள அலுவலர்'), findsOneWidget);
    expect(find.text('Field officer'), findsNothing);
    expect(container.read(sessionProvider).locale, tamil);
    // The officer home watches Drift streams; Drift closes a cancelled stream on a zero-length timer (as in M07).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
