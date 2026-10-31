// The one Notifier behind a farm-event log: the draft being captured, the previews it shows (out-of-order question,
// yield check, lot readiness), and the save that writes the entry, its media and its outbox rows in one transaction.
// Requirement: UserFlows §Logging a farm event, §Each farm event (what the app fills in by itself), §When things go
//   wrong (weak GPS saved with its accuracy; wrong entry → Undo for 24 hours); FR3, FR6 (undo before sale), FR55–FR58;
//   Dataflow Stages 1–6 (Stage 5/6: lot ready only at or under the moisture limit); Arch §Offline-first (three clocks,
//   save on the phone first); D-005, D-006, D-014, D-017, D-029.
//   M10 assist mode: UserFlows §Field officer flows (assisted entries carry the session, FR69 "entered remotely"), D-032.
// Callers: event_log screens (EventFlowScreen, CameraStep, ConfirmScreen, SavedScreen), problem_report
//   (VoiceNoteButton), farmer_home (assistFarmerProvider, farmerPath), app.dart (assist bar), app_router (route guards),
//   officer_moisture (activeLots); tests override the seams below.

import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/capture/camera_capture.dart';
import '../../core/capture/clocks.dart';
import '../../core/capture/gps_fix.dart';
import '../../core/capture/photo_compressor.dart';
import '../../core/capture/voice_note_recorder.dart';
import '../../core/db/daos/entries_dao.dart';
import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/providers/sync_providers.dart';
import '../../core/refdata/bundle_repository.dart';
import '../../core/refdata/models/reference.dart';
import '../../core/refdata/models/standards.dart';
import '../../core/rules/event_order.dart';
import '../../core/rules/moisture_limit.dart';
import '../../core/rules/yield_check.dart';
import '../officer_assist/assist_controller.dart';
import '../onboarding_farmer/onboarding_notifier.dart' show assistSessionKey;
import 'farm_event.dart';
import 'field_rules.dart';

/// Folder for evidence photos and voice notes: `<app support>/media`, which the OS never purges, because an entry
/// can wait days offline for its upload (mobile-design.md §3). Tests override it with a temp folder.
final mediaDirProvider = FutureProvider<Directory>(
  (ref) async => Directory('${(await getApplicationSupportDirectory()).path}/media'),
);

/// Makes the camera session of one capture screen (M04 [CameraCapture]); tests return a fake-controller session.
final cameraFactoryProvider = Provider<CameraCapture Function()>((ref) => CameraCapture.new);

/// GPS fixes for the capture screen (M04 [GpsFix]); tests inject a scripted stream.
final gpsFixProvider = Provider<GpsFix>((ref) => GpsFix());

/// The photo compressor (M04); tests replace the isolate with a canned result.
final photoCompressorProvider = Provider<PhotoCompressor>((ref) => const PhotoCompressor());

/// Makes a voice-note recorder for the problem report (M04); tests return a fake-plugin recorder.
final voiceRecorderFactoryProvider = Provider<VoiceNoteRecorder Function()>((ref) => VoiceNoteRecorder.new);

/// The phone clock; tests pin it.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Typed reference bundles (M03) for the previews.
final bundleRepositoryProvider = Provider<BundleRepository>(
  (ref) => BundleRepository(ref.watch(appDatabaseProvider).refBundlesDao),
);

/// The farmer an officer is logging for (assist mode), or null when the farmer uses their own phone.
typedef AssistFarmer = ({String farmerId, String name});

/// The assisted farmer of the running assist session (M10 [assistProvider]), read by the assist bar, the home screen,
/// [farmerPath] and the save (assist flag, farmer id); null when the farmer uses their own phone.
final assistFarmerProvider = Provider<AssistFarmer?>((ref) {
  final session = ref.watch(assistProvider);
  return session == null ? null : (farmerId: session.farmerId, name: session.name);
});

