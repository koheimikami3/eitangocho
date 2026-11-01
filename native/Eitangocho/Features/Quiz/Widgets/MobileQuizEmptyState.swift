#if os(iOS)
  import SwiftUI

  /// iOS 版のクイズの空の状態(学習済みが 0 件のとき。Flutter 版の MobileQuizEmptyState)。
  struct MobileQuizEmptyState: View {
    let onToLearning: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      VStack(spacing: 16) {
        AppText(.quizEmpty, style: AppTextStyle(size: 14, height: 1.8))
          .foregroundStyle(palette.textAlpha(45))
          .multilineTextAlignment(.center)
        MobileFilledButton(
          label: String(localized: .toLearningList), fontSize: 14,
          padding: EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24), cornerRadius: 11,
          action: onToLearning)
      }
    }
  }
#endif
