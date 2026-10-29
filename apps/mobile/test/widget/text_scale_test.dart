// Text-scale clamp: the user's system font scale is honoured between 1.0x and 1.5x and clamped outside.
// Requirement: mobile-design.md §6 (textScaler clamped 1.0-1.5); UserFlows §Design rules "Big targets".
// Callers: flutter test (CI mobile job).

import 'package:agritrace/app.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the app at several system text scales and reads the scaler a screen actually gets.
void main() {
  const cases = [(0.8, 10.0), (1.0, 10.0), (1.3, 13.0), (2.0, 15.0)];
  for (final (system, expected) in cases) {
    testWidgets('system text scale $system -> 10 sp renders at $expected', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = system;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = ProviderContainer.test();
      container.read(sessionProvider.notifier).signIn(Role.farmer);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
      await tester.pumpAndSettle();

      final scaler = MediaQuery.textScalerOf(tester.element(find.text('விவசாயி')));
      expect(scaler.scale(10), moreOrLessEquals(expected));
    });
  }
}
