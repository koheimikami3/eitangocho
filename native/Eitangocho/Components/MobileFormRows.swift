#if os(iOS)
  import SwiftUI

  /// iOS 版フォームの項目を縦に並べる(単語の登録・編集シート。Flutter 版の MobileFormRows)。
  ///
  /// 2.2.0 で入力欄に枠を付けたので項目の間の線はやめ、余白だけで区切る(ユーザー判断)。
  struct MobileFormRows<Content: View>: View {
    @ViewBuilder let content: () -> Content

    /// 項目の上下の余白。項目の間は 2 倍の 24pt になる(デザインの 14 = 28pt は間延びするので詰めた。
    /// 見出しと欄の間の 7pt の 3 倍以上あれば、見出しがどの欄のものかは迷わない)。
    private static var verticalPadding: CGFloat { 12 }

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        Group(subviews: content()) { subviews in
          ForEach(subviews) { subview in
            subview
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.vertical, Self.verticalPadding)
          }
        }
      }
    }
  }
#endif
