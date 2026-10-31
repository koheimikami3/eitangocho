#if os(iOS)
  import GoogleMobileAds
  import SwiftUI
  import UIKit

  /// タブバーのすぐ上に常設するアンカー型アダプティブバナー(Flutter 版の MobileBannerAd)。
  ///
  /// Flutter 版はタブバーと一体の帯(地・ぼかし・影を共有)だったが、タブバーが標準の TabView
  /// (iOS 26 以降は Liquid Glass)になって一体にできないため、タブバーとは別の全幅の帯にする
  /// (面の色の地・上端に影。Phase 6 の案 A)。
  ///
  /// 固定の 320x50 ではなく端末幅に合わせたサイズを Google に決めさせる。高さは読み込みが終わるまで
  /// 分からないため、確定したら `onHeightChange` で帯の高さを返し、シェルがコンテンツの下余白に足す。
  ///
  /// 隠す条件(`visible` が false のとき・キーボードが出ている間)では枠ごと外す(広告も破棄する)。
  /// キーボードの間はタブバーごとキーボードの下に隠れるので、見えない広告のインプレッションを避ける。
  struct MobileBannerAd: View {
    /// シートや押して進む画面に覆われていない・クイズ結果でない(TabBarBannerVisibility)か。
    let visible: Bool
    /// 帯の高さ(広告 + 上下の余白)。出ていない間は 0。
    let onHeightChange: (CGFloat) -> Void

    @Environment(\.palette) private var palette
    @State private var keyboardShown = false

    /// デザインの余白(padding:8px 12px)。高さの計算にも使う。
    private static let verticalPadding: CGFloat = 8
    private static let horizontalPadding: CGFloat = 12

    var body: some View {
      Group {
        if visible, !keyboardShown {
          MobileAdSlot(
            adUnitId: AdUnitIds.tabBarBanner,
            // 常設のこの枠だけ通常サイズのアンカー型アダプティブにする(大型は常に居座るには大きすぎる)。
            resolveSize: { .currentOrientationAnchoredAdaptive(width: $0.rounded(.down)) },
            horizontalInset: Self.horizontalPadding,
            onHeightChange: { height in
              onHeightChange(height.map { $0 + Self.verticalPadding * 2 } ?? 0)
            }
          ) { adView in
            let shape = Rectangle()
            adView
              .padding(.vertical, Self.verticalPadding)
              .padding(.horizontal, Self.horizontalPadding)
              .frame(maxWidth: .infinity)
              .background(palette.surface)
              .appShadows(palette.bottomBarShadow, in: shape, scale: 1)
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
