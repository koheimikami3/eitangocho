import SwiftUI

/// 枠線ボタン(面の色の地・文字色指定可)。Flutter 版の AppOutlinedButton。
struct AppOutlinedButton: View {
  let label: String
  /// 文字色。nil なら本文色(AppColors.textPrimary)。
  var textColor: Color?
  /// ホバー中の地。nil なら他のボタン・行と同じグレー(AppColors.rowHoverBackground)。
  var hoverBackground: Color?
  // AppFilledButton と組み合わせて使う画面で高さを揃えるためのパラメータ。
  var verticalPadding: CGFloat = 9
  var fontSize: CGFloat = 14
  var fontWeight: AppTextStyle.Weight = .w600
  var borderRadius: CGFloat = 8
  let action: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(borderRadius))
    AppText(label, style: AppTextStyle(size: fontSize, weight: fontWeight))
      .foregroundStyle(textColor ?? colors.textPrimary)
      .multilineTextAlignment(.center)
      // 枠線の幅も内側の余白に足す(Flutter の Container は枠線の幅を余白に含める)。
      .padding(.horizontal, px(18 + 1))
      .padding(.vertical, px(verticalPadding + 1))
      .background(shape.fill(isHovered ? hoverBackground ?? colors.rowHoverBackground : colors.surface))
      .overlay(shape.strokeBorder(colors.borderStrong, lineWidth: px(1)))
      .hoverTap($isHovered, in: shape, action: action)
  }
}