/// Where the farmer screen [path] (`/home…` or `/log…`) lives for whoever uses the app: unchanged for the farmer, and
/// under `/assist/<farmerId>` while an officer assists (`/home/saved` → `/assist/F/saved`, `/log/harvest` →
/// `/assist/F/log/harvest`), so every assisted screen stays inside the assist scope. [ref] reads the assist state.
/// Returns the path; throws nothing.
String farmerPath(WidgetRef ref, String path) {
  final assist = ref.read(assistFarmerProvider);
  return assist == null ? path : '/assist/${assist.farmerId}${path.replaceFirst(RegExp('^/home'), '')}';
}

/// Called after every save and undo to start a send: M02's debounced kick (`SyncService.afterSave`, 500 ms, only when
/// the API is reachable; mobile-design.md §3). Tests replace it with a no-op.
final afterSaveProvider = Provider<void Function()>((ref) => ref.watch(syncServiceProvider).afterSave);

/// Lot statuses that still take farm events (server `LotStatus` open, drying, ready_for_sale).
const _activeLotStatuses = ['open', 'drying', 'ready_for_sale'];

/// Lot status the packing save sets when the moisture gate passes (server `LotStatus.READY_FOR_SALE`).
const readyForSale = 'ready_for_sale';

/// SyncState key prefix of the phone-only "already asked" marker of the out-of-order question, one key per lot
/// (`order_asked:<lotId>`). A local marker, not a server code: the server raises its own `event_out_of_order` flag.
const orderAskedKey = 'order_asked:';

/// The event being captured. Mutable on purpose: the notifier changes a field and calls `ref.notifyListeners()`,
/// instead of a copyWith for every one of its many optional fields.
class EventDraft {
  /// Creates an empty draft (no event chosen yet), or a draft for [event] on [lot] with what [EventLogNotifier.start]
  /// loaded: [rules], [plot], [history] (latest version of each event on the lot) and [standards].
  EventDraft({
    this.event,
    this.lot,
    this.rules = const FieldRules(null),
    this.plot,
    this.history = const [],
    this.standards,
  });

  /// Event being logged; null before one is chosen.
  final FarmEvent? event;

  /// Lot the event belongs to.
  final Lot? lot;

  /// The tenant's field rules for [event] (D-017).
  final FieldRules rules;

  /// Plot of [lot] (declared area for land preparation and the yield preview); null when not pulled.
  final Plot? plot;

  /// Latest version of every event on [lot], oldest first (undone roots end in an `undo` row).
  final List<Entry> history;

  /// Standards Profile rules of the lot's crop (yield and moisture previews); null when not downloaded.
  final StandardsRules? standards;

  /// Chosen seed variety (nursery); null with "Seed packet".
  String? seedVariety;

  /// Chosen input product (fertiliser or pesticide).
  InputItem? input;

  /// Pack size of [input] in its unit; null when the master has none.
  num? packSize;

  /// Bags on the stepper (input, harvest, packing).
  int bags = 1;

  /// Drying phase `start` or `end`.
  String? dryingPhase;

  /// Problem kind (one of [kProblemTypes]).
  String? problemType;

  /// The compressed evidence photo; null until the camera step accepts one.
  CompressedPhoto? photo;

  /// Device and GPS clocks at the shutter.
  Clocks? clocks;

  /// GPS fix written into the photo at the shutter.
  LocationFix? photoFix;

  /// GPS fix saved with the entry (the best one seen until the camera step accepted the photo).
  LocationFix? fix;

  /// Quality of [fix].
  LocationStatus locationStatus = LocationStatus.none;

  /// Problem-report voice note.
  VoiceNote? voice;

  /// True while the voice note is recording; the confirm tick waits for it.
  bool recording = false;

  /// Entry id once saved; null before.
  String? savedEntryId;

  /// True when the packing save made the lot ready for sale.
  bool lotNowReady = false;

  /// Lot status before the packing save changed it, restored by undo.
  String? previousLotStatus;

  /// Local reminder task created by "Start drying", closed by undo.
  String? reminderTaskId;

  /// Open tasks this save marked done, reopened by undo.
  List<String> completedTaskIds = const [];

  /// The seed variety of the latest nursery entry on the lot, for sowing. Throws nothing.
  String? get nurseryVariety => _payloadsOf(FarmEvent.nursery).lastOrNull?['seed_variety'] as String?;

