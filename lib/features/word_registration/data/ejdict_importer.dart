import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ejdict_importer.g.dart';

/// 同梱している EJDict-hand テキストの asset パス。
const ejdictAssetPath = 'assets/ejdict/ejdict-hand-utf8.txt';

/// EJDict-hand のテキスト(1 行 =「単語 TAB 訳文字列」)をパースする。
/// - タブで 2 分割できない行(空行等)はスキップ
/// - 同一単語が複数行ある場合は訳を改行で連結して 1 レコードにする
List<EjdictEntriesCompanion> parseEjdict(String content) {
  final merged = <String, String>{};
  for (final line in content.split('\n')) {
    final tabIndex = line.indexOf('\t');
    if (tabIndex <= 0) continue;
    final word = line.substring(0, tabIndex);
    final meanings = line.substring(tabIndex + 1);
    if (meanings.isEmpty) continue;
    merged.update(
      word,
      (existing) => '$existing\n$meanings',
      ifAbsent: () => meanings,
    );
  }
  return [
    for (final entry in merged.entries)
      EjdictEntriesCompanion.insert(word: entry.key, meanings: entry.value),
  ];
}

/// EJDict の初回取込。アプリ起動時に watch でキックし、バックグラウンドで実行する
/// (UI はブロックしない。自動入力側は本 Provider の完了を await する)。
/// 取込済みかは shared_preferences のフラグでなく DB の件数で判定する
/// (DB ファイル削除時に自動復旧できるようにするため)。戻り値は取り込んだ件数。
@Riverpod(keepAlive: true)
Future<int> ejdictImport(Ref ref) async {
  final dao = ref.watch(databaseProvider).ejdictDao;
  if (await dao.count() > 0) {
    debugPrint('EJDict: 取込済みのためスキップ');
    return 0;
  }
  final content = await rootBundle.loadString(ejdictAssetPath);
  final entries = parseEjdict(content);
  await dao.bulkInsert(entries);
  debugPrint('EJDict: ${entries.length} 件を取り込んだ');
  return entries.length;
}
