import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/domain/registration_step.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_registration_state.freezed.dart';

@freezed
abstract class WordRegistrationState with _$WordRegistrationState {
  const factory WordRegistrationState({
    @Default(RegistrationStep.input) RegistrationStep step,

    /// 自動入力の取得結果。手動入力(スキップ・未収録)のときは null。
    /// audioUrl はフォームに出さず、保存時にここから words へ書き込む。
    WordInfo? fetched,

    /// 自動入力したが辞書(FD・EJDict とも)未収録だった
    @Default(false) bool notFound,

    /// 例文の DeepL 翻訳に失敗した(exampleJa 空のまま続行し警告を出す)
    @Default(false) bool translationFailed,
    @Default(<PartOfSpeech>{}) Set<PartOfSpeech> selectedPartsOfSpeech,
    String? errorMessage,
  }) = _WordRegistrationState;
}
