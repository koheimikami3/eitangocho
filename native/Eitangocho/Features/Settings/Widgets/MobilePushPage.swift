#if os(iOS)
  import SwiftUI

  /// iOS 版の押して進む画面の枠(上にヘッダ、下に中身。Flutter 版の Scaffold + MobilePushHeader)。
  /// 出し方は `AppOverlay.push`。
  struct MobilePushPage<Content: View>: View {
    let title: String
    let backLabel: String
    @ViewBuilder let content: () -> Content

    @Environment(\.palette) private var palette

    var body: some View {
      VStack(spacing: 0) {
        MobilePushHeader(title: title, backLabel: backLabel)
          // ヘッダの影を中身の上に落とす。
          .zIndex(1)
        content()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      // タブバーのシェルと同じく、大きい機種でもデザインの幅に収める。
      .frame(maxWidth: AppDimensions.mobileContentMaxWidth)
      .frame(maxWidth: .infinity)
      .background(palette.background)
    }
  }
#endif
