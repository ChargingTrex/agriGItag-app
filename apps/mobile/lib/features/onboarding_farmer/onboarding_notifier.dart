// Onboarding wizard state: the step enum, the tenant's field rules, the farmer + plot draft, and the save that
//   writes the farmer, the consent and the plot to the phone (and the farmer to the API when online).
// Requirement: UserFlows §Onboarding a farmer steps 1-9 (and "If the farmer has no smartphone, the officer stops
//   after step 8"), Dataflow Stage 0, PRD FR53-FR54 (farming type vs irrigation source), FR64-FR66 (live-GPS pin,
//   declared size, optional walked boundary), FR41 (consent with witness), PLAN §7.2 M09 and the field-config note
//   (D-017: a disabled field's step is skipped, a required one blocks Next; "Add another plot"), CLAUDE.md §6.
// Callers: onboarding_wizard.dart and the step widgets in this folder (through onboardingProvider);
//   test/features/onboarding/*.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:agritrace_api/agritrace_api.dart' show FarmerIn, standardSerializers;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/api/api_client.dart';
import '../../core/capture/clocks.dart';
import '../../core/capture/gps_fix.dart';
import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/refdata/bundle_repository.dart';
import '../../core/refdata/models/reference.dart';
import '../../core/router/session.dart' show AuthFailure;
import 'boundary_area.dart';
import 'who_step.dart' show takeFarmerPhoto;

/// The wizard's screens in order. Which of them a farmer sees depends on [OnboardingDraft.applies].
enum OnboardingStep {
  /// Step 1: the farmer's mobile number.
  start,

  /// Step 2: the recorded consent message and "I agree".
  consent,

  /// Step 3: photo, name, language.
  who,

  /// Step 4: "I am standing in my field" and the GPS ring.
  location,

  /// Step 5: declared size in acres or cents, optional survey number.
  landSize,

  /// Step 6 (optional): walk the boundary.
  boundary,

  /// Step 7: farming type and water source.
  water,

  /// Step 7b: soil type, only when the tenant's field configuration has `plot.soil_type` (PLAN §7.2 note).
  soil,

  /// Step 8: crop with the GI preview; saving happens when leaving it.
  crop,

  /// Step 9: QR handoff to the farmer's phone and the voice tour.
  handoff,

  /// After saving: the farmer summary with "Another plot" and "Done".
  summary,
}

/// Which farmer and plot fields this FPO captures and requires, plus the boundary-walk feature flag (D-017).
class FieldRules {
  /// Creates the rules. [farmer] and [plot] map each enabled field name to whether it is required; null means the
  /// field configuration was never pulled (every field enabled, none required beyond the `core` ones the wizard
  /// always asks for). [boundaryWalk] is `features.boundary_walk`.
  const FieldRules({this.farmer, this.plot, this.boundaryWalk = true});

  /// Parses the FieldConfig JSON of one entity (`[{name, required, enabled, ...}]`, disabled fields usually absent).
  ///
  /// Returns field name → required, or null for a null [json] (never pulled). Throws [FormatException] or
  /// [TypeError] when the stored JSON is not a list of field objects.
  static Map<String, bool>? parse(String? json) => json == null
      ? null
      : {
          for (final f in (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>())
            if (f['enabled'] != false) f['name'] as String: f['required'] == true,
        };

  /// Enabled farmer fields → required, or null before the first pull.
  final Map<String, bool>? farmer;

  /// Enabled plot fields → required, or null before the first pull.
  final Map<String, bool>? plot;

  /// Whether the FPO uses the boundary-walk step (features.yaml `boundary_walk`).
  final bool boundaryWalk;

  /// Whether [field] of [entity] (`farmer` or `plot`) is captured. Returns the flag; throws nothing.
  bool enabled(String entity, String field) {
    final fields = entity == 'farmer' ? farmer : plot;
    return fields == null || fields.containsKey(field);
  }

  /// Whether [field] of [entity] must be filled before Next. Returns the flag; throws nothing.
  bool required(String entity, String field) => (entity == 'farmer' ? farmer : plot)?[field] ?? false;
}

/// The wizard's mutable draft: what the officer has entered so far, for one farmer and the plot being added.
///
/// Mutated only through [OnboardingNotifier.edit] and the notifier's actions, which notify the screens.
class OnboardingDraft {
  /// Creates an empty draft for [rules], positioned on the first step that applies.
  OnboardingDraft(this.rules) {
    step = steps.first;
  }

