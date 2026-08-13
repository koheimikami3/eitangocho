import 'package:eitangocho/db/daos/dictionary_cache_dao.dart';
import 'package:eitangocho/db/daos/ejdict_dao.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/word_registration/data/deepl_client.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:eitangocho/features/word_registration/data/kaikki_api_client.dart';
import 'package:eitangocho/features/word_registration/data/kaikki_response.dart';
import 'package:eitangocho/features/word_registration/data/tatoeba_api_client.dart';
import 'package:eitangocho/features/word_registration/domain/word_form_matcher.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_provider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictionary_word_info_provider.g.dart';

/// WordInfoProvider の辞書ベース実装(kaikki + EJDict + DeepL)。
/// 依存はすべてコンストラクタ注入し、テストでフェイクに差し替えられるようにする。
class DictionaryWordInfoProvider implements WordInfoProvider {
  const DictionaryWordInfoProvider({
    required this._kaikkiClient,
    required this._tatoebaClient,
    required this._deeplClient,
    required this._cacheDao,
    required this._ejdictDao,
    required this._ensureEjdictImported,
    required this._getDeeplApiKey,
  });

  final KaikkiApiClient _kaikkiClient;
  final TatoebaApiClient _tatoebaClient;
  final DeeplClient _deeplClient;
  final DictionaryCacheDao _cacheDao;
  final EjdictDao _ejdictDao;

  /// EJDict の初回取込完了を待つ(バックグラウンド取込中に自動入力された場合に備える)
  final Future<void> Function() _ensureEjdictImported;
  final Future<String> Function() _getDeeplApiKey;

  /// 例文として短すぎるものを弾く語数。`obtain permission` のような
  /// コロケーションの断片は単語帳の例文にならない。
  static const _minExampleWords = 4;

  /// kaikki の訳語から日本語訳に採る最大件数(EJDict が未収録のときの予備)。
  static const _maxJapaneseWords = 5;

  @override
  Future<WordInfo?> fetch(String word) async {
    final normalized = word.trim().toLowerCase();

    // 1. kaikki: キャッシュ優先、miss なら取得し成功時のみ保存。
    //    取得に失敗しても例外にせず、EJDict の訳だけで登録を続けられるようにする
    //    (辞書ソースが落ちている間に登録フロー全体が死ぬのを防ぐ。
    //     Free Dictionary 時代は 502 のたびに登録できなくなっていた)。
    List<KaikkiEntry>? entries;
    Object? kaikkiFailure;
    try {
      var entriesJson = await _cacheDao.find(normalized);
      if (entriesJson == null) {
        entriesJson = await _kaikkiClient.fetchEntriesJson(normalized);
        if (entriesJson != null) {
          await _cacheDao.save(normalized, entriesJson);
        }
      }
      entries =
          entriesJson == null ? null : KaikkiApiClient.parseEntries(entriesJson);
    } on WordInfoException catch (e) {
      kaikkiFailure = e;
    }

    // 2. EJDict の訳(取込完了を待ってから引く)
    await _ensureEjdictImported();
    final japanese = await _ejdictDao.lookup(normalized);

    // 3. 辞書が両方空振りで、しかも通信に失敗していたならエラーにする。
    //    「取得できない」を「辞書に未収録」と誤解させないため。オフラインなら
    //    続く Tatoeba も失敗するので、ここで打ち切ってよい。
    if (entries == null && japanese == null && kaikkiFailure != null) {
      throw kaikkiFailure;
    }

    // EJDict の語義を優先し、未収録のときだけ kaikki の訳語に落とす。
    // EJDict は英和辞典の語義で情報量が多く、kaikki 側は訳語の列挙なので
    // 出番は EJDict が持たない見出し(句動詞がほぼこれに当たる)だけになる。
    var info = _mapEntries(normalized, entries ?? const []);
    if (japanese != null) info = info.copyWith(japanese: japanese);

    // 4. Tatoeba の例文を優先する。和訳が対で付いてくるうえ、kaikki の例文より
    //    単語帳向き(kaikki 側は語義の説明が目的で、断片や文献引用が混ざる)。
    //    空振りしたときだけ kaikki の例文(和訳なし)を使う。
    //
    //    **辞書が両方空振りでも引く**。kaikki の見出しがユーザーの入力とずれる句
    //    (`run out of` は Wiktionary の見出しが `run out` なので 404)では、
    //    ここが唯一の自動入力になる。単語 1 語では kaikki がほぼ埋めるため、
    //    この経路に来るのは実質そういう句と綴り間違いだけ。
    final example = await _tatoebaClient.findExample(normalized);
    if (example != null) {
      info = info.copyWith(exampleEn: example.en, exampleJa: example.ja);
    }

    // 5. 辞書にも例文にも何も無ければ未収録として扱う(手動入力へ倒す)。
    if (entries == null && japanese == null && example == null) return null;

    // 6. 和訳がまだ無くキー設定済みなら DeepL で訳す(失敗は空のまま続行)
    if (info.exampleEn.isNotEmpty && info.exampleJa.isEmpty) {
      final apiKey = await _getDeeplApiKey();
      if (apiKey.isNotEmpty) {
        final translated =
            await _deeplClient.translateToJapanese(info.exampleEn, apiKey);
        info = info.copyWith(exampleJa: translated ?? '');
      }
    }
    return info;
  }

