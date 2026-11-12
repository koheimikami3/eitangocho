#if os(iOS)
  import SwiftUI

  /// iOS 版の設定のシート(ヘッダ右上の ⚙・クイズ結果の Pro への導線から開く。試作)。
  ///
  /// 設定はタブではなく、一時的に開いて閉じれば元の画面に戻るものなのでシートにする(右から押し出す画面だと
  /// 「今の画面の奥へ進む」意味になり、学習中などの奥に設定があるわけではないため)。
  /// 下の階層(外観モード・テーマカラーなど)はシートの中で右から押し出す(AppOverlay.push を、この中の
  /// MobilePushLayer が描く)。押し出した画面はシートのヘッダごと覆い、‹ で戻る。
  struct MobileSettingsSheet: View {
    let session: AppModel.Session
    let settings: SettingsStore
    let dismiss: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.appOverlay) private var overlay

    var body: some View {
      MobileSheet(
        title: String(localized: .navSettings), leftLabel: String(localized: .close), onLeft: dismiss,
        scrollableBody: false, reachesTop: true, headerBackground: palette.background
      ) {
        // 設定のカードは白い面なので、地は一覧の画面と同じ薄いグレーにする(シートの面の白のままだとカードが溶ける)。
        SettingsViewMobile(session: session, settings: settings)
          .background(palette.background)
      }
      .overlay {
        if let overlay {
          MobilePushLayer(overlay: overlay)
        }
      }
      .clipShape(UnevenRoundedRectangle(topLeadingRadius: 18, topTrailingRadius: 18))
    }
  }
#endif
