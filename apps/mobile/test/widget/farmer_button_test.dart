// FarmerButton size and semantics at 56 dp and 64 dp, in English and Tamil (runs on every platform).
// Requirement: plan §7.2 M00 acceptance "FarmerButton ... at 56/64 dp"; UserFlows §Design rules
//   "Big targets" and "Pictures and voice before words"; mobile-design.md §6 (Semantics on icon controls).
// Callers: flutter test (CI mobile job). The pixel goldens are in farmer_button_golden_test.dart.

import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/theme/app_theme.dart';
import 'package:agritrace/core/widgets/farmer_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'farmer_button_harness.dart';

/// Size, full-width and semantics checks for each locale x size, plus the two-word label guard.
void main() {
  for (final locale in [english, tamil]) {
    for (final prominent in [false, true]) {
      final height = prominent ? 64.0 : 56.0;
      testWidgets('FarmerButton ${locale.languageCode} ${height.toInt()} dp size and semantics', (tester) async {
        await pumpFarmerButton(tester, locale, prominent: prominent);

        expect(tester.getSize(find.bySubtype<FilledButton>()).height, height);
        expect(tester.getSize(find.byType(IconButton)), Size.square(height));
        // Full width: the row spans the 360 dp surface minus 16 dp padding on each side.
        expect(tester.getSize(find.byType(FarmerButton)).width, 328);
        // Wide gap: the speaker starts one 16 dp token after the action button ends.
        expect(
          tester.getTopLeft(find.byType(IconButton)).dx - tester.getTopRight(find.bySubtype<FilledButton>()).dx,
          16,
        );
        final playVoice = locale == tamil ? 'குரல் கேள்' : 'Play voice';
        expect(find.bySemanticsLabel(playVoice), findsOneWidget);
      });
    }
  }

  testWidgets('FarmerButton rejects labels longer than two words', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FarmerButton(icon: Icons.login, label: 'one two three', onPressed: () {}, onSpeak: null),
      ),
    );
    expect(tester.takeException(), isA<AssertionError>());
  });
}
