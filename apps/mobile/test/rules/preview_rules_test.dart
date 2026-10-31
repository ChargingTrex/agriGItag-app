// Plan acceptance for the M03 preview rules that have no Python twin yet: GI check, yield on a plot, event order,
// moisture gate and practice tags, all offline from fixtures.
// Requirement: plan §7.2 M03 acceptance; FR55, FR56, FR67, FR68, Dataflow Stage 5; D-006.
// Callers: `flutter test test/rules` (CI mobile job).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agritrace/core/refdata/models/reference.dart';
import 'package:agritrace/core/refdata/models/standards.dart';
import 'package:agritrace/core/rules/event_order.dart';
import 'package:agritrace/core/rules/gi_check.dart';
import 'package:agritrace/core/rules/moisture_limit.dart';
import 'package:agritrace/core/rules/practice_tags.dart';
import 'package:agritrace/core/rules/yield_check.dart';
import 'package:flutter_test/flutter_test.dart';

/// Decoded JSON object of `test/fixtures/[name]`. Throws: [FileSystemException] when missing.
Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync()) as Map<String, dynamic>;

void main() {
  final chilli = StandardsRules.fromJson(_fixture('dry_chilli_agmark_v1.json'));
  final region = GiRegion.fromJson(_fixture('gi_region_fixture.geojson'));
  final bundle = _fixture('reference_bundle.json');

  group('GI check (fixture octagon, east edge = meridian 78.30 E between 9.50 and 9.60 N)', () {
    // Degrees of longitude per metre at 9.55 N.
    final degPerM = 1 / (111194.93 * cos(9.55 * pi / 180));
    final buffer50 = GiRegion(polygons: region.polygons, bufferM: 50);

    test('pin inside the region is inside', () {
      expect(giCheck(buffer50, 9.55, 78.2).status, GiStatus.inside);
    });
    test('10 m outside with a 50 m buffer is near_edge (shown as a tick)', () {
      final r = giCheck(buffer50, 9.55, 78.30 + 10 * degPerM);
      expect(r.status, GiStatus.nearEdge);
      expect(r.distanceM, closeTo(10, 0.1));
    });
    test('500 m outside is outside (orange)', () {
      final r = giCheck(buffer50, 9.55, 78.30 + 500 * degPerM);
      expect(r.status, GiStatus.outside);
      expect(r.distanceM, closeTo(500, 1));
    });
    test("Madurai (9.9252, 78.1198), the server tests' far point, is outside", () {
      final r = giCheck(region, 9.9252, 78.1198);
      expect(r.status, GiStatus.outside);
      expect(r.distanceM, greaterThan(30000));
    });
    test("the fixture's own 150 m buffer: about 100 m outside is near_edge", () {
      expect(region.bufferM, 150);
      expect(giCheck(region, 9.55, 78.300911).status, GiStatus.nearEdge);
    });
    test('a point on the outline counts as inside (ST_Covers)', () {
      expect(giCheck(buffer50, 9.55, 78.30).status, GiStatus.inside);
    });
    test('a hole is outside', () {
      final holed = GiRegion(
        polygons: [
          [
            ...region.polygons.first,
            [(78.15, 9.52), (78.20, 9.52), (78.20, 9.58), (78.15, 9.58), (78.15, 9.52)],
          ],
        ],
        bufferM: 50,
      );
      expect(giCheck(holed, 9.55, 78.175).status, GiStatus.outside);
    });
  });

  group('yield on a plot (ceiling 1,000 kg/acre, 20 %/30 %)', () {
    const acre = RefPlot(id: 'p', farmerId: 'f', lat: 9.55, lon: 78.2, declaredArea: 1, areaUnit: 'acre');
    final cases = {
      1150: 'pass',
      1250: 'warn',
      1350: 'hold',
      1200: 'pass',
      1200.001: 'warn',
      1300: 'warn',
      1300.001: 'hold',
    };
    cases.forEach(
      (kg, want) => test('$kg kg on 1 acre → $want', () => expect(yieldCheck(chilli, kg: kg, plot: acre), want)),
    );
    test('150 cents = 1.5 acres: 1,950 kg is exactly 30 % over → warn', () {
      const cents = RefPlot(id: 'p', farmerId: 'f', lat: 0, lon: 0, declaredArea: 150, areaUnit: 'cent');
      expect(yieldCheck(chilli, kg: 1950, plot: cents), 'warn');
    });
  });

  group('event order (nursery and main-field tracks)', () {
    final crop = Crop.fromJson(((bundle['crops'] as Map)['crops'] as List).first as Map<String, dynamic>);
    final schema = crop.eventSchema;
    final landPrep = (type: 'land_preparation', on: DateTime(2025, 9, 30));

    test('harvest dated before sowing prompts for sowing (order_gap)', () {
      final recorded = [
        landPrep,
        (type: 'nursery', on: DateTime(2025, 9, 5)),
        (type: 'sowing', on: DateTime(2025, 11, 1)),
      ];
      expect(orderGaps(schema, recorded, 'harvest', DateTime(2025, 10, 15)), ['sowing']);
    });
    test('nursery before land preparation does not prompt', () {
      expect(orderGaps(schema, [landPrep], 'nursery', DateTime(2025, 9, 5)), isEmpty);
    });
    test('sowing before any nursery prompts for the nursery', () {
      expect(orderGaps(schema, [landPrep], 'sowing', DateTime(2025, 10, 20)), ['nursery']);
    });
    test('harvest in order does not prompt', () {
      final recorded = [
        landPrep,
        (type: 'nursery', on: DateTime(2025, 9, 5)),
        (type: 'sowing', on: DateTime(2025, 10, 20)),
      ];
      expect(orderGaps(schema, recorded, 'harvest', DateTime(2026, 2, 14)), isEmpty);
    });
  });

  group('moisture gate (ready_for_sale: drying-end moisture ≤ 11.0 %)', () {
    test('11.5 → continue drying', () => expect(moistureVerdict(chilli, 11.5), MoistureVerdict.continueDrying));
    test('10.9 → ready', () => expect(moistureVerdict(chilli, 10.9), MoistureVerdict.ready));
    test('11.0 (inclusive limit) → ready', () => expect(moistureVerdict(chilli, 11.0), MoistureVerdict.ready));
  });

  group('practice tags', () {
    final inputs = [
      for (final i in (bundle['inputs'] as Map)['inputs'] as List) InputItem.fromJson(i as Map<String, dynamic>),
    ];
    final organic = [
      for (final i in inputs)
        if (i.category != 'chemical_fertilizer') i.category,
    ];

    test('all-organic inputs derive Organic', () => expect(derivedPracticeTags(organic), {'organic'}));
    test('any chemical input derives Inorganic', () {
      expect(derivedPracticeTags([...organic, 'chemical_fertilizer']), {'inorganic'});
    });
    test('declared Inorganic with only organic inputs is a contradiction', () {
      expect(practiceFlags(declared: {'inorganic'}, inputCategories: organic, hasPestEvent: true), [
        'practice_tag_contradiction',
      ]);
    });
    test('IPM declared without a problem/pest event is flagged', () {
      expect(practiceFlags(declared: {'organic', 'ipm'}, inputCategories: organic, hasPestEvent: false), [
        'ipm_without_pest_event',
      ]);
    });
    test('PRD §12 lots (Inorganic + IPM, organic inputs, no pest event) raise both flags', () {
      expect(practiceFlags(declared: {'inorganic', 'ipm'}, inputCategories: organic, hasPestEvent: false), [
        'practice_tag_contradiction',
        'ipm_without_pest_event',
      ]);
    });
    test('`other` inputs are ignored: only `other` derives nothing and contradicts nothing', () {
      expect(derivedPracticeTags(['other']), isEmpty);
      expect(practiceFlags(declared: {'inorganic'}, inputCategories: ['other'], hasPestEvent: true), isEmpty);
    });
    test('organic inputs plus `other` still derive Organic; declared Inorganic contradicts', () {
      expect(derivedPracticeTags(['organic_fertilizer', 'other']), {'organic'});
      expect(practiceFlags(declared: {'inorganic'}, inputCategories: ['bio_pesticide', 'other'], hasPestEvent: true), [
        'practice_tag_contradiction',
      ]);
    });
    test('no inputs recorded: nothing derived, no contradiction', () {
      expect(practiceFlags(declared: {'inorganic'}, inputCategories: const [], hasPestEvent: false), isEmpty);
    });
  });
}
