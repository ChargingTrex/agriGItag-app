// Field configuration DAO: the field list of one entity, which decides which form fields show and which are required.
// Requirement: mobile-design.md §4 ("Form fields and their requiredness come from FieldConfig"); D-017.
// Callers: feature forms (M07+); M02 pull_service.dart writes the rows from the `fields` bundle.

import 'package:drift/drift.dart';

import '../database.dart';

part 'field_config_dao.g.dart';

/// Reads field configuration.
@DriftAccessor(tables: [FieldConfig])
class FieldConfigDao extends DatabaseAccessor<AppDatabase> with _$FieldConfigDaoMixin {
  /// Creates the DAO on [db]; use `db.fieldConfigDao` instead of calling this.
  FieldConfigDao(super.db);

  /// The field-list JSON of [entity] (`farmer`, `plot`, `harvest`, ...), or null before the first config pull.
  /// Throws nothing.
  Future<String?> get(String entity) async =>
      (await (select(fieldConfig)..where((c) => c.entity.equals(entity))).getSingleOrNull())?.json;
}
