import SwiftUI

/// 塗りボタン(白文字・角丸)。Flutter 版の AppFilledButton。
///
/// 既定はアクセント色の主ボタンで、iOS の MobileFilledButton と同じ
/// グラデーション + 影にする。`color` を渡すと(削除の赤など)その単色で塗る。
struct AppFilledButton: View {
  let label: String
  /// 単色で塗るときの色とホバー色。nil ならアクセント色のグラデーション。
  var color: Color?
  var hoverColor: Color?
  // AppOutlinedButton と組み合わせて使う画面で高さを揃えるためのパラメータ。
  // 既定はダイアログ・登録フォーム系(標準のボタン)の値。
  var verticalPadding: CGFloat = 9
  var fontSize: CGFloat = 14
  var borderRadius: CGFloat = 8
  let action: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(borderRadius))
    AppText(
      label,
      // 日本語の代替フォントの行の高さが大きく、ボタンの上下が太って見えるため行の高さを明示する
      style: AppTextStyle(size: fontSize, weight: .w600, height: 1.4)
    )
    .foregroundStyle(.white)
    // ボタン幅がラベル幅より広い場面(全幅ボタン等)でも中央寄せにする。
    .multilineTextAlignment(.center)
    .padding(.horizontal, px(14))
    .padding(.vertical, px(verticalPadding))
    .background { fill(shape) }
    .appShadows(color == nil ? colors.buttonShadow : [], in: shape, scale: px.factor)
    .hoverTap($isHovered, in: shape, action: action)
  }

  @ViewBuilder
  private func fill(_ shape: RoundedRectangle) -> some View {
    if let color {
      shape.fill(isHovered ? hoverColor ?? color : color)
    } else {
      shape.fill(
        LinearGradient(
          colors: isHovered ? colors.buttonGradientHover : colors.buttonGradient,
          startPoint: .top, endPoint: .bottom))
    }
  }
}
