// Reads the downloaded reference bundles (RefBundles rows) into typed models for the preview rules and screens.
// Requirement: D-006 (phone previews read the same JSON the server uses), D-016 (reference data as bundles),
//   backend-design.md §3 "Reference bundles", mobile-design.md §1 core/refdata; FR22, FR55, FR56, FR67, FR68.
// Callers: farmer, officer and QC features (M07, M09, M11) and reminders (M12) through Riverpod providers they
//   own; test/rules/bundle_repository_test.dart. The only Drift reader of reference data: rules stay pure.
//
// Part bodies the phone expects (B07 contract, see docs/agents/reports/M03.md):
//   crops     {"crops": [Crop]}            inputs    {"inputs": [InputItem]}
//   plots     {"plots": [RefPlot]}         calendar  {"calendar": [CalendarEntry]}
//   standards {"profiles": {"<crop_id>": <StandardsProfileRules JSON>}}
//   gi_region {"geometry": <GeoJSON>, "tolerance_buffer_m": n, ...}

import 'dart:convert';

import '../db/daos/ref_bundles_dao.dart';
import 'models/reference.dart';
import 'models/standards.dart';

/// Typed, read-only access to the reference bundles stored by the sync engine (M02).
class BundleRepository {
  /// Creates the repository over [_dao] (`db.refBundlesDao`).
  BundleRepository(this._dao);

  final RefBundlesDao _dao;

  /// The decoded JSON body of bundle [part], or null when it was never downloaded.
  ///
  /// Throws: [FormatException] when the stored body is not a JSON object.
  Future<Map<String, dynamic>?> _body(String part) async {
    final row = await _dao.get(part);
    if (row == null) return null;
    final body = jsonDecode(row.bodyJson);
    if (body is! Map<String, dynamic>) throw FormatException('bundle $part is not a JSON object');
    return body;
  }

  /// The list under key [part] of bundle [part], each item parsed with [parse]; empty when not downloaded.
  ///
  /// Throws: [FormatException] or [TypeError] when the body does not match the expected shape.
  Future<List<T>> _list<T>(String part, T Function(Map<String, dynamic>) parse) async => [
    for (final item in (await _body(part))?[part] as List<dynamic>? ?? const []) parse(item as Map<String, dynamic>),
  ];

  /// Crops with their event schema. Returns an empty list before the first download.
  ///
  /// Throws: [FormatException] or [TypeError] when the stored part is malformed.
  Future<List<Crop>> crops() => _list('crops', Crop.fromJson);

  /// The input master (FR56). Returns an empty list before the first download.
  ///
  /// Throws: [FormatException] or [TypeError] when the stored part is malformed.
  Future<List<InputItem>> inputs() => _list('inputs', InputItem.fromJson);

  /// Plots visible to this user. Returns an empty list before the first download.
  ///
  /// Throws: [FormatException] or [TypeError] when the stored part is malformed.
  Future<List<RefPlot>> plots() => _list('plots', RefPlot.fromJson);

  /// Crop-calendar reminders. Returns an empty list before the first download.
  ///
  /// Throws: [FormatException] or [TypeError] when the stored part is malformed.
  Future<List<CalendarEntry>> calendar() => _list('calendar', CalendarEntry.fromJson);

  /// The Standards Profile rules of crop [cropId], or null when not downloaded or the crop has no profile.
  ///
  /// Throws: [FormatException] or [TypeError] when the stored part is malformed.
  Future<StandardsRules?> standards(String cropId) async {
    final rules = ((await _body('standards'))?['profiles'] as Map<String, dynamic>?)?[cropId];
    return rules == null ? null : StandardsRules.fromJson(rules as Map<String, dynamic>);
  }

  /// The GI region outline and buffer, or null before the first download.
  ///
  /// Throws: [FormatException] or [TypeError] when the stored part is malformed.
  Future<GiRegion?> giRegion() async {
    final body = await _body('gi_region');
    return body == null ? null : GiRegion.fromJson(body);
  }
}
