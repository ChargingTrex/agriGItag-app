// Locale switch: one tap re-renders the sample screen in Tamil.
// Requirement: plan §7.2 M00 acceptance "locale switch re-renders sample screen in Tamil"; UserFlows
//   §Design rules "Language first" (switched with one button).
// Callers: flutter test (CI mobile job).

import 'package:agritrace/app.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Starts in English as a farmer, taps the language button, expects Tamil strings.
void main() {
  testWidgets('language button switches the farmer screen from English to Tamil', (tester) async {
    final container = ProviderContainer.test();
    container.read(sessionProvider.notifier)
      ..setLocale(english)
      ..signIn(Role.farmer);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
    await tester.pumpAndSettle();

    expect(find.text('Farmer'), findsOneWidget);
    expect(find.text('AgriTrace'), findsOneWidget);

    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();

    expect(find.text('விவசாயி'), findsOneWidget);
    expect(find.text('அக்ரிட்ரேஸ்'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Farmer'), findsNothing);
    expect(container.read(sessionProvider).locale, tamil);
  });
}
