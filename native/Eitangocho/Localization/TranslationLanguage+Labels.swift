import EitangochoData
import Foundation

/// 訳の言語ごとの文言(Flutter 版の TranslationLanguage の l10n の部分)。
extension TranslationLanguage {
  /// 設定の選択肢に出す名前(「中国語(繁体字)」など)。
  var label: LocalizedStringResource {
    switch self {
    case .ja: .translationLanguageNameJa
    case .zhHant: .translationLanguageNameZhHant
    case .es: .translationLanguageNameEs
    case .fr: .translationLanguageNameFr
    case .enDefinition: .translationLanguageNameEnDefinition
    }
  }

  /// 項目名や出題方向に差し込む短い名前(「日本語訳」の「日本語」)。
  var shortLabel: LocalizedStringResource {
    switch self {
    case .ja: .translationLanguageShortNameJa
    case .zhHant: .translationLanguageShortNameZhHant
    case .es: .translationLanguageShortNameEs
    case .fr: .translationLanguageShortNameFr
    case .enDefinition: .translationLanguageShortNameEnDefinition
    }
  }

  /// 訳の欄の項目名(「日本語訳 *」/ 語義なら「語義 *」)。
  var meaningFieldLabel: LocalizedStringResource {
    usesDefinition ? .fieldDefinition : .fieldMeaning(String(localized: shortLabel))
  }

  /// カードの「訳を表示」ボタンの文言。
  var showMeaningLabel: LocalizedStringResource {
    usesDefinition ? .showDefinition : .showMeaningWithLanguage(String(localized: shortLabel))
  }

  /// 全単語の表の訳の列名。
  var meaningColumnLabel: LocalizedStringResource {
    usesDefinition ? .tableDefinition : .tableMeaning(String(localized: shortLabel))
  }

  /// 登録画面の説明文。
  var registrationIntro: LocalizedStringResource {
    usesDefinition ? .registrationIntroDefinition : .registrationIntro(String(localized: shortLabel))
  }
}