  /// Kilograms already harvested on the lot by earlier harvest entries (undone ones excluded). Throws nothing.
  num get harvestedKg =>
      _payloadsOf(FarmEvent.harvest).fold<num>(0, (sum, p) => sum + (((p['quantity'] as Map?)?['value'] as num?) ?? 0));

  /// The drying phase to suggest: `end` when the latest drying entry started drying, else `start`. Throws nothing.
  String get suggestedDryingPhase => _payloadsOf(FarmEvent.drying).lastOrNull?['phase'] == 'start' ? 'end' : 'start';

  /// Decoded payloads of [type]'s entries in [history], oldest first. Throws [FormatException] on corrupt JSON.
  List<Map<String, dynamic>> _payloadsOf(FarmEvent type) => [
    for (final e in history)
      if (e.entryType == type.wireName) jsonDecode(e.payloadJson) as Map<String, dynamic>,
  ];
}

/// Drives one farm-event log from the event choice to the saved screen. One flow at a time.
class EventLogNotifier extends Notifier<EventDraft> {
  /// The running or finished save of this draft; a second tap gets the same future (D-005).
  Future<String>? _saving;

  /// Starts with an empty draft. Returns it; throws nothing.
  @override
  EventDraft build() => EventDraft();

  /// The app database. Throws nothing.
  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// The phone clock now ([clockProvider]). Throws nothing.
  DateTime _now() => ref.read(clockProvider)();

  /// Active lots of the farmer (or of the assisted farmer), ordered by plot. Returns an empty list when the farmer has
  /// no crop registered yet. Throws nothing beyond database errors.
  Future<List<Lot>> activeLots() {
    final assist = ref.read(assistFarmerProvider);
    return (_db.select(_db.lots)
          ..where(
            (l) =>
                l.status.isIn(_activeLotStatuses) &
                (assist == null ? const Constant(true) : l.farmerId.equals(assist.farmerId)),
          )
          ..orderBy([(l) => OrderingTerm.asc(l.plotId)]))
        .get();
  }

  /// Starts a new draft for [event] on [lot], loading its field rules, plot, lot history and standards.
  ///
  /// Returns when loaded. Throws [FormatException] or [TypeError] when a stored bundle or field config is malformed.
  /// Side effect: replaces the draft (a previous unsaved one is dropped; its photo files stay until the purge).
  Future<void> start(FarmEvent event, Lot lot) async {
    _saving = null;
    final db = _db;
    final draft = EventDraft(
      event: event,
      lot: lot,
      rules: FieldRules.parse(await db.fieldConfigDao.get(event.configEntity)),
      plot: await (db.select(db.plots)..where((p) => p.plotId.equals(lot.plotId))).getSingleOrNull(),
      history: await db.entriesDao.latestVersions(lot.lotId),
      standards: await ref.read(bundleRepositoryProvider).standards(lot.cropId),
    );
    state = draft..dryingPhase = draft.suggestedDryingPhase;
  }

  /// Applies [change] to the draft and rebuilds the screens. Throws what [change] throws.
  void update(void Function(EventDraft d) change) {
    change(state);
    ref.notifyListeners();
  }

  /// Whether the event has an extra choice screen (UserFlows §Each farm event) that the field rules leave visible.
  /// Throws nothing.
  bool get hasExtraChoice {
    final r = state.rules;
    return switch (state.event) {
      FarmEvent.nursery => r.enabled('seed_variety'),
      FarmEvent.inputApplication => r.enabled('input_id') || r.enabled('quantity'),
      FarmEvent.harvest || FarmEvent.packing => r.enabled('bags') || r.enabled('quantity'),
      FarmEvent.drying => r.enabled('phase'),
      FarmEvent.problem => r.enabled('problem_type'),
      _ => false,
    };
  }

