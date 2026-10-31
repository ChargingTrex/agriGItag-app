// Bundle phase: one delta request `GET /v1/sync/reference?since=<part>:<version>,…` returns only the parts whose
// version differs from the ones this phone holds (304 when none); store them in RefBundles and mirror the `plots`
// part into the Plots table.
// Requirement: PLAN §13 C2 (delta bundles with `?since=` + 304); mobile-design.md §3; backend-design.md §3
//   "Reference bundles"; docs/api/conventions.md "Reference bundles" (B07: per-part "version differs", parts not
//   listed are returned, `gi_region` absent while no region is in effect); Arch §Offline-first "Reference data
//   travels to the phone"; D-006, D-016.
// Callers: sync_service.dart (fetchBundles each run); lib/core/refdata/bundle_repository.dart reads what this
//   writes; tests.

import 'dart:convert';

import 'package:dio/dio.dart';

import '../db/database.dart';
import 'sync_context.dart';

/// Downloads every bundle part whose version differs from the stored one (and every part not stored yet).
///
/// [c] is the run. Every held part is listed in `since` (a bare number would be a 422); versions are compared by
/// equality on the server because some parts carry a content fingerprint, so the answer's version is stored as is.
/// A part missing from the answer is unchanged, or (`gi_region`) not in effect yet: the GI preview then has no
/// region, which is not an error. Returns when done. Throws [DioException] when the request fails and [TypeError]
/// for an unreadable answer (the caller logs it; the next run tries again). Side effects: RefBundles rows; Plots
/// rows for the `plots` part.
Future<void> fetchBundles(SyncContext c) async {
  final held = await c.db.refBundlesDao.versions();
  final res = await c.api.get<Map<String, Object?>>(
    '/v1/sync/reference',
    queryParameters: {
      if (held.isNotEmpty) 'since': [for (final MapEntry(:key, :value) in held.entries) '$key:$value'].join(','),
    },
    options: SyncContext.authed.copyWith(validateStatus: (s) => s == 200 || s == 304),
  );
  if (res.statusCode == 304) return;
  final now = c.now();
  for (final MapEntry(key: part, value: raw) in (res.data!['parts'] as Map).cast<String, Object?>().entries) {
    final p = (raw as Map).cast<String, Object?>();
    final body = jsonEncode(p['body']);
    await c.db.transaction(() async {
      await c.db.refBundlesDao.upsert(
        RefBundlesCompanion.insert(
          bundleType: part,
          version: p['version'] as int,
          etag: p['etag'] as String,
          fetchedAt: now,
          bodyJson: body,
        ),
      );
      if (part == 'plots') await _mirrorPlots(c, (p['body'] as Map)['plots'] as List);
    });
  }
}

/// Upserts the plots of the `plots` bundle part into the Plots table.
///
/// DECISION D-016: plots reach the phone as the downloadable `plots` bundle part, the one source M03's
///   BundleRepository (D-006 preview rules) reads; the M01 Plots table is filled from the same payload in the same
///   transaction, so screens reading either agree.
///   ADV: one download, no second plot endpoint; RefBundles and Plots never disagree after a fetch.
///   COMPROMISE: the part carries no accuracy, pin method, GI status, lock or version, so those columns get
///   placeholders; plots missing from the part are not deleted (a plot captured on this phone may not have reached
///   the server yet), and the phone-only survey number is never overwritten.
/// [plots] is the part's `plots` list. Returns when written; throws [TypeError] for an unreadable plot.
Future<void> _mirrorPlots(SyncContext c, List<Object?> plots) async {
  for (final p in plots.cast<Map<String, Object?>>()) {
    final pin = (p['pin'] as Map).cast<String, Object?>();
    await c.db
        .into(c.db.plots)
        .insertOnConflictUpdate(
          PlotsCompanion.insert(
            plotId: p['id'] as String,
            farmerId: p['farmer_id'] as String,
            pinLat: (pin['lat'] as num).toDouble(),
            pinLng: (pin['lon'] as num).toDouble(),
            pinAccuracyM: (pin['accuracy_m'] as num? ?? 0).toDouble(),
            pinMethod: p['pin_method'] as String? ?? 'live_gps',
            declaredArea: double.parse('${p['declared_area']}'),
            areaUnit: p['area_unit'] as String,
            giStatus: p['gi_status'] as String? ?? 'unknown',
            locked: p['locked'] as bool? ?? false,
            version: p['version'] as int? ?? 1,
          ),
        );
  }
}
