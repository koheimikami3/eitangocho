#if os(iOS)
  import SwiftUI

  /// 設定画面の Pro の欄への小さな文字リンク(Flutter 版の MobileProLink)。
  ///
  /// 置くのはクイズ結果の広告の下だけ。広告を見たその場で「消せる」と分かる文脈で、押しても作業を中断させない
  /// ため。タブバー上のバナーは横に余白が無く、登録・編集シートは閉じると入力が失われるので置かない。
  ///
  /// 設定のタブは選ばれるたびに先頭から表示する(SettingsViewMobile)ので、タブを切り替えるだけで
  /// 先頭の Pro の欄が見える。
  struct MobileProLink: View {
    let action: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.analytics) private var analytics

    var body: some View {
      MobilePressable(style: .text) {
        analytics.logProLinkTapped()
        action()
      } content: {
        // 末尾の › もリンクの印。前はノーブレークスペースにして、› だけが次の行に送られないようにする。
        // 押せることは末尾の › で示す。青字のリンクにすると広告の下で目立ちすぎるため、本文と同じ色にする。
        AppText(String(localized: .proLink) + "\u{00a0}›", style: AppTextStyle(size: 13))
          .foregroundStyle(palette.text)
          .multilineTextAlignment(.center)
          // 文字だけでは押しにくいので、上下に余白を足してタップ領域を広げる。
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
      }
    }
  }
#endif
