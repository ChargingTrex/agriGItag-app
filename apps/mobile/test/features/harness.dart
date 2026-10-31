// Shared harness for the M07 farmer screens and scripted flows: the real app (router, session, Drift on an in-memory
// database) with fakes at the hardware seams — camera, GPS, photo compressor, voice recorder, clock — plus seed data
// (farmer, plot, lot, reference bundles) and a tap counter.
// Requirement: plan §7.2 M07 acceptance (each event ≤ 3 taps (+1 optional) with photo/GPS/clocks; 6 bags × 50 → 300 kg;
//   packing at 12 % not ready; "Did you already sow?" once; scripted log < 20 s), UserFlows §When things go wrong.
// Callers: test/features/*_test.dart (M07 and M08), integration_test/farmer_flows_test.dart.

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/app.dart';
import 'package:agritrace/core/capture/camera_capture.dart';
import 'package:agritrace/core/capture/gps_fix.dart';
import 'package:agritrace/core/capture/photo_compressor.dart';
import 'package:agritrace/core/capture/photo_quality_check.dart';
import 'package:agritrace/core/capture/voice_note_recorder.dart';
import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/router/app_router.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/widgets/call_officer_button.dart';
import 'package:agritrace/core/widgets/cloud_sync_indicator.dart';
import 'package:agritrace/features/event_log/event_log_controller.dart';
import 'package:camera/camera.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

import '../auth/harness.dart';
import '../db/db_fixtures.dart';

/// The fixed phone clock of every flow: 14 Feb 2026, 09:30 local.
final flowNow = DateTime(2026, 2, 14, 9, 30);

/// Camera controller fake: never initialised for the preview (CameraPreview draws an empty box), writes a small
/// "JPEG" file per shot into [dir]. [denied] makes initialisation fail like a refused permission.
class FakeCameraController implements CameraController {
  /// Creates the fake for [description] writing shots into [dir].
  FakeCameraController(this.description, this.dir, {this.denied = false});

  @override
  final CameraDescription description;

  /// Folder of the camera "cache".
  final Directory dir;

  /// Whether [initialize] throws CameraAccessDenied.
  final bool denied;

  /// Number of shots taken.
  int shots = 0;

  @override
  CameraValue get value => CameraValue.uninitialized(description);

  @override
  Future<void> initialize() async {
    if (denied) throw CameraException('CameraAccessDenied', 'denied');
  }

