// Tasks DAO: the farmer's next task, shown on the farmer home screen with its voice prompt.
// Requirement: mobile-design.md §2 (Tasks); plan §7.2 farmer home (F01 "what to do next").
// Callers: M07 farmer_home feature.

import 'package:drift/drift.dart';

import '../database.dart';

part 'tasks_dao.g.dart';

/// Reads tasks.
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  /// Creates the DAO on [db]; use `db.tasksDao` instead of calling this.
  TasksDao(super.db);

  /// The open task of [farmerId] with the earliest due date, re-emitted when tasks change; null when none.
  /// Never errors on its own.
  Stream<FarmTask?> nextForFarmer(String farmerId) =>
      (select(tasks)
            ..where((t) => t.farmerId.equals(farmerId) & t.done.not())
            // julianday orders correctly whichever time zone each value was stored with.
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate.julianday)])
            ..limit(1))
          .watchSingleOrNull();
}
