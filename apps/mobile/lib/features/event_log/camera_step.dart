// F06 camera: opens by itself (no gallery), takes the evidence photo with its clocks and GPS, compresses it with a
// progress indicator, refuses a dark or blurry photo, and waits for a good GPS fix with the ring and "Save anyway".
// Requirement: UserFlows §Design rules "The photo is the proof" (camera opens by itself; location and time recorded
//   silently; no gallery), §When things go wrong (photo too dark or blurry → "Photo is not clear. Take again?"; weak
//   GPS → filling circle, "Save anyway" after 60 s, saved with its accuracy; phone full); FR3, FR26, FR61; Arch
//   §Offline-first ("Photos made light", "Three clocks"); D-011.
// Callers: EventFlowScreen (event_flow_screen.dart) as the photo step of every event.

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/capture/camera_capture.dart';
import '../../core/capture/capture_constants.dart';
import '../../core/capture/gps_fix.dart';
import '../../core/capture/photo_compressor.dart';
import '../../core/capture/photo_quality_check.dart';
import '../../core/db/database.dart' show LocationStatus;
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/call_officer_button.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/gps_ring.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import 'event_log_controller.dart';
import 'farmer_sheet.dart';

/// The camera step: preview + shutter, then (only if the fix is weak) the GPS ring. Calls [onAccepted] once the
/// photo and its location are stored in the draft.
class CameraStep extends ConsumerStatefulWidget {
  /// Creates the step; [onAccepted] opens the confirm screen.
  const CameraStep({super.key, required this.onAccepted});

  /// Opens the confirm screen.
  final VoidCallback onAccepted;

  /// Creates the state owning the camera session and the GPS subscription. Returns it; throws nothing.
  @override
  ConsumerState<CameraStep> createState() => _CameraStepState();
}

/// State of [CameraStep]: the camera session, the GPS subscription and the step's phase.
class _CameraStepState extends ConsumerState<CameraStep> {
  /// The camera session of this screen (M04).
  late final CameraCapture _camera = ref.read(cameraFactoryProvider)();

  /// GPS fixes while the screen is open.
  StreamSubscription<LocationFix>? _gps;

  /// The most accurate fix seen so far (saved with the entry).
  LocationFix? _best;

  /// The latest fix (drives the ring).
  LocationFix? _latest;

  /// Null while the camera opens, true when ready, false when refused or broken.
  bool? _ready;

  /// True while the photo is taken and compressed (shutter disabled, progress shown).
  bool _busy = false;

  /// True after the photo while the GPS fix is still weak (the ring is shown).
  bool _waitingGps = false;

  /// Opens the camera and starts listening to GPS fixes so a fix is usually ready by the shutter.
  /// Side effects: camera and GPS on. Throws nothing.
  @override
  void initState() {
    super.initState();
    _open();
    _gps = ref.read(gpsFixProvider).fixes().listen(_onFix, onError: (Object _) {});
  }

  /// Releases the camera and the GPS. Throws nothing.
  @override
  void dispose() {
    _gps?.cancel();
    _camera.dispose();
    super.dispose();
  }

  /// Opens the back camera; a refusal or a broken camera shows the "camera is off" state (no error code).
  /// Side effect: rebuilds. Throws nothing.
  Future<void> _open() async {
    setState(() => _ready = null);
    bool ok;
    try {
      ok = await _camera.open();
    } on Object {
      // CameraException or StateError (no camera): the farmer only needs "try again" or the officer.
      ok = false;
    }
    if (mounted) setState(() => _ready = ok);
  }

  /// Keeps the latest and the most accurate [fix]; while waiting after the photo, a good fix accepts it.
  /// Side effect: rebuilds. Throws nothing.
  void _onFix(LocationFix fix) {
    if (!mounted) return;
    setState(() {
      _latest = fix;
      if (_best == null || fix.accuracyM < _best!.accuracyM) _best = fix;
    });
    if (_waitingGps && fix.accuracyM <= kGpsGoodAccuracyM) _accept(LocationStatus.ok);
  }

