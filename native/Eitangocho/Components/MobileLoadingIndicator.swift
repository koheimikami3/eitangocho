#if os(iOS)
  import SwiftUI

  /// iOS 版の読み込み中表示。領域の中央にアクセント色の小さなスピナーを出す(Flutter 版の MobileLoadingIndicator)。
  ///
  /// 寸法と配色は単語登録シートの辞書取得中の表示と揃える。
  struct MobileLoadingIndicator: View {
    @Environment(\.palette) private var palette

    var body: some View {
      CircularProgress(color: palette.accent, size: 28, lineWidth: 3, trackColor: palette.borderAlpha(10))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
#endif
