// Schema dump test: fails when the Drift tables change without a new schema version and dump.
// Requirement: mobile-design.md §2 ("Schema dump test from day one"); M01 migrations deliverable.
// Callers: `flutter test test/db`. After a schema change: bump AppDatabase.schemaVersion, add the onUpgrade step,
//   run tool/schema_dump.sh, and add a migration test from the previous version here.

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
}