  /// The FPO's field rules, read once when the wizard opens.
  final FieldRules rules;

  /// Step on screen.
  late OnboardingStep step;

  /// The 10 digits after +91 typed so far (empty when the farmer has no phone and the field is optional).
  String phoneDigits = '';

  /// When the farmer tapped "I agree"; null before.
  DateTime? consentGivenAt;

  /// Language code of the consent clip played (`ta`/`en`), recorded with the consent.
  String consentLang = 'ta';

  /// Local path of the farmer's photo, or null when none was taken.
  String? photoPath;

  /// Farmer's name as the officer typed it.
  String name = '';

  /// Farmer's language code (`ta` or `en`).
  String lang = 'ta';

  /// Null until the officer leaves the crop step; false after "No smartphone".
  bool? hasSmartphone;

  /// Farmer id once known: the server id (online) or a phone UUIDv7 (offline, D-005).
  String? farmerId;

  /// True when [farmerId] was made on the phone because there was no signal (the farmer is queued offline).
  bool farmerOffline = false;

  /// Whether the farmer row and consent are on the phone (only plots are saved after this).
  bool farmerSaved = false;

  /// Plots saved for this farmer in this wizard.
  int plotsSaved = 0;

  /// Best GPS fix kept as the plot pin; null until saved.
  LocationFix? pin;

  /// Phone and GPS clocks when the pin was saved.
  Clocks? pinClocks;

  /// True when the pin was saved with "Save anyway" (worse than 20 m; the server flags it for review).
  bool pinLowAccuracy = false;

  /// Unit the farmer uses: `acre` or `cent`.
  String areaUnit = 'acre';

  /// Declared size in [areaUnit] (whole acres or whole cents).
  int areaValue = 1;

  /// Survey / patta number as typed (optional).
  String surveyNo = '';

  /// GPS points of the walked boundary, in walking order.
  List<LonLat> walked = [];

  /// `irrigated` or `rainfed` (FR54), or null.
  String? farmingType;

  /// `well`, `borewell`, `canal`, `tank` or `rain` (FR54), or null.
  String? irrigationSource;

  /// Soil code (`red`, `black`, `sandy`, `alluvial`), or null.
  String? soilType;

  /// Crop picked at step 8, or null.
  Crop? crop;

  /// True while [OnboardingNotifier.save] runs.
  bool saving = false;

  /// Code of the last save failure (`farmer_phone_taken`, `network`, `unknown`, ...), or null.
  String? error;

  /// Phone number in E.164 (`+91` + 10 digits), or null when none was entered. Throws nothing.
  String? get phone => phoneDigits.length == 10 ? '+91$phoneDigits' : null;

  /// Declared size in acres. Throws nothing.
  double get declaredAcres => areaUnit == 'cent' ? areaValue / centsPerAcre : areaValue.toDouble();

  /// Walked area in acres, or null with fewer than 3 points. Throws nothing.
  double? get walkedAcres => walked.length < 3 ? null : geodesicAreaM2(walked) / squareMetresPerAcre;

  /// Steps that apply now, in order. Returns the list; throws nothing.
  List<OnboardingStep> get steps => OnboardingStep.values.where(applies).toList();

  /// Whether [s] is shown for this farmer and FPO.
  ///
  /// DECISION D-017: the wizard's steps follow the tenant's field configuration: a step whose fields are all
  ///   disabled is skipped (`plot.soil_type` off removes the soil step), and steps 1-3 run once per farmer.
  ///   ADV: one wizard serves every FPO without code changes; the YAML is the only switch.
  ///   COMPROMISE: the step list can change under the officer if a config pull lands mid-wizard; it is read once
  ///   when the wizard opens to avoid that.
  /// Returns the flag; throws nothing.
  bool applies(OnboardingStep s) => switch (s) {
    OnboardingStep.start => !farmerSaved && rules.enabled('farmer', 'phone'),
    OnboardingStep.consent || OnboardingStep.who => !farmerSaved,
    OnboardingStep.location || OnboardingStep.landSize || OnboardingStep.crop || OnboardingStep.summary => true,
    OnboardingStep.boundary => rules.boundaryWalk && rules.enabled('plot', 'walked_boundary'),
    OnboardingStep.water => rules.enabled('plot', 'farming_type') || rules.enabled('plot', 'irrigation_source'),
    OnboardingStep.soil => rules.enabled('plot', 'soil_type'),
    OnboardingStep.handoff => hasSmartphone == true && phone != null,
  };

