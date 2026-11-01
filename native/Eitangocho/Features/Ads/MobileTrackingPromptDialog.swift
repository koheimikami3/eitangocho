#if os(iOS)
  import SwiftUI

  /// ATT のダイアログの直前に出す案内(`TrackingAuthorizer` の `explain`)。
  ///
  /// ボタンは「次へ」だけにし、押したら必ず ATT のダイアログへ進む。案内だけ閉じて ATT を出さずに
  /// 済ませられる作り(「許可しない」「あとで」など)は、App Store の審査で断られることがあるため。
  /// 幕を押しても閉じない。
  struct MobileTrackingPromptDialog: View {
    let onNext: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      AppDialogSurface(cornerRadius: 14) {
        VStack(spacing: 0) {
          AppText(.trackingPromptTitle, style: AppTextStyle(size: 17, weight: .w700))
            .foregroundStyle(palette.text)
          AppText(.trackingPromptBody, style: AppTextStyle(size: 14))
            .foregroundStyle(palette.textAlpha(70))
            .padding(.top, 12)
          MobileFilledButton(label: String(localized: .trackingPromptNext), expands: true, action: onNext)
            .padding(.top, 24)
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 28, leading: 24, bottom: 24, trailing: 24))
        .frame(width: 300)
      }
    }

    /// 出して、「次へ」が押されるまで待つ。幕は削除の確認ダイアログと同じ。
    static func show(overlay: AppOverlay) async {
      await withCheckedContinuation { continuation in
        overlay.present(dismissible: false, barrier: Color(argb: 0x6614_1923)) { dismiss in
          MobileTrackingPromptDialog {
            dismiss()
            continuation.resume()
          }
        }
      }
    }
  }
#endif
