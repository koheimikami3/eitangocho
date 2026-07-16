import 'package:drift/drift.dart';
import 'package:eitangocho/enums/part_of_speech.dart';

/// `List<PartOfSpeech>` を 'verb,noun' 形式の CSV で保存する。
/// 未知のトークンはデシリアライズ時に黙って捨てる(将来 enum を削除しても
/// 読み込みが失敗しないようにするための防御)。
class PartOfSpeechListConverter
    extends TypeConverter<List<PartOfSpeech>, String> {
  const PartOfSpeechListConverter();

  @override
  List<PartOfSpeech> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final byName = PartOfSpeech.values.asNameMap();
    return fromDb.split(',').map((name) => byName[name]).nonNulls.toList();
  }

  @override
  String toSql(List<PartOfSpeech> value) =>
      value.map((p) => p.name).join(',');
}
