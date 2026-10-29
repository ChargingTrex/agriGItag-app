// go_router configuration: role-based redirect and the /assist/:farmerId scope.
// Requirement: plan §7.2 M00 and M06 ("farmer never reaches officer routes"), D-013, UserFlows §"Who uses
//   what" (a farmer only ever sees the farmer screens; the field officer can act for a farmer).
// Callers: AgriTraceApp (lib/app.dart) via routerProvider; test/unit/redirect_test.dart,
//   test/widget/router_test.dart.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/gen/app_localizations.dart';
import 'placeholder_screen.dart';
import 'session.dart';

/// Route prefixes each role may open; the first entry is the role's home.
/// A signed-out user (null role) may only open /auth.
const Map<Role?, List<String>> allowedPrefixes = {
  null: ['/auth'],
  Role.farmer: ['/home'],
  Role.fieldOfficer: ['/officer', '/assist'],
  Role.qc: ['/qc'],
};

/// Decides where a navigation to [location] must go for [role].
///
/// [role] is the signed-in role or null; [location] the matched path (e.g. `/assist/F-1`).
/// Returns null to allow the navigation, or the role's home path when [location] is outside the role's
/// prefixes. Throws nothing.
String? redirectFor(Role? role, String location) {
  final prefixes = allowedPrefixes[role]!;
  final allowed = prefixes.any((p) => location == p || location.startsWith('$p/'));
  return allowed ? null : prefixes.first;
}

/// The app router. Rebuilt never; it re-runs [redirectFor] whenever the session's role changes.
///
/// DECISION D-013: go_router with one redirect function instead of per-route guards.
///   ADV: the whole role matrix is one table ([allowedPrefixes]) that a test can enumerate.
///   COMPROMISE: deep links into another role's screens silently land on the caller's home.
final routerProvider = Provider<GoRouter>((ref) {
  final role = ValueNotifier<Role?>(ref.read(sessionProvider).role);
  ref.listen(sessionProvider.select((s) => s.role), (_, next) => role.value = next);

  final router = GoRouter(
    initialLocation: '/auth',
    refreshListenable: role,
    redirect: (context, state) => redirectFor(role.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).signIn),
      ),
      GoRoute(
        path: '/home',
        builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).roleFarmer),
      ),
      GoRoute(
        path: '/officer',
        builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).roleFieldOfficer),
      ),
      GoRoute(
        path: '/qc',
        builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).roleQc),
      ),
      // Assist scope: M10 nests the farmer screens under this path so every entry made here is recorded
      // with assistMode = true (CLAUDE.md §6).
      GoRoute(
        path: '/assist/:farmerId',
        builder: (context, state) =>
            PlaceholderScreen(title: AppLocalizations.of(context).assistFor(state.pathParameters['farmerId']!)),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    role.dispose();
  });
  return router;
});
