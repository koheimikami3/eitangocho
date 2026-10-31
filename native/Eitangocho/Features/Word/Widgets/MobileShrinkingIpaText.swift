#if os(iOS)
  import SwiftUI

  /// 学習中カードの発音記号。幅に収まらないときは字を縮めて 1 行に収める(Flutter 版の MobileShrinkingIpaText)。
  ///
  /// 折り返させるとカードごとにヘッダの高さが変わり、2 列に並べたときに単語の位置が揃わない。
  /// IPA は読めれば足りる補助情報なので、行を増やすより字を小さくする方を採る。
  /// 下限(minFontSize)で止め、そこでも溢れる分は末尾を省略する。
  struct MobileShrinkingIpaText: View {
    let ipa: String

    @Environment(\.palette) private var palette
    @Environment(\.textScale) private var textScale
    @State private var width: CGFloat?

    /// 通常の字の大きさ。Andika は小文字の背が低く字幅も狭いため、カードの他の補助テキスト(11px)より大きくする。
    static let maxFontSize: CGFloat = 13
    /// これ以上は縮めない下限。
    static let minFontSize: CGFloat = 8
    private static var step: CGFloat { 0.5 }

    var body: some View {
      AppText(ipa, style: Self.style(fontSize))
        .foregroundStyle(palette.textAlpha(45))
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { width = $0 }
    }

    static func style(_ size: CGFloat) -> AppTextStyle { AppTextStyle(size: size, family: .ipa) }

    /// 幅に収まる最大の大きさ。iOS は OS の文字サイズに従うため、測るときにも同じ倍率を掛ける。
    private var fontSize: CGFloat {
      guard let width else { return Self.maxFontSize }
      var size = Self.maxFontSize
      while size > Self.minFontSize && Self.style(size).width(of: ipa, scale: .none, textScale: textScale) > width {
        size -= Self.step
      }
      return size
    }
  }
#endif
