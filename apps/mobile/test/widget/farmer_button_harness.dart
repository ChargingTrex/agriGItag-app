// Shared test harness: pumps one FarmerButton in a themed, localised app on a 360 dp wide surface.
// Requirement: plan §7.2 M00 acceptance "FarmerButton golden at 56/64 dp".
// Callers: test/widget/farmer_button_test.dart (sizes, semantics), farmer_button_golden_test.dart (goldens).

import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/theme/app_theme.dart';
import 'package:agritrace/core/widgets/farmer_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps one [FarmerButton] labelled "Sign in" in [locale]; [prominent] picks 64 dp over 56 dp.
///
/// [tester] is the running widget test. Returns when the frame is rendered. Side effect: sets a
/// 360 x 100 dp surface, reset when the test ends.
Future<void> pumpFarmerButton(WidgetTester tester, Locale locale, {required bool prominent}) async {
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
