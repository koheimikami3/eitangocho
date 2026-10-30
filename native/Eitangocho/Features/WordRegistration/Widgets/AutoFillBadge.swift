import SwiftUI

/// 自動取得できた項目のラベル横に出すピル(Flutter 版の AutoFillBadge)。
struct AutoFillBadge: View {
  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    AppText(.autoFillBadge, style: AppTextStyle(size: 10, weight: .w600))
      .foregroundStyle(colors.autoFillBadgeForeground)
      .padding(.horizontal, px(6))
      .padding(.vertical, px(1))
      .background(Capsule().fill(colors.autoFillBadgeBackground))
  }
}
