// Session state: who is signed in (role) and which language the app shows.
// Requirement: plan §7.2 M00 (Session provider + role redirect), UserFlows §Design rules "Language first"
//   (Tamil default, switched with one button), mobile-design.md §2 (Session row: role, locale).
// Callers: app_router.dart (redirect), app.dart (locale), placeholder_screen.dart (language switch), tests.
// M01/M06 back this with the Drift Session row and the OTP flow; the public API here stays.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The three roles the mobile app serves. Wire names match the API (`field_officer`).
enum Role {
  /// A farmer: sees only farmer screens.
  farmer('farmer'),

  /// An FPO field officer: officer screens plus assist mode for a farmer.
  fieldOfficer('field_officer'),

  /// A quality-check / grading officer at the processing unit.
  qc('qc');

  const Role(this.wireName);

  /// Name used by the API and the Drift Session row.
  final String wireName;
}

/// Tamil, the default language for the pilot FPOs (D-016).
const tamil = Locale('ta');

/// English, the second bundled language.
const english = Locale('en');

/// Immutable snapshot of the session.
@immutable
class Session {
  /// Creates a session. [role] is null while nobody is signed in; [locale] is the UI language.
  const Session({this.role, this.locale = tamil});

  /// Signed-in role, or null when signed out.
  final Role? role;

  /// Language the UI renders in.
  final Locale locale;
}

/// Holds the [Session]. The only app state in M00.
///
/// DECISION D-013: Riverpod Notifier for session state, read by go_router's redirect.
///   ADV: one provider drives both routing and locale; tests override or drive it directly.
///   COMPROMISE: plain Notifier without riverpod_annotation codegen while there is a single provider;
///   add the codegen when feature providers arrive (M01+).
class SessionNotifier extends Notifier<Session> {
  /// Initial state: signed out, Tamil. Returns the starting [Session]; throws nothing.
  @override
  Session build() => const Session();

  /// Marks [role] as signed in, keeping the language.
  ///
  /// Placeholder for M06, which signs in with OTP and persists the session. Side effect: routes redirect
  /// to the role's home. Throws nothing.
  void signIn(Role role) => state = Session(role: role, locale: state.locale);

  /// Signs out, keeping the language. Side effect: routes redirect to /auth. Throws nothing.
  void signOut() => state = Session(locale: state.locale);

  /// Switches the UI language to [locale]. Side effect: every visible string re-renders. Throws nothing.
  void setLocale(Locale locale) => state = Session(role: state.role, locale: locale);
}

/// The app-wide session provider.
final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);
