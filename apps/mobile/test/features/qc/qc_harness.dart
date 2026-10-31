// Shared harness for the QC mode tests: an in-memory database with a signed-in QC officer, the chilli Standards
//   Profile and crops bundles, two moisture meters (one past its calibration), a ready lot of farmer Murugan, a fake
//   QR camera and a fake batch list.
// Requirement: PLAN §7.2 M11 tests (widget tests per screen state, scripted flow, goldens, accessibility sweep).
// Callers: test/features/qc/*_test.dart.

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/db/providers.dart';
import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/theme/app_theme.dart';
import 'package:agritrace/core/voice/voice_player.dart';
import 'package:agritrace/features/qc_grading/batch_list_screen.dart';
import 'package:agritrace/features/qc_grading/grading_screen.dart';
import 'package:agritrace/features/qc_home/qc_common.dart';
import 'package:agritrace/features/qc_home/qc_home_screen.dart';
import 'package:agritrace/features/qc_intake/intake_screen.dart';
import 'package:agritrace/features/qc_intake/scan_screen.dart';
import 'package:agritrace/features/sell/sell_qr.dart';
import 'package:agritrace/features/qc_packing/packing_screen.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show OrderingTerm, Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../widget/kit_harness.dart' show RecordingVoicePlayer;

/// The ready lot stored on the phone (200 kg packed by Murugan).
const lotId = '0192f000-0000-7000-8000-00000000a001';

/// Murugan's farmer id.
const farmerId = '0192f000-0000-7000-8000-00000000f001';

/// Crop id of Samba Vathal chilli in the test bundles.
const cropId = 'crop-chilli';

/// The valid moisture meter (calibrated until 2099).
const meterId = '0192f000-0000-7000-8000-0000000000e1';

/// The moisture meter whose calibration expired on 14 Feb 2025.
const expiredMeterId = '0192f000-0000-7000-8000-0000000000e2';

/// M08's QR for the stored lot.
final lotQr = jsonEncode({
  'lotId': lotId,
  'farmerId': farmerId,
  'packedKg': 200,
  'sig': SellQr(lotId: lotId, farmerId: farmerId, packedKg: 200).sig,
});

/// A batch waiting for grading (320 kg received).
const toGrade = QcBatch(
  id: '0192f000-0000-7000-8000-0000000000b1',
  code: 'FGP8T4033HM7',
  cropId: cropId,
  status: 'created',
  totalKg: '320',
);

/// A batch graded at 180 kg, waiting for packing.
const toPack = QcBatch(
  id: '0192f000-0000-7000-8000-0000000000b2',
  code: 'HQ2K9P7M4X1A',
  cropId: cropId,
  status: 'graded',
  totalKg: '200',
  gradedKg: '180',
);

/// What a test needs after [pumpQc]: the database, the container and the code the fake camera reports.
class QcFixture {
  /// Creates the fixture from its parts.
  QcFixture(this.db, this.container, this.player);

  /// The in-memory database the screens write to.
  final AppDatabase db;

  /// The provider container of the pumped app.
  final ProviderContainer container;

  /// Records the voice clips played.
  final RecordingVoicePlayer player;

  /// The code the fake camera reports when "Fake scan" is tapped.
  String scanned = '';
}

