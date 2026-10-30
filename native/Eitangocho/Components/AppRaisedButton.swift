import SwiftUI

/// 影で浮かせた面のボタン(副操作)。Flutter 版の AppRaisedButton。
///
/// iOS のクイズの「忘れていた」(面ボタン)に相当する。枠線は持たず、
/// カードと同じ影(AppColors.elevation)で輪郭を出す。ホバーでは他のボタン・行と同じグレーの地にする。
struct AppRaisedButton: View {
  let label: String
  /// 文字色。nil なら本文色(AppColors.textPrimary)。
  var textColor: Color?
  var verticalPadding: CGFloat = 9
  var fontSize: CGFloat = 14
  var borderRadius: CGFloat = 8
  /// 横いっぱいに広げるか(Flutter の Expanded の中に置いたとき)。
  var expands = false
  let action: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(borderRadius))
    AppText(label, style: AppTextStyle(size: fontSize, weight: .w600))
      .foregroundStyle(textColor ?? colors.textPrimary)
      .multilineTextAlignment(.center)
      .frame(maxWidth: expands ? .infinity : nil)
      .padding(.horizontal, px(18))
      .padding(.vertical, px(verticalPadding))
      .background(shape.fill(isHovered ? colors.rowHoverBackground : colors.surface))
      .appShadows(colors.elevation, in: shape, scale: px.factor)
      .hoverTap($isHovered, in: shape, action: action)
  }
}
