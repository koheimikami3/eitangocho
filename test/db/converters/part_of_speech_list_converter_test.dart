import 'package:eitangocho/db/converters/part_of_speech_list_converter.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = PartOfSpeechListConverter();

  test('空文字列は空リストになる', () {
    expect(converter.fromSql(''), isEmpty);
  });

  test('空リストは空文字列になる', () {
    expect(converter.toSql(const []), '');
  });

  test('単一の品詞を往復変換できる', () {
    const list = [PartOfSpeech.verb];
    expect(converter.fromSql(converter.toSql(list)), list);
  });

  test('複数の品詞を往復変換できる', () {
    const list = [PartOfSpeech.verb, PartOfSpeech.noun];
    expect(converter.fromSql(converter.toSql(list)), list);
  });

  test('未知のトークンは無視される', () {
    expect(
      converter.fromSql('verb,unknown,noun'),
      [PartOfSpeech.verb, PartOfSpeech.noun],
    );
  });
}
