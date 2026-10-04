import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/domain/registration_step.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_registration_state.freezed.dart';

@freezed
abstract class WordRegistrationState with _$WordRegistrationState {
  const WordRegistrationState._();

  const factory WordRegistrationState({
    @Default(RegistrationStep.input) RegistrationStep step,

    /// 自動入力の取得結果。手動入力(スキップ・未収録)のときは null。
    /// audioUrl はフォームに出さず、保存時にここから words へ書き込む。
    WordInfo? fetched,

    /// 自動入力したが辞書(FD・EJDict とも)未収録だった
    @Default(false) bool notFound,

    /// 例文の DeepL 翻訳に失敗した(exampleTranslation 空のまま続行し警告を出す)
    @Default(false) bool translationFailed,
    @Default(<PartOfSpeech>{}) Set<PartOfSpeech> selectedPartsOfSpeech,
    String? errorMessage,
  }) = _WordRegistrationState;

  /// 確認フォームの上部に出す警告文言(無ければ null)。
  ///
  /// 自動入力で埋まらなかった項目を伝えるためのもので、macOS / iOS の
  /// どちらのフォームからも同じものを引く(片方だけ文言が増える事故を防ぐ)。
  String? get warningMessage {
    if (notFound) return '辞書に見つかりませんでした。手動で入力できます。';
    final fetched = this.fetched;
    if (fetched == null) return null;
    // 訳は必須項目なので、空なら他に何が埋まっていてもまずこれを伝える。
    // EJDict は句動詞を 1 件も収録していないため、句動詞ではこれが常態になる。
    if (fetched.meaning.isEmpty) {
      return '日本語訳は辞書に見つかりませんでした(手動で入力してください)';
    }
    // audioUrl は画面に出さないので、文言どおり IPA と例文だけで判定する。
    if (fetched.ipa.isEmpty && fetched.exampleEn.isEmpty) {
      return '発音記号・例文は辞書に見つかりませんでした(訳のみ自動入力)';
    }
    return null;
  }
}
