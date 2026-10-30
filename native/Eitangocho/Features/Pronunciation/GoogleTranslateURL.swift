import EitangochoData
import Foundation

/// 発音確認用の Google 翻訳の URL(Flutter 版の googleTranslateUrl)。
///
/// 訳先(`tl`)は訳の言語に合わせる。発音を聞くのが目的だが、ページには
/// 訳も並ぶため、利用者が読める言語にしておく。
enum GoogleTranslateURL {
  /// Dart の Uri.encodeComponent と同じく、英数字と `-_.!~*'()` 以外を百分率符号化する。
  private static let allowed = CharacterSet(
    charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~*'()")

  static func make(_ word: String, language: TranslationLanguage) -> URL {
    let text = word.addingPercentEncoding(withAllowedCharacters: allowed) ?? word
    return URL(
      string: "https://translate.google.com/?sl=en&tl=\(language.googleTranslateCode)&text=\(text)&op=translate")!
  }
}