  /// Whether the officer may leave [s] with Next: every required field of the step is filled.
  ///
  /// Name, pin and declared size are `core: true` in the YAML (the database needs them), so they always block.
  /// Returns the flag; throws nothing.
  bool canLeave(OnboardingStep s) {
    bool need(String entity, String field) => rules.required(entity, field);
    return switch (s) {
      OnboardingStep.start => phone != null || (phoneDigits.isEmpty && !need('farmer', 'phone')),
      OnboardingStep.consent => consentGivenAt != null,
      OnboardingStep.who => name.trim().isNotEmpty && (photoPath != null || !need('farmer', 'photo_key')),
      OnboardingStep.location => pin != null,
      OnboardingStep.landSize => areaValue >= 1 && (surveyNo.trim().isNotEmpty || !need('plot', 'land_record_ref')),
      OnboardingStep.boundary => walkedAcres != null || !need('plot', 'walked_boundary'),
      OnboardingStep.water =>
        (farmingType != null || !need('plot', 'farming_type')) &&
            (irrigationSource != null || !need('plot', 'irrigation_source')),
      OnboardingStep.soil => soilType != null || !need('plot', 'soil_type'),
      OnboardingStep.crop => !saving && (crop != null || !need('plot', 'gi_tag_id')),
      OnboardingStep.handoff || OnboardingStep.summary => true,
    };
  }

  /// `POST /v1/farmers` body (registry `FarmerIn`): disabled fields are dropped (D-017).
  ///
  /// Returns the JSON map; throws nothing.
  Map<String, Object?> farmerIn() => {
    'name': name.trim(),
    if (phone != null && rules.enabled('farmer', 'phone')) 'phone': phone,
    if (rules.enabled('farmer', 'lang')) 'lang': lang,
    if (rules.enabled('farmer', 'no_smartphone')) 'no_smartphone': hasSmartphone == false,
  };

  /// Sync push `data` of kind `plot` (registry `PlotIn` without `client_id`, which is the entry id) for [farmerId].
  ///
  /// The declared size goes in the farmer's own unit; the server converts it to acres (`to_acres`). Disabled and
  /// empty fields are dropped (D-017, `extra: forbid`). Returns the JSON map. Throws [StateError] without a pin.
  Map<String, Object?> plotIn(String farmerId) {
    final fix = pin, clocks = pinClocks;
    if (fix == null || clocks == null) throw StateError('no pin');
    bool on(String field) => rules.enabled('plot', field);
    final ring = walkedAcres == null
        ? null
        : [
            for (final (lon, lat) in [...walked, walked.first]) [lon, lat],
          ];
    final data = <String, Object?>{
      'farmer_id': farmerId,
      if (on('gi_tag_id')) 'gi_tag_id': crop?.giTagId,
      'pin': {'lat': fix.lat, 'lon': fix.lng, 'accuracy_m': fix.accuracyM},
      // Always live GPS: "Save anyway" keeps the live fix and its accuracy; map pins are not offered (FR64).
      if (on('pin_method')) 'pin_method': 'live_gps',
      'device_time': clocks.deviceTime.toUtc().toIso8601String(),
      if (on('gps_time')) 'gps_time': clocks.gpsTime?.toUtc().toIso8601String(),
      'declared_area': {'value': areaValue, 'unit': areaUnit},
      if (on('land_record_ref') && surveyNo.trim().isNotEmpty) 'land_record_ref': surveyNo.trim(),
      if (on('walked_boundary') && ring != null)
        'walked_boundary': {
          'type': 'Polygon',
          'coordinates': [ring],
        },
      if (on('farming_type')) 'farming_type': farmingType,
      if (on('irrigation_source')) 'irrigation_source': irrigationSource,
      if (on('soil_type')) 'soil_type': soilType,
    };
    return data..removeWhere((_, value) => value == null);
  }

