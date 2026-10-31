// Tests for CameraCapture with a fake camera controller: back camera chosen, permission refusal as a typed
//   result, photo stamped with device and GPS time.
// Requirement: UserFlows §The photo is the proof (camera opens by itself; time and location recorded), FR26,
//   Arch §Offline-first (three clocks).
// Callers: `flutter test test/capture`.

import 'package:agritrace/core/capture/camera_capture.dart';
import 'package:agritrace/core/capture/gps_fix.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake controller: [initialize] throws [error] when set; [takePicture] returns a fixed path.
class FakeController implements CameraController {
  /// Creates the fake for [description]; [error] makes [initialize] fail.
  FakeController(this.description, {this.error});

  @override
  final CameraDescription description;

  /// Exception thrown by [initialize], or null.
  final CameraException? error;

  /// Whether [dispose] ran.
  bool disposed = false;

  @override
  Future<void> initialize() async {
    if (error != null) throw error!;
  }

  @override
  Future<XFile> takePicture() async => XFile('/cache/CAP_1.jpg');

  @override
  Future<void> dispose() async => disposed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _front = CameraDescription(name: 'f', lensDirection: CameraLensDirection.front, sensorOrientation: 270);
const _back = CameraDescription(name: 'b', lensDirection: CameraLensDirection.back, sensorOrientation: 90);

void main() {
  test('opens the back camera and stamps the photo with device time and GPS time', () async {
    final cap = CameraCapture(
      cameras: () async => [_front, _back],
      controllerFor: FakeController.new,
      now: () => DateTime(2026, 2, 14, 9, 30),
    );
    expect(await cap.open(), isTrue);
    expect(cap.controller!.description.name, 'b');

    final fix = LocationFix(lat: 9.56, lng: 78.13, accuracyM: 8, gpsTime: DateTime.utc(2026, 2, 14, 4, 0, 1));
    final shot = await cap.take(fix: fix);
    expect(shot.file.path, '/cache/CAP_1.jpg');
    expect(shot.clocks.deviceTime, DateTime(2026, 2, 14, 9, 30));
    expect(shot.clocks.gpsTime, DateTime.utc(2026, 2, 14, 4, 0, 1));
    expect(shot.fix, same(fix));
  });

  test('camera access refused → false, controller released, no error code surfaced', () async {
    late FakeController made;
    final cap = CameraCapture(
      cameras: () async => [_back],
      controllerFor: (d) => made = FakeController(d, error: CameraException('CameraAccessDenied', 'denied')),
    );
    expect(await cap.open(), isFalse);
    expect(made.disposed, isTrue);
    expect(cap.controller, isNull);
    expect(() => cap.take(), throwsStateError);
  });

  test('other camera failures propagate', () async {
    final cap = CameraCapture(
      cameras: () async => [_back],
      controllerFor: (d) => FakeController(d, error: CameraException('cameraNotFound', 'x')),
    );
    expect(cap.open(), throwsA(isA<CameraException>()));
  });
}
