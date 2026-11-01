#if os(iOS)
  import SwiftUI

  /// iOS 版ヘッダの並び替えボタン(全単語のときだけ出す。Flutter 版の MobileWordSortButton)。
  ///
  /// 現在の並び順をラベルにしたピル形。どの順で並んでいるかがボタンを見るだけで分かるので、
  /// 既定以外のときに色で知らせる必要は無い(常にアクセント色)。
  struct MobileWordSortButton: View {
    let settings: SettingsStore

    @Environment(\.palette) private var palette
    @Environment(\.appOverlay) private var overlay

    var body: some View {
      MobilePressable(action: showSheet) {
        HStack(spacing: 6) {
          MaterialIconView(.sort, size: 14, color: palette.accentOnSoft)
          AppText(settings.wordSortOrder.label, style: AppTextStyle(size: 12, weight: .w700))
            .foregroundStyle(palette.accentOnSoft)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 6)
        .frame(minHeight: 32)
        .background(Capsule().fill(palette.accentSoft))
        .overlay(Capsule().strokeBorder(palette.accentLine, lineWidth: 1))
      }
    }

    private func showSheet() {
      overlay?.presentSheet { dismiss in
        MobileWordSortSheet(settings: settings, dismiss: dismiss)
      }
    }
  }
#endif
