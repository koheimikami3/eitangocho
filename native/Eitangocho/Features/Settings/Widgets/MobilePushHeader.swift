#if os(iOS)
  import SwiftUI

  /// iOS 版の押し出した画面のヘッダ(戻るボタン + 中央のタイトル。Flutter 版の MobilePushHeader)。
  ///
  /// 戻るは押せる「文字」なので、面の青(`accent`)ではなく濃い方の `accentOnSoft` を使う
  /// (1.6.0 の刷新案 A で設定画面の青を 2 値に統一)。
  struct MobilePushHeader: View {
    let title: String
    /// 戻り先の画面名(iOS の慣習どおり「‹ 設定」のように出す)。
    let backLabel: String

    @Environment(\.palette) private var palette
    @Environment(\.appOverlay) private var overlay

    var body: some View {
      // タイトルは画面の中央に置く。戻るボタンのラベルの長さで中央がずれないよう、横に並べず重ねる。
      ZStack(alignment: .leading) {
        AppText(title, style: AppTextStyle(size: 16, weight: .w600))
          .foregroundStyle(palette.text)
          .frame(maxWidth: .infinity)
        HStack(spacing: 2) {
          AppText("‹", style: AppTextStyle(size: 20, height: 1))
          AppText(backLabel, style: AppTextStyle(size: 16))
        }
        .foregroundStyle(palette.accentOnSoft)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture { overlay?.pop() }
      }
      .frame(minHeight: 44)
      .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
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
