// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$DictionaryCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $DictionaryCacheEntriesTable get dictionaryCacheEntries =>
      attachedDatabase.dictionaryCacheEntries;
  DictionaryCacheDaoManager get managers => DictionaryCacheDaoManager(this);
}

class DictionaryCacheDaoManager {
  final _$DictionaryCacheDaoMixin _db;
  DictionaryCacheDaoManager(this._db);
  $$DictionaryCacheEntriesTableTableManager get dictionaryCacheEntries =>
      $$DictionaryCacheEntriesTableTableManager(
        _db.attachedDatabase,
        _db.dictionaryCacheEntries,
      );
}
