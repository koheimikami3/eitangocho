#if os(iOS)
  import SwiftUI

  /// 設定画面「Pro」の復元行(Flutter 版の MobileProRestoreRow)。
  ///
  /// 機種変更・再インストールで購入が消えた人のための導線なので、購入済みに見えているかどうかに関わらず
  /// 押せる(購入済みのときだけ隠すと、まさに必要な人が使えない)。
  struct MobileProRestoreRow: View {
    let purchase: PurchaseModel

    @Environment(\.palette) private var palette

    var body: some View {
      // 押したときの見た目は変えない(Flutter 版は GestureDetector)。
      // 購入の実行中も押させない(PurchaseModel.isBusy)。
      MobilePressable(style: .row, action: purchase.isBusy ? nil : { Task { await purchase.restore() } }) {
        HStack(spacing: 0) {
          AppText(.restorePurchases, style: AppTextStyle(size: 13))
            // デザインはここに --accText を当てている。その対応色が accentOnSoft で、13pt の文字でも
            // 4.5:1 を満たす(accent のままだとカード地に対して足りない)。
            .foregroundStyle(purchase.isBusy ? palette.textAlpha(40) : palette.accentOnSoft)
            .frame(maxWidth: .infinity, alignment: .leading)
          if let status = purchase.restoreStatus {
            AppText(Self.label(status), style: AppTextStyle(size: 11))
              .foregroundStyle(palette.textAlpha(45))
          }
        }
        // 上下 13 は他のリンク行(MobileSettingsLinkRow)と同じ。
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
      }
    }

    private static func label(_ status: RestoreStatus) -> String {
      switch status {
      case .checking: String(localized: .restoreChecking)
      case .restored: String(localized: .restoreDone)
      case .notFound: String(localized: .restoreNotFound)
      case .failed: String(localized: .restoreFailed)
      }
    }
  }
#endif
