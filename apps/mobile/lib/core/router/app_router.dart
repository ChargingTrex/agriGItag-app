// go_router configuration: role-based redirect and the /assist/:farmerId scope.
// Requirement: plan §7.2 M00 and M06 ("farmer never reaches officer routes"), D-013, UserFlows §"Who uses
//   what" (a farmer only ever sees the farmer screens; the field officer can act for a farmer).
//   M06 wires the real sign-in screens (UserFlows §Log in once) and the /settings placeholder with sign-out;
//   M09 adds /officer/onboard (UserFlows §Onboarding a farmer).
// Callers: AgriTraceApp (lib/app.dart) via routerProvider; test/unit/redirect_test.dart,
//   test/widget/router_test.dart.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agritrace_api/agritrace_api.dart' show PinRequiredOut;

import '../../features/auth/otp_screen.dart';
import '../../features/auth/phone_screen.dart';
import '../../features/auth/pin_screen.dart';
import '../../features/onboarding_farmer/onboarding_wizard.dart';
import '../l10n/gen/app_localizations.dart';
import 'placeholder_screen.dart';
import 'session.dart';

/// Route prefixes each role may open; the first entry is the role's home.
/// A signed-out user (null role) may only open /auth (phone, /auth/otp, /auth/pin); every signed-in role may open
/// /settings (sign-out; M08 replaces the placeholder).
const Map<Role?, List<String>> allowedPrefixes = {
  null: ['/auth'],
  Role.farmer: ['/home', '/settings'],
  Role.fieldOfficer: ['/officer', '/assist', '/settings'],
  Role.qc: ['/qc', '/settings'],
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
      // The OTP and PIN steps need what the previous step returned (`extra`); without it (deep link, restored
      // route) they fall back to the phone step.
      GoRoute(
        path: '/auth',
        builder: (context, _) => const PhoneScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (context, state) =>
                state.extra is String ? OtpScreen(phone: state.extra! as String) : const PhoneScreen(),
          ),
          GoRoute(
            path: 'pin',
            builder: (context, state) =>
                state.extra is PinRequiredOut ? PinScreen(step: state.extra! as PinRequiredOut) : const PhoneScreen(),
          ),
        ],
      ),
      GoRoute(path: '/settings', builder: (context, _) => const SettingsPlaceholder()),
      GoRoute(
        path: '/home',
        builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).roleFarmer),
      ),
      GoRoute(
        path: '/officer',
        builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).roleFieldOfficer),
        // M09: the officer's onboarding wizard (UserFlows §Onboarding a farmer); M10's home links "Add farmer" here.
        routes: [GoRoute(path: 'onboard', builder: (context, _) => const OnboardingWizard())],
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
