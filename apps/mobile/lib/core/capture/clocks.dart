// The phone's clock and the GPS clock at the moment of capture; the server adds the third (serverReceivedAt).
// Requirement: Arch §Offline-first mobile design ("Three clocks": phone, GPS and server time are all stored so
//   a phone with a wrong clock is detected), FR26 (GPS and timestamp captured with every photo), PLAN §13 F1.
// Callers: camera_capture.dart (CapturedPhoto.clocks), M07 event save (Entries.deviceTime / gpsTime).

import 'gps_fix.dart';

/// Device time and GPS time of one capture. The server's received time is the third clock and is written on
/// sync, not here.
class Clocks {
  /// Creates a stamp from known values: [deviceTime] (phone clock) and [gpsTime] (time of the GPS fix, or
  /// null without one). Throws nothing.
  const Clocks({required this.deviceTime, this.gpsTime});

  /// Stamps "now": [now] is the phone clock (injectable so tests can fake it), [fix] the GPS fix used for the
  /// capture (its satellite/provider time becomes [gpsTime]). Returns the stamp; throws nothing.
  factory Clocks.stamp({LocationFix? fix, DateTime Function() now = DateTime.now}) =>
      Clocks(deviceTime: now(), gpsTime: fix?.gpsTime);

  /// Phone clock at capture (may be wrong; the server compares it with [gpsTime] and its own clock).
  final DateTime deviceTime;

  /// Time reported with the GPS fix, independent of the phone clock; null when there was no fix.
  final DateTime? gpsTime;
}
