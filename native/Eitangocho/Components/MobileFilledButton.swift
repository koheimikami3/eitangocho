#if os(iOS)
  import SwiftUI

  /// iOS 版の主ボタン(アクセント色のグラデーション + 白文字。Flutter 版の MobileFilledButton)。
  ///
  /// 寸法はボタンごとにデザインの値が違うため、既定値はクイズ・結果画面の全幅ボタン
  /// (15px・上下 14・角丸 12)にして他は呼び出し側で上書きする。
  struct MobileFilledButton: View {
    let label: String
    var fontSize: CGFloat = 15
    var weight: AppTextStyle.Weight = .w600
    var padding = EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
    var cornerRadius: CGFloat = 12
    /// 横いっぱいに広げるか(Flutter で幅いっぱいの親に置かれたとき)。
    var expands = false
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      MobilePressable(action: action) {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        AppText(label, style: AppTextStyle(size: fontSize, weight: weight))
          .foregroundStyle(.white)
          // 全幅で置かれたときも中央に寄せる。
          .multilineTextAlignment(.center)
          .frame(maxWidth: expands ? .infinity : nil)
          .padding(padding)
          .background(shape.fill(palette.buttonFill))
          .appShadows(palette.buttonShadow, in: shape, scale: 1)
      }
    }
  }
#endif
