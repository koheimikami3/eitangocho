import EitangochoData
import Foundation

/// 登録のエラーと辞書の注意の文言(Flutter 版の registration_messages.dart)。macOS の画面と iOS のシートで共有する。
enum RegistrationMessages {
  static func error(_ error: WordRegistrationModel.RegistrationError, language: TranslationLanguage) -> String {
    switch error {
    case .duplicate(let word): String(localized: .errorDuplicate(word))
    case .emptyWord: String(localized: .errorEmptyWord)
    case .fetchFailed: String(localized: .errorFetchFailed)
    case .requiredFields: String(localized: .errorRequiredFields(String(localized: language.shortLabel)))
    }
  }

  static func notice(_ notice: WordRegistrationModel.Notice, language: TranslationLanguage) -> String {
    switch notice {
    case .notFound: String(localized: .noticeNotFound)
    case .meaningNotFound: String(localized: .noticeMeaningNotFound(String(localized: language.shortLabel)))
    case .onlyMeaningFound: String(localized: .noticeOnlyMeaningFound)
    }
  }
}
