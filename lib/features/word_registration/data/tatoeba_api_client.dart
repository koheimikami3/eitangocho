import 'dart:convert';

import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:eitangocho/features/word_registration/data/tatoeba_response.dart';
import 'package:eitangocho/features/word_registration/domain/example_sentence.dart';
import 'package:eitangocho/features/word_registration/domain/word_form_matcher.dart';
import 'package:http/http.dart' as http;

/// Tatoeba(対訳付き例文コーパス)のクライアント。
///
/// 英文とその訳が対でぶら下がっているため、1 リクエストで exampleEn と
/// exampleTranslation の両方が埋まる。辞書側(kaikki)の例文は語義説明用の断片や
/// 文献引用が混ざるので、単語帳の例文としてはこちらを優先する。
///
/// 例文は補助情報なので、失敗しても throw せず null を返す(登録を妨げない。
/// DeeplClient と同じ方針)。
class TatoebaApiClient {
  const TatoebaApiClient(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  /// 候補の取得件数。1 件だけ取ると語形フィルタで落ちたときに空振りするため
  /// 多めに取り、クライアント側で選ぶ。
  ///
  /// 10 から 30 に増やした([_preferredMinWords] を 6 に上げたのに合わせて)。
  /// 下限を満たす文が候補に入る確率が上がり、実測 25 語では下限に届かず降格
  /// するのが 2 件だけになった。`gradual` のように 10 件では語形フィルタを
  /// 通る文が 1 つも無く例文ゼロだった語も拾えるようになる。
  static const _limit = 30;

  /// 優先する最低語数。最短を採るだけだと `monster` に「Monster!」のような
  /// 感嘆詞 1 語の文が選ばれてしまうため、これを下回る文は後回しにする。
  ///
  /// **3 から 6 に上げた**。3 だと `He is diligent.` / `Are ghosts real?` /
  /// `Tom is reluctant.` のような文が選ばれ、単語帳の例文として文脈が足りて
  /// いなかった(実測 25 語で平均 4.2 語)。6 にすると平均 6.0 語になり、
  /// `Yoshiko is very diligent in knitting.` のような文に変わる。
  ///
  /// 8 まで上げると 7/25 が下限に届かず降格し、`negligible` では 21 語の文が
  /// 選ばれてカード(英例文は 2 行)で切れるため、6 で止める。
  ///
  /// **下限であって上限ではない**。長さを決めているのは [_select] の
  /// 「下限以上の中で最短」の方で、この値を下げると例文は短くなる。
  ///
  /// なお辞書側(kaikki)の下限は 4 語のままにしてある。あちらは
  /// `obtain permission` のような句の断片を除くためのハード条件で目的が違い、
  /// 上げると例文が丸ごと消える(Tatoeba が空振りしたときしか使われない)。
  static const _preferredMinWords = 6;

  /// [word] を含む英文と、[language] の訳の組を 1 つ返す。見つからなければ null。
  Future<ExampleSentence?> findExample(
    String word,
    TranslationLanguage language,
  ) async {
    final normalized = word.trim();
    if (normalized.isEmpty) return null;

    final uri = Uri.https('api.tatoeba.org', '/unstable/sentences', {
      'lang': 'eng',
      'q': normalized,
      'trans:lang': language.tatoebaLang,
      // sort は必須。省略すると 400 が返る。
      'sort': 'relevance',
      'limit': '$_limit',
    });

    final TatoebaSearchResponse parsed;
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) return null;
      parsed = TatoebaSearchResponse.fromJson(decoded);
    } on Exception {
      // 通信失敗・レスポンス形式の変化はどちらも「例文なし」として扱う
      return null;
    }
    return _select(parsed.data, normalized, language);
  }

  /// 訳があり、見出し語を実際に含む文のうち最短のものを選ぶ。
  ///
  /// Tatoeba の検索はステミングするため、`negligible` で検索しても
  /// `negligence` の文しか返らないことがある。語形フィルタを通さないと
  /// 別の単語の例文を登録してしまう。短い文ほど単語帳では覚えやすいので、
  /// 条件を満たす中では最短を採る。
  ///
  /// ただし [_preferredMinWords] 語以上を先に見て、そこに候補が無いときだけ
  /// 短い文に降りる。語数で足切りしてしまうと、短文しか無い語で和訳付きの
  /// 例文を丸ごと失う(辞書側の和訳なし例文に落ちる)ため。
  ///
  /// 長短の比較は文字数ではなく**語数**で行う。下限を語数で見ているのに
  /// 比較が文字数だと、降格したときに「語数は少ないが文字数は長い文」が
  /// 選ばれて基準が噛み合わない。
  ExampleSentence? _select(
    List<TatoebaSentence> sentences,
    String word,
    TranslationLanguage language,
  ) {
    final candidates = <ExampleSentence>[];
    for (final sentence in sentences) {
      final en = (sentence.text ?? '').trim();
      if (en.isEmpty) continue;
      if (!containsWordForm(en, word)) continue;
      final translation = sentence.translations
          .where((t) => _matches(t, language))
          .map((t) => t.text!.trim())
          .firstOrNull;
      if (translation == null) continue;
      candidates.add(ExampleSentence(en: en, translation: translation));
    }
    if (candidates.isEmpty) return null;
    final qualified = candidates
        .where((c) => _wordCount(c.en) >= _preferredMinWords)
        .toList();
    if (qualified.isNotEmpty) {
      qualified.sort((a, b) => _wordCount(a.en).compareTo(_wordCount(b.en)));
      return qualified.first;
    }
    // 全部が短すぎるときは、その中でいちばん語数の多いものを採る
    // (ここで最短を採ると「Ghosts exist.」より「Ghosts!」が勝ってしまう)。
    candidates.sort((a, b) => _wordCount(b.en).compareTo(_wordCount(a.en)));
    return candidates.first;
  }

  /// [language] の訳として使えるか。
  ///
  /// 中国語(cmn)は繁体字と簡体字の訳が混ざって返るので、文字体系
  /// (`script`)でも絞る。字形を変換せずに済むよう、繁体字の訳がある文だけを
  /// 候補にする(実測では 40 語中 37 語で繁体字の訳が見つかる)。
  static bool _matches(TatoebaTranslation t, TranslationLanguage language) =>
      t.lang == language.tatoebaLang &&
      (language.tatoebaScript == null || t.script == language.tatoebaScript) &&
      (t.text ?? '').trim().isNotEmpty;

  static int _wordCount(String sentence) =>
      sentence.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).length;
}
