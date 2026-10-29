import CoreText
import SwiftUI

/// 同梱フォント(Flutter 版と同じ `assets/fonts/` のファイル)の登録と、
/// Flutter 版と同じ字形・行の高さになるフォントの組み立て。
///
/// 欧文は Inter を主にし、Inter に無い漢字・かなは cjkFallback の順に探す。
/// 発音記号だけは IPA 用に作られた Andika を使う。
/// Noto の縦の数値は `tool/center_font_metrics.py` でファイルそのものを直してあるので、
/// そのファイルを入れれば補正も効く(CoreText も hhea の値で行を組む)。
enum AppFonts {
  enum Family: Sendable {
    /// Inter(画面の文字のほぼすべて)
    case sans
    /// Andika(発音記号)
    case ipa
  }

  /// 同梱するファイル。Xcode の Resources に `../assets/fonts/` のファイル参照で入れてある。
  static let fileNames = ["Inter.ttf", "NotoSansJP.ttf", "NotoSansTC.ttf", "Andika-Regular.ttf"]

  // PostScript 名。Inter と Noto は可変フォントで、名前が指すのは既定の位置の
  // インスタンス(Noto の既定は Thin)。太さは wght 軸で指定する。
  private static let interName = "Inter-Regular"
  private static let andikaName = "Andika"
  private static let japaneseName = "NotoSansJP-Thin"
  private static let traditionalChineseName = "NotoSansTC-Thin"

  // 可変フォントの軸の識別子('wght' / 'opsz' の 4 文字コード)。
  private static let weightAxis = 0x7767_6874
  private static let opticalSizeAxis = 0x6F70_737A

  /// Inter の opsz 軸の既定値。Flutter は opsz を指定しないので既定の 14 で描く。
  /// CoreText は文字の大きさに合わせて opsz を自動で動かすため、明示して止める。
  private static let interOpticalSize = 14

