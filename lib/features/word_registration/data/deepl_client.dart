import 'dart:convert';

import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:http/http.dart' as http;

/// DeepL API Free のクライアント(例文を訳の言語へ訳すのにだけ使う。単語訳には使わない)。
/// 翻訳は補助機能なので、失敗(キー不正・上限超過・ネットワーク)は throw せず
/// null を返し、呼び出し側は exampleTranslation 空のまま続行する(登録を妨げない)。
class DeeplClient {
  const DeeplClient(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  Future<String?> translate(
    String text,
    String apiKey,
    TranslationLanguage targetLanguage,
  ) async {
    final uri = Uri.https('api-free.deepl.com', '/v2/translate');
    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'DeepL-Auth-Key $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'text': [text],
              'source_lang': 'EN',
              'target_lang': targetLanguage.deeplTargetLang,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) return null;
      final decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final translations = decoded['translations'] as List<dynamic>?;
      if (translations == null || translations.isEmpty) return null;
      return (translations.first as Map<String, dynamic>)['text'] as String?;
    } on Exception {
      return null;
    }
  }
}
