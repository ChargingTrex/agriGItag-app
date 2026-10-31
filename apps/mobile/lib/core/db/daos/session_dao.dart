// Session DAO: reads and writes the single Session row (who is signed in on this phone), without tokens.
// Requirement: FR1 (OTP sign-in), UserFlows §Log in once (stay signed in), mobile-design.md §2 (Session row), D-024.
// Callers: SessionNotifier (lib/core/router/session.dart) on sign-in, restore, locale change and sign-out;
//   features/settings/settings_screen.dart (Wi-Fi-only photos, M08).

import 'package:drift/drift.dart';

import '../../router/session.dart' show Role;
import '../database.dart';

part 'session_dao.g.dart';

/// Reads and writes the singleton Session row (id = 1).
@DriftAccessor(tables: [SessionTable])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  /// Creates the DAO on [db]; use `db.sessionDao` instead of calling this.
  SessionDao(super.db);

  /// The signed-in session row, or null when nobody is signed in. Throws nothing.
  Future<SessionRow?> read() => select(sessionTable).getSingleOrNull();

  /// Stores who signed in, replacing any previous row.
  ///
  /// [userId], [role] and [fpoId] come from the server session; [deviceId] is this install's id; [locale] the UI
  /// language code (`ta`/`en`). Returns when written; throws nothing.
  ///
  /// DECISION D-027: tokens live in flutter_secure_storage (Keychain/Keystore), never in this SQLite row.
  ///   ADV: tokens never sit in plain SQLite on a shared family phone (a rooted phone or a backup cannot read them).
  ///   COMPROMISE: secure storage is per-install and gone after a reinstall (the desired behaviour: sign in again);
  ///   one more plugin. The v1 schema still has NOT NULL token columns, so they are written empty until the next
  ///   schema bump drops them.
  Future<void> save({
    required String userId,
    required Role role,
    required String fpoId,
    required String deviceId,
    required String locale,
  }) => into(sessionTable).insertOnConflictUpdate(
    SessionTableCompanion.insert(
      userId: userId,
      role: role,
      fpoId: fpoId,
      deviceId: deviceId,
      accessToken: '',
      refreshToken: '',
      locale: Value(locale),
    ),
  );

  /// Changes the stored UI language to [locale] (`ta`/`en`); a no-op when signed out. Throws nothing.
  Future<void> setLocale(String locale) => update(sessionTable).write(SessionTableCompanion(locale: Value(locale)));

  /// Stores the "photos on Wi-Fi only" setting [on] (PLAN §13 B5, default off) that the sync engine reads before each
  /// photo phase; a no-op when signed out. Throws nothing.
  Future<void> setWifiOnlyPhotos(bool on) =>
      update(sessionTable).write(SessionTableCompanion(wifiOnlyPhotos: Value(on)));

  /// The session row as a stream (null while signed out), for the Settings switches. Never errors on its own.
  Stream<SessionRow?> watch() => select(sessionTable).watchSingleOrNull();

  /// Deletes the row (sign-out). Every other table, the outbox included, is left alone. Throws nothing.
  Future<void> clear() => delete(sessionTable).go();
}
