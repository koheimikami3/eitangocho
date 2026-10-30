#if os(macOS)
  import SwiftUI

  /// 設定画面のセクション(見出し + 中身)。Flutter 版の SettingsSection。
  struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        // 見出しはカードの外枠ではなく、角丸が終わる位置まで内側に寄せる(iOS のセクションと同じ)。
        AppText(title, style: AppTextStyle(size: 12, weight: .w700))
          .foregroundStyle(colors.textMuted)
          .padding(.horizontal, px(AppDimensions.mobileCardRadius))
        Spacer().frame(height: px(8))
        content()
      }
    }
  }
#endif
