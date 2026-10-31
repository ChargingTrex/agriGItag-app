// Schema dump test: fails when the Drift tables change without a new schema version and dump.
// Requirement: mobile-design.md §2 ("Schema dump test from day one"); M01 migrations deliverable.
// Callers: `flutter test test/db`. After a schema change: bump AppDatabase.schemaVersion, add the onUpgrade step,
//   run tool/schema_dump.sh, and add a migration test from the previous version here (v1 → v2: Outbox owner, D-029;
//   v2 → v3: Session without the token/PIN columns, M13).

import 'package:agritrace/core/db/database.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final verifier = SchemaVerifier(GeneratedHelper());

  test('schemaVersion has a dump, and the tables, indexes and triggers match it', () async {
    // A fresh install: onCreate builds the schema from the current Dart tables and append_only.drift.
    final db = AppDatabase(NativeDatabase.memory());
    expect(GeneratedHelper.versions.last, db.schemaVersion, reason: 'run tool/schema_dump.sh after bumping');
    // Compares every table, index and trigger of that fresh database with the committed dump of schemaVersion.
    // validateDropped also fails on tables, indexes or triggers that exist in the code but not in the dump.
    await verifier.migrateAndValidate(db, db.schemaVersion, options: const ValidationOptions(validateDropped: true));
    await db.close();
  });

  test('v1 → v2 rebuilds Outbox with ownerUserId filled from the entry (media: from its entry)', () async {
    final schema = await verifier.schemaAt(1);
    final raw = schema.rawDatabase;
    const t = '2026-03-04T08:12:10.000Z';
    raw.execute(
      'INSERT INTO entries (entry_id, root_id, version, entry_type, farmer_id, instance_no, payload_json, '
      'device_time, location_status, entered_by_user_id, assist_mode, entered_remotely, status, undo_deadline, '
      "created_at) VALUES ('e1', 'e1', 1, 'harvest', 'f1', 1, '{}', '$t', 'ok', 'user-1', 0, 0, 'saved', '$t', '$t')",
    );
    raw.execute(
      'INSERT INTO media (media_id, entry_id, kind, local_path, bytes, sha256, width, height, captured_at, '
      "upload_status, thumb_path) VALUES ('m1', 'e1', 'photo', '/p.jpg', 1, 'ab', 1, 1, '$t', 'pending', '/t.jpg')",
    );
    raw.execute(
      'INSERT INTO outbox (kind, ref_id, idempotency_key, priority, attempts, next_attempt_at, status, created_at) '
      "VALUES ('entry', 'e1', 'e1', 0, 0, '$t', 'waiting', '$t'), ('media', 'm1', 'm1', 1, 0, '$t', 'waiting', '$t')",
    );

    final db = AppDatabase(schema.newConnection());
    // The app database always migrates to its current version, so this runs (and validates) v1 → v2 → v3.
    await verifier.migrateAndValidate(db, db.schemaVersion);
    final rows = await db.select(db.outbox).get();
    expect(rows.map((r) => (r.refId, r.ownerUserId)), [('e1', 'user-1'), ('m1', 'user-1')]);
    await db.close();
  });

  test('v2 → v3 drops the Session token and PIN columns and keeps the signed-in row', () async {
    final schema = await verifier.schemaAt(2);
    schema.rawDatabase.execute(
      'INSERT INTO session (id, user_id, role, fpo_id, device_id, access_token, refresh_token, locale, '
      "wifi_only_photos) VALUES (1, 'user-1', 'farmer', 'fpo-1', 'dev-1', '', '', 'en', 1)",
    );

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    final row = await db.sessionDao.read();
    expect((row!.userId, row.locale, row.wifiOnlyPhotos), ('user-1', 'en', true));
    await db.close();
  });
}
