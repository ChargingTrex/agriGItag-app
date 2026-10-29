// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_dao.dart';

// ignore_for_file: type=lint
mixin _$OutboxDaoMixin on DatabaseAccessor<AppDatabase> {
  $OutboxTable get outbox => attachedDatabase.outbox;
  $EntriesTable get entries => attachedDatabase.entries;
  $MediaTable get media => attachedDatabase.media;
  OutboxDaoManager get managers => OutboxDaoManager(this);
}

class OutboxDaoManager {
  final _$OutboxDaoMixin _db;
  OutboxDaoManager(this._db);
  $$OutboxTableTableManager get outbox => $$OutboxTableTableManager(_db.attachedDatabase, _db.outbox);
  $$EntriesTableTableManager get entries => $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
  $$MediaTableTableManager get media => $$MediaTableTableManager(_db.attachedDatabase, _db.media);
}
