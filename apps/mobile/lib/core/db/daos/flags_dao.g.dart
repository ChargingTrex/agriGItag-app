// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flags_dao.dart';

// ignore_for_file: type=lint
mixin _$FlagsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FlagsTable get flags => attachedDatabase.flags;
  FlagsDaoManager get managers => FlagsDaoManager(this);
}

class FlagsDaoManager {
  final _$FlagsDaoMixin _db;
  FlagsDaoManager(this._db);
  $$FlagsTableTableManager get flags => $$FlagsTableTableManager(_db.attachedDatabase, _db.flags);
}
