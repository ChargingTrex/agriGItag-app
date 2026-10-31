// Drift table for the signed-in session: one row (id = 1) holding who is signed in on this phone.
// Requirement: mobile-design.md §2 (Session row); plan §7.2 M06 (OTP sign-in, PIN, language, Wi-Fi-only photos).
// Callers: database.dart (table list); SessionDao (daos/session_dao.dart), used by lib/core/router/session.dart.

import 'package:drift/drift.dart';

import '../../router/session.dart' show Role;

/// The signed-in session: a singleton row with [id] = 1 (a CHECK constraint enforces it).
///
/// Tokens are not stored here: they live in the platform keystore (D-027, SessionNotifier). Schema v3 (M13) dropped
/// the empty v1 token and PIN columns.
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

  /// Stable id of this install (UUID, also kept in the keystore), sent in `POST /v1/auth/otp/verify`.
  TextColumn get deviceId => text()();

  /// UI language code, `ta` (default) or `en` (D-016).
  TextColumn get locale => text().withDefault(const Constant('ta'))();

  /// When true, photos wait for Wi-Fi before uploading (Arch §Offline-first "When it syncs").
  BoolColumn get wifiOnlyPhotos => boolean().withDefault(const Constant(false))();

  /// Primary key: [id].
  @override
  Set<Column<Object>> get primaryKey => {id};
}