  /// 起動時に 1 回呼ぶ。プロセスの中だけで使えるように登録する。
  /// 何度呼んでも 2 回目以降は「登録済み」で失敗するだけなので、結果は見ない。
  static func register(bundle: Bundle = .main) {
    for name in fileNames {
      guard let url = bundle.url(forResource: name, withExtension: nil) else {
        assertionFailure("フォントが同梱されていない: \(name)")
        continue
      }
      CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
  }

  /// 和文・繁体字フォントの優先順(PostScript 名)。
  ///
  /// 漢字はどちらのフォントにも入っているので、先頭のフォントの字形で出る。
  /// 繁体字の画面で日本の字形を出さないよう、表示言語で先頭を入れ替える。
  /// 繁体字以外の画面(英・西・仏を含む)は和文を先にする。訳の言語の既定が
  /// 日本語になるため(AppLocale.defaultTranslationLanguage)。
  static func cjkFallback(_ language: AppLocale.Language) -> [String] {
    language == .zhHant
      ? [traditionalChineseName, japaneseName]
      : [japaneseName, traditionalChineseName]
  }

  /// 画面の文字が漢字・かなになる表示言語か(日本語・繁体字)。
  static func isCjk(_ language: AppLocale.Language) -> Bool {
    language == .ja || language == .zhHant
  }

  // MARK: - フォントの組み立て

  private struct FontKey: Hashable {
    var family: Family
    var size: CGFloat
    var weight: Int
    var language: AppLocale.Language
  }

  private static var fontCache: [FontKey: CTFont] = [:]

  /// 主のフォントに、和文・繁体字の cascade list と太さを付けたもの。
  /// `size` は倍率を掛けた後の値。
  static func ctFont(
    _ family: Family, size: CGFloat, weight: Int, language: AppLocale.Language = AppLocale.current
  ) -> CTFont {
    let key = FontKey(family: family, size: size, weight: weight, language: language)
    if let cached = fontCache[key] { return cached }
    // Flutter は太さを可変フォントの wght 軸に当てる(和文の代替フォントにも)。
    // cascade の各フォントにも同じ太さを付けないと、Noto は既定の Thin で出る。
    let cascade = cjkFallback(language).map { descriptor($0, size: size, weight: weight) }
    var attributes: [CFString: Any] = [kCTFontCascadeListAttribute: cascade]
    switch family {
    case .sans:
      attributes[kCTFontNameAttribute] = interName
      attributes[kCTFontVariationAttribute] = [weightAxis: weight, opticalSizeAxis: interOpticalSize]
    case .ipa:
      // Andika は太さを 1 つしか持たない(画面でも標準の太さでしか使わない)。
      attributes[kCTFontNameAttribute] = andikaName
    }
    let font = CTFontCreateWithFontDescriptor(
      CTFontDescriptorCreateWithAttributes(attributes as CFDictionary), size, nil)
    fontCache[key] = font
    return font
  }

  private static func descriptor(_ name: String, size: CGFloat, weight: Int) -> CTFontDescriptor {
    let attributes: [CFString: Any] = [
      kCTFontNameAttribute: name,
      kCTFontSizeAttribute: size,
      kCTFontVariationAttribute: [weightAxis: weight],
    ]
    return CTFontDescriptorCreateWithAttributes(attributes as CFDictionary)
  }

  // MARK: - 行の高さ

  /// フォントの縦の数値(文字の大きさに対する比)。Flutter と同じく hhea の値を使う。
  struct VerticalMetrics: Equatable {
    var ascent: CGFloat
    var descent: CGFloat
  }

  private static var metricsCache: [String: VerticalMetrics] = [:]

  static func verticalMetrics(postScriptName name: String) -> VerticalMetrics {
    if let cached = metricsCache[name] { return cached }
    let font = CTFontCreateWithName(name as CFString, 1, nil)
    let metrics = hheaMetrics(font) ?? VerticalMetrics(ascent: CTFontGetAscent(font), descent: CTFontGetDescent(font))
    metricsCache[name] = metrics
    return metrics
  }

  private static func hheaMetrics(_ font: CTFont) -> VerticalMetrics? {
    guard let hhea = CTFontCopyTable(font, CTFontTableTag(kCTFontTableHhea), []) as Data?,
      let head = CTFontCopyTable(font, CTFontTableTag(kCTFontTableHead), []) as Data?,
      hhea.count >= 8, head.count >= 20
    else { return nil }
    func int16(_ data: Data, _ offset: Int) -> CGFloat {
      CGFloat(Int16(bitPattern: UInt16(data[data.startIndex + offset]) << 8 | UInt16(data[data.startIndex + offset + 1])))
    }
    let unitsPerEm = int16(head, 18)
    return VerticalMetrics(ascent: int16(hhea, 4) / unitsPerEm, descent: -int16(hhea, 6) / unitsPerEm)
  }

  static func primaryName(_ family: Family) -> String {
    family == .sans ? interName : andikaName
  }

  /// 和文の代替フォントの縦の数値(JP / TC は同じ値に直してある)。
  static var fallbackMetrics: VerticalMetrics { verticalMetrics(postScriptName: japaneseName) }

  /// `text` の文字を、主のフォントにある文字と無い文字(漢字・かな・全角記号など)に分けたときに、
  /// それぞれが 1 つでもあるか。Flutter は主のフォントに無い文字を代替フォントで描き、
  /// 行の高さは実際に使ったフォントの数値で決まる(和文だけの行は Noto だけ、混ざれば両方)。
  static func coverage(_ text: String, family: Family) -> (primary: Bool, fallback: Bool) {
    let font = CTFontCreateWithName(primaryName(family) as CFString, 12, nil)
    var primary = false
    var fallback = false
    for scalar in text.unicodeScalars where !CharacterSet.newlines.contains(scalar) {
      let units = Array(String(scalar).utf16)
      var glyphs = [CGGlyph](repeating: 0, count: units.count)
      if CTFontGetGlyphsForCharacters(font, units, &glyphs, units.count) {
        primary = true
      } else {
        fallback = true
      }
      if primary && fallback { break }
    }
    // 空の文字列も主のフォントの行の高さになる。
    return (primary || !fallback, fallback)
  }
}