  /// Clears the plot fields for "Another plot" (steps 4-8 run again for the same farmer). Throws nothing.
  void resetPlot() {
    pin = pinClocks = null;
    pinLowAccuracy = false;
    areaUnit = 'acre';
    areaValue = 1;
    surveyNo = '';
    walked = [];
    farmingType = irrigationSource = soilType = null;
    crop = null;
    error = null;
  }
}

/// Creates a farmer through `POST /v1/farmers` from a `FarmerIn` JSON map.
///
/// Returns the server farmer id, or null when there is no signal (the wizard then queues the farmer offline).
/// Throws [DioException] for an answer from the server (`farmer_phone_taken`, `field_required`, ...).
typedef FarmerCreator = Future<String?> Function(Map<String, Object?> farmerIn);

/// The REST farmer creation; tests override it (offline: `(_) async => null`).
final farmerCreatorProvider = Provider<FarmerCreator>(
  (ref) => (farmerIn) async {
    try {
      final response = await ref
          .read(apiClientProvider)
          .api
          .getRegistryApi()
          .createFarmerV1FarmersPost(farmerIn: standardSerializers.deserializeWith(FarmerIn.serializer, farmerIn)!);
      return response.data!.id;
    } on DioException catch (e) {
      if (e.response == null) return null;
      rethrow;
    }
  },
);

/// The phone's location provider for the pin and the boundary walk; tests override it with scripted fixes.
final gpsFixProvider = Provider<GpsFix>((ref) => GpsFix());

/// Opens the camera for the farmer's photo and returns the local file path, or null when cancelled or refused.
typedef FarmerPhotoTaker = Future<String?> Function(BuildContext context);

/// The farmer-photo camera; tests override it with a fake path.
final farmerPhotoProvider = Provider<FarmerPhotoTaker>((ref) => takeFarmerPhoto);

/// Crops of the FPO from the reference bundle (empty before the first download).
final onboardingCropsProvider = FutureProvider.autoDispose<List<Crop>>(
  (ref) => BundleRepository(ref.read(appDatabaseProvider).refBundlesDao).crops(),
);

/// GI region outline for the instant preview, or null before the first download.
final onboardingGiRegionProvider = FutureProvider.autoDispose<GiRegion?>(
  (ref) => BundleRepository(ref.read(appDatabaseProvider).refBundlesDao).giRegion(),
);

/// Entry types the wizard writes; the sync engine maps `plot` and `consent` straight to the push kinds of the same
/// name (B06) and must turn `farmer` into `POST /v1/farmers` (see [OnboardingNotifier.save]).
const plotEntryType = 'plot', consentEntryType = 'consent', farmerEntryType = 'farmer';

/// Version of the recorded consent text (identity `ConsentIn.consent_version`), suffixed with the clip language.
const consentTextVersion = 'v1';

/// The wizard: one draft, the step machine and the save.
///
/// DECISION D-013: one Riverpod AsyncNotifier with a step enum holds the whole wizard; the steps are plain
///   widgets on one route (/officer/onboard).
///   ADV: one place decides order, skips and saving; the draft survives step changes; tests drive it directly.
///   COMPROMISE: the draft lives in memory, so an app kill mid-wizard loses it (about 10 minutes of work, nothing
///   saved half-way); a mutable draft with `ref.notifyListeners()` instead of an immutable copyWith state.
class OnboardingNotifier extends AsyncNotifier<OnboardingDraft> {
  /// Reads the field rules of `farmer` and `plot` and the `features` flags from FieldConfig, then opens the first
  /// step. Returns the draft. Throws [FormatException] or [TypeError] for a malformed stored config.
  @override
  Future<OnboardingDraft> build() async {
    final dao = ref.read(appDatabaseProvider).fieldConfigDao;
    // TODO(M02): store the `fields` bundle part's `features` object under FieldConfig entity `features`.
    final features = await dao.get('features');
    return OnboardingDraft(
      FieldRules(
        farmer: FieldRules.parse(await dao.get('farmer')),
        plot: FieldRules.parse(await dao.get('plot')),
        boundaryWalk: features == null || (jsonDecode(features) as Map<String, dynamic>)['boundary_walk'] != false,
      ),
    );
  }

  /// Applies [change] to the draft and rebuilds the screens. Throws [StateError] before the draft is loaded.
  void edit(void Function(OnboardingDraft draft) change) {
    change(state.requireValue);
    ref.notifyListeners();
  }

  /// Moves to the next step that applies (stays on the last). Throws [StateError] before the draft is loaded.
  void next() => edit((d) {
    final steps = d.steps;
    d.step = steps[min(steps.indexOf(d.step) + 1, steps.length - 1)];
  });

