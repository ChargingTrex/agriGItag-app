// FarmerButton size, semantics and golden tests at 56 dp and 64 dp, in English and Tamil.
// Requirement: plan §7.2 M00 acceptance "FarmerButton golden at 56/64 dp"; UserFlows §Design rules
//   "Big targets" and "Pictures and voice before words"; mobile-design.md §6 (Semantics on icon controls).
// Callers: flutter test (CI mobile job). Regenerate goldens with `flutter test --update-goldens`.

import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/theme/app_theme.dart';
import 'package:agritrace/core/widgets/farmer_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps one [FarmerButton] labelled "Sign in" in [locale], [prominent] picking 64 dp over 56 dp.
/// Returns when the frame is rendered. Side effect: sets a 360 dp wide surface for the test.
Future<void> _pumpButton(WidgetTester tester, Locale locale, {required bool prominent}) async {
  await tester.binding.setSurfaceSize(const Size(360, 100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) => FarmerButton(
                icon: Icons.login,
                label: AppLocalizations.of(context).signIn,
                onPressed: () {},
                onSpeak: () {},
                prominent: prominent,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Golden, size and semantics checks for each locale x size.
void main() {
  for (final locale in [english, tamil]) {
    for (final prominent in [false, true]) {
      final height = prominent ? 64.0 : 56.0;
      testWidgets('FarmerButton ${locale.languageCode} ${height.toInt()} dp', (tester) async {
        await _pumpButton(tester, locale, prominent: prominent);

        expect(tester.getSize(find.bySubtype<FilledButton>()).height, height);
        expect(tester.getSize(find.byType(IconButton)), Size.square(height));
        // Full width: the row spans the 360 dp surface minus 16 dp padding on each side.
        expect(tester.getSize(find.byType(FarmerButton)).width, 328);
        final playVoice = locale == tamil ? 'குரல் கேள்' : 'Play voice';
        expect(find.bySemanticsLabel(playVoice), findsOneWidget);

        await expectLater(
          find.byType(FarmerButton),
          matchesGoldenFile('../goldens/farmer_button_${locale.languageCode}_${height.toInt()}.png'),
        );
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
