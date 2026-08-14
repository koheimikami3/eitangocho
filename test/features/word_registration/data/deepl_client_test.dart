import 'dart:convert';

import 'package:eitangocho/features/word_registration/data/deepl_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('200 なら translations[0].text を返す。ヘッダとボディも検証', () async {
    late http.Request captured;
    final client = DeeplClient(
      MockClient((request) async {
        captured = request;
        return http.Response.bytes(
          utf8.encode('{"translations":[{"text":"彼は本を読む。"}]}'),
          200,
        );
      }),
    );

    final result = await client.translateToJapanese(
      'He reads a book.',
      'test-key',
    );

    expect(result, '彼は本を読む。');
    expect(captured.headers['Authorization'], 'DeepL-Auth-Key test-key');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['text'], ['He reads a book.']);
    expect(body['source_lang'], 'EN');
    expect(body['target_lang'], 'JA');
  });

  test('403(キー不正)なら null を返す(throw しない)', () async {
    final client = DeeplClient(
      MockClient((_) async => http.Response('forbidden', 403)),
    );

    expect(await client.translateToJapanese('text', 'bad-key'), isNull);
  });

  test('ネットワーク例外でも null を返す(throw しない)', () async {
    final client = DeeplClient(
      MockClient((_) async => throw http.ClientException('offline')),
    );

    expect(await client.translateToJapanese('text', 'key'), isNull);
  });
}
