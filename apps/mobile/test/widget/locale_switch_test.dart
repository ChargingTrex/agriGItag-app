// Locale switch: one tap re-renders the sample screen in Tamil.
// Requirement: plan §7.2 M00 acceptance "locale switch re-renders sample screen in Tamil"; UserFlows
//   §Design rules "Language first" (switched with one button).
// Callers: flutter test (CI mobile job).

import 'package:agritrace/app.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/harness.dart';

/// Starts in English as a field officer (whose home is still the placeholder with the language button; the farmer home
/// moved it to Settings in M07), taps the language button, expects Tamil strings.
void main() {
  testWidgets('language button switches the placeholder screen from English to Tamil', (tester) async {
    final container = await signedIn('field_officer');
    container.read(sessionProvider.notifier).setLocale(english);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
    await tester.pumpAndSettle();

    expect(find.text('Field officer'), findsOneWidget);
    expect(find.text('AgriTrace'), findsOneWidget);

    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();

    expect(find.text('கள அலுவலர்'), findsOneWidget);
    expect(find.text('அக்ரிட்ரேஸ்'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Field officer'), findsNothing);
    expect(container.read(sessionProvider).locale, tamil);
  });
}
