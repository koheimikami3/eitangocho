#if os(iOS)
  import SwiftUI

  /// iOS 版の設定画面の Pro の欄(Flutter 版の MobileProSection)。設定のトップの先頭に置く。
  ///
  /// 未購入のときは Pro 版で手に入るものの一覧と購入ボタン(MobileProOffer)、購入後は 1 行のお礼
  /// (MobileProPurchasedRow)に縮める。欄の上の「Pro」の見出しは置かない(カードの見出しで分かるため)。
  /// 課金を扱えない環境では、呼び出し側が欄ごと出さない。
  struct MobileProSection: View {
    let purchase: PurchaseModel

    var body: some View {
      MobileSettingsSection(title: nil) {
        if purchase.proUnlocked {
          MobileProPurchasedRow()
        } else {
          MobileProOffer(purchase: purchase, source: .settings)
        }
      }
    }
  }
#endif
