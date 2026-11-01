#if os(iOS)
  import SwiftUI

  /// iOS 版の押し出した画面のヘッダ(戻るボタン + 中央のタイトル。Flutter 版の MobilePushHeader)。
  ///
  /// 戻るは Flutter 版の「‹ 設定」の文字をやめ、ヘッダ右上の 🔍 と同じ丸いガラスのボタンにする
  /// (2026-11-01 のユーザーの要望。iOS 26 の標準の戻るボタンと同じく ‹ だけを出す)。
  struct MobilePushHeader: View {
    let title: String
    /// 戻り先の画面名(戻るボタンの読み上げに使う)。
    let backLabel: String

    @Environment(\.palette) private var palette
    @Environment(\.appOverlay) private var overlay

    var body: some View {
      // タイトルは画面の中央に置く。戻るボタンのラベルの長さで中央がずれないよう、横に並べず重ねる。
      ZStack(alignment: .leading) {
        AppText(title, style: AppTextStyle(size: 16, weight: .w600))
          .foregroundStyle(palette.text)
          .frame(maxWidth: .infinity)
        MobileGlassCircleButton(systemName: "chevron.left", accessibilityLabel: backLabel) { overlay?.pop() }
      }
      .frame(minHeight: MobileGlassCircleButton.diameter)
      // 左右の余白はタブのヘッダ(MobileHeader)と同じにし、丸いボタンの位置を揃える。
      .padding(
        EdgeInsets(
          top: 0, leading: AppDimensions.mobilePadding, bottom: 8, trailing: AppDimensions.mobilePadding))
      .background {
        Rectangle()
          .fill(palette.surface)
          .appShadows(palette.headerShadow, in: Rectangle(), scale: 1)
          // 上のセーフエリア(ステータスバーの裏)まで面の色で埋める(Flutter 版の SafeArea の外の Container)。
          .ignoresSafeArea(edges: .top)
      }
    }
  }
#endif
