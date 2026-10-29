// Shared harness for the M05 widget kit: pumps a widget in a themed, localised, provider-scoped app at a
//   given screen size and text scale, plus one sample screen per widget used by the goldens and the
//   accessibility sweep.
// Requirement: plan §7.2 M05 acceptance (goldens en+ta x scale 1.0/1.5 x 360x640/412x915; every control
//   >= 56 dp; Semantics on icon controls).
// Callers: test/widget/kit_test.dart, kit_golden_test.dart, voice_test.dart.

import 'dart:io';

import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/theme/app_theme.dart';
import 'package:agritrace/core/theme/farmer_tokens.dart';
import 'package:agritrace/core/voice/voice_player.dart';
import 'package:agritrace/core/widgets/assist_bar.dart';
import 'package:agritrace/core/widgets/big_stepper.dart';
import 'package:agritrace/core/widgets/call_officer_button.dart';
import 'package:agritrace/core/widgets/cloud_sync_indicator.dart';
import 'package:agritrace/core/widgets/confirm_scaffold.dart';
import 'package:agritrace/core/widgets/error_sheet.dart';
import 'package:agritrace/core/widgets/gps_ring.dart';
import 'package:agritrace/core/widgets/number_pad.dart';
import 'package:agritrace/core/widgets/picture_card_grid.dart';
import 'package:agritrace/core/widgets/status_badge.dart';
import 'package:agritrace/core/widgets/voice_prompt_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Officer number the harness injects through [fieldOfficerPhoneProvider].
const officerPhone = '+919876543210';

/// The two phone screens of the acceptance matrix, in dp.
const screenSizes = [Size(360, 640), Size(412, 915)];

/// The two text scales of the acceptance matrix (the app clamps to 1.0-1.5).
const textScales = [1.0, 1.5];

/// Reads assets straight from the package directory with synchronous file I/O.
///
/// rootBundle's real I/O never completes inside testWidgets' fake-async zone; this bundle returns completed
/// futures, so the real `assets/prompts.json` is used without `runAsync`.
class _FileAssetBundle extends CachingAssetBundle {
  /// Returns the bytes of the asset file at [key] (relative to apps/mobile). Throws [FileSystemException]
  /// when it does not exist.
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(File(key).readAsBytesSync());
}

/// A [VoicePlayer] over the real asset files (real prompts.json) that records clip paths instead of playing.
class RecordingVoicePlayer extends VoicePlayer {
  /// Creates the player; every started clip path is appended to [played].
  RecordingVoicePlayer._(this.played) : super(bundle: _FileAssetBundle(), playClip: (path) async => played.add(path));

  /// Creates a player with an empty [played] list. Returns it; throws nothing.
  factory RecordingVoicePlayer() => RecordingVoicePlayer._([]);

  /// Asset paths of the clips started, in order.
  final List<String> played;
}

/// Pumps [child] in the app shell and returns the voice player the widgets use.
///
/// [tester] is the running test; [locale] the UI language; [size] the logical screen size (rendered at
/// device pixel ratio 1 so goldens stay small); [textScale] the text scale; [pending] the pending-send
/// stream (default: one value, 3); [scaffold] wraps [child] in a padded [Scaffold] body (false for widgets
/// that are screens themselves); [autoplay] the voice autoplay setting. Side effect: changes the test view,
/// reset when the test ends. Returns after the first frame and the autoplay callbacks.
Future<RecordingVoicePlayer> pumpKit(
  WidgetTester tester,
  Widget child, {
  Locale locale = tamil,
  Size size = const Size(360, 640),
  double textScale = 1.0,
  Stream<int>? pending,
  bool scaffold = true,
  bool autoplay = true,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final player = RecordingVoicePlayer();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        voicePlayerProvider.overrideWithValue(player),
        voiceAutoplayProvider.overrideWithValue(autoplay),
        pendingSendCountProvider.overrideWith((ref) => pending ?? Stream.value(3)),
        fieldOfficerPhoneProvider.overrideWithValue(officerPhone),
      ],
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
        home: scaffold
            ? Scaffold(
                body: SafeArea(
                  child: Padding(padding: const EdgeInsets.all(16), child: child),
                ),
              )
            : child,
      ),
    ),
  );
  await tester.pump();
  return player;
}

/// One sample screen per widget: [name] (golden file stem), whether it needs the [scaffold] wrapper, the
/// [build] function (run below the localisations) and an optional [settle] that advances time before checks (GpsRing's 60 s wait).
typedef KitSample = ({
  String name,
  bool scaffold,
  Widget Function(BuildContext context) build,
  Future<void> Function(WidgetTester tester)? settle,
});

/// True when [context] renders Tamil. Returns the flag; throws nothing.
bool _ta(BuildContext context) => Localizations.localeOf(context).languageCode == 'ta';

