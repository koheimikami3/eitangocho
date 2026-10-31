#if os(iOS)
  import SwiftUI

  /// iOS 版の学習中 0 件の空の状態(Flutter 版の MobileLearningEmptyState)。
  ///
  /// macOS 版と分けるのは登録の導線が違うため。iOS に登録の画面は無く、ヘッダの ＋ と同じくシートで開く。
  struct MobileLearningEmptyState: View {
    let onRegister: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      VStack(spacing: 16) {
        AppText(.learningEmpty, style: AppTextStyle(size: 14, height: 1.7))
          .foregroundStyle(palette.textAlpha(45))
          .multilineTextAlignment(.center)
        MobileFilledButton(
          label: String(localized: .addWord), fontSize: 14,
          padding: EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24), cornerRadius: 11, action: onRegister)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
#endif
