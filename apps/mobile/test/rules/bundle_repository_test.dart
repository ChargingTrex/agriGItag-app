// BundleRepository reads RefBundles rows into typed models, and returns empty/null before the first download.
// Requirement: D-006, D-016 (reference data as bundles), backend-design.md §3 bundle parts, mobile-design.md §1.
// Callers: `flutter test test/rules` (CI mobile job).

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/refdata/bundle_repository.dart';
import 'package:agritrace/core/rules/gi_check.dart';
import 'package:agritrace/core/rules/grade_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../db/db_fixtures.dart';

/// Stores [body] as bundle [part] in [db], as the sync engine would. Throws nothing.
Future<void> _store(AppDatabase db, String part, Object body) => db.refBundlesDao.upsert(
  RefBundlesCompanion.insert(bundleType: part, version: 1, etag: '"v1"', fetchedAt: t0, bodyJson: jsonEncode(body)),
);

/// The decoded JSON of `test/fixtures/[name]`. Throws: [FileSystemException] when missing.
Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync()) as Map<String, dynamic>;

void main() {
  late AppDatabase db;
  late BundleRepository repo;
  setUp(() {
    db = memoryDb();
    repo = BundleRepository(db.refBundlesDao);
  });
  tearDown(() => db.close());

  test('nothing downloaded: empty lists and nulls', () async {
    expect(await repo.crops(), isEmpty);
    expect(await repo.inputs(), isEmpty);
    expect(await repo.plots(), isEmpty);
    expect(await repo.calendar(), isEmpty);
    expect(await repo.standards('crop-chilli'), isNull);
    expect(await repo.giRegion(), isNull);
  });

  test('every part parses into its model and feeds the rules', () async {
    final bundle = _fixture('reference_bundle.json');
    for (final part in ['crops', 'inputs', 'plots', 'calendar']) {
      await _store(db, part, bundle[part] as Object);
    }
    await _store(db, 'standards', {
      'profiles': {'crop-chilli': _fixture('dry_chilli_agmark_v1.json')},
    });
    final gi = (_fixture('gi_region_fixture.geojson')['features'] as List).first as Map<String, dynamic>;
    await _store(db, 'gi_region', {'geometry': gi['geometry'], 'tolerance_buffer_m': 150, 'version_no': 1});

    final crop = (await repo.crops()).single;
    expect(crop.eventSchema.tracks['nursery'], ['nursery', 'sowing']);
    expect((await repo.inputs()).map((i) => i.category).toSet(), {
      'organic_fertilizer',
      'bio_fertilizer',
      'chemical_fertilizer',
    });
    expect((await repo.plots()).last.areaUnit, 'cent');
    expect((await repo.calendar()).single.dueOn, DateTime(2026, 2, 14));

    final rules = (await repo.standards('crop-chilli'))!;
    expect(rules.yieldRule!.ceilingKgPerAcre.toString(), '1000');
    expect(yieldOutcome(rules, 1250, 1), 'warn');
    expect(await repo.standards('other-crop'), isNull);

    final region = (await repo.giRegion())!;
    expect(region.bufferM, 150);
    expect(giCheck(region, 9.55, 78.2).status, GiStatus.inside);
  });

  test('a part that is not a JSON object is a FormatException', () async {
    await _store(db, 'crops', [1, 2]);
    expect(repo.crops(), throwsFormatException);
  });
}