/// The sample screens, in kit order. Sample labels that are FPO data in the real app (crop, unit, farmer
/// name, event summary) are written here per language.
final List<KitSample> kitSamples = [
  (
    name: 'picture_card_grid',
    scaffold: true,
    settle: null,
    build: (context) => SingleChildScrollView(
      child: PictureCardGrid<int>(
        selected: 1,
        onSelected: (_) {},
        choices: [
          for (final (i, icon, ta, en) in [
            (0, Icons.water, 'கிணறு', 'Well'),
            (1, Icons.water_drop, 'ஆழ்துளை', 'Borewell'),
            (2, Icons.waves, 'கால்வாய்', 'Canal'),
            (3, Icons.cloud, 'மழை', 'Rain only'),
          ])
            PictureChoice(value: i, picture: Icon(icon, size: 56), label: _ta(context) ? ta : en, promptId: 'water$i'),
        ],
      ),
    ),
  ),
  (
    name: 'big_stepper',
    scaffold: true,
    settle: null,
    build: (context) =>
        BigStepper(value: 120000, min: 0, max: 999999, unit: _ta(context) ? 'கிலோ' : 'kg', onChanged: (_) {}),
  ),
  (
    name: 'number_pad',
    scaffold: true,
    settle: null,
    build: (context) =>
        NumberPad(value: '120000', onChanged: (_) {}, allowDecimal: true, unit: _ta(context) ? 'கிலோ' : 'kg'),
  ),
  (
    name: 'status_badge',
    scaffold: true,
    settle: null,
    build: (_) => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        StatusBadge(status: FarmerStatus.done),
        StatusBadge(status: FarmerStatus.todo),
        StatusBadge(status: FarmerStatus.attention),
      ],
    ),
  ),
  (
    name: 'voice_prompt_bar',
    scaffold: true,
    settle: null,
    // Bundled clip: speaker on. Not bundled: crossed-out speaker, text only.
    build: (context) => Column(
      spacing: 16,
      children: [
        VoicePromptBar(promptId: 'gpsHold', text: AppLocalizations.of(context).gpsHold),
        VoicePromptBar(promptId: 'photoNotClear', text: AppLocalizations.of(context).photoNotClear),
      ],
    ),
  ),
  (name: 'call_officer_button', scaffold: true, settle: null, build: (_) => const CallFieldOfficerButton()),
  (
    name: 'confirm_scaffold',
    scaffold: false,
    settle: null,
    build: (context) => ConfirmScaffold(
      title: _ta(context) ? 'அறுவடை' : 'Harvest',
      summary: _ta(context) ? 'அறுவடை, 6 மூட்டை, இன்று. சரியா?' : 'Harvest, 6 bags, today. Correct?',
      promptId: 'confirmHarvest',
      preview: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image, size: 96)),
      ),
      onConfirm: () {},
      onRetake: () {},
      showCloud: true,
    ),
  ),
  (
    name: 'cloud_sync_indicator',
    scaffold: true,
    settle: null,
    build: (_) => const Align(alignment: Alignment.topLeft, child: CloudSyncIndicator()),
  ),
  (
    name: 'assist_bar',
    scaffold: true,
    settle: null,
    build: (context) => Align(
      alignment: Alignment.topCenter,
      child: AssistBar(farmerName: _ta(context) ? 'முருகன்' : 'Murugan'),
    ),
  ),
  (
    name: 'gps_ring',
    scaffold: true,
    settle: (tester) => tester.pump(GpsRing.saveAnywayAfter),
    build: (_) => SingleChildScrollView(child: GpsRing(accuracyMetres: 35, onSaveAnyway: () {})),
  ),
  (
    name: 'error_sheet',
    scaffold: false,
    settle: null,
    build: (context) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          elevation: 1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: ErrorSheet(
            picture: Icon(
              Icons.no_photography,
              size: 96,
              color: Theme.of(context).extension<FarmerTokens>()!.attention.color,
            ),
            sentence: AppLocalizations.of(context).photoNotClear,
            promptId: 'photoNotClear',
            actionIcon: Icons.photo_camera,
            actionLabel: AppLocalizations.of(context).retake,
            actionPromptId: 'retake',
            onAction: () {},
          ),
        ),
      ),
    ),
  ),
];

/// Pumps [sample] with the given matrix values and runs its [KitSample.settle]. Returns the voice player.
///
/// [tester], [locale], [size] and [textScale] as in [pumpKit]. Throws whatever the widget throws while
/// laying out (an overflow fails the test).
Future<RecordingVoicePlayer> pumpSample(
  WidgetTester tester,
  KitSample sample, {
  required Locale locale,
  required Size size,
  required double textScale,
}) async {
  final player = await pumpKit(
    tester,
    Builder(builder: sample.build),
    locale: locale,
    size: size,
    textScale: textScale,
    scaffold: sample.scaffold,
  );
  await sample.settle?.call(tester);
  await tester.pump();
  return player;
}
