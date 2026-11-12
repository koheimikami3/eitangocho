#if os(iOS)
  import GoogleMobileAds
  import SwiftUI

  /// 登録シート・編集シートの最下部に固定するバナー(Flutter 版の MobileSheetBannerAd)。
  ///
  /// `MobileSheet` の `footer` に渡す。スクロール領域の外側に置くのはデザインどおり。下の余白だけ
  /// タブバー上のバナーより厚い(36pt)のは、シートの下端がホームインジケータと画面の丸い角に接するため
  /// (22pt では広告の枠の下の角が画面の角にかかって欠けた)。
  ///
  /// **キーボードが出ている間は出さない**。シートはキーボードの分だけ持ち上がるので、そのまま置くと
  /// 入力欄とキーボードの間に広告が挟まる。誤タップは AdMob のポリシー違反(無効なクリック)に
  /// なりうるため、隠す方を取る。ただし広告は捨てず、キーボードを閉じたらその場で出し直す
  /// (捨てて読み込み直すと、閉じて次の欄へ指を伸ばす頃に広告が割り込むため)。
  ///
  /// 遅れて割り込まないよう、広告は一覧の画面にいる間に先読みしておき(`MobileAdPreloader`)、
  /// 読み込みが間に合わなかったときも広告の大きさの枠を先に空けておく。
  struct MobileSheetBannerAd: View {
    @Environment(\.palette) private var palette
    @Environment(\.mobileSheetLayout) private var layout
    @Environment(\.sheetBannerPreloader) private var preloader

    /// このシートで出す広告。シートを開いたときに先読みから受け取り、シートを閉じるまで持つ。
    @State private var loader: MobileAdLoader?

    /// 余白(デザインの padding:8px 12px 22px から、下だけ画面の角にかからない分を足した)。
    private static let topPadding: CGFloat = 8
    private static let bottomPadding: CGFloat = 36
    nonisolated private static let horizontalPadding: CGFloat = 12

    /// シートの幅から要求する広告サイズ。先読み(`MobileAdPreloader`)も同じものを使う。
    /// こちらは大型のまま。シートは開いている間だけのもので、下半分は元から余っているため
    /// 常設のバナーほど圧迫しない。
    nonisolated static func adSize(sheetWidth: CGFloat) -> AdSize? {
      largeAnchoredAdaptiveBanner(width: (sheetWidth - horizontalPadding * 2).rounded(.down))
    }

    var body: some View {
      Group {
        if let loader, layout.keyboardHeight == 0 {
          slot(loader)
        } else {
          // 中身の無い Group には onAppear が届かないので、高さ 0 の面を置く。
          Color.clear.frame(height: 0)
        }
      }
      .onAppear {
        if loader == nil { loader = preloader?.take() ?? MobileAdLoader() }
      }
    }

    private func slot(_ loader: MobileAdLoader) -> some View {
      MobileAdSlot(
        adUnitId: AdUnitIds.sheetBanner,
        resolveSize: { largeAnchoredAdaptiveBanner(width: $0.rounded(.down)) },
        horizontalInset: Self.horizontalPadding, loader: loader, reservesSpace: true
      ) { adView in
        adView
          .padding(
            EdgeInsets(
              top: Self.topPadding, leading: Self.horizontalPadding, bottom: Self.bottomPadding,
              trailing: Self.horizontalPadding)
          )
          .frame(maxWidth: .infinity)
          // シートと同じ地の色にし(灰色の帯にすると別の部品が挟まったように見えるため)、
          // 上端は一覧の下のバナー(MobileBannerAd)と同じ線で入力欄と分ける。シートの見出しの下の線と対になる。
          .background(palette.surface)
          .appShadows(palette.bottomBarShadow, in: Rectangle(), scale: 1)
      }
    }
  }
#endif
