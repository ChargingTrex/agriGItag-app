// Every string key exists in both Tamil and English with an @description, including every sign-in key M06 added.
// Requirement: mobile-design.md §5 (ta default, en second; prompt id = string key), UserFlows §Design rules
//   "Language first"; CLAUDE.md §5 (descriptions). Callers: flutter test (CI mobile job).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads the string keys (not `@` metadata) of `app_<lang>.arb`. Returns the decoded map; throws on a bad file.
Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/core/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

/// Key parity and the M06 key list.
void main() {
  const authKeys = [
    'authPhoneTitle',
    'authGetCode',
    'authOtpTitle',
    'authResend',
    'authPinTitle',
    'authPinChoose',
    'authPinRepeat',
    'authPinMismatch',
    'authStartAgain',
    'authDelete',
    'errorOtpInvalid',
    'errorOtpExpired',
    'errorOtpLocked',
    'errorPinInvalid',
    'errorPinLocked',
    'errorRateLimited',
    'errorDeviceInUse',
    'errorSignInExpired',
    'errorPhoneInvalid',
    'errorNetwork',
    'errorPortalOnly',
    'errorUnknown',
    'sessionEnded',
    'signOut',
    'settingsTitle',
    'unsentReminder',
  ];

  test('ta and en have the same keys, each described, and every sign-in key', () {
    final ta = _arb('ta'), en = _arb('en');
    Set<String> keys(Map<String, dynamic> arb) => arb.keys.where((k) => !k.startsWith('@')).toSet();
    expect(keys(en), keys(ta));
    expect(keys(ta), containsAll(authKeys));
    for (final key in keys(ta)) {
      for (final arb in [ta, en]) {
        expect((arb['@$key'] as Map?)?['description'], isNotEmpty, reason: '@$key description');
      }
      expect(ta[key], isNot(en[key]), reason: '$key looks untranslated');
    }
  });
}
