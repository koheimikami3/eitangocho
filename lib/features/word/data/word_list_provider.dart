import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 単語一覧。drift の生成型(Word)を戻り値にするため、riverpod_generator と
/// drift の既知の非互換(riverpod #4370 / #4323: 他の generator が生成した型を
/// @riverpod の戻り値にすると InvalidTypeException でコード生成が失敗する)を
/// 避けて手書きの StreamProvider として定義する。
final wordListProvider = StreamProvider<List<Word>>(
  (ref) => ref.watch(databaseProvider).wordDao.watchAll(),
);