  /// The input master with each product's pack size (FR56), in master order. Empty before the first download.
  ///
  /// Throws [FormatException] or [TypeError] when the stored bundle is malformed.
  Future<List<(InputItem, num?)>> inputs() async {
    final items = await ref.read(bundleRepositoryProvider).inputs();
    // shortcut: M03's InputItem has no pack size, so it is read from the raw bundle (a Decimal arrives as a JSON
    //   string); drop this once refdata parses `pack_size`.
    final body = (await _db.refBundlesDao.get('inputs'))?.bodyJson;
    final raw = body == null ? const [] : (jsonDecode(body) as Map<String, dynamic>)['inputs'] as List<dynamic>;
    final sizes = {for (final i in raw.cast<Map<String, dynamic>>()) i['id']: num.tryParse('${i['pack_size']}')};
    return [for (final i in items) (i, sizes[i.id])];
  }

  /// The earlier steps missing before this event (Stage order, FR55) that the farmer was not asked about yet, and the
  /// one to ask: the nearest missing step ("Did you already sow?" before a harvest).
  ///
  /// DECISION D-006: the phone only asks and remembers the farmer's answer; the server re-runs `event_order` and owns
  ///   the officer flag (`event_out_of_order`).
  ///   ADV: the farmer is asked once, offline, at the moment they remember best.
  ///   COMPROMISE: the Yes/No answer stays on the phone (SyncState marker) until M02/B06 ship it with the entry.
  /// Returns null when the order is fine, the crop is unknown or every gap was already asked about. Throws nothing
  /// beyond database and bundle parsing errors.
  Future<({FarmEvent ask, List<String> gaps})?> orderQuestion() async {
    final d = state;
    final lot = d.lot!;
    final crop = (await ref.read(bundleRepositoryProvider).crops()).where((c) => c.id == lot.cropId).firstOrNull;
    if (crop == null) return null;
    final recorded = [
      for (final e in d.history)
        if (e.entryType != undoEntryType) (type: e.entryType, on: e.deviceTime),
    ];
    final asked = {for (final a in await _answers(lot.lotId)) ...(a['missing'] as List<dynamic>).cast<String>()};
    final gaps = [
      for (final g in orderGaps(crop.eventSchema, recorded, d.event!.wireName, _now()))
        if (!asked.contains(g)) g,
    ];
    final ask = FarmEvent.fromWire(gaps.lastOrNull);
    return ask == null ? null : (ask: ask, gaps: gaps);
  }

  /// Records the farmer's answer to the out-of-order question in the lot's phone-only SyncState marker
  /// ([orderAskedKey]), which no pull touches, so the question is never asked again for these [gaps] on this lot.
  /// [didIt] is the Yes/No answer.
  ///
  /// Returns when written. Throws nothing beyond database errors. Side effect: writes a SyncState row.
  Future<void> answerOrder(List<String> gaps, {required bool didIt}) async {
    final d = state;
    final answers = [
      ...await _answers(d.lot!.lotId),
      {'event_type': d.event!.wireName, 'missing': gaps, 'farmer_says_done': didIt},
    ];
    await _db.syncStateDao.set('$orderAskedKey${d.lot!.lotId}', jsonEncode(answers));
  }

