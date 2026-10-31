// Shared harness for the onboarding wizard tests: an in-memory database with a signed-in field officer, reference
//   bundles (crops, GI outline), scripted GPS, a fake camera and a fake (offline by default) farmer API.
// Requirement: PLAN §7.2 M09 tests (full wizard offline with fakes; GI preview; field config; accessibility sweep;
//   goldens). Callers: test/features/onboarding/*_test.dart.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/capture/gps_fix.dart';
import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/db/providers.dart';
import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/theme/app_theme.dart';
import 'package:agritrace/core/voice/voice_player.dart';
import 'package:agritrace/core/widgets/call_officer_button.dart';
import 'package:agritrace/core/widgets/cloud_sync_indicator.dart';
import 'package:agritrace/features/onboarding_farmer/onboarding_notifier.dart';
import 'package:agritrace/features/onboarding_farmer/onboarding_wizard.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../widget/kit_harness.dart' show RecordingVoicePlayer;

/// A pin inside the GI test outline (test/fixtures/gi_region_fixture.geojson).
const insideGi = (lat: 9.55, lng: 78.2);

/// Madurai: outside the GI test outline and its 150 m buffer.
const outsideGi = (lat: 9.9252, lng: 78.1198);

/// Photo path the fake camera returns (a real file, so FileImage has something to read).
const fakePhotoPath = 'test/fixtures/capture_12mp.jpg';

/// A GPS fix at [lat], [lng] with accuracy [accuracyM] metres. Returns it; throws nothing.
LocationFix fixAt(double lat, double lng, double accuracyM) =>
    LocationFix(lat: lat, lng: lng, accuracyM: accuracyM, gpsTime: DateTime.utc(2026, 10, 31, 6));

/// What a test needs after [pumpWizard]: the database, the provider container and the GPS feed.
class WizardFixture {
  /// Creates the fixture from its parts.
  WizardFixture(this.db, this.container, this.gps, this.player);

  /// The in-memory database the wizard writes to.
  final AppDatabase db;

  /// The provider container of the pumped app.
  final ProviderContainer container;

  /// Feed of GPS fixes; every `GpsFix.fixes()` listens to it.
  final StreamController<LocationFix> gps;

  /// Records the voice clips played.
  final RecordingVoicePlayer player;

  /// The wizard notifier. Throws nothing.
  OnboardingNotifier get notifier => container.read(onboardingProvider.notifier);

  /// The current draft. Throws [StateError] before it loaded.
  OnboardingDraft get draft => container.read(onboardingProvider).requireValue;
}

/// Pumps the wizard and returns its [WizardFixture].
///
/// [tester] is the running test; [locale], [size] and [textScale] set the screen; [fieldConfig] maps an entity
/// (`farmer`, `plot`, `features`) to its FieldConfig JSON value (omitted entities were never pulled); [creator] is
/// the farmer API (default: no signal); [crops] and [region] store the crops and GI-outline bundles; [pushed] shows
/// the wizard as a pushed route (route chrome measured by the accessibility sweep); [gpsSource] replaces the GPS feed
/// (e.g. `Stream.empty` for location off). Side effects: changes the test
/// view (reset at tear-down); the database is closed at tear-down. Returns after the draft loaded.
Future<WizardFixture> pumpWizard(
  WidgetTester tester, {
  Locale locale = english,
  Size size = const Size(360, 640),
  double textScale = 1.0,
  Map<String, Object?> fieldConfig = const {},
  FarmerCreator? creator,
  bool crops = true,
  bool region = true,
  bool pushed = false,
  Stream<LocationFix> Function()? gpsSource,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  final gps = StreamController<LocationFix>.broadcast();
  addTearDown(gps.close);
  await db.sessionDao.save(
    userId: 'officer-1',
    role: Role.fieldOfficer,
    fpoId: 'fpo-1',
    deviceId: 'dev-1',
    locale: 'en',
  );
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
  if (crops) {
    await bundle('crops', {
      'crops': [
        {
          'id': 'crop-chilli',
          'code': 'VIRUDHUNAGAR_SAMBA_VATHAL',
          'name_en': 'Samba Vathal',
          'name_local': 'சம்பா வத்தல்',
          'gi_tag_id': 'gi-883',
        },
      ],
    });
  }
  if (region) {
    final fixture = jsonDecode(File('test/fixtures/gi_region_fixture.geojson').readAsStringSync()) as Map;
    final feature = (fixture['features'] as List).first as Map;
    await bundle('gi_region', {'geometry': feature['geometry'], 'tolerance_buffer_m': 150});
  }
  final player = RecordingVoicePlayer();
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      voicePlayerProvider.overrideWithValue(player),
      pendingSendCountProvider.overrideWith((ref) => Stream.value(0)),
      fieldOfficerPhoneProvider.overrideWithValue(null),
      gpsFixProvider.overrideWithValue(GpsFix(source: gpsSource ?? () => gps.stream)),
      farmerPhotoProvider.overrideWithValue((_) async => fakePhotoPath),
      farmerCreatorProvider.overrideWithValue(creator ?? (_, _) async => null),
    ],
  );
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
        home: pushed ? const Scaffold() : const OnboardingWizard(),
      ),
    ),
  );
  if (pushed) {
    unawaited(navigator.currentState!.push(MaterialPageRoute<void>(builder: (_) => const OnboardingWizard())));
  }
  await tester.pumpAndSettle();
  return WizardFixture(db, container, gps, player);
}

/// Scrolls [finder] into view, taps it and settles. Returns when done; throws when [finder] matches nothing.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The [FilledButton] (FarmerButton's action, a `FilledButton.icon` subclass) whose label is [label].
/// Returns the finder; throws nothing.
Finder button(String label) =>
    find.ancestor(of: find.text(label), matching: find.byWidgetPredicate((w) => w is FilledButton));

/// Whether the FarmerButton labelled [label] is enabled. Throws when there is no such button.
bool enabled(WidgetTester tester, String label) => tester.widget<FilledButton>(button(label)).onPressed != null;

/// Entries saved by the wizard, by entry type (`farmer`, `consent`, `plot`). Returns them; throws nothing.
Future<Map<String, List<Entry>>> savedEntries(AppDatabase db) async {
  final byType = <String, List<Entry>>{};
  for (final e in await db.select(db.entries).get()) {
    (byType[e.entryType] ??= []).add(e);
  }
  return byType;
}

/// The decoded payload of [entry]. Throws [FormatException] for a malformed payload.
Map<String, dynamic> payloadOf(Entry entry) => jsonDecode(entry.payloadJson) as Map<String, dynamic>;

/// Puts [f]'s draft on [step] with the data that step shows (a saved pin, a chosen crop, a saved farmer, ...).
/// Returns when the screen settled; throws nothing.
Future<void> showStep(WidgetTester tester, WizardFixture f, OnboardingStep step) async {
  if (step.index >= OnboardingStep.crop.index) {
    f.notifier.savePin(fixAt(insideGi.lat, insideGi.lng, 9), lowAccuracy: false);
  }
  final crops = await f.container.read(onboardingCropsProvider.future);
  f.notifier.edit((d) {
    d.phoneDigits = '9876543210';
    d.name = 'Murugan';
    if (step == OnboardingStep.crop) d.crop = crops.single;
    if (step.index > OnboardingStep.crop.index) {
      d.hasSmartphone = true;
      d.farmerSaved = true;
      d.plotsSaved = 1;
    }
    d.step = step;
  });
  await tester.pumpAndSettle();
}
