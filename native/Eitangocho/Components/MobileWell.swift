#if os(iOS)
  import SwiftUI

  /// 内側の影で沈めた角丸の面(デザインの box-shadow: inset 相当。Flutter 版の MobileWell)。
  ///
  /// 入力欄・訳の表示枠で使う(`AppPalette.wellShadow`。ライトは内側の 1px の枠線だけ)。
  /// 影の spread は内側へ食い込む幅で、blur 0・spread 1 で 1px の内枠になる。
  struct MobileWell<Content: View>: View {
    let color: Color
    let shadows: [AppShadow]
    let cornerRadius: CGFloat
    var padding = EdgeInsets()
    @ViewBuilder let content: () -> Content

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: cornerRadius)
      content()
        .padding(padding)
        .background(shape.fill(color))
        .overlay {
          ZStack {
            ForEach(Array(shadows.enumerated()), id: \.offset) { _, shadow in
              InsetShadowShape(cornerRadius: cornerRadius, shadow: shadow)
                .fill(shadow.color, style: FillStyle(eoFill: true))
                .blur(radius: shadow.sigma(scale: 1))
            }
          }
          .clipShape(shape)
          .allowsHitTesting(false)
        }
    }
  }

  /// 面の外側を大きな矩形でくり抜いた板(Flutter 版の InsetShadowPainter と同じ形)。
  ///
  /// 板の穴を offset だけずらすと、その反対側の縁に影が溜まる(CSS の inset shadow と同じ見え方)。
  /// ぼかして面の形で切り抜いて使う。
  nonisolated private struct InsetShadowShape: Shape {
    let cornerRadius: CGFloat
    let shadow: AppShadow

    func path(in rect: CGRect) -> Path {
      let hole = rect.offsetBy(dx: shadow.x, dy: shadow.y).insetBy(dx: shadow.spread, dy: shadow.spread)
      // 板の外周はぼかしが面に回り込まない程度に十分広く取る。
      let margin = shadow.blurRadius * 2 + hypot(shadow.x, shadow.y) + 1
      var path = Path(rect.insetBy(dx: -margin, dy: -margin))
      path.addRoundedRect(
        in: hole,
        cornerSize: CGSize(width: max(cornerRadius - shadow.spread, 0), height: max(cornerRadius - shadow.spread, 0)))
      return path
    }
  }
#endif