  /// The out-of-order answers stored for [lotId], oldest first (`{event_type, missing, farmer_says_done}`); empty
  /// when none. Throws [FormatException] when the stored marker is not JSON.
  Future<List<Map<String, dynamic>>> _answers(String lotId) async {
    final raw = await _db.syncStateDao.get('$orderAskedKey$lotId');
    return raw == null ? [] : (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Yield preview of this harvest (FR57, FR68): `pass`, `warn` or `hold` for the lot's harvested kilograms plus the
  /// stepper's bags; null when the plot or the crop's yield rule is not downloaded. Throws nothing.
  String? yieldPreview() {
    final d = state;
    final plot = d.plot;
    if (d.standards == null || plot == null) return null;
    return yieldCheck(
      d.standards!,
      kg: d.harvestedKg + d.bags * kBagKg,
      plot: RefPlot(
        id: plot.plotId,
        farmerId: plot.farmerId,
        lat: plot.pinLat,
        lon: plot.pinLng,
        declaredArea: plot.declaredArea,
        areaUnit: plot.areaUnit,
      ),
    );
  }

  /// Whether packing makes the lot ready for sale: the lot's last moisture reading passes the crop's `ready_for_sale`
  /// gate (≤ 11 % for dry chilli, Stage 5). No reading, or no downloaded standards, keeps it drying. Throws nothing.
  ///
  /// DECISION D-006: the phone sets the local lot to `ready_for_sale` from the ported `lotGate` preview at once; the
  ///   server re-runs the gate on the packing entry and its lot status replaces this one on the next pull.
  ///   ADV: "Ready to sell." and the Sell QR (M08) work offline right after packing.
  ///   COMPROMISE: until the pull, the phone can show ready a lot the server holds (e.g. a newer meter reading).
  bool get packingMakesReady {
    final s = state.standards;
    final moisture = state.lot?.lastMoisture;
    if (s == null) return false;
    if (!s.lotGates.containsKey('ready_for_sale')) return true;
    return moisture != null && moistureVerdict(s, moisture) == MoistureVerdict.ready;
  }

  /// Stores the accepted [photo] with its [clocks] and the [photoFix] written into it, deleting the files of a photo it
  /// replaces (Back from Confirm, then a new shot). Throws nothing. Side effect: deletes files.
  void setPhoto(CompressedPhoto photo, Clocks clocks, LocationFix? photoFix) {
    final old = state.photo;
    if (old != null && old.path != photo.path) {
      deleteQuietly(old.path);
      deleteQuietly(old.thumbPath);
    }
    update((d) {
      d
        ..photo = photo
        ..clocks = clocks
        ..photoFix = photoFix;
    });
  }

  /// Stores the entry's GPS [fix] and its [status] (`ok`, `lowAccuracy` after "Save anyway", `none`). Throws nothing.
  void setLocation(LocationFix? fix, LocationStatus status) => update((d) {
    d
      ..fix = fix
      ..locationStatus = status;
  });

  /// Stores the problem-report voice [note], deleting a previous one. Throws nothing; a delete failure is ignored.
  void setVoice(VoiceNote note) {
    deleteQuietly(state.voice?.file.path);
    update((d) => d.voice = note);
  }

  /// Drops the photo (Retake) and deletes its files. Throws nothing. Side effect: deletes files.
  void discardPhoto() {
    final photo = state.photo;
    deleteQuietly(photo?.path);
    deleteQuietly(photo?.thumbPath);
    update((d) {
      d
        ..photo = null
        // Retake while recording: the button's result handler discards that note.
        ..recording = false;
    });
  }

  /// The payload JSON of the draft in B06's schema (`apps/api/agritrace/modules/events/payloads/farm.py`): field
  /// names exactly, quantities as `{value, unit}` (FR58), fields the tenant disabled and empty values left out.
  ///
  /// DECISION D-014: one typed JSON payload per event type, the same keys on phone and server.
  ///   ADV: one save, sync and undo path for all eight events.
  ///   COMPROMISE: the payload is not type-checked here; B06 rejects unknown keys (`extra = forbid`), so a typo
  ///     surfaces as a rejected entry, and tests pin the keys.
  /// Returns the map. Throws nothing.
  Map<String, Object?> payload() {
    final d = state;
    final today = _isoDay(_now());
    final plot = d.plot;
    final input = d.input;
    final size = d.packSize;
    final p = switch (d.event!) {
      FarmEvent.landPreparation => {
        'cultivated_area': plot == null ? null : _quantity(plot.declaredArea, plot.areaUnit),
        'last_ploughed_on': today,
      },
      FarmEvent.nursery => {'seed_variety': d.seedVariety},
      FarmEvent.sowing => {'seed_variety': d.nurseryVariety},
      FarmEvent.inputApplication => {
        'input_id': input?.id,
        // Without a pack size the bag count is all that is known; the unit says so (FR58).
        'quantity': input == null || size == null
            ? _quantity(d.bags, 'bag')
            : _quantity(_times(d.bags, size), input.unit),
      },
      FarmEvent.harvest || FarmEvent.packing => {'quantity': _quantity(d.bags * kBagKg, 'kg'), 'bags': d.bags},
      FarmEvent.drying => {'phase': d.dryingPhase},
      FarmEvent.problem => {'problem_type': d.problemType},
    };
    return {
      for (final MapEntry(:key, :value) in p.entries)
        if (value != null && d.rules.enabled(key)) key: value,
    };
  }

  /// Required fields (D-017) the draft has no value for; the confirm tick stays disabled while any is listed.
  /// Throws nothing.
  List<String> get missingRequired => state.rules.missing(state.event!.fields, payload());

  /// Saves the draft once: a second call (double tap on the tick) returns the first call's future (D-005).
  ///
  /// Returns the new entry id (UUIDv7). Throws [StateError] when nobody is signed in or no photo was taken;
  /// `SqliteException` on a database failure (nothing is written then, and the next call tries again).
  /// Side effects: see [_save].
  Future<String> save() => _saving ??= () async {
    try {
      return await _save();
    } catch (_) {
      _saving = null;
      rethrow;
    }
  }();

  /// Writes the entry, its media and outbox rows (EntriesDao.save), the packing lot status, the drying reminder and
  /// the tasks it completes, in one transaction; then kicks a send. Returns the entry id. Throws as [save].
  Future<String> _save() async {
    final d = state;
    final lot = d.lot!;
    final event = d.event!;
    final photo = d.photo ?? (throw StateError('no photo'));
    final session = await _db.sessionDao.read() ?? (throw StateError('signed out'));
    final assist = ref.read(assistFarmerProvider);
    final now = _now();
    final id = const Uuid().v7();
    final fix = d.fix;
    final entry = EntriesCompanion.insert(
      entryId: id,
      rootId: id,
      version: 1,
      entryType: event.wireName,
      lotId: Value(lot.lotId),
      plotId: Value(lot.plotId),
      farmerId: lot.farmerId,
      // Latest versions of this type still standing; an undone event ends in an `undo` row and is not counted.
      instanceNo: d.history.where((e) => e.entryType == event.wireName).length + 1,
      // D-032: the assist session travels in the payload; M02 lifts it onto the push entry.
      payloadJson: jsonEncode({...payload(), assistSessionKey: ?ref.read(assistProvider)?.sessionId}),
      deviceTime: now,
      gpsTime: Value(fix?.gpsTime),
      lat: Value(fix?.lat),
      lng: Value(fix?.lng),
      accuracyM: Value(fix?.accuracyM),
      locationStatus: d.locationStatus,
      enteredByUserId: session.userId,
      // CLAUDE.md §6: assist mode is recorded on every entry it creates; FR69 preview from the officer's fix.
      assistMode: Value(assist != null),
      enteredRemotely: Value(assist != null && enteredRemotely(d.plot, fix)),
      status: EntryStatus.saved,
      undoDeadline: now.add(const Duration(hours: 24)),
      createdAt: now,
    );
    // The outbox rows' ownerUserId (D-029) is filled by EntriesDao.save from enteredByUserId.
    final media = [
      MediaCompanion.insert(
        mediaId: const Uuid().v7(),
        entryId: id,
        kind: 'photo',
        localPath: photo.path,
        bytes: photo.bytes.length,
        sha256: photo.sha256,
        width: photo.width,
        height: photo.height,
        capturedAt: d.clocks?.deviceTime ?? now,
        lat: Value(d.photoFix?.lat),
        lng: Value(d.photoFix?.lng),
        accuracyM: Value(d.photoFix?.accuracyM),
        uploadStatus: UploadStatus.pending,
        thumbPath: photo.thumbPath,
      ),
      if (d.voice case final voice?)
        MediaCompanion.insert(
          mediaId: const Uuid().v7(),
          entryId: id,
          kind: 'voice',
          localPath: voice.file.path,
          bytes: voice.file.lengthSync(),
          sha256: voice.sha256,
          width: 0,
          height: 0,
          capturedAt: now,
          uploadStatus: UploadStatus.pending,
          // Audio has no thumbnail.
          thumbPath: '',
        ),
    ];
    final ready = event == FarmEvent.packing && packingMakesReady;
    final open = (_db.select(_db.tasks)
      ..where(
        (t) =>
            t.farmerId.equals(lot.farmerId) &
            t.eventType.equals(event.wireName) &
            t.done.not() &
            (t.lotId.equals(lot.lotId) | t.lotId.isNull()),
      ));
    String? reminder;
    late List<String> completed;
    await _db.transaction(() async {
      await _db.entriesDao.save(entry, media);
      completed = [for (final t in await open.get()) t.taskId];
      await (_db.update(
        _db.tasks,
      )..where((t) => t.taskId.isIn(completed))).write(const TasksCompanion(done: Value(true)));
      if (ready) await _setLotStatus(lot.lotId, readyForSale);
      if (event == FarmEvent.drying && d.dryingPhase == 'start') {
        reminder = const Uuid().v7();
        await _db
            .into(_db.tasks)
            .insert(
              TasksCompanion.insert(
                taskId: reminder!,
                farmerId: lot.farmerId,
                lotId: Value(lot.lotId),
                eventType: FarmEvent.drying.wireName,
                dueDate: now.add(const Duration(days: kDryingReminderDays)),
                promptId: 'taskDryingDone',
                source: 'local',
              ),
            );
      }
    });
    update((d) {
      d
        ..savedEntryId = id
        ..lotNowReady = ready
        ..previousLotStatus = ready ? lot.status : null
        ..reminderTaskId = reminder
        ..completedTaskIds = completed;
    });
    ref.read(afterSaveProvider)();
    return id;
  }

  /// Undoes the saved entry within its 24 h window (EntriesDao.undo) and reverts what the save changed locally: the
  /// lot status, the drying reminder and the tasks it completed.
  ///
  /// Returns when done. Throws [StateError] from EntriesDao.undo when the window closed or the entry changed.
  /// Side effects: an `undo` entry version queued for sending; tasks and lot rows updated; a send kicked.
  Future<void> undo() async {
    final d = state;
    await _db.transaction(() async {
      await _db.entriesDao.undo(d.savedEntryId!, now: _now());
      if (d.previousLotStatus case final status?) await _setLotStatus(d.lot!.lotId, status);
      final reopen = d.completedTaskIds;
      await (_db.update(
        _db.tasks,
      )..where((t) => t.taskId.isIn(reopen))).write(const TasksCompanion(done: Value(false)));
      if (d.reminderTaskId case final task?) {
        await (_db.update(
          _db.tasks,
        )..where((t) => t.taskId.equals(task))).write(const TasksCompanion(done: Value(true)));
      }
    });
    update((d) => d.savedEntryId = null);
    ref.read(afterSaveProvider)();
  }

  /// Sets the local lot row's [status] (a preview; the server's lot status replaces it on the next pull).
  /// Returns when written; throws nothing beyond database errors.
  Future<void> _setLotStatus(String lotId, String status) =>
      (_db.update(_db.lots)..where((l) => l.lotId.equals(lotId))).write(LotsCompanion(status: Value(status)));
}

/// The app's one event-log flow.
final eventLogProvider = NotifierProvider<EventLogNotifier, EventDraft>(EventLogNotifier.new);

/// A quantity with its unit (FR58), the `Quantity {value, unit}` wire shape. Throws nothing.
Map<String, Object> _quantity(num value, String unit) => {'value': value, 'unit': unit};

/// [bags] × [size] computed in decimal (0.1 l × 6 is 0.6, not 0.6000000000000001); an integer when whole.
/// Throws nothing.
num _times(int bags, num size) {
  final v = Decimal.fromInt(bags) * Decimal.parse('$size');
  return v.isInteger ? v.toBigInt().toInt() : v.toDouble();
}

/// The calendar day of [t] as `YYYY-MM-DD` (ISO 8601 date). Throws nothing.
String _isoDay(DateTime t) => t.toIso8601String().substring(0, 10);

/// Deletes the file at [path] when it exists; null or a failing delete is ignored (a stray file is purged later).
/// Used for camera originals (never kept, Arch §Offline-first "Photos made light") and discarded captures.
/// Throws nothing.
void deleteQuietly(String? path) {
  if (path == null) return;
  try {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  } on FileSystemException {
    // Best effort: a leftover file costs storage, never data.
  }
}
