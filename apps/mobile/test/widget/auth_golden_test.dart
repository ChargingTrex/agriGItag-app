// Pixel goldens of F01 (phone step) and the PIN step, in English and Tamil at text scale 1.0 and 1.5, on a 360 x 640
//   dp phone (tag `golden`, macOS only for now, as farmer_button_golden_test.dart).
// Requirement: WP-M06 goldens; UserFlows §Design rules ("Big targets", "Language first"); mobile-design.md §6
//   (text scale clamped 1.0-1.5). Callers: flutter test on macOS (developers); skipped on Linux CI until Q01.
// Re-record with `flutter test --update-goldens test/widget/auth_golden_test.dart` and review the PNGs.
@Tags(['golden'])
library;

import 'dart:io';

import 'package:agritrace/app.dart';
import 'package:agritrace/core/router/app_router.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/features/auth/otp_screen.dart';
import 'package:agritrace_api/agritrace_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/harness.dart';

/// Why the goldens are skipped on this platform, or null when they run (macOS).
///
/// shortcut: goldens recorded on macOS; re-record on Linux in Q01, then remove the skip.
final String? _skipReason = Platform.isMacOS
    ? null
    : 'goldens recorded on macOS, this is ${Platform.operatingSystem}; re-record on Linux in Q01';

/// One golden per screen x locale x text scale.
void main() {
  if (_skipReason != null) debugPrint('auth_golden_test: SKIPPED ($_skipReason)');
  final pinStep = PinRequiredOut(
    (b) => b
      ..kind = PinRequiredOutKindEnum.pinRequired
      ..pinToken = 'pt'
      ..expiresIn = 300
      ..pinSet = true,
  );
  for (final (screen, location, extra) in [('phone', null, null), ('pin', '/auth/pin', pinStep)]) {
    for (final locale in [english, tamil]) {
      for (final scale in [1.0, 1.5]) {
        final name = '${screen}_${locale.languageCode}_x$scale';
        testWidgets('auth $name golden', skip: _skipReason != null, (tester) async {
          tester.view
            ..physicalSize = const Size(360, 640)
            ..devicePixelRatio = 1.0;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final container = authContainer(FakeApi(), overrides: [smsCodeProvider.overrideWithValue(() async => null)]);
          container.read(sessionProvider.notifier).setLocale(locale);
          await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
          if (location != null) container.read(routerProvider).push(location, extra: extra);
          await tester.pumpAndSettle();
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('../goldens/auth/$name.png'));
        });
      }
    }
  }
}
