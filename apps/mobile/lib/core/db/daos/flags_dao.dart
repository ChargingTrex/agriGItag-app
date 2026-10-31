// Flags DAO: open flags of a farmer, for the officer's flag list and the farmer's attention badge.
// Requirement: mobile-design.md §2 (Flags); plan §7.2 officer flags feature; backend-design.md §2 rules_flags.
// Callers: M07/M09 flags and officer_home features.

import 'package:drift/drift.dart';

import '../database.dart';

part 'flags_dao.g.dart';

/// Reads flags.
@DriftAccessor(tables: [Flags])
class FlagsDao extends DatabaseAccessor<AppDatabase> with _$FlagsDaoMixin {
  /// Creates the DAO on [db]; use `db.flagsDao` instead of calling this.
  FlagsDao(super.db);

  /// Flags of [farmerId] with status `open`, most recently changed first, re-emitted when flags change.
  /// Emits an empty list when none; never errors on its own.
  Stream<List<Flag>> openForFarmer(String farmerId) =>
      (select(flags)
            ..where((f) => f.farmerId.equals(farmerId) & f.status.equals('open'))
            ..orderBy([(f) => OrderingTerm.desc(f.updatedAt.julianday)]))
          .watch();
}
