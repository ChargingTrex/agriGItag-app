// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_config_dao.dart';

// ignore_for_file: type=lint
mixin _$FieldConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $FieldConfigTable get fieldConfig => attachedDatabase.fieldConfig;
  FieldConfigDaoManager get managers => FieldConfigDaoManager(this);
}

class FieldConfigDaoManager {
  final _$FieldConfigDaoMixin _db;
  FieldConfigDaoManager(this._db);
  $$FieldConfigTableTableManager get fieldConfig =>
      $$FieldConfigTableTableManager(_db.attachedDatabase, _db.fieldConfig);
}
