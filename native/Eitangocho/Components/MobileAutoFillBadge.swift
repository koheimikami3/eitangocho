#if os(iOS)
  import SwiftUI

  /// 辞書から自動入力された項目を示す小さなバッジ(Flutter 版の MobileAutoFillBadge)。
  struct MobileAutoFillBadge: View {
    @Environment(\.palette) private var palette

    var body: some View {
      AppText(.autoFillBadge, style: AppTextStyle(size: 10, weight: .w600))
        .foregroundStyle(palette.autoFillBadgeForeground)
        .padding(.horizontal, 6)
        .padding(.vertical, 1)
        .background(Capsule().fill(palette.autoFillBadgeBackground))
    }
  }
#endif
