import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_sentence.freezed.dart';

/// 英例文と、その対訳。対訳が取れないソースもあるため [translation] は空になりうる。
@freezed
abstract class ExampleSentence with _$ExampleSentence {
  const factory ExampleSentence({
    required String en,
    @Default('') String translation,
  }) = _ExampleSentence;
}
