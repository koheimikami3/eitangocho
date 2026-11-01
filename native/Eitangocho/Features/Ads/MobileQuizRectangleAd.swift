#if os(iOS)
  import GoogleMobileAds
  import SwiftUI

  /// クイズ結果に出す 300x250 レクタングル(Flutter 版の MobileQuizRectangleAd)。
  ///
  /// 忘れていた単語の一覧とボタンの間に置く(デザインどおり)。ここだけアダプティブではなく固定サイズ
  /// なのは、レクタングルは寸法が決まったフォーマットで、幅に合わせて伸縮しないため。
  ///
  /// デザインの枠は白地・角丸 12 で幅いっぱいに広がっているが、実際の広告は 300pt 固定なので、
  /// 枠を広告幅に合わせて中央に置く(幅いっぱいの枠にすると左右に白帯が残る)。
  ///
  /// 広告の下には Pro への導線(`MobileProLink`)を添える。装飾の中に置くので、広告が出ていないとき・
  /// Pro を購入済みのときは導線も出ない。
  ///
  /// 結果を開いてから読み込むと遅れて出て、下の「続ける」などのボタンを押し下げるので、出題中に
  /// 先読みしておいたもの(`MobileAdPreloader`)を受け取って出す。
  struct MobileQuizRectangleAd: View {
    /// Pro への導線を押したとき(設定のタブへ移る)。
    let onOpenPro: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.quizRectanglePreloader) private var preloader

    /// この結果の画面で出す広告。開いたときに先読みから受け取る。
    @State private var loader: MobileAdLoader?

    /// 要求する広告サイズ(幅に関わらず 300x250)。先読みも同じものを使う。
    nonisolated static func adSize(width: CGFloat) -> AdSize? { AdSizeMediumRectangle }

    var body: some View {
      Group {
        if let loader {
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
      MobileAdSlot(adUnitId: AdUnitIds.quizRectangle, resolveSize: Self.adSize(width:), loader: loader) { adView in
        let shape = RoundedRectangle(cornerRadius: AppDimensions.mobileCardRadius)
        // 上の余白はここで持つ。広告が無いときに空白だけが残らないよう、呼び出し側(クイズ結果)には
        // 隙間を持たせない。
        VStack(spacing: 0) {
          adView
            .background(palette.surface)
            .clipShape(shape)
            .appShadows(palette.elevation, in: shape, scale: 1)
          // 導線は広告の枠の外に、間隔を空けて置く。広告の一部に見えたり、広告を誤タップさせたり
          // すると AdMob のポリシー違反(無効なクリック)になりうるため。
          Spacer().frame(height: 6)
          MobileProLink(action: onOpenPro)
        }
        .padding(.top, 16)
      }
    }
  }
#endif
