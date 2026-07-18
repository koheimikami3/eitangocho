import 'dart:convert';

import 'package:eitangocho/features/word_registration/data/free_dictionary_api_client.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// 実レスポンス相当のフィクスチャ(欠落しうるフィールドを含む)
const fixtureFull = '''
[
  {
    "word": "serendipity",
    "phonetic": "/ˌsɛ.ɹən.ˈdɪ.pɪ.ti/",
    "phonetics": [
      {"text": "/ˌsɛ.ɹən.ˈdɪ.pɪ.ti/", "audio": "https://example.com/a.mp3"}
    ],
    "meanings": [
      {
        "partOfSpeech": "noun",
        "definitions": [
          {"definition": "A combination of events...", "example": "Some notable discoveries."}
        ]
      }
    ]
  }
]
''';

/// phonetic なし・phonetics 空・example なし(欠落フィールドの検証用)
const fixtureSparse = '''
[
  {
    "word": "rare",
    "phonetics": [],
    "meanings": [
      {"partOfSpeech": "adjective", "definitions": [{"definition": "Uncommon."}]}
    ]
  }
]
''';

void main() {
  // http.Response(String) は latin1 でエンコードするため、IPA 記号を
  // 含むボディは UTF-8 バイト列で返す。
  http.Response utf8Response(String body, int status) =>
      http.Response.bytes(utf8.encode(body), status);

  group('fetchRawJson', () {
    test('200 なら生 JSON 文字列を返し、URL エンコードして呼び出す', () async {
      late Uri requested;
      final client = FreeDictionaryApiClient(
        MockClient((request) async {
          requested = request.url;
          return utf8Response(fixtureFull, 200);
        }),
      );

      final raw = await client.fetchRawJson('serendipity');

      expect(raw, fixtureFull);
      expect(
        requested.toString(),
        'https://api.dictionaryapi.dev/api/v2/entries/en/serendipity',
      );
    });

    test('404 なら null(未収録)', () async {
      final client = FreeDictionaryApiClient(
        MockClient((_) async => http.Response('{"title":"No Definitions Found"}', 404)),
      );

      expect(await client.fetchRawJson('zzzzz'), isNull);
    });

    test('500 なら WordInfoException', () async {
      final client = FreeDictionaryApiClient(
        MockClient((_) async => http.Response('error', 500)),
      );

      expect(
        () => client.fetchRawJson('apple'),
        throwsA(isA<WordInfoException>()),
      );
    });

    test('ネットワーク例外は WordInfoException に包む', () async {
      final client = FreeDictionaryApiClient(
        MockClient((_) async => throw http.ClientException('offline')),
      );

      expect(
        () => client.fetchRawJson('apple'),
        throwsA(isA<WordInfoException>()),
      );
    });

    test('マルチバイトを含むレスポンスを UTF-8 でデコードする', () async {
      final client = FreeDictionaryApiClient(
        MockClient(
          (_) async => http.Response.bytes(
            utf8.encode('[{"word":"café"}]'),
            200,
          ),
        ),
      );

      expect(await client.fetchRawJson('café'), '[{"word":"café"}]');
    });
  });

  group('parseEntries', () {
    test('欠落フィールドがあってもパースできる', () {
      final entries = FreeDictionaryApiClient.parseEntries(fixtureSparse);

      expect(entries, hasLength(1));
      expect(entries[0].word, 'rare');
      expect(entries[0].phonetic, isNull);
      expect(entries[0].phonetics, isEmpty);
      expect(entries[0].meanings[0].partOfSpeech, 'adjective');
      expect(entries[0].meanings[0].definitions[0].example, isNull);
    });

    test('完全なレスポンスをパースできる', () {
      final entries = FreeDictionaryApiClient.parseEntries(fixtureFull);

      expect(entries[0].phonetic, '/ˌsɛ.ɹən.ˈdɪ.pɪ.ti/');
      expect(entries[0].phonetics[0].audio, 'https://example.com/a.mp3');
      expect(
        entries[0].meanings[0].definitions[0].example,
        'Some notable discoveries.',
      );
    });

    test('配列以外(オブジェクト)なら WordInfoException', () {
      expect(
        () => FreeDictionaryApiClient.parseEntries('{"title":"unexpected"}'),
        throwsA(isA<WordInfoException>()),
      );
    });
  });
}
