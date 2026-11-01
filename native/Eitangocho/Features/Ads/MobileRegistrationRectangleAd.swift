#if os(iOS)
  import GoogleMobileAds
  import SwiftUI

  /// 登録シートの単語の入力・読み込み中に、「スキップして手動で入力する」の下に出す 300x250 レクタングル。
  ///
  /// この段階は中身が少なく下半分が空いているので、バナーより単価の高いレクタングルを置く
  /// (2026-11-01 のユーザーの要望)。この段階では下端のバナーは出さない(1 画面に広告を 2 つ並べない)。
  /// 自動入力の読み込み中も同じ広告を出し続け、フォームに進んだら下端のバナーに替わる。
  ///
  /// 遅れて割り込まないよう、一覧の画面にいる間に先読みしておき(`MobileAdPreloader`)、読み込み中も
  /// 広告の大きさの枠を空けておく。キーボードが出ている間は隠す(そのままだとキーボードのすぐ上に
  /// 広告がはみ出す)が、捨てずにキーボードを閉じたらその場で出し直す。
  struct MobileRegistrationRectangleAd: View {
    @Environment(\.palette) private var palette
    @Environment(\.mobileSheetLayout) private var layout
    @Environment(\.registrationRectanglePreloader) private var preloader

    /// このシートで出す広告。シートを開いたときに先読みから受け取り、シートを閉じるまで持つ。
    @State private var loader: MobileAdLoader?

    /// 上の「スキップして手動で入力する」との間。押し間違えて広告に触れないよう広めに空ける。
    private static let topPadding: CGFloat = 24

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
        adUnitId: AdUnitIds.registrationRectangle, resolveSize: MobileQuizRectangleAd.adSize(width:), loader: loader,
        reservesSpace: true
      ) { adView in
        let shape = RoundedRectangle(cornerRadius: AppDimensions.mobileCardRadius)
        adView
          .background(palette.surface)
          .clipShape(shape)
          .appShadows(palette.elevation, in: shape, scale: 1)
          .padding(.top, Self.topPadding)
      }
    }
  }
#endif
