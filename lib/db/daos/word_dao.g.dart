// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_dao.dart';

// ignore_for_file: type=lint
mixin _$WordDaoMixin on DatabaseAccessor<AppDatabase> {
  $WordsTable get words => attachedDatabase.words;
  $DeletedWordsTable get deletedWords => attachedDatabase.deletedWords;
  WordDaoManager get managers => WordDaoManager(this);
}

class WordDaoManager {
  final _$WordDaoMixin _db;
  WordDaoManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db.attachedDatabase, _db.words);
  $$DeletedWordsTableTableManager get deletedWords =>
      $$DeletedWordsTableTableManager(_db.attachedDatabase, _db.deletedWords);
}