  /// Takes, compresses and checks the photo; deletes the camera original (never kept); then accepts it or waits for
  /// GPS. A dark/blurry photo or a full phone opens its one-button sheet.
  /// Side effects: files in the media folder, the draft's photo. Throws nothing.
  Future<void> _shoot() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final shot = await _camera.take(fix: _best);
      final CompressedPhoto photo;
      try {
        photo = await ref
            .read(photoCompressorProvider)
            .compress(
              shot.file,
              outDir: await ref.read(mediaDirProvider.future),
              capturedAt: shot.clocks.deviceTime,
              fix: shot.fix,
            );
      } finally {
        deleteQuietly(shot.file.path);
      }
      if (!mounted) return;
      if (photo.quality != PhotoQuality.ok) {
        deleteQuietly(photo.path);
        deleteQuietly(photo.thumbPath);
        return _notClear(l10n);
      }
      ref.read(eventLogProvider.notifier).setPhoto(photo, shot.clocks, shot.fix);
      if (_best != null && _best!.accuracyM <= kGpsGoodAccuracyM) {
        _accept(LocationStatus.ok);
      } else {
        setState(() => _waitingGps = true);
      }
    } on FileSystemException {
      if (mounted) await _phoneFull(l10n);
    } on FormatException {
      // The camera wrote something that is not a JPEG: to the farmer that is an unclear photo.
      if (mounted) await _notClear(l10n);
    } on CameraException {
      if (mounted) await _notClear(l10n);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Shows "Photo is not clear. Take again?" with the camera button ([l10n] strings). Returns when closed.
  Future<void> _notClear(AppLocalizations l10n) => showFarmerSheet(
    context,
    icon: Icons.no_photography,
    sentence: l10n.photoNotClear,
    promptId: 'photoNotClear',
    actionIcon: Icons.photo_camera,
    actionLabel: l10n.retake,
    actionPromptId: 'retake',
  );

  /// Shows "Phone is full. Send your entries now?"; the button starts a send ([l10n] strings). Returns when closed.
  Future<void> _phoneFull(AppLocalizations l10n) => showFarmerSheet(
    context,
    icon: Icons.sd_card_alert,
    sentence: l10n.phoneFull,
    promptId: 'phoneFull',
    actionIcon: Icons.cloud_upload,
    actionLabel: l10n.sendNow,
    actionPromptId: 'sendNow',
    onAction: ref.read(afterSaveProvider),
  );

  /// Stores the best fix with [status] and opens the confirm screen. Side effect: draft location. Throws nothing.
  void _accept(LocationStatus status) {
    setState(() => _waitingGps = false);
    ref.read(eventLogProvider.notifier).setLocation(_best, status);
    widget.onAccepted();
  }

  /// Builds the GPS ring while waiting, the "camera is off" state, or preview + shutter. [context] supplies theme and
  /// strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final gap = SizedBox(height: tokens.gap);
    if (_waitingGps) {
      return ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          GpsRing(
            accuracyMetres: _latest?.accuracyM,
            onSaveAnyway: () => _accept(_best == null ? LocationStatus.none : LocationStatus.lowAccuracy),
          ),
          gap,
          const CallFieldOfficerButton(),
        ],
      );
    }
    if (_ready == false) {
      return ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          Icon(Icons.no_photography, size: 96, color: tokens.attention.color),
          gap,
          VoicePromptBar(promptId: 'cameraOff', text: l10n.cameraOff),
          gap,
          FarmerButton(
            icon: Icons.refresh,
            label: l10n.tryAgain,
            onPressed: _open,
            onSpeak: () => playPrompt(ref, context, 'tryAgain'),
            prominent: true,
          ),
          gap,
          const CallFieldOfficerButton(),
        ],
      );
    }
    final controller = _camera.controller;
    return Padding(
      padding: EdgeInsets.all(tokens.gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VoicePromptBar(promptId: 'cameraPrompt', text: l10n.cameraPrompt),
          gap,
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: Colors.black,
                    child: controller == null ? null : Center(child: CameraPreview(controller)),
                  ),
                  if (_busy)
                    // Compression runs in an isolate (pure-Dart decoder, slow on Android Go): show it is working.
                    ColoredBox(
                      color: Colors.black54,
                      child: Center(
                        child: Semantics(
                          liveRegion: true,
                          label: l10n.photoSaving,
                          child: const CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          gap,
          FarmerButton(
            icon: Icons.camera,
            label: l10n.takePhoto,
            onPressed: _ready == true && !_busy ? _shoot : null,
            onSpeak: () => playPrompt(ref, context, 'takePhoto'),
            prominent: true,
          ),
          gap,
          const CallFieldOfficerButton(),
        ],
      ),
    );
  }
}
