#if os(iOS)
  import SwiftUI

  /// テーマカラーの画面で鍵の付いた色を押したときの案内。中身は設定画面の Pro の欄(MobileProOffer)と同じで、
  /// 一番下だけ「購入を復元」の代わりに「閉じる」を置く。
  ///
  /// 押してすぐ購入の画面を出すと驚かせるので、一度ここで買うかどうかを選ばせる。色だけでなく広告の非表示も
  /// 同じ買い物で手に入ることを伝えるため、Pro の欄の一覧をそのまま見せる。買えたら閉じる。
  struct MobileThemeColorLockedDialog: View {
    let purchase: PurchaseModel
    let dismiss: () -> Void

    var body: some View {
      AppDialogSurface(cornerRadius: 14) {
        MobileProOffer(purchase: purchase, source: .themeColor, onClose: dismiss)
          // Pro の欄の余白(上 14・左右 14・下は「閉じる」の 10 + 2)はカードの中の詰めた値なので、ダイアログでは
          // 足して上 24・左右 22・下 18 にする(削除の確認と ATT の案内の間くらい)。
          .padding(EdgeInsets(top: 10, leading: 8, bottom: 6, trailing: 8))
          // Pro の欄は設定画面の幅(約 343)を想定しているので、ダイアログの既定の 280 より広げて折り返しを減らす
          // (中身の幅は余白を足す前の 284 のまま)。
          .frame(width: 328)
      }
      .onChange(of: purchase.proUnlocked) { _, unlocked in
        if unlocked { dismiss() }
      }
    }

    /// 出す。幕は削除の確認ダイアログと同じ。
    @MainActor
    static func present(purchase: PurchaseModel, overlay: AppOverlay?) {
      overlay?.present(barrier: Color(argb: 0x6614_1923)) { dismiss in
        MobileThemeColorLockedDialog(purchase: purchase, dismiss: dismiss)
      }
    }
  }
#endif
