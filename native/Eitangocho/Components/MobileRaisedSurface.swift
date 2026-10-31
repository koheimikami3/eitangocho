#if os(iOS)
  import SwiftUI

  /// 影で浮かせた、押せる面(学習中カード・クイズの「忘れていた」ボタン。Flutter 版の MobileRaisedSurface)。
  ///
  /// 押している間は縮むだけで、地・影は変えない(2.2.0 で沈み込みをやめた。ユーザー判断)。
  struct MobileRaisedSurface<Content: View>: View {
    let cornerRadius: CGFloat
    var padding = EdgeInsets()
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.palette) private var palette

    var body: some View {
      MobilePressable(style: .card, action: action) {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        content()
          .padding(padding)
          .background(shape.fill(palette.surface))
          .appShadows(palette.elevation, in: shape, scale: 1)
      }
    }
  }
#endif