/// Pumps [screen] (default the QC home is passed by the caller) in the app shell and returns the [QcFixture].
///
/// [locale], [size] and [textScale] set the screen; [fieldConfig] maps a FieldConfig entity to its JSON value;
/// [standards] stores the chilli profile; [instruments] stores the two meters; [batches] is the batch list (null: no
/// signal); [fetchInstruments] is the instruments API (default: no signal, so the stored meters are used);
/// [pushed] shows [screen] as a pushed route (route chrome measured). Side effects: changes the test view
/// (reset at tear-down); the database is closed at tear-down. Returns after the first frames settled.
Future<QcFixture> pumpQc(
  WidgetTester tester,
  Widget screen, {
  Locale locale = english,
  Size size = const Size(360, 640),
  double textScale = 1.0,
  Map<String, Object?> fieldConfig = const {},
  bool standards = true,
  bool instruments = true,
  List<QcBatch>? batches = const [toGrade, toPack],
  InstrumentFetcher? fetchInstruments,
  bool pushed = false,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  await db.sessionDao.save(userId: 'qc-1', role: Role.qc, fpoId: 'fpo-1', deviceId: 'dev-1', locale: 'en');
  for (final MapEntry(:key, :value) in fieldConfig.entries) {
    await db.into(db.fieldConfig).insert(FieldConfigCompanion.insert(entity: key, json: jsonEncode(value)));
  }
  Future<void> bundle(String part, Object body) => db.refBundlesDao.upsert(
    RefBundlesCompanion.insert(
      bundleType: part,
      version: 1,
      etag: '"1"',
      fetchedAt: DateTime.utc(2026, 10, 31),
      bodyJson: jsonEncode(body),
      assetDir: const Value(null),
    ),
  );
  await bundle('crops', {
    'crops': [
      {'id': cropId, 'code': 'VIRUDHUNAGAR_SAMBA_VATHAL', 'name_en': 'Samba Vathal'},
    ],
  });
  if (standards) {
    final profile = jsonDecode(File('test/fixtures/dry_chilli_agmark_v1.json').readAsStringSync());
    await bundle('standards', {
      'profiles': {cropId: profile},
    });
  }
  if (instruments) {
    await db
        .into(db.instruments)
        .insert(
          InstrumentsCompanion.insert(
            instrumentId: meterId,
            kind: 'moisture_meter',
            label: 'Delmhorst G-7',
            calibrationDueDate: DateTime(2099, 12, 31),
          ),
        );
    await db
        .into(db.instruments)
        .insert(
          InstrumentsCompanion.insert(
            instrumentId: expiredMeterId,
            kind: 'moisture_meter',
            label: 'Old meter',
            calibrationDueDate: DateTime(2025, 2, 14),
          ),
        );
  }
  await db
      .into(db.farmers)
      .insert(
        FarmersCompanion.insert(
          farmerId: farmerId,
          fpoId: 'fpo-1',
          name: 'Murugan',
          village: 'Sattur',
          hasSmartphone: true,
          language: 'ta',
          status: 'active',
          json: '{}',
        ),
      );
  await db
      .into(db.lots)
      .insert(
        LotsCompanion.insert(
          lotId: lotId,
          plotId: 'plot-1',
          farmerId: farmerId,
          cropId: cropId,
          season: '2026-rabi',
          status: 'ready_for_sale',
          kgPacked: const Value(200),
          updatedAt: DateTime.utc(2026, 10, 30),
        ),
      );
  final player = RecordingVoicePlayer();
  late final QcFixture fixture;
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      voicePlayerProvider.overrideWithValue(player),
      qrScannerProvider.overrideWithValue(
        (onCode) => Center(
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(160, 56)),
            onPressed: () => onCode(fixture.scanned),
            child: const Text('Fake scan'),
          ),
        ),
      ),
      qcInstrumentFetcherProvider.overrideWithValue(
        fetchInstruments ?? () async => throw DioException(requestOptions: RequestOptions(path: '/v1/instruments')),
      ),
      qcBatchesProvider.overrideWith(
        (ref) async => batches ?? (throw DioException(requestOptions: RequestOptions(path: '/v1/batches'))),
      ),
    ],
  );
  fixture = QcFixture(db, container, player);
  addTearDown(() async {
    container.dispose();
    await db.close();
  });
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: app!,
        ),
        navigatorKey: navigator,
        home: pushed ? const Scaffold() : screen,
      ),
    ),
  );
  if (pushed) {
    navigator.currentState!.push(MaterialPageRoute<void>(builder: (_) => screen)).ignore();
  }
  await tester.pumpAndSettle();
  return fixture;
}

/// Scrolls [finder] into view, taps it and settles. Returns when done; throws when [finder] matches nothing.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The QC form tile of field [name] (payload key or parameter code), in any language. Returns the finder.
Finder tileOf(String name) => find.byKey(ValueKey('qcTile-$name'));

