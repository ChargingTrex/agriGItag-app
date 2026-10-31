// Contract test of the Dart grade preview: every case of the shared grade_cases.json gives the outcome the Python
// engine's test expects (same assertions as apps/api/tests/unit/test_grade_engine.py).
// Requirement: D-006 contract test (plan §7.2 M03), FR44, FR48–FR51, FR68, Dataflow Stages 5, 7, 8.
// Callers: `flutter test test/rules` (CI mobile job). test/fixtures/grade_cases.json is a byte-identical copy of
//   apps/api/tests/fixtures/grade_cases.json (tool/check_shared_fixtures.sh).

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/refdata/models/standards.dart';
import 'package:agritrace/core/rules/grade_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

final _cases = jsonDecode(File('test/fixtures/grade_cases.json').readAsStringSync()) as Map<String, dynamic>;

/// The rules a case names: a key of the fixture's `profiles`, else `test/fixtures/<name>.json`.
///
/// [name] is the case's `profile`. Returns the parsed rules. Throws: [FileSystemException] for an unknown name.
StandardsRules _rules(String name) {
  final inline = (_cases['profiles'] as Map<String, dynamic>)[name];
  final json = inline ?? jsonDecode(File('test/fixtures/$name.json').readAsStringSync());
  return StandardsRules.fromJson(json as Map<String, dynamic>);
}

/// The cases of fixture section [kind] (e.g. `compute`). Throws: [TypeError] when the section is missing.
List<Map<String, dynamic>> _section(String kind) => (_cases[kind] as List<dynamic>).cast<Map<String, dynamic>>();

/// The readings list under [key] of [c], parsed. Throws: [TypeError] or [FormatException] on a bad reading.
List<Reading> _readings(Map<String, dynamic> c, String key) => [
  for (final r in c[key] as List<dynamic>) Reading.fromJson(r as Map<String, dynamic>),
];

void main() {
  group('compute', () {
    for (final c in _section('compute')) {
      test(c['name'] as String, () {
        final flags = (c['exception_flags'] as List<dynamic>? ?? const []).cast<String>();
        final result = compute(_rules(c['profile'] as String), _readings(c, 'readings'), flags);
        final want = c['expect'] as Map<String, dynamic>;
        expect((result.status, result.grade), (want['status'], want['grade']));
        if (want.containsKey('lab_certified')) expect(result.labCertified, want['lab_certified']);
        if (want.containsKey('profile_incomplete')) expect(result.profileIncomplete, want['profile_incomplete']);
        if (want.containsKey('missing_required')) expect(result.missingRequired, want['missing_required']);
        if (want.containsKey('warnings')) expect(result.warnings, want['warnings']);
        final per = result.perParameter.values;
        if (want.containsKey('lab_parameters')) {
          expect([
            for (final p in per)
              if (p.labCertified) p.parameter,
          ], want['lab_parameters']);
        }
        if (want.containsKey('capped')) {
          expect([
            for (final p in per)
              if (p.cappedBySource) p.parameter,
          ], want['capped']);
        }
      });
    }
  });

  group('declared', () {
    for (final c in _section('declared')) {
      test(c['name'] as String, () {
        final verdict = declaredVsComputed(
          _rules(c['profile'] as String),
          c['declared'] as String,
          c['computed'] as String?,
        );
        expect(verdict, c['expect']);
      });
    }
  });

  group('plausibility', () {
    for (final c in _section('plausibility')) {
      test(c['name'] as String, () {
        final found = checkPlausibility(
          _rules(c['profile'] as String),
          Reading.fromJson(c['reading'] as Map<String, dynamic>),
        );
        expect([for (final v in found) v.code], c['expect']);
      });
    }
  });

  group('trail', () {
    for (final c in _section('trail')) {
      test(c['name'] as String, () {
        final found = checkTrail(
          _rules(c['profile'] as String),
          _readings(c, 'prior'),
          Reading.fromJson(c['reading'] as Map<String, dynamic>),
        );
        expect(found?.code, c['expect']);
        if (found != null) expect(found.overridable, c['overridable']);
      });
    }
  });

  group('yield', () {
    for (final c in _section('yield')) {
      // Raw JSON types (int, double or String), as the Python test passes them.
      test(
        c['name'] as String,
        () =>
            expect(yieldOutcome(_rules(c['profile'] as String), c['kg'] as Object, c['acres'] as Object), c['expect']),
      );
    }
  });

  group('lot_gate', () {
    for (final c in _section('lot_gate')) {
      test(
        c['name'] as String,
        () =>
            expect(lotGate(_rules(c['profile'] as String), c['gate'] as String, _readings(c, 'readings')), c['expect']),
      );
    }
  });

  test('rank orders grades best first, then the fail grade; unknown names are null', () {
    final rules = _rules('dry_chilli_agmark_v1');
    expect(
      [
        for (final g in ['Special', 'Standard', 'Below grade', 'A']) rank(rules, g),
      ],
      [0, 1, 2, null],
    );
  });

  test('per-parameter detail names the limit reached and the skipped parameters', () {
    final reading = Reading(
      parameterCode: 'moisture',
      value: toDecimal('10.5'),
      unit: '%',
      stage: 'grading',
      source: 'lab',
    );
    final per = compute(_rules('dry_chilli_agmark_v1'), [reading]).perParameter;
    expect(per['moisture']!.grade, 'Standard');
    expect(per['moisture']!.limit!.max, toDecimal('11.0'));
    expect(per['extraneous_matter']!.outcome, 'profile_incomplete');
    expect(per['capsaicinoid']!.outcome, 'not_graded');
  });

  test('plan acceptance: chilli {moisture 10.5} previews Standard', () {
    final reading = Reading(
      parameterCode: 'moisture',
      value: toDecimal(10.5),
      unit: '%',
      stage: 'grading',
      source: 'instrument',
    );
    expect(compute(_rules('dry_chilli_agmark_v1'), [reading]).grade, 'Standard');
  });
}
