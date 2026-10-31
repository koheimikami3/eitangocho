import AppKit
import CoreText
import EitangochoData
import SwiftUI
import Testing

@testable import Eitangocho

/// 文字の書式が Flutter 版と同じ行の高さ・ベースラインになることを確かめる。
///
/// 期待値は Flutter 版で、Scaffold の既定の書式(bodyMedium: 行の高さ 1.43・字間 0.25・行間は上下に均等)を
/// 継承した TextPainter を同梱フォントで組んで測った値(文字の大きさ 20)。Flutter のテスト環境は
/// 行の高さを整数に丸めて返すので、高さは行の高さとベースラインから求めた値を書き、許容差を 0.6 にしている。
@MainActor
struct AppTextStyleTests {
  init() { AppFonts.register() }

  /// 倍率 1 に換算した(高さ, 1 行目のベースライン)。
  ///
  /// ベースラインは、下端がベースラインになる高さ 100 の空の面を
  /// `.firstTextBaseline` で横に並べ、全体の高さから逆算する。
  /// fittingSize は整数に丸めて返すので、4 倍で組んで 4 で割る(丸めの誤差を 0.25 にする)。
  private func measure(_ text: String, _ style: AppTextStyle) -> (height: CGFloat, baseline: CGFloat) {
    let factor: CGFloat = 4
    func fittingHeight(_ view: some View) -> CGFloat {
      NSHostingView(rootView: view.environment(\.uiScale, UIScale(factor: factor))).fittingSize.height / factor
    }
    let height = fittingHeight(AppText(text, style: style).fixedSize())
    let combined = fittingHeight(
      HStack(alignment: .firstTextBaseline, spacing: 0) {
        AppText(text, style: style).fixedSize()
        Color.clear.frame(width: 1, height: 100 * factor)
      })
    return (height, 100 + height - combined)
  }

  @Test(arguments: [
    // (文字, family, height(nil は書かない = 継承の 1.43), Flutter の高さ, Flutter のベースライン)
    ("Hello", AppFonts.Family.sans, nil, 28.6, 21.575),
    ("Hello", .sans, 1.4, 28, 21.275),
    ("Hello", .sans, 1.5, 30, 22.275),
    ("Hello", .sans, 1.0, 20, 17.275),
    ("学習中", .sans, nil, 28.6, 21.9),
    ("学習中", .sans, 1.4, 28, 21.6),
    // 和文と欧文が混ざる行は、上下それぞれでフォントの最大を取るので行の高さより少し高い。
    ("Ab学", .sans, nil, 28.925, 21.9),
    ("Ab学", .sans, 1.0, 20.325, 17.6),
    ("Ab学", .sans, 1.4, 28.325, 21.6),
    ("Hello\nWorld", .sans, 1.4, 56, 21.275),
    ("学習\n中です", .sans, 1.4, 56, 21.6),
    ("Hello\nWorld", .sans, nil, 57.2, 21.575),
    ("/ˈhɛloʊ/", .ipa, nil, 28.6, 19.329),
    ("Hello", .ipa, 1.4, 28, 19.029),
  ] as [(String, AppFonts.Family, CGFloat?, CGFloat, CGFloat)])
  func Flutterと同じ行の高さとベースラインになる(
    text: String, family: AppFonts.Family, height: CGFloat?, expectedHeight: CGFloat, expectedBaseline: CGFloat
  ) {
    let style = height.map { AppTextStyle(size: 20, height: $0, family: family) } ?? AppTextStyle(size: 20, family: family)
    let measured = measure(text, style)
    #expect(abs(measured.height - expectedHeight) < 0.6, "高さ \(measured.height)")
    #expect(abs(measured.baseline - expectedBaseline) < 0.6, "ベースライン \(measured.baseline)")
  }

  @Test func 既定はFlutterが継承するbodyMediumの行の高さと字間() {
    let style = AppTextStyle(size: 13)
    #expect(style.height == 1.43)
    #expect(style.letterSpacing == 0.25)
  }

  @Test func 同梱フォントが登録されていて名前で引ける() {
    for name in ["Inter-Regular", "NotoSansJP-Thin", "NotoSansTC-Thin", "Andika"] {
      let font = CTFontCreateWithName(name as CFString, 12, nil)
      #expect(CTFontCopyPostScriptName(font) as String == name)
    }
  }

  @Test func cascade_の和文にも太さが付き表示言語で順が入れ替わる() throws {
    let japanese = AppFonts.ctFont(.sans, size: 20, weight: 600, language: .ja)
    let traditional = AppFonts.ctFont(.sans, size: 20, weight: 600, language: .zhHant)
    #expect(runFontName("学", japanese).hasPrefix("NotoSansJP"))
    #expect(runFontName("學", traditional).hasPrefix("NotoSansTC"))

    let fallback = try #require(runFont("学", japanese))
    let variation = CTFontCopyVariation(fallback) as? [Int: Double]
    #expect(variation?[0x7767_6874] == 600)
  }

  /// Flutter で同じ書式の "Hello World" を測った幅。CoreText は opsz を文字の大きさで
  /// 自動で動かすので、止めていないと幅が変わる(既定の 14 で Flutter と一致する)。
  @Test(arguments: [(400, 109.443), (600, 111.957), (700, 113.214)])
  func Interの字幅がFlutterと一致する(weight: Int, expectedWidth: Double) {
    let font = AppFonts.ctFont(.sans, size: 20, weight: weight, language: .en)
    let line = CTLineCreateWithAttributedString(
      NSAttributedString(string: "Hello World", attributes: [.font: font]))
    #expect(abs(CTLineGetTypographicBounds(line, nil, nil, nil) - expectedWidth) < 0.01)
  }

  private func runFont(_ text: String, _ font: CTFont) -> CTFont? {
    let line = CTLineCreateWithAttributedString(
      NSAttributedString(string: text, attributes: [.font: font]))
    guard let run = (CTLineGetGlyphRuns(line) as? [CTRun])?.first else { return nil }
    let attributes = CTRunGetAttributes(run) as NSDictionary
    return attributes[kCTFontAttributeName] as! CTFont?
  }

  private func runFontName(_ text: String, _ font: CTFont) -> String {
    runFont(text, font).map { CTFontCopyPostScriptName($0) as String } ?? ""
  }
}
