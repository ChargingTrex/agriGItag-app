// go_router configuration: role-based redirect and the /assist/:farmerId scope.
// Requirement: plan §7.2 M00 and M06 ("farmer never reaches officer routes"), D-013, UserFlows §"Who uses
//   what" (a farmer only ever sees the farmer screens; the field officer can act for a farmer).
//   M06 wires the real sign-in screens (UserFlows §Log in once) and the /settings placeholder with sign-out;
//   M09 adds /officer/onboard (UserFlows §Onboarding a farmer).
//   M07 adds the farmer home and event routes (UserFlows §Farmer home screen, §Logging a farm event; F17 deep link
//   `/log/<eventType>`) and a farmer-friendly page for unknown routes (UserFlows §When things go wrong).
//   M08 adds Sell, Money, History (+ entry detail) and the real Settings (UserFlows §Selling to the FPO).
// Callers: AgriTraceApp (lib/app.dart) via routerProvider; test/unit/redirect_test.dart,
//   test/widget/router_test.dart.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agritrace_api/agritrace_api.dart' show PinRequiredOut;

import '../../features/auth/otp_screen.dart';
import '../../features/auth/phone_screen.dart';
import '../../features/auth/pin_screen.dart';
import '../../features/event_log/choose_event_screen.dart';
import '../../features/event_log/confirm_screen.dart';
import '../../features/event_log/event_flow_screen.dart';
import '../../features/event_log/event_log_controller.dart';
import '../../features/event_log/farm_event.dart';
import '../../features/event_log/saved_screen.dart';
import '../../features/farmer_home/farmer_home_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/money/money_screen.dart';
import '../../features/onboarding_farmer/onboarding_wizard.dart';
import '../../features/sell/sell_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../l10n/gen/app_localizations.dart';
import 'placeholder_screen.dart';
import 'session.dart';

/// Route prefixes each role may open; the first entry is the role's home.
/// A signed-out user (null role) may only open /auth (phone, /auth/otp, /auth/pin); every signed-in role may open
/// /settings (language, Wi-Fi-only photos, voice tour, sign-out). A farmer's event flow lives under /log (F04–F07,
/// deep links).
const Map<Role?, List<String>> allowedPrefixes = {
  null: ['/auth'],
  Role.farmer: ['/home', '/log', '/settings'],
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
    errorBuilder: (context, _) => const NotFoundScreen(),
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
      GoRoute(path: '/settings', builder: (context, _) => const SettingsScreen()),
      GoRoute(
        path: '/home',
        builder: (context, _) => const FarmerHomeScreen(),
        routes: [
          // Only reachable right after a save; a restored or typed URL goes home.
          GoRoute(
            path: 'saved',
            redirect: (context, _) => ref.read(eventLogProvider).savedEntryId == null ? '/home' : null,
            builder: (context, _) => const SavedScreen(),
          ),
          GoRoute(path: 'sell', builder: (context, _) => const SellScreen()),
          GoRoute(path: 'money', builder: (context, _) => const MoneyScreen()),
          GoRoute(
            path: 'history',
            builder: (context, _) => const HistoryScreen(),
            routes: [
              GoRoute(
                path: ':entryId',
                builder: (context, state) => HistoryDetailScreen(entryId: state.pathParameters['entryId']!),
              ),
            ],
          ),
          // Placeholder until My farm lands.
          GoRoute(
            path: 'farm',
            builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).homeMyFarm),
          ),
        ],
      ),
      GoRoute(
        path: '/log',
        builder: (context, _) => const ChooseEventScreen(),
        routes: [
          // F17: `/log/harvest` preselects the event; an unknown event type falls back to the event grid.
          GoRoute(
            path: ':eventType',
            redirect: (context, state) => FarmEvent.fromWire(state.pathParameters['eventType']) == null ? '/log' : null,
            // Keyed by event: going from /log/packing to /log/harvest must start a new flow, not reuse the state.
            builder: (context, state) {
              final event = FarmEvent.fromWire(state.pathParameters['eventType'])!;
              return EventFlowScreen(key: ValueKey(event), event: event);
            },
            routes: [
              GoRoute(
                path: 'confirm',
                // Confirm needs a photo in the draft; without one (restored route) go back to the camera.
                redirect: (context, state) =>
                    ref.read(eventLogProvider).photo == null ? '/log/${state.pathParameters['eventType']}' : null,
                builder: (context, _) => const ConfirmScreen(),
              ),
            ],
          ),
        ],
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
