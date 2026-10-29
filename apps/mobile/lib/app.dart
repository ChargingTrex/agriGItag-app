// Root widget: MaterialApp.router with theme, Tamil-first localisation, router and text-scale clamp.
// Requirement: mobile-design.md §5-§6 (gen-l10n ta default; textScaler clamped 1.0-1.5), UserFlows §Design
//   rules "Language first" and "Big targets"; D-013 (Riverpod + go_router), D-016 (ta + en bundled).
// Callers: bootstrap.dart (runApp); widget tests.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/gen/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/router/session.dart';
import 'core/theme/app_theme.dart';

/// The AgriTrace application widget. Must sit under a [ProviderScope].
class AgriTraceApp extends ConsumerWidget {
  /// Creates the app.
  const AgriTraceApp({super.key});

  /// Builds the app from the router and the session's locale.
  ///
  /// [context] is the root context; [ref] watches [routerProvider] and the session locale.
  /// Returns the [MaterialApp]; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(),
      // DECISION D-016: Tamil and English ship in the app; Tamil is the default (session starts in ta).
      //   ADV: offline first run in the farmer's language.
      //   COMPROMISE: other languages need a downloadable bundle and an app-side loader later.
      locale: ref.watch(sessionProvider.select((s) => s.locale)),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      // Large system fonts must not push farmer controls off screen: honour the user's scale up to 1.5x
      // and never shrink below 1.0x.
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(minScaleFactor: 1.0, maxScaleFactor: 1.5, child: child!),
    );
  }
}
