import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_error.freezed.dart';

/// 単語登録で入力を止めるエラーの種類。
///
/// 文言は持たせず、表示側(registrationErrorText)が表示言語と訳の言語に
/// 合わせて組み立てる。Notifier は BuildContext を持たないため。
@freezed
sealed class RegistrationError with _$RegistrationError {
  /// 既に登録済み。[word] は登録済みの表記(大文字小文字は保存されたまま)。
  const factory RegistrationError.duplicate(String word) = DuplicateWordError;

  /// 英単語が空。
  const factory RegistrationError.emptyWord() = EmptyWordError;

  /// 辞書の取得に失敗した(通信など)。
  const factory RegistrationError.fetchFailed() = FetchFailedError;

  /// 必須項目(英単語・訳)が空。
  const factory RegistrationError.requiredFields() = RequiredFieldsError;
}

/// 確認フォームの上部に出す警告の種類(自動入力で埋まらなかった項目を伝える)。
enum RegistrationNotice {
  /// 辞書に見つからなかった(全項目を手入力)。
  notFound,

  /// 訳だけ見つからなかった。
  meaningNotFound,

  /// 訳だけ見つかり、発音記号・例文が見つからなかった。
  onlyMeaningFound,
}