  /// kaikki のエントリ(1 件 = 1 品詞)を WordInfo に畳み込む。
  WordInfo _mapEntries(String word, List<KaikkiEntry> entries) {
    final partsOfSpeech = <PartOfSpeech>[];
    for (final entry in entries) {
      final pos = _toPartOfSpeech(entry.pos);
      if (!partsOfSpeech.contains(pos)) partsOfSpeech.add(pos);
    }
    return WordInfo(
      word: word,
      ipa: _selectIpa(entries),
      partsOfSpeech: partsOfSpeech,
      japanese: _selectJapanese(entries),
      exampleEn: _selectExample(entries, word),
    );
  }

  /// kaikki の訳語を日本語訳の文字列にまとめる。
  ///
  /// 同じ訳語が語義ごとに重複して来る(`give up` の「諦める」は 2 件)ので
  /// 畳み、EJDict の語義と同じ ` / ` 区切りで連結する。並びは kaikki が
  /// 返した順のままで、語義の主従は反映されない(`give up` は「降服する」が
  /// 先頭に来る)。**必須項目の欄が長大にならないよう [_maxJapaneseWords] で
  /// 打ち切る**。多義語では 10 件以上返ることがあるため。
  String _selectJapanese(List<KaikkiEntry> entries) {
    final words = <String>{};
    for (final entry in entries) {
      for (final translation in entry.translations) {
        final word = (translation.word ?? '').trim();
        if (word.isEmpty) continue;
        words.add(word);
        if (words.length == _maxJapaneseWords) return words.join(' / ');
      }
    }
    return words.join(' / ');
  }

  /// 米音を優先して IPA を 1 つ選ぶ。
  ///
  /// kaikki は方言ごとに複数の発音を持ち、`tags` に `US` /
  /// `General-American` / `Received-Pronunciation` などが付く。
  /// `[ˈlɪɾ.ɚ.ə.t͡ʃɚ]` のような異音表記も混ざるので、`/` で囲まれた
  /// 音素表記だけを候補にする。方言タグが無い語(`obtain` など)は
  /// 最初の候補をそのまま使う。
  String _selectIpa(List<KaikkiEntry> entries) {
    final candidates = [
      for (final entry in entries)
        for (final sound in entry.sounds)
          if ((sound.ipa ?? '').startsWith('/')) sound,
    ];
    if (candidates.isEmpty) return '';
    const usTags = {'US', 'General-American'};
    final us = candidates
        .where((s) => s.tags.any(usTags.contains))
        .firstOrNull;
    return (us ?? candidates.first).ipa ?? '';
  }

  /// 例文を 1 つ選ぶ。見出し語を実際に含み、短すぎないものの中から最短を採る。
  ///
  /// kaikki の例文は語義ごとに付くため派生語の文が混ざり、`collocation`
  /// タグの断片(`obtain permission`)も含まれる。単語帳の例文は短いほど
  /// 覚えやすいので、条件を満たす中では最短を選ぶ。
  String _selectExample(List<KaikkiEntry> entries, String word) {
    final candidates = <String>[];
    for (final entry in entries) {
      for (final sense in entry.senses) {
        for (final example in sense.examples) {
          final text = (example.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
          if (text.isEmpty) continue;
          if (example.tags.contains('collocation')) continue;
          if (text.split(' ').length < _minExampleWords) continue;
          if (!containsWordForm(text, word)) continue;
          candidates.add(text);
        }
      }
    }
    if (candidates.isEmpty) return '';
    candidates.sort((a, b) => a.length.compareTo(b.length));
    return candidates.first;
  }

  /// kaikki の pos は `adj` / `adv` と略される(Free Dictionary の
  /// `adjective` / `adverb` とは表記が違う)。それ以外(pron, prep, name 等)は
  /// other に落とす。
  PartOfSpeech _toPartOfSpeech(String? raw) => switch (raw) {
        'verb' => PartOfSpeech.verb,
        'noun' => PartOfSpeech.noun,
        'adj' => PartOfSpeech.adjective,
        'adv' => PartOfSpeech.adverb,
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
    kaikkiClient: KaikkiApiClient(httpClient),
    tatoebaClient: TatoebaApiClient(httpClient),
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
