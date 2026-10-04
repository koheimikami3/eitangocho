import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:eitangocho/features/word_registration/domain/registration_error.dart';
import 'package:eitangocho/l10n/app_localizations.dart';

/// 登録画面のエラー文言。macOS / iOS のどちらのフォームからも同じものを引く。
String registrationErrorText(
  AppLocalizations l10n,
  RegistrationError error,
  TranslationLanguage language,
) => switch (error) {
  DuplicateWordError(:final word) => l10n.errorDuplicate(word),
  EmptyWordError() => l10n.errorEmptyWord,
  FetchFailedError() => l10n.errorFetchFailed,
  RequiredFieldsError() => l10n.errorRequiredFields(language.shortLabel(l10n)),
};

/// 確認フォームの上部に出す警告文言。
String registrationNoticeText(
  AppLocalizations l10n,
  RegistrationNotice notice,
  TranslationLanguage language,
) => switch (notice) {
  RegistrationNotice.notFound => l10n.noticeNotFound,
  RegistrationNotice.meaningNotFound => l10n.noticeMeaningNotFound(
    language.shortLabel(l10n),
  ),
  RegistrationNotice.onlyMeaningFound => l10n.noticeOnlyMeaningFound,
};
