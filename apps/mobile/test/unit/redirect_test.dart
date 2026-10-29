// Table test of redirectFor: every role against every route family.
// Requirement: plan §7.2 M00 role redirect; UserFlows §"Who uses what" (a farmer only ever sees farmer
//   screens). Callers: flutter test (CI mobile job).

import 'package:agritrace/core/router/app_router.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks allowed paths return null and every other path returns the role's home.
void main() {
  const paths = ['/auth', '/home', '/officer', '/qc', '/assist/F-1', '/homework', '/qcx'];
  const expected = <Role?, Map<String, String?>>{
    null: {
      '/auth': null,
      '/home': '/auth',
      '/officer': '/auth',
      '/qc': '/auth',
      '/assist/F-1': '/auth',
      '/homework': '/auth',
      '/qcx': '/auth',
    },
    Role.farmer: {
      '/auth': '/home',
      '/home': null,
      '/officer': '/home',
      '/qc': '/home',
      '/assist/F-1': '/home',
      '/homework': '/home',
      '/qcx': '/home',
    },
    Role.fieldOfficer: {
      '/auth': '/officer',
      '/home': '/officer',
      '/officer': null,
      '/qc': '/officer',
      '/assist/F-1': null,
      '/homework': '/officer',
      '/qcx': '/officer',
    },
    Role.qc: {
      '/auth': '/qc',
      '/home': '/qc',
      '/officer': '/qc',
      '/qc': null,
      '/assist/F-1': '/qc',
      '/homework': '/qc',
      '/qcx': '/qc',
    },
  };

  for (final MapEntry(key: role, value: table) in expected.entries) {
    test('redirectFor ${role?.wireName ?? 'signed out'}', () {
      for (final path in paths) {
        expect(redirectFor(role, path), table[path], reason: path);
      }
    });
  }
}
