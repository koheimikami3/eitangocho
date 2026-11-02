#if os(iOS)
  import SwiftUI

  /// iOS 版の設定から押して進む、選ぶ項目の画面の枠(ヘッダ + スクロールする中身)。
  ///
  /// 選んだ時点で保存し、戻るボタンで設定へ戻る(設定のトップと同じく「保存」ボタンは置かない)。
  /// 中身はカード(見出しなしの MobileSettingsSection)と、その下の説明文(MobileSettingsCaption)。
  struct MobileSettingsSubpage<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
      MobilePushPage(title: title, backLabel: String(localized: .navSettings)) {
        ScrollView {
          // カードと説明文の間は 8(MobileSettingsCaption の決まり)。
          VStack(alignment: .leading, spacing: 8) {
            content()
          }
          // 上だけ広めに空け、ヘッダとカードがくっついて見えないようにする。
          .padding(
            EdgeInsets(
              top: 24, leading: AppDimensions.mobilePadding, bottom: AppDimensions.mobilePadding,
              trailing: AppDimensions.mobilePadding))
        }
      }
    }
  }
#endif
