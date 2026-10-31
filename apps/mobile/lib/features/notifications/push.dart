// Push notifications seam (FCM on Android, APNs on iOS): a provider interface with the console provider this build
// ships, and the device registration behind the `push_notifications` feature flag of the `fields` bundle (off unless
// the tenant's features.yaml turns it on). No Firebase SDK is in the app yet (PLAN §13 size budget, §12 human step).
// Requirement: FR7 (push reminders); UserFlows §Alerts, help and feature phones; PLAN §7.2 M12; D-017 (feature flags
//   from YAML); D-046 (local reminders now, push later); CLAUDE.md §6 (a push payload would carry ids and a template
//   key only, B04).
// Callers: bootstrap.dart (registerPush); test/notifications/reminders_test.dart.

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/providers.dart';

/// A push service that gives this phone a device token.
abstract interface class PushProvider {
  /// The device token, or null when this build has no push service. Throws what the service throws.
  Future<String?> token();
}

/// The provider this build ships: logs and gives no token, so nothing registers.
///
/// shortcut: no FCM/APNs; when the Firebase project exists (human step, PLAN §12: google-services.json,
///   GoogleService-Info.plist, the APNs key and the Push Notifications entitlement), add firebase_messaging with a
///   LIBRARIES.md row and a provider returning its token.
class ConsolePushProvider implements PushProvider {
  /// Logs that push is not built in. Returns null; throws nothing.
  @override
  Future<String?> token() async {
    developer.log('push: no push service in this build', name: 'agritrace.push');
    return null;
  }
}

/// The app's push provider; tests override it.
final pushProviderProvider = Provider<PushProvider>((ref) => ConsolePushProvider());

/// Registers this phone for push on the app's container [c] when the `fields` bundle's `features.push_notifications`
/// is true and the provider gives a token.
///
/// Returns true when registered; false when the flag is off or absent (the default), the bundle is not downloaded yet,
/// or there is no token. Throws [FormatException] when the stored bundle is not JSON, and what the provider throws.
Future<bool> registerPush(ProviderContainer c) async {
  final row = await c.read(appDatabaseProvider).refBundlesDao.get('fields');
  final features = row == null ? null : (jsonDecode(row.bodyJson) as Map)['features'];
  if (features is! Map || features['push_notifications'] != true) return false;
  final token = await c.read(pushProviderProvider).token();
  if (token == null) return false;
  // shortcut: the API has no device-token endpoint yet (B04 delivers SMS/console only); the token goes nowhere. Add the
  //   call here with the endpoint, then server-side pushes carry only ids and a template key (CLAUDE.md §6).
  return true;
}
