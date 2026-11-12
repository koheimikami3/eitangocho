#if os(iOS)
  import SwiftUI

  /// iOS 版の押して進む画面の枠(上にヘッダ、下に中身)。出し方は `AppOverlay.push`。
  ///
  /// 押し出す画面は設定のシートの中にだけ出るので、ヘッダはシートのヘッダ(つまみ・左の丸いボタン・中央のタイトル)を
  /// そのまま使い、左を ‹ にする(設定のトップと同じ位置・同じ見た目のまま進んで見え、下へ引けばシートごと閉じる)。
  struct MobilePushPage<Content: View>: View {
    let title: String
    /// 戻り先の画面名(戻るボタンの読み上げに使う)。
    let backLabel: String
    @ViewBuilder let content: () -> Content

    @Environment(\.palette) private var palette
    @Environment(\.appOverlay) private var overlay

    var body: some View {
      VStack(spacing: 0) {
        // 地は設定のシートのヘッダと同じく、中身と同じグレーにする。
        MobileSheetHeader(
          title: title, leftLabel: backLabel, leftIcon: .back, onLeft: { overlay?.pop() },
          background: palette.background)
        content()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      // 大きい機種でもデザインの幅に収める。
      .frame(maxWidth: AppDimensions.mobileContentMaxWidth)
      .frame(maxWidth: .infinity)
      .background(palette.background)
    }
  }
#endif
