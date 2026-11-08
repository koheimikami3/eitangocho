#if os(macOS)
  import SwiftUI

  /// ツールバー右端の「単語を登録」ボタン。
  ///
  /// macOS 26 以降はアクセント色の Liquid Glass のカプセル(iOS のヘッダの ＋・シートの「登録」と同じ)。
  /// それより前は、ほかの主ボタンと同じグラデーションの塗りボタン。
  struct ToolbarAddButton: View {
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      if #available(macOS 26, *) {
        Button(action: action) {
          AppText(String(localized: .addWord), style: AppTextStyle(size: 13, weight: .w600))
            .foregroundStyle(.white)
            .padding(.horizontal, px(14))
            .frame(height: px(AppDimensions.toolbarControlHeight))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(colors.accent).interactive(), in: .capsule)
        .pointerStyle(.link)
      } else {
        AppFilledButton(
          label: String(localized: .addWord), verticalPadding: 6, fontSize: 13, borderRadius: 7, action: action)
      }
    }
  }
#endif