  /// Whether the system back gesture should leave the wizard (first step, or the summary after saving).
  /// Returns the flag; throws [StateError] before the draft is loaded.
  bool get canLeaveWizard {
    final d = state.requireValue;
    return d.step == OnboardingStep.summary || (d.steps.first == d.step && !d.farmerSaved);
  }

  /// Goes one step back. After a save, steps before it are closed: the handoff and the first step of
  /// "Another plot" go back to the summary. Throws [StateError] before the draft is loaded.
  void back() => edit((d) {
    if (d.step == OnboardingStep.handoff || (d.farmerSaved && d.step == d.steps.first)) {
      d.step = OnboardingStep.summary;
      return;
    }
    final steps = d.steps;
    d.step = steps[max(steps.indexOf(d.step) - 1, 0)];
  });

  /// Records the farmer's "I agree" at [now] for the clip played in [lang], and moves on. Throws [StateError]
  /// before the draft is loaded.
  void agree(DateTime now, String lang) {
    edit((d) {
      d.consentGivenAt = now;
      d.consentLang = lang;
    });
    next();
  }

  /// Keeps [fix] as the plot pin, stamped with the three clocks; [lowAccuracy] marks a "Save anyway" pin.
  /// Throws [StateError] before the draft is loaded.
  void savePin(LocationFix fix, {required bool lowAccuracy}) => edit((d) {
    d.pin = fix;
    d.pinClocks = Clocks.stamp(fix: fix);
    d.pinLowAccuracy = lowAccuracy;
  });

  /// Saves the draft when the officer leaves the crop step: the farmer (first plot only) and the plot.
  ///
  /// [hasSmartphone] is false after "No smartphone" and true after "Farmer's phone"; it is ignored for later
  /// plots. First plot: the farmer goes to `POST /v1/farmers` when online (server id), else gets a UUIDv7 and an
  /// offline `farmer` entry; then, in one transaction, the local Farmers row, that entry, the `consent` entry and
  /// the `plot` entry are written and queued (EntriesDao.save). A server refusal (e.g. `farmer_phone_taken`) or a
  /// database failure keeps the draft and sets [OnboardingDraft.error] so the officer can fix it and tap again.
  /// Returns when done; throws [StateError] before the draft is loaded. Side effects: network call, Drift writes,
  /// outbox rows, then moves to the handoff or the summary.
  Future<void> save({required bool hasSmartphone}) async {
    final d = state.requireValue;
    if (d.saving) return;
    edit((d) {
      d.saving = true;
      d.error = null;
      if (!d.farmerSaved) d.hasSmartphone = hasSmartphone;
    });
    try {
      final db = ref.read(appDatabaseProvider);
      final officer = await db.sessionDao.read();
      if (officer == null) throw StateError('signed out');
      if (d.farmerId == null) await _createFarmer(d);
      final now = DateTime.now();
      await db.transaction(() async {
        if (!d.farmerSaved) {
          await db
              .into(db.farmers)
              .insert(
                FarmersCompanion.insert(
                  farmerId: d.farmerId!,
                  fpoId: officer.fpoId,
                  name: d.name.trim(),
                  // shortcut: no village picker in the 9 binding steps; the admin sets it on approval (FR53).
                  village: '',
                  photoPath: Value(d.photoPath),
                  hasSmartphone: hasSmartphone,
                  language: d.lang,
                  status: 'pending',
                  json: jsonEncode({if (d.phone != null) 'phone': d.phone}),
                ),
              );
          // TODO(M02): the push has no `farmer` kind. Send this entry as POST /v1/farmers before this farmer's other
          //   entries and substitute the returned id for `farmer_id` when building their push bodies (the payload
          //   is append-only). Cleaner fix: a `client_id` on FarmerIn (D-005), see TODO.md.
          if (d.farmerOffline) await _saveEntry(db, d, officer.userId, farmerEntryType, d.farmerIn(), now, now);
          await _saveEntry(
            db,
            d,
            officer.userId,
            consentEntryType,
            {
              'farmer_id': d.farmerId,
              'consent_type': 'data_collection',
              'consent_version': '$consentTextVersion-${d.consentLang}',
              // The clip played is bundled in the app; the server records the officer as witness from the token.
              'recording_ref': 'assets/audio/${d.consentLang}/onboardConsentMessage.ogg',
              'given_at': d.consentGivenAt!.toUtc().toIso8601String(),
            },
            d.consentGivenAt!,
            now,
          );
        }
        final plotId = const Uuid().v7();
        await _saveEntry(
          db,
          d,
          officer.userId,
          plotEntryType,
          d.plotIn(d.farmerId!),
          d.pinClocks!.deviceTime,
          now,
          id: plotId,
          fix: d.pin,
          gpsTime: d.pinClocks!.gpsTime,
          lowAccuracy: d.pinLowAccuracy,
        );
      });
      edit((d) {
        d.farmerSaved = true;
        d.plotsSaved++;
        d.saving = false;
      });
      next();
    } catch (e) {
      // Every failure keeps the draft: nothing was written (one transaction), the officer fixes it and taps again.
      edit((d) {
        d.saving = false;
        d.error = AuthFailure.from(e).code;
      });
    }
  }

