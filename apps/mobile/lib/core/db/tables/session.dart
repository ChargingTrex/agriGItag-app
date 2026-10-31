// Drift table for the signed-in session: one row (id = 1) holding who is signed in on this phone.
// Requirement: mobile-design.md §2 (Session row); plan §7.2 M06 (OTP sign-in, PIN, language, Wi-Fi-only photos).
// Callers: database.dart (table list); M06 auth and lib/core/router/session.dart will read and write it.

import 'package:drift/drift.dart';

import '../../router/session.dart' show Role;

/// The signed-in session: a singleton row with [id] = 1 (a CHECK constraint enforces it).
///
/// Tokens are stored as the API returns them; M06 decides whether they move to the platform keystore.
@DataClassName('SessionRow')
class SessionTable extends Table {
  /// SQL table name `session` (the Dart name avoids a clash with the router's `Session` class).
  @override
  String get tableName => 'session';

  /// Always 1: there is at most one signed-in user per phone.
  // ignore: recursive_getters, Drift reads this CHECK at build time; the getter itself never runs.
  IntColumn get id => integer().check(id.equals(1)).withDefault(const Constant(1))();

  /// Server user id (UUID).
  TextColumn get userId => text()();

  /// Role of the signed-in user, stored as the Dart enum name (`farmer`, `fieldOfficer`, `qc`).
  TextColumn get role => textEnum<Role>()();

  /// FPO the user belongs to (UUID); every API call is scoped to it.
  TextColumn get fpoId => text()();

  /// Stable id of this install, sent as `X-Device-Id`.
  TextColumn get deviceId => text()();

  /// Short-lived bearer token.
  TextColumn get accessToken => text()();

  /// Token that obtains a new [accessToken].
  TextColumn get refreshToken => text()();

  /// Hash of the optional quick-unlock PIN; null when no PIN is set.
  TextColumn get pinHash => text().nullable()();

  /// UI language code, `ta` (default) or `en` (D-016).
  TextColumn get locale => text().withDefault(const Constant('ta'))();

  /// When true, photos wait for Wi-Fi before uploading (Arch §Offline-first "When it syncs").
  BoolColumn get wifiOnlyPhotos => boolean().withDefault(const Constant(false))();

  /// Primary key: [id].
  @override
  Set<Column<Object>> get primaryKey => {id};
}
