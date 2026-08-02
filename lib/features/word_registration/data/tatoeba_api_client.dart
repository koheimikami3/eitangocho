import 'dart:convert';

import 'package:eitangocho/features/word_registration/data/tatoeba_response.dart';
import 'package:eitangocho/features/word_registration/domain/example_sentence.dart';
import 'package:eitangocho/features/word_registration/domain/word_form_matcher.dart';
import 'package:http/http.dart' as http;

/// Tatoeba(対訳付き例文コーパス)のクライアント。
///
/// 英文とその和訳が対でぶら下がっているため、1 リクエストで exampleEn と
/// exampleJa の両方が埋まる。辞書側(kaikki)の例文は語義説明用の断片や
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
  static const _limit = 10;

  /// [word] を含む英文と和訳の組を 1 つ返す。見つからなければ null。
  Future<ExampleSentence?> findExample(String word) async {
    final normalized = word.trim();
    if (normalized.isEmpty) return null;

    final uri = Uri.https('api.tatoeba.org', '/unstable/sentences', {
      'lang': 'eng',
      'q': normalized,
      'trans:lang': 'jpn',
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
    return _select(parsed.data, normalized);
  }

  /// 和訳があり、見出し語を実際に含む文のうち最短のものを選ぶ。
  ///
  /// Tatoeba の検索はステミングするため、`negligible` で検索しても
  /// `negligence` の文しか返らないことがある。語形フィルタを通さないと
  /// 別の単語の例文を登録してしまう。短い文ほど単語帳では覚えやすいので、
  /// 条件を満たす中では最短を採る。
  ExampleSentence? _select(List<TatoebaSentence> sentences, String word) {
    final candidates = <ExampleSentence>[];
    for (final sentence in sentences) {
      final en = (sentence.text ?? '').trim();
      if (en.isEmpty) continue;
      if (!containsWordForm(en, word)) continue;
      final ja = sentence.translations
          .where((t) => t.lang == 'jpn' && (t.text ?? '').trim().isNotEmpty)
          .map((t) => t.text!.trim())
          .firstOrNull;
      if (ja == null) continue;
      candidates.add(ExampleSentence(en: en, ja: ja));
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.en.length.compareTo(b.en.length));
    return candidates.first;
  }
}
