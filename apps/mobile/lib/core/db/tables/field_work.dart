// Drift tables for field work pulled from the server: tasks, flags, instruments and the field configuration.
// Requirement: mobile-design.md §2 (Tasks, Flags, Instruments, FieldConfig) and §4 (FieldConfig drives which form
//   fields show and which are required, D-017); backend-design.md §2 rules_flags and quality.instruments.
// Callers: database.dart (table list), daos/tasks_dao.dart, daos/flags_dao.dart, daos/field_config_dao.dart;
//   M02 pull_service.dart writes them.

import 'package:drift/drift.dart';

/// Tasks: the next farm events a farmer is prompted to log ("time to harvest").
@DataClassName('FarmTask')
class Tasks extends Table {
  /// Task id (UUID).
  TextColumn get taskId => text()();

  /// Farmer the task is for.
  TextColumn get farmerId => text()();

  /// Lot the task is about; null for farmer-level tasks.
  TextColumn get lotId => text().nullable()();

  /// Event type to log (`harvest`, `drying`, ...).
  TextColumn get eventType => text()();

  /// Day the task is due.
  DateTimeColumn get dueDate => dateTime()();

  /// Voice prompt id played with the task (D-016).
  TextColumn get promptId => text()();

  /// Where the task came from (`schedule`, `officer`, ...).
  TextColumn get source => text()();

  /// True once the farmer logged the event.
  BoolColumn get done => boolean().withDefault(const Constant(false))();

  /// Primary key: [taskId].
  @override
  Set<Column<Object>> get primaryKey => {taskId};
}

/// Flags raised by server rules (GI region, yield, event order) for the officer to resolve.
@DataClassName('Flag')
class Flags extends Table {
  /// Server flag id (UUID).
  TextColumn get flagId => text()();

  /// Farmer the flag concerns.
  TextColumn get farmerId => text()();

  /// Entry that raised it; null for plot- or lot-level flags.
  TextColumn get entryId => text().nullable()();

  /// Plot that raised it; null when not plot-related.
  TextColumn get plotId => text().nullable()();

  /// Rule code (`gi_region_outside`, `yield_over_ceiling`, ...).
  TextColumn get type => text()();

  /// Severity: `info`, `warn` or `hold`.
  TextColumn get severity => text()();

  /// Status: `open`, `cleared`, `fixed` or `escalated`.
  TextColumn get status => text()();

  /// Rule details as JSON (measured value, limit, units).
  TextColumn get detailJson => text()();

  /// Resolution reason code; null while open.
  TextColumn get resolvedReason => text().nullable()();

  /// When the server last changed the flag.
  DateTimeColumn get updatedAt => dateTime()();

  /// Primary key: [flagId].
  @override
  Set<Column<Object>> get primaryKey => {flagId};
}

/// Measuring instruments (moisture meters, scales) with their calibration due dates.
@DataClassName('Instrument')
class Instruments extends Table {
  /// Server instrument id (UUID).
  TextColumn get instrumentId => text()();

  /// Instrument kind (`moisture_meter`, `colorimeter`, `hygrometer`, `scale`).
  TextColumn get kind => text()();

  /// Label shown to the QC officer (make, model, serial).
  TextColumn get label => text()();

  /// Day the calibration expires; readings after it are flagged.
  DateTimeColumn get calibrationDueDate => dateTime()();

  /// Primary key: [instrumentId].
  @override
  Set<Column<Object>> get primaryKey => {instrumentId};
}

/// Field configuration per entity from `GET /v1/config/fields` (D-017).
@DataClassName('FieldConfigEntry')
class FieldConfig extends Table {
  /// Entity name (`farmer`, `plot`, `harvest`, ...).
  TextColumn get entity => text()();

  /// The entity's field list as JSON (name, type, required, enabled, visibility, label keys).
  TextColumn get json => text()();

  /// Primary key: [entity].
  @override
  Set<Column<Object>> get primaryKey => {entity};
}
