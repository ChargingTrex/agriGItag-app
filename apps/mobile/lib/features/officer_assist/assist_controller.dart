// Assist mode: the field officer's assist session for one farmer (start, end) and the phone's "entered remotely"
//   preview.
// Requirement: UserFlows §Field officer flows "Assist mode" (tap the farmer's name, the screen switches to that farmer's
//   home with "Logging for: [farmer name]"; the record shows "entered by field officer" and the officer's GPS, and
//   "entered remotely" when the officer is not on the plot); PRD FR69; CLAUDE.md §6 (assist mode is recorded on every
//   entry it creates); D-032 (an `assist_session` entry starts it, every assisted entry carries `assist_session_id`,
//   `POST /assist/end` online at exit).
// Callers: officer_home_screen.dart (start), farmer_home_screen.dart (End assist, back), event_log_controller.dart
//   (assistFarmerProvider, session id and enteredRemotely on save), officer_moisture/moisture_screen.dart (session id),
//   app.dart (assist bar on every screen), app_router.dart (assist route guard); tests.

import 'dart:async';
import 'dart:convert';

import 'package:agritrace_api/agritrace_api.dart' show AssistEndIn;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:uuid/uuid.dart';

import '../../core/api/api_client.dart';
import '../../core/capture/capture_constants.dart';
import '../../core/capture/gps_fix.dart';
import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../event_log/event_log_controller.dart';
import '../onboarding_farmer/onboarding_notifier.dart' show assistSessionEntryType;

/// FR69 radius around the plot pin, in metres; mirrors `EVENT_RADIUS_M` in the server's `events/service.py`.
const kEventRadiusM = 100.0;

/// FR32 GPS-drift buffer added to [kEventRadiusM], in metres; mirrors the server's `EVENT_BUFFER_M`.
const kEventBufferM = 50.0;

/// One running assist session: its UUIDv7 [sessionId] (the `assist_session` entry id and the server's session id),
/// the assisted farmer's id and display name.
typedef AssistSession = ({String sessionId, String farmerId, String name});

/// Whether an entry with the officer's [fix] counts as entered away from [plot] (FR69): more than
/// [kEventRadiusM] + [kEventBufferM] from the pin. False without a plot or a fix, as on the server.
///
/// shortcut: the pin radius only; the server also accepts a fix inside the walked boundary, so on a large walked plot
///   the phone can say "remote" where the server does not. The server recomputes `entered_remotely` on every event
///   (CLAUDE.md §6), so the phone value is a preview; check the boundary here when M08 shows it to anyone.
/// Returns the flag; throws nothing.
bool enteredRemotely(Plot? plot, LocationFix? fix) =>
    plot != null &&
    fix != null &&
    Geolocator.distanceBetween(fix.lat, fix.lng, plot.pinLat, plot.pinLng) > kEventRadiusM + kEventBufferM;

/// Holds the running assist session, or null when the officer is not logging for anyone.
///
/// The session lives in memory: an app restart ends assist mode on the phone, and the server session stays open
/// (allowed by D-032: an open session grants nothing an officer could not get by starting a new one).
class AssistNotifier extends Notifier<AssistSession?> {
  /// No session until [start]. Returns null; throws nothing.
  @override
  AssistSession? build() => null;

  /// Starts assist mode for [farmer], ending any session still running first.
  ///
  /// Mints the session's UUIDv7 and queues an `assist_session` entry (`{farmer_id, started_at, started_gps}`, the
  /// push `data` of D-032) through `EntriesDao.save`, the same path online and offline; [gps] is the officer's latest
  /// fix, or null when none came yet. Returns when the entry is written and the state set.
  /// Throws [StateError] when nobody is signed in; `SqliteException` when the write fails (state unchanged then).
  /// Side effects: one Entries row and its outbox row; a send kick ([afterSaveProvider]); see [end].
  Future<void> start(Farmer farmer, {LocationFix? gps}) async {
    end();
    final db = ref.read(appDatabaseProvider);
    final officer = await db.sessionDao.read() ?? (throw StateError('signed out'));
    final now = ref.read(clockProvider)();
    final id = const Uuid().v7();
    // DECISION D-032: assist mode starts with an `assist_session` entry, not a `POST /assist/start` call.
    //   ADV: one offline-capable write path; the outbox pushes it before the entries that name it.
    //   COMPROMISE: the session exists on the server only after the next push, and stays open there unless [end]
    //     reaches the server.
    await db.entriesDao.save(
      EntriesCompanion.insert(
        entryId: id,
        rootId: id,
        version: 1,
        entryType: assistSessionEntryType,
        farmerId: farmer.farmerId,
        instanceNo: 1,
        payloadJson: jsonEncode({
          'farmer_id': farmer.farmerId,
          'started_at': now.toUtc().toIso8601String(),
          if (gps != null) 'started_gps': {'lat': gps.lat, 'lon': gps.lng, 'accuracy_m': gps.accuracyM},
        }),
        deviceTime: now,
        gpsTime: Value(gps?.gpsTime),
        lat: Value(gps?.lat),
        lng: Value(gps?.lng),
        accuracyM: Value(gps?.accuracyM),
        locationStatus: gps == null
            ? LocationStatus.none
            : (gps.accuracyM <= kGpsGoodAccuracyM ? LocationStatus.ok : LocationStatus.lowAccuracy),
        enteredByUserId: officer.userId,
        assistMode: const Value(true),
        status: EntryStatus.saved,
        // A session start is not a farm event: nothing to undo.
        undoDeadline: now,
        createdAt: now,
      ),
      const [],
    );
    state = (sessionId: id, farmerId: farmer.farmerId, name: farmer.name);
    ref.read(afterSaveProvider)();
  }

  /// Ends assist mode on the phone at once, then tells the server (`POST /v1/assist/end`) without waiting for it.
  ///
  /// Does nothing when no session runs. Returns nothing; throws nothing. Side effects: state null (the assist bar
  /// goes); one network call in the background whose failure is ignored.
  void end() {
    final session = state;
    if (session == null) return;
    state = null;
    unawaited(_endOnServer(session.sessionId));
  }

  /// Best-effort `POST /v1/assist/end` for [sessionId]. Returns when answered or failed; throws nothing.
  ///
  /// shortcut: without signal, or before the outbox pushed the `assist_session` entry (404), the server session stays
  ///   open; queue an `assist_end` push kind if audit needs session durations (D-032 "Revisit when").
  Future<void> _endOnServer(String sessionId) async {
    try {
      await ref
          .read(apiClientProvider)
          .api
          .getIdentityApi()
          .assistEndV1AssistEndPost(assistEndIn: AssistEndIn((b) => b.assistSessionId = sessionId));
    } on DioException {
      // No signal or not pushed yet: D-032 allows an open session.
    }
  }
}

/// The app's assist session.
final assistProvider = NotifierProvider<AssistNotifier, AssistSession?>(AssistNotifier.new);
