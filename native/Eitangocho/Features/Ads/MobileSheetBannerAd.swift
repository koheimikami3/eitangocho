#if os(iOS)
  import GoogleMobileAds
  import SwiftUI

  /// 登録シート・編集シートの最下部に固定するバナー(Flutter 版の MobileSheetBannerAd)。
  ///
  /// `MobileSheet` の `footer` に渡す。スクロール領域の外側に置くのはデザインどおり。下の余白だけ
  /// タブバー上のバナーより厚い(22pt)のは、シートの下端がホームインジケータに接するため。
  ///
  /// **キーボードが出ている間は出さない**。シートはキーボードの分だけ持ち上がるので、そのまま置くと
  /// 入力欄とキーボードの間に広告が挟まる。誤タップは AdMob のポリシー違反(無効なクリック)に
  /// なりうるため、隠す方を取る。
  struct MobileSheetBannerAd: View {
    @Environment(\.palette) private var palette
    @Environment(\.mobileSheetLayout) private var layout

    /// デザインの余白(padding:8px 12px 22px)。
    private static let topPadding: CGFloat = 8
    private static let bottomPadding: CGFloat = 22
    private static let horizontalPadding: CGFloat = 12

    var body: some View {
      if layout.keyboardHeight == 0 {
        MobileAdSlot(
          adUnitId: AdUnitIds.sheetBanner,
          // こちらは大型のまま。シートは開いている間だけのもので、下半分は元から余っているため
          // 常設のバナーほど圧迫しない。
          resolveSize: { largeAnchoredAdaptiveBanner(width: $0.rounded(.down)) },
          horizontalInset: Self.horizontalPadding
        ) { adView in
          adView
            .padding(
              EdgeInsets(
                // 上の線の太さの分は上の余白に足す(Flutter の Container は枠線の幅を内側の余白に足す)。
                top: Self.topPadding + 1, leading: Self.horizontalPadding, bottom: Self.bottomPadding,
                trailing: Self.horizontalPadding)
            )
            .frame(maxWidth: .infinity)
            // シートと同じ地の色にし、上の細い線だけで入力欄と分ける
            // (灰色の帯にすると別の部品が挟まったように見えるため)。
            .background(palette.surface)
            .overlay(alignment: .top) {
              Rectangle().fill(palette.borderAlpha(8)).frame(height: 1)
            }
        }
      }
    }
  }
#endif
