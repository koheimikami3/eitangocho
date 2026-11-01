#if os(iOS)
  import GoogleMobileAds
  import SwiftUI
  import UIKit

  /// タブバーのすぐ上に常設するアンカー型アダプティブバナー(Flutter 版の MobileBannerAd)。
  ///
  /// Flutter 版はタブバーと一体の帯(地・ぼかし・影を共有)だったが、タブバーが標準の TabView
  /// (iOS 26 以降は Liquid Glass)になって一体にできないため、タブバーとは別にする。左右に余白を取った
  /// カード(`MobileAdCard`。クイズ結果のレクタングルと同じ見た目)に載せ、タブバーとの間も空ける。
  /// 押せる部品のすぐ隣に広告を置くと誤タップ(無効なクリック)を招くため(2026-11-01 のユーザーの判断。
  /// それまでは全幅の帯だった)。
  ///
  /// 固定の 320x50 ではなく、カードの内側の幅に合わせたサイズを Google に決めさせる(縮めても
  /// アダプティブのままにする)。高さは読み込みが終わるまで分からないため、確定したら `onHeightChange` で
  /// カードとタブバーとの間を足した高さを返し、シェルがコンテンツの下余白に足す。
  ///
  /// 隠す条件(`visible` が false のとき・キーボードが出ている間)では枠ごと外す。キーボードの間は
  /// タブバーごとキーボードの下に隠れるので、見えない広告のインプレッションを避ける。外しても広告は
  /// 捨てずに持ち(`loader`)、隠す条件が解けたらその場で出し直す。捨てて読み込み直すと、シートを閉じる
  /// たびに 0.5〜1 秒バナーが無くなり、出た瞬間に一覧の下端が持ち上がるため。
  struct MobileBannerAd: View {
    /// シートや押して進む画面に覆われていない・クイズ結果でない(TabBarBannerVisibility)か。
    let visible: Bool
    /// 帯の高さ(広告 + 上下の余白)。出ていない間は 0。
    let onHeightChange: (CGFloat) -> Void

    @State private var keyboardShown = false
    /// 表示する広告。隠している間も持ち続ける。
    @State private var loader = MobileAdLoader()

    /// 広告とカードの縁の間。
    private static let cardInset: CGFloat = 6
    /// 画面の左右の端とカードの間。
    private static let horizontalMargin: CGFloat = 16
    /// カードとタブバーの間。
    private static let tabBarGap: CGFloat = 8

    var body: some View {
      Group {
        if visible, !keyboardShown {
          MobileAdSlot(
            adUnitId: AdUnitIds.tabBarBanner,
            // 常設のこの枠だけ通常サイズのアンカー型アダプティブにする(大型は常に居座るには大きすぎる)。
            resolveSize: { .currentOrientationAnchoredAdaptive(width: $0.rounded(.down)) },
            horizontalInset: Self.horizontalMargin + Self.cardInset,
            onHeightChange: { height in
              onHeightChange(height.map { $0 + Self.cardInset * 2 + Self.tabBarGap } ?? 0)
            },
            loader: loader
          ) { adView in
            MobileAdCard(adView: adView, inset: Self.cardInset)
              .padding(.horizontal, Self.horizontalMargin)
              .padding(.bottom, Self.tabBarGap)
          }
        } else {
          // 消えている間は下余白も返す。
          Color.clear.frame(height: 0)
            .onAppear { onHeightChange(0) }
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
        keyboardShown = true
      }
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
        keyboardShown = false
      }
    }
  }
#endif
