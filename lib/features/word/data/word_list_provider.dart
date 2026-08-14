import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 単語一覧・検索フィルタ後の一覧。drift の生成型(Word)を戻り値にするため、
/// riverpod_generator と drift の既知の非互換(riverpod #4370 / #4323: 他の
/// generator が生成した型を @riverpod の戻り値にすると InvalidTypeException で
/// コード生成が失敗する)を避けて手書きの Provider として定義する。
final wordListProvider = StreamProvider<List<Word>>(
  (ref) => ref.watch(databaseProvider).wordDao.watchAll(),
);

/// ツールバー検索でフィルタした一覧。
/// 英単語は大文字小文字を無視した部分一致、日本語訳はそのまま部分一致(プロトタイプ準拠)。
final filteredWordListProvider = Provider<List<Word>>((ref) {
  final words = ref.watch(wordListProvider).value ?? const <Word>[];
  final query = ref.watch(mainPageProvider.select((s) => s.searchQuery)).trim();
  if (query.isEmpty) return words;
  final lower = query.toLowerCase();
  return words
      .where(
        (w) =>
            w.word.toLowerCase().contains(lower) || w.japanese.contains(query),
      )
      .toList();
});
