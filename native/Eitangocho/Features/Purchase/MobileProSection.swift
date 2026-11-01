#if os(iOS)
  import SwiftUI

  /// iOS 版の設定画面「Pro」の欄(Flutter 版の MobileProSection)。
  ///
  /// カード・区切り線は `MobileSettingsSection` が他のセクションと同じトークンで描くため、ここは行を 2 つ
  /// 渡すだけでよい。課金を扱えない環境では、呼び出し側が欄ごと出さない。
  struct MobileProSection: View {
    let purchase: PurchaseModel

    var body: some View {
      MobileSettingsSection(title: "Pro") {
        MobileProPurchaseRow(purchase: purchase)
        MobileProRestoreRow(purchase: purchase)
      }
    }
  }
#endif
