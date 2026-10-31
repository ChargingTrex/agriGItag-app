// GPS fixes with accuracy, and the "wait until ≤ 20 m or 60 s" rule behind the GPS ring and "Save anyway".
// Requirement: FR26 (event GPS captured silently with every photo), UserFlows §When things go wrong (Weak GPS:
//   filling circle; after 60 seconds "Save anyway"; saved with its accuracy, low accuracy flagged),
//   Arch §Offline-first ("Three clocks": the fix carries GPS time, separate from the phone clock).
// Callers: M07 event capture and M09 onboarding pin (feed GpsRing from [GpsFix.fixes], save with
//   [GpsFix.waitForAccuracy]); camera_capture.dart and exif_rewriter.dart take a [LocationFix].

import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'capture_constants.dart';

/// One location fix: position, horizontal accuracy and the time the location provider reported for it.
class LocationFix {
  /// Creates a fix: [lat]/[lng] in WGS84 degrees, [accuracyM] horizontal accuracy in metres (68 %),
  /// [gpsTime] the provider's fix time (not the phone clock), [altitudeM] metres above WGS84 or null.
  const LocationFix({
    required this.lat,
    required this.lng,
    required this.accuracyM,
    required this.gpsTime,
    this.altitudeM,
  });

  /// Converts a geolocator [p]. Returns the fix; throws nothing.
  factory LocationFix.fromPosition(Position p) => LocationFix(
    lat: p.latitude,
    lng: p.longitude,
    accuracyM: p.accuracy,
    gpsTime: p.timestamp,
    altitudeM: p.hasAltitude ? p.altitude : null,
  );

  /// Latitude in degrees (WGS84).
  final double lat;

  /// Longitude in degrees (WGS84).
  final double lng;

  /// Horizontal accuracy in metres.
  final double accuracyM;

  /// Fix time from the location provider (GNSS time for satellite fixes), independent of the phone clock.
  final DateTime gpsTime;

  /// Altitude in metres, or null when unknown.
  final double? altitudeM;
}

/// Outcome of [GpsFix.waitForAccuracy]: the most accurate fix seen and whether it missed the target.
class GpsResult {
  /// Creates a result from [best] (null when no fix arrived) and [lowAccuracy] (target not reached).
  const GpsResult({required this.best, required this.lowAccuracy});

  /// Most accurate fix seen, or null when none arrived (permission denied, location off, indoors).
  final LocationFix? best;

  /// True when [best] is missing or worse than the target: the "Save anyway" case, flagged for the officer.
  final bool lowAccuracy;

  /// Value for `Entries.locationStatus`: `ok`, `low_accuracy` or `none`. Throws nothing.
  String get locationStatus => best == null ? 'none' : (lowAccuracy ? 'low_accuracy' : 'ok');
}

/// Stream of location fixes plus the wait-for-accuracy rule. The fix source is injectable so tests (and the
/// fake clock of `fake_async`) can drive it.
class GpsFix {
  /// Creates the service. [source] returns a stream of fixes; it defaults to the phone's location provider
  /// via geolocator (asks for permission first and yields nothing when refused or when location is off).
  GpsFix({Stream<LocationFix> Function()? source}) : _source = source ?? _deviceFixes;

  final Stream<LocationFix> Function() _source;

  /// Fixes as they arrive, for the GPS ring. Returns a single-subscription stream; errors from the provider
  /// pass through. Side effect: turns the GPS on while listened to.
  Stream<LocationFix> fixes() => _source();

  /// Listens until a fix is at or below [targetM] metres, or [timeout] passes, or the source ends.
  ///
  /// Returns the most accurate fix seen; [GpsResult.lowAccuracy] is true unless that fix met [targetM].
  /// Provider errors end the wait like the source ending. Throws nothing. Side effect: GPS on while waiting.
  Future<GpsResult> waitForAccuracy({double targetM = kGpsGoodAccuracyM, Duration timeout = kGpsTimeout}) {
    final done = Completer<GpsResult>();
    LocationFix? best;
    late final StreamSubscription<LocationFix> sub;
    late final Timer timer;
    void finish() {
      if (done.isCompleted) return;
      timer.cancel();
      unawaited(sub.cancel());
      done.complete(GpsResult(best: best, lowAccuracy: best == null || best!.accuracyM > targetM));
    }

    timer = Timer(timeout, finish);
    sub = _source().listen(
      (fix) {
        if (best == null || fix.accuracyM < best!.accuracyM) best = fix;
        if (fix.accuracyM <= targetM) finish();
      },
      onError: (Object _) => finish(),
      onDone: finish,
    );
    return done.future;
  }

  /// Device fixes via geolocator: requests permission once, then streams best-accuracy fixes.
  /// Returns an empty stream when permission is refused or location services are off. Throws nothing itself;
  /// later provider errors arrive on the stream.
  static Stream<LocationFix> _deviceFixes() async* {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
    if (!await Geolocator.isLocationServiceEnabled()) return;
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).map(LocationFix.fromPosition);
  }
}