  @override
  Future<XFile> takePicture() async {
    final f = File('${dir.path}/CAP_${++shots}.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xD9]);
    return XFile(f.path);
  }

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Compressor fake: writes the output and thumbnail files into `outDir` and answers the next verdict of [verdicts]
/// (the last one repeats). Records every camera original it was handed.
class FakeCompressor implements PhotoCompressor {
  /// Creates the fake answering [verdicts] in order.
  FakeCompressor(this.verdicts);

  /// Quality verdicts to answer, in order; the last repeats.
  final List<PhotoQuality> verdicts;

  /// Camera originals passed to [compress].
  final List<File> originals = [];

  @override
  Future<CompressedPhoto> compress(
    File source, {
    required Directory outDir,
    DateTime? capturedAt,
    LocationFix? fix,
    int maxBytes = 0,
  }) async {
    originals.add(source);
    final n = originals.length;
    final bytes = Uint8List.fromList(List.filled(2048, n));
    final path = '${outDir.path}/photo_${n}_1600.jpg';
    final thumb = '${outDir.path}/photo_${n}_thumb.jpg';
    File(path).writeAsBytesSync(bytes);
    File(thumb).writeAsBytesSync(bytes.sublist(0, 100));
    return CompressedPhoto(
      path: path,
      bytes: bytes,
      width: 1600,
      height: 1200,
      sha256: 'ab' * 32,
      thumbPath: thumb,
      jpegQuality: 80,
      quality: verdicts[n - 1 < verdicts.length ? n - 1 : verdicts.length - 1],
    );
  }
}

/// Record-plugin fake: always allowed, writes a small file on stop. Unused members fall to noSuchMethod.
class FakeAudioRecorder implements AudioRecorder {
  String? _path;

  @override
  Future<bool> hasPermission({bool request = true}) async => true;

  @override
  Future<bool> isEncoderSupported(AudioEncoder encoder) async => true;

  @override
  Future<void> start(RecordConfig config, {required String path}) async => _path = path;

  @override
  Future<String?> stop() async {
    File(_path!).writeAsBytesSync(List.filled(900, 7));
    return _path;
  }

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A GPS fix with [accuracyM] metres accuracy at the pilot plot. Returns it; throws nothing.
LocationFix fixOf(double accuracyM) =>
    LocationFix(lat: 9.5501, lng: 78.2002, accuracyM: accuracyM, gpsTime: DateTime.utc(2026, 2, 14, 4, 0, 1));

/// One app under test: database, fakes, container and the tap counter.
class FlowHarness {
  /// Creates the harness: [verdicts] for the compressor, [fixes] the GPS stream (default one 8 m fix), [pending] the
  /// cloud count (0 = all sent), [cameraDenied] refuses the camera, [overrides] are added last.
  FlowHarness({
    List<PhotoQuality> verdicts = const [PhotoQuality.ok],
    List<LocationFix>? fixes,
    this.pending = 0,
    bool cameraDenied = false,
    List<Override> overrides = const [],
  }) : compressor = FakeCompressor(verdicts) {
    dir = Directory.systemTemp.createTempSync('m07_flow');
    media = Directory('${dir.path}/media')..createSync();
    camera = Directory('${dir.path}/cache')..createSync();
    final gps = fixes ?? [fixOf(8)];
    db = memoryDb();
    container = authContainer(
      FakeApi(),
      db: db,
      overrides: [
        mediaDirProvider.overrideWith((ref) async => media),
        cameraFactoryProvider.overrideWithValue(
          () => CameraCapture(
            cameras: () async => const [
              CameraDescription(name: 'b', lensDirection: CameraLensDirection.back, sensorOrientation: 90),
            ],
            controllerFor: (d) => FakeCameraController(d, camera, denied: cameraDenied),
            now: () => flowNow,
          ),
        ),
        gpsFixProvider.overrideWithValue(GpsFix(source: () => Stream.fromIterable(gps))),
        photoCompressorProvider.overrideWithValue(compressor),
        voiceRecorderFactoryProvider.overrideWithValue(
          () => VoiceNoteRecorder(recorder: FakeAudioRecorder(), now: () => flowNow),
        ),
        // A test moves [now] to cross a deadline (M08 undo window, 7-day unsent warning).
        clockProvider.overrideWithValue(() => now),
        // No sync engine in widget tests: the save's send kick is counted instead.
        afterSaveProvider.overrideWithValue(() => kicks++),
        pendingSendCountProvider.overrideWith((ref) => Stream.value(pending)),
        fieldOfficerPhoneProvider.overrideWithValue('+919876543210'),
        ...overrides,
      ],
    );
  }

  /// Temp root (deleted by [dispose]).
  late final Directory dir;

  /// Media folder (what `mediaDirProvider` returns).
  late final Directory media;

  /// Camera cache folder (camera originals).
  late final Directory camera;

  /// The in-memory database.
  late final AppDatabase db;

  /// The app's provider container.
  late final ProviderContainer container;

  /// The compressor fake.
  final FakeCompressor compressor;

  /// Entries waiting to send, for the cloud icon.
  final int pending;

  /// The phone clock the app reads; [flowNow] unless a test moves it.
  DateTime now = flowNow;

  /// Taps on forward actions counted by [tap].
  int taps = 0;

  /// Send kicks requested after saves and undos ([afterSaveProvider]).
  int kicks = 0;

  /// Signs in as a farmer in [locale], seeds the farm (see [seedFarm]) and pumps the app on [tester] at [location].
  /// Returns when settled. Throws what the app throws while building.
  Future<void> start(
    WidgetTester tester, {
    String location = '/home',
    Locale locale = english,
    double? lastMoisture,
    bool withHistory = true,
    int lots = 1,
  }) async {
    // A tall phone (412 x 915 dp) so the screens fit without scrolling; the a11y sweep checks 360 x 640.
    tester.view
      ..physicalSize = const Size(412, 915)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await container.read(sessionProvider.notifier).openSession(sessionOut());
    container.read(sessionProvider.notifier).setLocale(locale);
    await seedFarm(lastMoisture: lastMoisture, withHistory: withHistory, lots: lots);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AgriTraceApp()));
    await tester.pumpAndSettle();
    go(location);
    await tester.pumpAndSettle();
  }

  /// Navigates the app's router to [location]. Throws nothing.
  void go(String location) => container.read(routerProvider).go(location);

  /// Path of the top-most route (pushed routes included). Throws nothing.
  String get path => container.read(routerProvider).state.uri.path;

  /// Scrolls [finder] (exactly one widget) into view, taps it, counts it and settles. Throws when [finder] finds
  /// nothing.
  Future<void> tap(WidgetTester tester, Finder finder) async {
    taps++;
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Seeds farmer-1 with plot-1 (1 acre) and lot-1 (dry chilli, open, [lastMoisture] %), [lots] − 1 more lots, the
  /// reference bundles (crops with tracks, inputs with pack sizes, standards) and, when [withHistory], land
  /// preparation, nursery, sowing, a 195 kg harvest and drying start on 10 Feb so no event is out of order.
  /// Returns when written; throws nothing.
  Future<void> seedFarm({double? lastMoisture, bool withHistory = true, int lots = 1}) async {
    await db
        .into(db.farmers)
        .insert(
          FarmersCompanion.insert(
            farmerId: 'farmer-1',
            fpoId: 'fpo-1',
            name: 'Murugan',
            village: 'Sattur',
            hasSmartphone: true,
            language: 'ta',
            status: 'active',
            json: '{}',
          ),
        );
    for (var i = 1; i <= lots; i++) {
      await db
          .into(db.plots)
          .insert(
            PlotsCompanion.insert(
              plotId: 'plot-$i',
              farmerId: 'farmer-1',
              pinLat: 9.55,
              pinLng: 78.2,
              pinAccuracyM: 6,
              pinMethod: 'gps',
              declaredArea: 1,
              areaUnit: 'acre',
              giStatus: 'inside',
              locked: false,
              version: 1,
            ),
          );
      await db
          .into(db.lots)
          .insert(
            LotsCompanion.insert(
              lotId: 'lot-$i',
              plotId: 'plot-$i',
              farmerId: 'farmer-1',
              cropId: 'crop-chilli',
              season: '2026-rabi',
              status: 'open',
              lastMoisture: Value(lastMoisture),
              updatedAt: flowNow,
            ),
          );
    }
    final fixture = jsonDecode(File('test/fixtures/reference_bundle.json').readAsStringSync()) as Map<String, dynamic>;
    final inputs = fixture['inputs'] as Map<String, dynamic>;
    // B07 sends Decimal pack sizes as JSON strings; one product without a pack size.
    (inputs['inputs'] as List<dynamic>).first['pack_size'] = '50.000';
    final standards = jsonDecode(File('test/fixtures/dry_chilli_agmark_v1.json').readAsStringSync());
    for (final (type, body) in [
      ('crops', fixture['crops']),
      ('inputs', inputs),
      (
        'standards',
        {
          'profiles': {'crop-chilli': standards},
        },
      ),
    ]) {
      await db.refBundlesDao.upsert(
        RefBundlesCompanion.insert(
          bundleType: type,
          version: 1,
          etag: 'e1',
          fetchedAt: flowNow,
          bodyJson: jsonEncode(body),
        ),
      );
    }
    if (!withHistory) return;
    final before = DateTime(2026, 2, 10);
    for (final (type, payload) in [
      ('land_preparation', '{}'),
      ('nursery', '{"seed_variety":"K2"}'),
      ('sowing', '{}'),
      ('harvest', '{"quantity":{"value":195,"unit":"kg"},"bags":13}'),
      ('drying', '{"phase":"start"}'),
    ]) {
      final e = entryAt(at: before, payload: payload);
      await db.entriesDao.save(e.copyWith(entryType: Value(type)), const []);
    }
  }

  /// Stores [fields] as the field configuration of [entity] (`event_harvest`, ...). Returns when written.
  Future<void> setFieldConfig(String entity, List<Map<String, Object?>> fields) => db
      .into(db.fieldConfig)
      .insertOnConflictUpdate(FieldConfigCompanion.insert(entity: entity, json: jsonEncode(fields)));

  /// Sets lot [lotId] to [status] with [kgPacked] kilograms from the server (M08 Sell, Money). Returns when written.
  Future<void> setLot(String lotId, String status, {double kgPacked = 0}) => (db.update(
    db.lots,
  )..where((l) => l.lotId.equals(lotId))).write(LotsCompanion(status: Value(status), kgPacked: Value(kgPacked)));

  /// Saves a [type] entry on lot-1 at [at] with [payload] and a 24 h undo window (M08 History, Settings). Returns its
  /// id; throws what EntriesDao.save throws.
  Future<String> saveEntry(String type, DateTime at, {String payload = '{}'}) async {
    final e = entryAt(at: at, payload: payload).copyWith(entryType: Value(type));
    await db.entriesDao.save(e, const []);
    return e.entryId.value;
  }

  /// Entries of [type] saved in this flow (not the seeded history), oldest first. Throws nothing.
  Future<List<Entry>> saved(String type) =>
      (db.select(db.entries)..where((e) => e.entryType.equals(type) & e.deviceTime.equals(flowNow))).get();

  /// Media rows of [entryId]. Throws nothing.
  Future<List<MediaFile>> mediaOf(String entryId) =>
      (db.select(db.media)..where((m) => m.entryId.equals(entryId))).get();

  /// Tears down: unmounts the app (stopping its streams) and deletes the temp folder. The in-memory database is left
  /// to the garbage collector: `close()` waits on a timer the fake-async test zone never fires.
  /// [tester] is the running test. Returns when done; throws nothing.
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Drift closes a cancelled stream query on a zero-length timer; let it run before the pending-timer check.
    await tester.pump(const Duration(seconds: 1));
    dir.deleteSync(recursive: true);
  }
}

/// A field-config object as `/v1/config/fields` serves it: [name], [required], and an optional English [label].
/// Returns the map; throws nothing.
Map<String, Object?> field(String name, {bool required = false, String? label}) => {
  'name': name,
  'type': 'integer',
  'required': required,
  'enabled': true,
  'visibility': 'internal',
  'stage': 'harvest',
  'label': {'en': label ?? name, 'ta': label ?? name},
};
