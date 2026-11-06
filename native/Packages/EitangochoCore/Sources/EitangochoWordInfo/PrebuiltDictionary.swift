import EitangochoData
import Foundation
import OSLog

/// 同梱の事前生成辞書(`Resources/prebuilt-dictionary.json`)の 1 語。
public struct PrebuiltEntry: Equatable, Sendable {
  public var ipa: String
  public var partsOfSpeech: [PartOfSpeech]
  public var meaning: String
  public var exampleEn: String
  public var exampleTranslation: String
}

/// 同梱の事前生成辞書。頻出語の IPA・品詞・訳・例文(訳付き)を開発時に作って同梱したもの。
///
/// 中身は tool/dictgen の build_bundle.py が書き出す(作り方と範囲は tool/dictgen を参照)。
/// 訳と例文の訳は日本語と繁体字だけを持つので、それ以外の訳の言語では引かない。
///
/// 約 4.5 MB あるので起動時には読まず、最初に引いたときに読み込んで持ち続ける。
public actor PrebuiltDictionary {
  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "prebuilt-dictionary")

  /// 読める形の版(build_bundle.py の VERSION)。違う版のファイルは読まない。
  static let supportedVersion = 1

  private let load: @Sendable () throws -> Data
  private var words: [String: Word]?

  /// アプリに同梱した辞書。
  public static let bundled = PrebuiltDictionary {
    guard let url = Bundle.module.url(forResource: "prebuilt-dictionary", withExtension: "json") else {
      throw CocoaError(.fileNoSuchFile)
    }
    return try Data(contentsOf: url)
  }

  /// `load` は最初に引いたときに 1 回だけ呼ぶ(テストでは JSON を直接渡す)。
  public init(load: @escaping @Sendable () throws -> Data) {
    self.load = load
  }

  /// 見出し語(trim・小文字化済み)の値を `language` で返す。辞書に無い語・対象外の言語は nil。
  public func lookup(_ word: String, language: TranslationLanguage) -> PrebuiltEntry? {
    guard let key = Self.languageKey(language), let entry = loadedWords()[word] else { return nil }
    let translation = entry[keyPath: key]
    return PrebuiltEntry(
      ipa: entry.ipa,
      partsOfSpeech: entry.pos.compactMap(PartOfSpeech.init(rawValue:)),
      meaning: translation.meaning,
      exampleEn: entry.exampleEn,
      exampleTranslation: translation.exampleTranslation)
  }

  /// 辞書が訳を持つ言語か。
  public static func covers(_ language: TranslationLanguage) -> Bool {
    languageKey(language) != nil
  }

  private static func languageKey(_ language: TranslationLanguage) -> KeyPath<Word, Translation>? {
    switch language {
    case .ja: \.ja
    case .zhHant: \.zhHant
    case .es, .fr, .enDefinition: nil
    }
  }

  /// 読めなかったら空の辞書として扱う(自動入力は今までの取得経路で続けられる)。
  private func loadedWords() -> [String: Word] {
    if let words { return words }
    var loaded: [String: Word] = [:]
    do {
      let file = try JSONDecoder().decode(File.self, from: try load())
      if file.version == Self.supportedVersion {
        loaded = file.words
      } else {
        Self.logger.error("事前生成辞書の版が違う: \(file.version)")
      }
    } catch {
      Self.logger.error("事前生成辞書を読めない: \(String(describing: error), privacy: .public)")
    }
    words = loaded
    return loaded
  }

  private struct File: Decodable {
    let version: Int
    let words: [String: Word]
  }

  private struct Word: Decodable {
    let ipa: String
    let pos: [String]
    let exampleEn: String
    let ja: Translation
    let zhHant: Translation
  }

  private struct Translation: Decodable {
    let meaning: String
    let exampleTranslation: String
  }
}
