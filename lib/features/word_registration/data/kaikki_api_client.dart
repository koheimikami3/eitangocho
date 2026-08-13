import 'dart:convert';

import 'package:eitangocho/features/word_registration/data/kaikki_response.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:http/http.dart' as http;

/// kaikki.org(wiktextract)のクライアント。
///
/// Wiktionary のダンプを構造化した静的 JSONL を配信しており、1 リクエストで
/// IPA・品詞・例文が揃う。API ではなくファイル配信なので、単語ごとに
/// `/dictionary/English/meaning/<頭文字>/<頭2文字>/<単語>.jsonl` を取りに行く。
///
/// テストで MockClient を差し込めるよう http.Client をコンストラクタ注入する。
class KaikkiApiClient {
  const KaikkiApiClient(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 15);

  /// 名乗らずに叩かない(商用サービスではないため)。
  static const _userAgent = 'eitangocho (https://github.com/koheimikami3/eitangocho)';

  /// 訳語のうち残す言語(kaikki の `lang_code`)。
  static const _japaneseLangCode = 'ja';

  /// 正規化済みの JSON 配列文字列を返す(キャッシュにそのまま保存する形)。
  /// 未収録は null、それ以外の失敗は [WordInfoException]。
  ///
  /// 生の JSONL は 1 語で 20〜170KB あるため、そのままはキャッシュしない。
  /// [parseEntries] で使う項目だけに絞って詰め直す(apple で 168KB → 約 1KB)。
  Future<String?> fetchEntriesJson(String word) async {
    final normalized = word.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    var body = await _get(normalized);
    // kaikki は大文字小文字を区別する。固有名詞・月名は見出しが大文字なので
    // (september は 404 で September は 200)、404 なら頭大文字で引き直す。
    if (body == null) {
      final capitalized =
          normalized[0].toUpperCase() + normalized.substring(1);
      body = await _get(capitalized);
    }
    if (body == null) return null;

    final entries = _parseJsonl(body);
    if (entries.isEmpty) return null;
    return jsonEncode([for (final entry in entries) entry.toJson()]);
  }

  /// [fetchEntriesJson] が返した JSON 配列(またはキャッシュ)をパースする。
  static List<KaikkiEntry> parseEntries(String entriesJson) {
    final decoded = jsonDecode(entriesJson);
    if (decoded is! List) {
      throw const WordInfoException('kaikki のキャッシュ形式が想定外');
    }
    return [
      for (final item in decoded)
        KaikkiEntry.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// 1 パスを取得する。404 は null、200 以外は [WordInfoException]。
  Future<String?> _get(String title) async {
    final uri = Uri.https(
      'kaikki.org',
      '/dictionary/English/meaning/${title[0]}/'
          '${title.length >= 2 ? title.substring(0, 2) : title}/$title.jsonl',
    );
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'User-Agent': _userAgent})
          .timeout(_timeout);
    } on Exception catch (e) {
      // SocketException / TimeoutException / http.ClientException をまとめて包む
      throw WordInfoException('kaikki の取得に失敗した', e);
    }
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw WordInfoException('kaikki がステータス ${response.statusCode} を返した');
    }
    return utf8.decode(response.bodyBytes);
  }

  /// JSONL(1 行 1 品詞)をパースし、使う項目だけに絞ったエントリにする。
  ///
  /// 例文は `type == 'example'`(用例)だけ残し、`quotation`(出典付きの
  /// 文献引用)は捨てる。引用は「[W]ith their magical words they [poets]
  /// bring forth ... — Leigh Hunt」のような長文で単語帳には使えないうえ、
  /// キャッシュサイズの大半を占めるため。
  ///
  /// 訳語は日本語だけ残す。全言語ぶんを持っており(`give up` は 1 品詞に
  /// 243 件)、そのまま保存するとキャッシュを縮めた意味が無くなる。
  static List<KaikkiEntry> _parseJsonl(String body) {
    final entries = <KaikkiEntry>[];
    for (final line in const LineSplitter().convert(body)) {
      if (line.trim().isEmpty) continue;
      final Object? decoded;
      try {
        decoded = jsonDecode(line);
      } on FormatException {
        // 1 行壊れていても他の品詞は使えるので、その行だけ捨てる
        continue;
      }
      if (decoded is! Map<String, dynamic>) continue;
      final entry = KaikkiEntry.fromJson(decoded);
      entries.add(
        entry.copyWith(
          senses: [
            for (final sense in entry.senses)
              sense.copyWith(
                examples: [
                  for (final example in sense.examples)
                    if (example.type == 'example') example,
                ],
              ),
          ],
          translations: [
            for (final translation in entry.translations)
              if (translation.langCode == _japaneseLangCode) translation,
          ],
        ),
      );
    }
    return entries;
  }
}
