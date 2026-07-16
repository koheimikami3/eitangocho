import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_info.freezed.dart';

/// WordInfoProvider が返す単語情報。取得できなかった項目は空文字 / 空リスト。
@freezed
abstract class WordInfo with _$WordInfo {
  const factory WordInfo({
    required String word,
    @Default('') String ipa,
    @Default(<PartOfSpeech>[]) List<PartOfSpeech> partsOfSpeech,
    @Default('') String japanese,
    @Default('') String exampleEn,
    @Default('') String exampleJa,
    @Default('') String audioUrl,
  }) = _WordInfo;
}
