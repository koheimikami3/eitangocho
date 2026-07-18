// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ejdict_dao.dart';

// ignore_for_file: type=lint
mixin _$EjdictDaoMixin on DatabaseAccessor<AppDatabase> {
  $EjdictEntriesTable get ejdictEntries => attachedDatabase.ejdictEntries;
  EjdictDaoManager get managers => EjdictDaoManager(this);
}

class EjdictDaoManager {
  final _$EjdictDaoMixin _db;
  EjdictDaoManager(this._db);
  $$EjdictEntriesTableTableManager get ejdictEntries =>
      $$EjdictEntriesTableTableManager(_db.attachedDatabase, _db.ejdictEntries);
}
