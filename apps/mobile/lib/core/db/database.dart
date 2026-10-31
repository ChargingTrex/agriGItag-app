// The phone's offline store: the Drift database with every table, DAO and the migration strategy.
// Requirement: mobile-design.md §1 (core/db) and §2 (Drift schema, schema dump test from day one); Arch §Offline-first
//   (every entry is saved on the phone first; outbox queue); FR4 (offline capture with later sync); D-014.
// Callers: M02 sync (outbox, entries, media, metrics, bundles), M06 auth (session), feature screens through the DAOs;
//   test/db/*_test.dart open it on NativeDatabase.memory().
// Regenerate database.g.dart and the DAO parts with `dart run build_runner build --delete-conflicting-outputs`; after a
// schema change bump [AppDatabase.schemaVersion] and run tool/schema_dump.sh.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../router/session.dart' show Role;
import 'daos/entries_dao.dart';
import 'daos/field_config_dao.dart';
import 'daos/flags_dao.dart';
import 'daos/media_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/ref_bundles_dao.dart';
import 'daos/session_dao.dart';
import 'daos/sync_metrics_dao.dart';
import 'daos/sync_state_dao.dart';
import 'daos/tasks_dao.dart';
import 'tables/entries.dart';
import 'tables/field_work.dart';
import 'tables/outbox.dart';
import 'tables/registry.dart';
import 'tables/session.dart';
import 'tables/sync.dart';

export 'tables/entries.dart';
export 'tables/field_work.dart';
export 'tables/outbox.dart';
export 'tables/registry.dart';
export 'tables/session.dart';
export 'tables/sync.dart';

part 'database.g.dart';

/// The AgriTrace offline database (SQLite through Drift).
@DriftDatabase(
  tables: [
    SessionTable,
    Farmers,
    Plots,
    Lots,
    Entries,
    Media,
    Outbox,
    RefBundles,
    SyncState,
    SyncMetrics,
    Tasks,
    Flags,
    Instruments,
    FieldConfig,
  ],
  include: {'tables/append_only.drift'},
  daos: [
    EntriesDao,
    OutboxDao,
    MediaDao,
    RefBundlesDao,
    SyncStateDao,
    SyncMetricsDao,
    TasksDao,
    FlagsDao,
    FieldConfigDao,
    SessionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the database on [executor]; tests pass `NativeDatabase.memory()`. Throws nothing until first use.
  AppDatabase(super.executor);

  /// Opens the app's database file `agritrace.sqlite` in the app documents directory.
  ///
  /// `shareAcrossIsolates` lets the background sync isolate (WorkManager, M02) use the same connection server, so the
  /// two isolates never fight over the file lock and stream queries (cloud icon) see background writes.
  /// Returns the database; the file is opened lazily on the first query. Throws nothing here.
  AppDatabase.open()
    : this(driftDatabase(name: 'agritrace', native: const DriftNativeOptions(shareAcrossIsolates: true)));

  /// Schema version 3 (M02 v2: `Outbox.ownerUserId`, D-029; M13 v3: Session without token/PIN columns). Bump it, add a step to [migration] and run
  /// tool/schema_dump.sh for every schema change.
  @override
  int get schemaVersion => 3;

  /// Creates every table, index and trigger on first open; upgrades older files step by step (v1 → v2: Outbox
  /// rebuilt with `ownerUserId`; v2 → v3: Session rebuilt without the empty token and PIN columns).
  ///
  /// `beforeOpen` turns on foreign keys (off by default in SQLite) so `Media.entryId` must name an existing entry,
  /// and recursive triggers, so the implicit delete of `INSERT OR REPLACE` fires `entries_no_delete` too.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // One `if (from < N)` block per version, oldest first, so a phone several versions behind runs every step.
      // Never drop or rewrite Entries rows: they are append-only facts that may not have reached the server yet.
      if (from < 2) {
        // Rebuilds Outbox (SQLite cannot add a NOT NULL column without a default) and fills the owner from the
        // entry, or for a media row from its entry, so v1 rows keep sending for the user who saved them (D-029).
        await m.alterTable(
          TableMigration(
            outbox,
            newColumns: [outbox.ownerUserId],
            columnTransformer: {
              outbox.ownerUserId: const CustomExpression<String>(
                'COALESCE((SELECT e.entered_by_user_id FROM entries e WHERE e.entry_id = outbox.ref_id), '
                '(SELECT e.entered_by_user_id FROM media m JOIN entries e ON e.entry_id = m.entry_id '
                "WHERE m.media_id = outbox.ref_id), '')",
              ),
            },
          ),
        );
      }
      if (from < 3) {
        // Rebuilds Session with the current columns only; the signed-in row is copied, so nobody is signed out.
        await m.alterTable(TableMigration(sessionTable));
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Without this, REPLACE deletes the old entry row silently and bypasses the append-only triggers.
      await customStatement('PRAGMA recursive_triggers = ON');
    },
  );
}