  /// Creates the farmer of [d] through [farmerCreatorProvider] and stores its id in the draft.
  ///
  /// Without signal the id is a UUIDv7 made here and [OnboardingDraft.farmerOffline] is set. Returns when done.
  /// Throws [DioException] when the server refused the farmer. Side effect: network call; sets
  /// [OnboardingDraft.farmerId] so a retry after a later failure never creates the farmer twice.
  Future<void> _createFarmer(OnboardingDraft d) async {
    final serverId = await ref.read(farmerCreatorProvider)(d.farmerIn());
    // DECISION D-005: offline, the farmer id is a phone UUIDv7, so the consent and plot entries can name it at once.
    //   ADV: the whole onboarding works with no signal and is queued in order.
    //   COMPROMISE: FarmerIn has no client_id yet, so the sync engine must map this id to the server's (TODO(M02)).
    d.farmerId = serverId ?? const Uuid().v7();
    d.farmerOffline = serverId == null;
  }

  /// Writes one entry of [type] with [payload] for the draft's farmer, entered by [userId], queued for sending.
  ///
  /// [deviceTime] is the phone clock of the fact (consent tap, pin fix), [now] the save time. [id] is the entry id
  /// (UUIDv7 made here when null; for a plot it is also the plot id); [fix], [gpsTime] and [lowAccuracy] describe
  /// the location taken with it. Returns when written. Throws `SqliteException` when the write fails.
  /// Side effects: one Entries row and its outbox row.
  Future<void> _saveEntry(
    AppDatabase db,
    OnboardingDraft d,
    String userId,
    String type,
    Map<String, Object?> payload,
    DateTime deviceTime,
    DateTime now, {
    String? id,
    LocationFix? fix,
    DateTime? gpsTime,
    bool lowAccuracy = false,
  }) {
    final entryId = id ?? const Uuid().v7();
    return db.entriesDao.save(
      EntriesCompanion.insert(
        entryId: entryId,
        rootId: entryId,
        version: 1,
        entryType: type,
        plotId: Value(type == plotEntryType ? entryId : null),
        farmerId: d.farmerId!,
        instanceNo: 1,
        payloadJson: jsonEncode(payload),
        deviceTime: deviceTime,
        gpsTime: Value(gpsTime),
        lat: Value(fix?.lat),
        lng: Value(fix?.lng),
        accuracyM: Value(fix?.accuracyM),
        locationStatus: fix == null
            ? LocationStatus.none
            : (lowAccuracy ? LocationStatus.lowAccuracy : LocationStatus.ok),
        enteredByUserId: userId,
        // CLAUDE.md §6: the officer enters these for the farmer, so assist mode is recorded on each of them.
        assistMode: const Value(true),
        status: EntryStatus.saved,
        // Registrations are not farmer events: nothing to undo (corrections go through the FPO admin, FR71).
        undoDeadline: now,
        createdAt: now,
      ),
      const [],
    );
  }

  /// Starts "Another plot" for the saved farmer: clears the plot fields and opens the location step.
  /// Throws [StateError] before the draft is loaded.
  void addAnotherPlot() => edit((d) {
    d.resetPlot();
    d.step = OnboardingStep.location;
  });
}

/// The wizard's state; disposed when the wizard route closes.
final onboardingProvider = AsyncNotifierProvider.autoDispose<OnboardingNotifier, OnboardingDraft>(
  OnboardingNotifier.new,
);
