#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版の削除の確認ダイアログ(iOS 標準のアラート風の 2 分割のボタン。Flutter 版の MobileDeleteConfirmDialog)。
  struct MobileDeleteConfirmDialog: View {
    let word: Word
    let store: WordStore
    let dismiss: () -> Void
    let onDeleted: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      AppDialogSurface(cornerRadius: 14) {
        VStack(spacing: 0) {
          VStack(spacing: 6) {
            AppText(.deleteConfirmTitle(word.word), style: AppTextStyle(size: 15, weight: .w700))
              .foregroundStyle(palette.text)
            AppText(.deleteConfirmBody, style: AppTextStyle(size: 12))
              .foregroundStyle(palette.textAlpha(50))
          }
          .multilineTextAlignment(.center)
          .padding(EdgeInsets(top: 20, leading: 16, bottom: 16, trailing: 16))
          Rectangle().fill(palette.rowLine).frame(height: 1)
          HStack(spacing: 0) {
            action(String(localized: .deleteConfirmCancel), color: palette.accent, weight: .w600, perform: dismiss)
            Rectangle().fill(palette.rowLine).frame(width: 1)
            action(String(localized: .deleteConfirmOk), color: palette.danger, weight: .w700) {
              dismiss()
              Task {
                await store.delete(word)
                onDeleted()
              }
            }
          }
          .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 280)
      }
    }

    private func action(
      _ label: String, color: Color, weight: AppTextStyle.Weight, perform: @escaping () -> Void
    ) -> some View {
      MobilePressable(style: .row, action: perform) { pressed in
        AppText(label, style: AppTextStyle(size: 15, weight: weight))
          .foregroundStyle(color)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 13)
          .background(pressed ? palette.pressBackground : .clear)
      }
    }

    /// 出す。幕は Flutter 版と同じ rgba(20,25,35,0.4)(シートの幕より少し濃い)。
    @MainActor
    static func present(_ word: Word, store: WordStore, overlay: AppOverlay?, onDeleted: @escaping () -> Void) {
      overlay?.present(barrier: Color(argb: 0x6614_1923)) { dismiss in
        MobileDeleteConfirmDialog(word: word, store: store, dismiss: dismiss, onDeleted: onDeleted)
      }
    }
  }
#endif