/// The instrument-picker row of [value] (an instrument id or `visual`), in any language. Returns the finder.
Finder sourceOf(String value) => find.byKey(ValueKey('qcSource-$value'));

/// The four pilot grading readings: parameter code, typed value and source (the meter for moisture, visual for the
/// counted defects, as an officer records them, FR42).
const gradingReadings = [
  ('moisture', '10.5', meterId),
  ('extraneous_matter', '1', 'visual'),
  ('unripe_marked_fruits', '2', 'visual'),
  ('broken_fruits', '3', 'visual'),
];

/// Types [digits] (digits and '.') on the visible number pad. Returns when done; throws when a key is missing.
Future<void> typeDigits(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tapOn(tester, find.widgetWithText(FilledButton, d).last);
  }
}

/// The tile of the QC form labelled [label] (tap it to point the pad at that field). Returns the finder.
Finder tile(String label) => find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first;

/// The FarmerButton action labelled [label]. Returns the finder; throws nothing.
Finder button(String label) =>
    find.ancestor(of: find.text(label), matching: find.byWidgetPredicate((w) => w is FilledButton));

/// Whether the FarmerButton labelled [label] is enabled. Throws when there is no such button.
bool enabled(WidgetTester tester, String label) => tester.widget<FilledButton>(button(label)).onPressed != null;

/// Entries saved so far, by entry type, oldest first. Returns them; throws nothing.
Future<Map<String, List<Entry>>> savedEntries(AppDatabase db) async {
  final byType = <String, List<Entry>>{};
  for (final e in await (db.select(db.entries)..orderBy([(e) => OrderingTerm(expression: e.createdAt)])).get()) {
    (byType[e.entryType] ??= []).add(e);
  }
  return byType;
}

/// The decoded payload of [entry]. Throws [FormatException] for a malformed payload.
Map<String, Object?> payloadOf(Entry entry) => (jsonDecode(entry.payloadJson) as Map).cast<String, Object?>();

/// The QC screens the accessibility sweep and the goldens show, each in its busiest state.
enum QcShot {
  /// QC home.
  home,

  /// Lot scanner (fake camera).
  scan,

  /// Intake check with 230 kg (orange) and 11.5 % (orange) and a meter picked.
  intake,

  /// Batch list.
  batches,

  /// Grading form with 4 readings, the grade preview and the meter picked.
  grading,

  /// Final packing at 175 of 180 kg.
  packing,
}

/// The screen widget of [shot]. Returns it; throws nothing.
Widget screenOf(QcShot shot) => switch (shot) {
  QcShot.home => const QcHomeScreen(),
  QcShot.scan => const ScanScreen(),
  QcShot.intake => const IntakeScreen(
    lot: QcLot(lotId: lotId, farmerId: farmerId, farmerName: 'Murugan', packedKg: 200, cropId: cropId),
  ),
  QcShot.batches => const BatchListScreen(),
  QcShot.grading => const GradingScreen(batch: toGrade),
  QcShot.packing => const PackingScreen(batch: toPack, gradedKg: '180'),
};

/// Brings the pumped [shot] into its busiest state by typing its values, in any language. Returns when settled;
/// throws when a control is missing.
Future<void> fillShot(WidgetTester tester, QcShot shot) async {
  switch (shot) {
    case QcShot.intake:
      await typeDigits(tester, '230');
      await tapOn(tester, tileOf('moisture'));
      await typeDigits(tester, '11.5');
      await tapOn(tester, find.text('Delmhorst G-7'));
      await tester.ensureVisible(tileOf('received'));
    case QcShot.grading:
      for (final (code, value, source) in gradingReadings) {
        await tapOn(tester, tileOf(code));
        await typeDigits(tester, value);
        await tapOn(tester, sourceOf(source));
      }
      await tester.ensureVisible(find.byKey(const ValueKey('qcGradePreview')));
    case QcShot.packing:
      await typeDigits(tester, '175');
      // Back to the top: a tile half scrolled out of the viewport measures as a short tap target.
      await tester.ensureVisible(tileOf('quantity'));
    case QcShot.home || QcShot.scan || QcShot.batches:
      break;
  }
  await tester.pumpAndSettle();
}
