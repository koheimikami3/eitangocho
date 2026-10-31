import EitangochoData
import SwiftUI

/// 削除の確認ダイアログ(Flutter 版の showDeleteConfirmDialog)。
/// 確定すると削除し、`onDeleted` を呼ぶ(編集ダイアログを閉じるのに使う)。
struct DeleteConfirmDialog: View {
  let word: Word
  let store: WordStore
  let dismiss: () -> Void
  var onDeleted: () -> Void = {}

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    AppDialogSurface(cornerRadius: 13) {
      VStack(spacing: 0) {
        AppText(.deleteConfirmTitle(word.word), style: AppTextStyle(size: 15, weight: .w700))
          .foregroundStyle(colors.textPrimary)
          .multilineTextAlignment(.center)
        Spacer().frame(height: px(8))
        AppText(.deleteConfirmBody, style: AppTextStyle(size: 12))
          .foregroundStyle(colors.textSecondary)
          .multilineTextAlignment(.center)
        Spacer().frame(height: px(12))
        HStack(spacing: px(10)) {
          AppOutlinedButton(label: String(localized: .deleteConfirmCancel), expands: true, action: dismiss)
          AppFilledButton(
            label: String(localized: .deleteConfirmOk), color: colors.danger, hoverColor: colors.dangerHover,
            expands: true
          ) {
            dismiss()
            Task {
              await store.delete(word)
              onDeleted()
            }
          }
        }
      }
      .frame(width: px(380))
      .padding(px(24))
    }
  }

  @MainActor
  static func present(_ word: Word, store: WordStore, overlay: AppOverlay?, onDeleted: @escaping () -> Void = {}) {
    overlay?.present { dismiss in
      DeleteConfirmDialog(word: word, store: store, dismiss: dismiss, onDeleted: onDeleted)
    }
  }
}
