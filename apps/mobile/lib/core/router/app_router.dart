// go_router configuration: role-based redirect and the /assist/:farmerId scope.
// Requirement: plan §7.2 M00 and M06 ("farmer never reaches officer routes"), D-013, UserFlows §"Who uses
//   what" (a farmer only ever sees the farmer screens; the field officer can act for a farmer).
//   M06 wires the real sign-in screens (UserFlows §Log in once) and the /settings placeholder with sign-out;
//   M09 adds /officer/onboard (UserFlows §Onboarding a farmer).
//   M07 adds the farmer home and event routes (UserFlows §Farmer home screen, §Logging a farm event; F17 deep link
//   `/log/<eventType>`) and a farmer-friendly page for unknown routes (UserFlows §When things go wrong).
//   M10 adds the officer home, flags and assist mode (UserFlows §Field officer flows): under `/assist/:farmerId` the
//   farmer's home and event screens run again for the assisted farmer, only while that farmer's assist session runs.
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
import '../../features/officer_assist/assist_controller.dart';
import '../../features/officer_flags/flag_actions.dart' show FlagAction;
import '../../features/officer_flags/flags_screen.dart';
import '../../features/officer_home/officer_home_screen.dart';
import '../../features/officer_moisture/moisture_screen.dart';
import '../../features/onboarding_farmer/onboarding_wizard.dart';
import '../l10n/gen/app_localizations.dart';
import 'placeholder_screen.dart';
import 'session.dart';

/// Route prefixes each role may open; the first entry is the role's home.
/// A signed-out user (null role) may only open /auth (phone, /auth/otp, /auth/pin); every signed-in role may open
/// /settings (sign-out; M08 replaces the placeholder). A farmer's event flow lives under /log (F04–F07, deep links).
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

/// The location one level up from the route [state] matched (`/log/harvest/confirm` → `/log/harvest`), so a route
/// redirect works the same at `/log/...` and at `/assist/<id>/log/...`. Returns the path; throws nothing.
String _parent(GoRouterState state) => state.matchedLocation.substring(0, state.matchedLocation.lastIndexOf('/'));

/// The app router. Rebuilt never; it re-runs [redirectFor] whenever the session's role changes.
///
/// DECISION D-013: go_router with one redirect function instead of per-route guards.
///   ADV: the whole role matrix is one table ([allowedPrefixes]) that a test can enumerate.
///   COMPROMISE: deep links into another role's screens silently land on the caller's home.
final routerProvider = Provider<GoRouter>((ref) {
  final role = ValueNotifier<Role?>(ref.read(sessionProvider).role);
  ref.listen(sessionProvider.select((s) => s.role), (_, next) => role.value = next);

  // The farmer's screens below home, and the event flow, built twice: for the farmer at `/home` and `/log`, and for
  // an assisted farmer under `/assist/:farmerId` (go_router needs one route object per place in the tree).
  List<RouteBase> homeRoutes() => [
    // Only reachable right after a save; a restored or typed URL goes home.
    GoRoute(
      path: 'saved',
      redirect: (context, state) => ref.read(eventLogProvider).savedEntryId == null ? _parent(state) : null,
      builder: (context, _) => const SavedScreen(),
    ),
    // Placeholders until M08 (Sell, Money) and M09 (My farm).
    GoRoute(
      path: 'sell',
      builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).homeSell),
    ),
    GoRoute(
      path: 'money',
      builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).homeMoney),
    ),
    GoRoute(
      path: 'farm',
      builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).homeMyFarm),
    ),
  ];
  GoRoute logRoute(String path) => GoRoute(
    path: path,
    builder: (context, _) => const ChooseEventScreen(),
    routes: [
      // F17: `/log/harvest` preselects the event; an unknown event type falls back to the event grid.
      GoRoute(
        path: ':eventType',
        redirect: (context, state) =>
            FarmEvent.fromWire(state.pathParameters['eventType']) == null ? _parent(state) : null,
        // Keyed by event: going from /log/packing to /log/harvest must start a new flow, not reuse the state.
        builder: (context, state) {
          final event = FarmEvent.fromWire(state.pathParameters['eventType'])!;
          return EventFlowScreen(key: ValueKey(event), event: event);
        },
        routes: [
          GoRoute(
            path: 'confirm',
            // Confirm needs a photo in the draft; without one (restored route) go back to the camera.
            redirect: (context, state) => ref.read(eventLogProvider).photo == null ? _parent(state) : null,
            builder: (context, _) => const ConfirmScreen(),
          ),
        ],
      ),
    ],
  );

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
      GoRoute(path: '/settings', builder: (context, _) => const SettingsPlaceholder()),
      GoRoute(path: '/home', builder: (context, _) => const FarmerHomeScreen(), routes: homeRoutes()),
      logRoute('/log'),
      GoRoute(
        path: '/officer',
        builder: (context, _) => const OfficerHomeScreen(),
        routes: [
          // M09: the officer's onboarding wizard (UserFlows §Onboarding a farmer), the home's "Add farmer".
          GoRoute(path: 'onboard', builder: (context, _) => const OnboardingWizard()),
          GoRoute(
            path: 'flags',
            builder: (context, _) => const FlagsScreen(),
            routes: [
              GoRoute(
                path: ':flagId',
                builder: (context, state) => FlagDetailScreen(flagId: state.pathParameters['flagId']!),
                routes: [
                  GoRoute(
                    path: ':action',
                    redirect: (context, state) =>
                        FlagAction.fromName(state.pathParameters['action']) == null ? _parent(state) : null,
                    builder: (context, state) => FlagActionScreen(
                      flagId: state.pathParameters['flagId']!,
                      action: FlagAction.fromName(state.pathParameters['action'])!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/qc',
        builder: (context, _) => PlaceholderScreen(title: AppLocalizations.of(context).roleQc),
      ),
      // DECISION D-034: assist mode is this route scope: the farmer screens again, for the assisted farmer, open only
      //   while that farmer's assist session runs (typed URL, app restarted → officer home).
      //   ADV: no copy of the farmer UI; every entry made here gets assistMode and the session (CLAUDE.md §6, D-032).
      //   COMPROMISE: routes exist twice and M07 screens must navigate through `farmerPath`.
      GoRoute(
        path: '/assist/:farmerId',
        redirect: (context, state) =>
            ref.read(assistProvider)?.farmerId == state.pathParameters['farmerId'] ? null : '/officer',
        builder: (context, _) => const FarmerHomeScreen(),
        routes: [
          ...homeRoutes(),
          logRoute('log'),
          GoRoute(path: 'moisture', builder: (context, _) => const MoistureScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    role.dispose();
  });
  return router;
});
