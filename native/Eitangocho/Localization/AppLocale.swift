import EitangochoData
import Foundation

/// 画面の表示言語の解決を 1 箇所に集約する(Flutter 版の AppLocale と同じ規則)。
///
/// 対応は日本語・英語・繁体字中国語・スペイン語・フランス語。端末の優先言語を
/// 上から見て、最初に対応しているものを採る。どれも無ければ英語にする
/// (対応外の言語の端末向け)。スペイン語・フランス語は地域を区別しない。
///
/// 画面の文言そのものは OS の言語解決(Bundle の .lproj の選択)で選ばれる。
/// その結果がここの `resolve` と一致することはテストで確かめている
/// (簡体字は対応言語にせず次の候補へ進む、など)。
enum AppLocale {
  /// 表示言語。rawValue は .lproj の名前。
  enum Language: String, CaseIterable {
    case ja
    case en
    case zhHant = "zh-Hant"
    case es
    case fr
  }

  /// `preferred`(端末の優先言語の BCP 47 の並び)から表示言語を決める。
  ///
  /// **簡体字は対応言語として扱わず、次の候補へ進む**。繁体字の画面を
  /// 簡体字の利用者に出すより、英語の方が読みやすいため。
  static func resolve(_ preferred: [String]) -> Language { match(preferred) ?? .en }

  /// `preferred` に対応言語が 1 つも無いか(ドイツ語・韓国語・簡体字の端末など)。
  /// 画面は英語になり、訳の言語の既定は英語の語義になる。
  static func isUnsupported(_ preferred: [String]) -> Bool { match(preferred) == nil }

  /// 端末の優先言語を上から見て、最初に対応しているものを返す。無ければ nil。
  private static func match(_ preferred: [String]) -> Language? {
    for identifier in preferred {
      let language = Locale.Language(identifier: identifier)
      switch language.languageCode?.identifier {
      case "ja": return .ja
      case "en": return .en
      case "zh" where isTraditional(language): return .zhHant
      case "es": return .es
      case "fr": return .fr
      default: continue
      }
    }
    return nil
  }

  /// 文字体系の無い `zh-TW` / `zh-HK` も繁体字とみなす。`Locale.Language.script` は
  /// 書かれていない文字体系を地域から補う(zh-TW → Hant、zh / zh-CN → Hans)ので、
  /// Flutter 版の「文字体系が Hant か、文字体系が無く地域が TW / HK / MO」と同じ結果になる。
  private static func isTraditional(_ language: Locale.Language) -> Bool {
    language.script?.identifier == "Hant"
  }

  /// 訳の言語の既定。画面の言語と同じ訳の言語があればそれ、無ければ日本語
  /// (繁体字の画面なら繁体字、スペイン語の画面ならスペイン語)。
  ///
  /// 英語の画面になる利用者も日本語にするのは、今の利用者のほとんどが
  /// 日本語話者で(端末を英語にしている海外在住者を含む)、英語を英語で
  /// 訳すことはできないため。
  static func defaultTranslationLanguage(_ appLanguage: Language) -> TranslationLanguage {
    switch appLanguage {
    case .zhHant: .zhHant
    case .es: .es
    case .fr: .fr
    case .ja, .en: .ja
    }
  }

  /// `preferred` の端末での訳の言語の既定。
  ///
  /// 対応外の言語の端末は英語の語義にする。どの訳の言語も利用者の言語では
  /// ないので、日本語などの訳を出すより英英の方が読める。英語の端末は
  /// defaultTranslationLanguage のとおり日本語のまま(海外在住の日本語話者)。
  static func defaultTranslationLanguage(for preferred: [String]) -> TranslationLanguage {
    isUnsupported(preferred) ? .enDefinition : defaultTranslationLanguage(resolve(preferred))
  }

  /// 設定に出す訳の言語の選択肢。
  ///
  /// 英語の語義は対応外の言語の端末と、すでに選んでいる利用者にだけ出す。
  /// 対応言語の端末の設定画面を今までと変えないため。
  static func translationLanguageChoices(
    _ preferred: [String], current: TranslationLanguage
  ) -> [TranslationLanguage] {
    TranslationLanguage.allCases.filter {
      !$0.usesDefinition || current == $0 || isUnsupported(preferred)
    }
  }

  /// この端末での訳の言語の選択肢(設定画面に出す)。
  static func deviceTranslationLanguageChoices(current: TranslationLanguage) -> [TranslationLanguage] {
    translationLanguageChoices(Locale.preferredLanguages, current: current)
  }

  /// この端末での訳の言語の既定(設定が未保存のときに使う)。
  static var deviceDefaultTranslationLanguage: TranslationLanguage {
    defaultTranslationLanguage(for: Locale.preferredLanguages)
  }

  /// 今の表示言語(Bundle が選んだ .lproj)。書体の和文・繁体字の順を決めるのに使う。
  static var current: Language {
    Bundle.main.preferredLocalizations.first.flatMap(Language.init(rawValue:)) ?? .en
  }
}
