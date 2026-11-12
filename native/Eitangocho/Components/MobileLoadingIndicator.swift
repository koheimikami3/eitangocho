#if os(iOS)
  import SwiftUI

  /// iOS 版の読み込み中表示。領域の中央に MobileSpinner を出す(Flutter 版の MobileLoadingIndicator)。
  struct MobileLoadingIndicator: View {
    var body: some View {
      MobileSpinner()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
#endif
