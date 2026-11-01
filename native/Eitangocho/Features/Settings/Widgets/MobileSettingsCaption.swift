#if os(iOS)
  import SwiftUI

  /// iOS 版の設定のセクションの下に置く説明文(Flutter 版の MobileSettingsCaption)。
  ///
  /// 直前のカードに掛かる補足なので、セクションとの間は 8 空ける(空ける側は呼び出し元が持つ)。
  struct MobileSettingsCaption: View {
    let text: String

    @Environment(\.palette) private var palette

    var body: some View {
      // セクションの見出しと同じく、カードの角丸が終わる位置に揃える。
      AppText(text, style: AppTextStyle(size: 11, height: 1.6))
        .foregroundStyle(palette.textAlpha(40))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppDimensions.mobileCardRadius)
    }
  }
#endif
