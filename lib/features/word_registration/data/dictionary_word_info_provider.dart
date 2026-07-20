import 'package:eitangocho/db/daos/dictionary_cache_dao.dart';
import 'package:eitangocho/db/daos/ejdict_dao.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/word_registration/data/deepl_client.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:eitangocho/features/word_registration/data/free_dictionary_api_client.dart';
import 'package:eitangocho/features/word_registration/data/free_dictionary_response.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_provider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictionary_word_info_provider.g.dart';

/// WordInfoProvider の辞書ベース実装(Free Dictionary + EJDict + DeepL)。
/// 依存はすべてコンストラクタ注入し、テストでフェイクに差し替えられるようにする。
class DictionaryWordInfoProvider implements WordInfoProvider {
  const DictionaryWordInfoProvider({
    required this._freeDictionaryClient,
    required this._deeplClient,
    required this._cacheDao,
    required this._ejdictDao,
    required this._ensureEjdictImported,
    required this._getDeeplApiKey,
  });

  final FreeDictionaryApiClient _freeDictionaryClient;
  final DeeplClient _deeplClient;
  final DictionaryCacheDao _cacheDao;
  final EjdictDao _ejdictDao;

  /// EJDict の初回取込完了を待つ(バックグラウンド取込中に自動入力された場合に備える)
  final Future<void> Function() _ensureEjdictImported;
  final Future<String> Function() _getDeeplApiKey;

  @override
  Future<WordInfo?> fetch(String word) async {
    final normalized = word.trim().toLowerCase();

    // 1-2. Free Dictionary: キャッシュ優先、miss なら API を呼び成功時のみ保存
    var rawJson = await _cacheDao.find(normalized);
    if (rawJson == null) {
      rawJson = await _freeDictionaryClient.fetchRawJson(normalized);
      if (rawJson != null) {
        await _cacheDao.save(normalized, rawJson);
      }
    }
    final entries =
        rawJson == null ? null : FreeDictionaryApiClient.parseEntries(rawJson);

    // 3. EJDict の訳(取込完了を待ってから引く)
    await _ensureEjdictImported();
    final japanese = await _ejdictDao.lookup(normalized);

    // 両方 miss なら未収録
    if (entries == null && japanese == null) return null;

    var info = _mapEntries(normalized, entries ?? const [])
        .copyWith(japanese: japanese ?? '');

    // 4. 例文が取れていてキー設定済みなら DeepL で和訳(失敗は空のまま続行)
    if (info.exampleEn.isNotEmpty) {
      final apiKey = await _getDeeplApiKey();
      if (apiKey.isNotEmpty) {
        final translated =
            await _deeplClient.translateToJapanese(info.exampleEn, apiKey);
        info = info.copyWith(exampleJa: translated ?? '');
      }
    }
    return info;
  }

  /// 全エントリを走査し、各項目の最初の非空値を採用する。
  WordInfo _mapEntries(String word, List<FreeDictionaryEntry> entries) {
    var ipa = '';
    var audioUrl = '';
    var exampleEn = '';
    final partsOfSpeech = <PartOfSpeech>[];
    for (final entry in entries) {
      if (ipa.isEmpty) {
        ipa = entry.phonetic ??
            entry.phonetics
                .map((p) => p.text ?? '')
                .firstWhere((t) => t.isNotEmpty, orElse: () => '');
      }
      if (audioUrl.isEmpty) {
        audioUrl = entry.phonetics
            .map((p) => p.audio ?? '')
            .firstWhere((a) => a.isNotEmpty, orElse: () => '');
      }
      for (final meaning in entry.meanings) {
        final pos = _toPartOfSpeech(meaning.partOfSpeech);
        if (!partsOfSpeech.contains(pos)) partsOfSpeech.add(pos);
        if (exampleEn.isEmpty) {
          exampleEn = meaning.definitions
              .map((d) => d.example ?? '')
              .firstWhere((e) => e.isNotEmpty, orElse: () => '');
        }
      }
    }
    return WordInfo(
      word: word,
      ipa: ipa,
      partsOfSpeech: partsOfSpeech,
      exampleEn: exampleEn,
      audioUrl: audioUrl,
    );
  }

  /// verb / noun / adjective / adverb 以外(pronoun, preposition 等)は other に落とす
  PartOfSpeech _toPartOfSpeech(String? raw) => switch (raw) {
        'verb' => PartOfSpeech.verb,
        'noun' => PartOfSpeech.noun,
        'adjective' => PartOfSpeech.adjective,
        'adverb' => PartOfSpeech.adverb,
        _ => PartOfSpeech.other,
      };
}

/// 登録 Notifier はこの Provider 経由でのみ WordInfoProvider を取得する
/// (具象クラスを直接 new しない。将来の LLM 実装への差し替えポイント)。
// 関数名を wordInfo にすると生成クラス名がドメインの WordInfoProvider 抽象と
// 衝突するため、あえて wordInfoProvider(生成 Provider は wordInfoProviderProvider)とする。
//
// keepAlive にするのは http.Client のライフサイクルを守るため。autoDispose だと、
// Notifier が ref.read()(購読を保持しない)で取得した直後に破棄予約され、
// fetch() の最初の await で制御を手放した隙に onDispose の httpClient.close() が走り、
// 続く API 呼び出しが "Client is already closed" で失敗する。依存する databaseProvider も
// keepAlive であり、http.Client はアプリ生存期間で 1 つ共有する(接続再利用の推奨形)。
@Riverpod(keepAlive: true)
WordInfoProvider wordInfoProvider(Ref ref) {
  final db = ref.watch(databaseProvider);
  final httpClient = http.Client();
  ref.onDispose(httpClient.close);
  return DictionaryWordInfoProvider(
    freeDictionaryClient: FreeDictionaryApiClient(httpClient),
    deeplClient: DeeplClient(httpClient),
    cacheDao: db.dictionaryCacheDao,
    ejdictDao: db.ejdictDao,
    ensureEjdictImported: () => ref.read(ejdictImportProvider.future),
    getDeeplApiKey: () async {
      // 設定ロード前に呼ばれた場合も既定値(空)でフォールバックする
      final settings = await ref.read(settingsProvider.future);
      return settings.deeplApiKey;
    },
  );
}
