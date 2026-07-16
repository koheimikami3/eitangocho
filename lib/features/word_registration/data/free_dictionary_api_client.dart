import 'dart:convert';

import 'package:eitangocho/features/word_registration/data/free_dictionary_response.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:http/http.dart' as http;

/// Free Dictionary API(api.dictionaryapi.dev)のクライアント。
/// テストで MockClient を差し込めるよう http.Client をコンストラクタ注入する。
class FreeDictionaryApiClient {
  const FreeDictionaryApiClient(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  /// 辞書エントリの生 JSON 文字列を返す(キャッシュ保存用に加工せず返す)。
  /// 未収録(404)は null、それ以外の失敗は [WordInfoException]。
  Future<String?> fetchRawJson(String word) async {
    final uri = Uri.https(
      'api.dictionaryapi.dev',
      '/api/v2/entries/en/$word',
    );
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on WordInfoException {
      rethrow;
    } on Exception catch (e) {
      // SocketException / TimeoutException / http.ClientException 等をまとめて包む
      throw WordInfoException('Free Dictionary API の呼び出しに失敗した', e);
    }
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw WordInfoException(
        'Free Dictionary API がステータス ${response.statusCode} を返した',
      );
    }
    return utf8.decode(response.bodyBytes);
  }

  /// 生 JSON 文字列(API レスポンスまたはキャッシュ)をエントリ一覧にパースする。
  static List<FreeDictionaryEntry> parseEntries(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw WordInfoException('Free Dictionary API のレスポンス形式が想定外');
    }
    return [
      for (final item in decoded)
        FreeDictionaryEntry.fromJson(item as Map<String, dynamic>),
    ];
  }
}
