/// 訳の言語。単語の訳語・例文の訳を何語で取得し保存するかを決める。
///
/// 画面の表示言語とは別に持つ。英語の画面で日本語の訳を使う利用者(海外在住の
/// 日本語話者など)がいるため。既定は端末の言語から決め(AppLocale)、設定で変えられる。
///
/// 取得元ごとの言語コードもここに集める。言語を足すときは値を 1 つ足し、
/// 各コードを埋めれば取得の経路が揃う(docs/design.md「多言語化」)。
///
/// `rawValue` は設定(UserDefaults の `translationLanguage`)に保存する名前で、
/// Flutter 版の enum の name と同じ。DB と同期 JSON に入れる `storageCode` とは別の値。
///
/// `enDefinition` だけは訳ではなく英語の語義(英英)。対応外の言語の端末で
/// 日本語などの訳を出さないための既定で、訳の欄に語義を入れ、例文の訳は持たない。
public enum TranslationLanguage: String, CaseIterable, Sendable {
  case ja
  case zhHant
  case es
  case fr
  case enDefinition

  /// words.translation_language と同期 JSON に保存する値(BCP 47)。
  public var storageCode: String {
    switch self {
    case .ja: "ja"
    case .zhHant: "zh-Hant"
    case .es: "es"
    case .fr: "fr"
    case .enDefinition: "en"
    }
  }

  /// kaikki の訳語の `lang_code`。中国語は北京語(cmn)の訳語を使う。
  /// nil は訳語を使わない(enDefinition)。
  public var kaikkiLangCode: String? {
    switch self {
    case .ja: "ja"
    case .zhHant: "cmn"
    case .es: "es"
    case .fr: "fr"
    case .enDefinition: nil
    }
  }

  /// Tatoeba の言語コード(ISO 639-3)。nil は対訳を取らない(enDefinition)。
  public var tatoebaLang: String? {
    switch self {
    case .ja: "jpn"
    case .zhHant: "cmn"
    case .es: "spa"
    case .fr: "fra"
    case .enDefinition: nil
    }
  }

  /// Tatoeba の訳の文字体系。中国語は繁体字と簡体字が同じ cmn に混ざるため
  /// これで絞る。nil なら絞らない。
  public var tatoebaScript: String? {
    self == .zhHant ? "Hant" : nil
  }

  /// DeepL の target_lang。nil は DeepL で訳さない(enDefinition)。
  public var deeplTargetLang: String? {
    switch self {
    case .ja: "JA"
    case .zhHant: "ZH-HANT"
    case .es: "ES"
    case .fr: "FR"
    case .enDefinition: nil
    }
  }

  /// 発音確認で開く Google 翻訳の訳先(`tl`)。
  public var googleTranslateCode: String {
    switch self {
    case .ja: "ja"
    case .zhHant: "zh-TW"
    case .es: "es"
    case .fr: "fr"
    case .enDefinition: "en"
    }
  }

  /// 訳の欄に英語の語義を入れるか。
  public var usesDefinition: Bool { self == .enDefinition }

  /// 例文の訳を持つか。false なら例文の訳の欄を出さず、空でも取得失敗とみなさない。
  public var translatesExamples: Bool { tatoebaLang != nil }

  /// 保存値から引く。未知・欠落(古い版のデータ)は日本語として扱う。
  public static func fromStorageCode(_ code: String?) -> TranslationLanguage {
    allCases.first { $0.storageCode == code } ?? .ja
  }
}
