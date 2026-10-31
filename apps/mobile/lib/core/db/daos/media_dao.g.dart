// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_dao.dart';

// ignore_for_file: type=lint
mixin _$MediaDaoMixin on DatabaseAccessor<AppDatabase> {
  $EntriesTable get entries => attachedDatabase.entries;
  $MediaTable get media => attachedDatabase.media;
  MediaDaoManager get managers => MediaDaoManager(this);
}

class MediaDaoManager {
  final _$MediaDaoMixin _db;
  MediaDaoManager(this._db);
  $$EntriesTableTableManager get entries => $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$MediaTableTableManager get media => $$MediaTableTableManager(_db.attachedDatabase, _db.media);
}
