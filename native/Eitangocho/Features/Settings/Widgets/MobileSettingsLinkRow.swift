#if os(iOS)
  import SwiftUI

  /// iOS 版の設定の行(ラベル + 右端のシェブロン。押すと別の画面へ進む・処理を始める。Flutter 版の MobileSettingsLinkRow)。
  ///
  /// 選ぶ項目の行は、シェブロンの手前に今の値を出す(開かなくても今の設定が分かるように)。
  /// 値が色のとき(テーマカラー)は、文字の代わりに小さな色の丸を出す。
  struct MobileSettingsLinkRow: View {
    let label: String
    var value: String?
    var valueColor: Color?
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      MobilePressable(style: .row, action: action) { pressed in
        HStack(spacing: 0) {
          AppText(label, style: AppTextStyle(size: 14))
            .foregroundStyle(palette.text)
            // 値より先にラベルの幅を確定させ、値の方を省く(ラベルを折り返させない)。
            .layoutPriority(1)
          Spacer(minLength: 12)
          if let value {
            AppText(value, style: AppTextStyle(size: 13))
              .foregroundStyle(palette.textAlpha(40))
              .lineLimit(1)
            Spacer().frame(width: 8)
          }
          if let valueColor {
            Circle().fill(valueColor).frame(width: 22, height: 22)
            Spacer().frame(width: 8)
          }
          AppText("›", style: AppTextStyle(size: 16, height: 1))
            .foregroundStyle(palette.textAlpha(30))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(pressed ? palette.pressBackground : .clear)
      }
    }
  }
#endif
