// Opens the back camera directly (there is no gallery path) and takes one evidence photo with its clocks.
// Requirement: UserFlows §The photo is the proof ("the camera opens by itself; location and time are recorded
//   silently with it. Gallery uploads are not allowed"), FR3 (mandatory photo), FR26 (GPS + time at capture),
//   PLAN §13 B1 (capture size feeds the 1600 px compressor).
// Callers: M07 camera screen (shows CameraPreview(capture.controller!), then PhotoCompressor.compress);
//   test/capture/camera_capture_test.dart.

import 'dart:io';

import 'package:camera/camera.dart';

import 'clocks.dart';
import 'gps_fix.dart';

/// A photo straight from the camera, before compression.
class CapturedPhoto {
  /// Creates the result from the camera [file], the [clocks] at the shutter and the [fix] used (or null).
  const CapturedPhoto({required this.file, required this.clocks, this.fix});

  /// The camera's JPEG (full size, in the app cache); M07 deletes it after compression (originals not kept).
  final File file;

  /// Device time at the shutter and the GPS time of [fix] (three clocks; the server adds the third).
  final Clocks clocks;

  /// GPS fix recorded with the photo, or null when none was available.
  final LocationFix? fix;
}

/// Camera session for one capture screen: [open], show [controller] in a preview, [take], [dispose].
class CameraCapture {
  /// Creates the session. [cameras] lists the device cameras and [controllerFor] builds a controller for one;
  /// both default to the camera plugin and are injectable for tests. [now] is the phone clock (fakeable).
  CameraCapture({
    Future<List<CameraDescription>> Function()? cameras,
    CameraController Function(CameraDescription camera)? controllerFor,
    DateTime Function() now = DateTime.now,
  }) : _cameras = cameras ?? availableCameras,
       _controllerFor = controllerFor ?? _defaultController,
       _now = now;

  final Future<List<CameraDescription>> Function() _cameras;
  final CameraController Function(CameraDescription) _controllerFor;
  final DateTime Function() _now;

  /// The initialised controller for the preview widget; null until [open] succeeds.
  CameraController? controller;

  /// Opens the back camera (first camera if there is no back one).
  ///
  /// Returns true when the camera is ready, false when the user refused camera access (M07 shows its one
  /// sentence + one button sheet; no error code reaches the farmer). Side effect: starts the camera.
  /// Throws: [CameraException] for other camera failures; [StateError] when the phone has no camera.
  Future<bool> open() async {
    final all = await _cameras();
    if (all.isEmpty) throw StateError('no camera');
    final back = all.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => all.first);
    final c = _controllerFor(back);
    try {
      await c.initialize();
    } on CameraException catch (e) {
      await c.dispose();
      if (e.code.startsWith('CameraAccessDenied') || e.code.startsWith('CameraAccessRestricted')) return false;
      rethrow;
    }
    controller = c;
    return true;
  }

  /// Takes a photo and stamps it with the phone clock and the GPS time of [fix] (the latest fix from
  /// GpsFix, or null). Returns the [CapturedPhoto]. Side effect: the camera writes a JPEG to the app cache.
  /// Throws: [StateError] if [open] has not succeeded; [CameraException] if the capture fails.
  Future<CapturedPhoto> take({LocationFix? fix}) async {
    final c = controller;
    if (c == null) throw StateError('camera not open');
    final shot = await c.takePicture();
    return CapturedPhoto(
      file: File(shot.path),
      clocks: Clocks.stamp(fix: fix, now: _now),
      fix: fix,
    );
  }

  /// Releases the camera. Side effect: stops the preview. Throws nothing the caller must handle.
  Future<void> dispose() async {
    await controller?.dispose();
    controller = null;
  }

  /// Plugin controller for [camera]: 1080p-class preset, no audio, JPEG output.
  ///
  /// DECISION D-002: capture at `ResolutionPreset.veryHigh` (1080p, ~2 MP), not `max` (12 MP+).
  ///   ADV: Android Go phones with 2 GB RAM stay under the 250 MB PSS budget: a 1080p frame is ~8 MB RGBA
  ///   against ~48 MB at 12 MP, and the compressor's isolate decodes ~2 MP instead of 12 MP. 1920 px is
  ///   still above the 1600 px stored long edge (PLAN §13 B1); `medium` (480p) would fall below it.
  ///   COMPROMISE: no extra detail for zoom-in on the server; plugins may pick the nearest supported size,
  ///   so the stored long edge can be below 1600 px on odd sensors (never upscaled). PSS measured in Q01.
  /// Returns the unopened controller; throws nothing.
  static CameraController _defaultController(CameraDescription camera) =>
      CameraController(camera, ResolutionPreset.veryHigh, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
}
