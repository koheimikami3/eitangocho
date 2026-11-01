#if os(iOS)
  import SwiftUI

  /// iOS 版フォームの項目名。`autoFilled` のときは脇に「自動入力」バッジを出す(Flutter 版の MobileFieldLabel)。
  ///
  /// 入力欄(MobileLabeledField)と品詞チップの見出しで同じ見た目にするため共通化。
  struct MobileFieldLabel: View {
    let label: String
    var autoFilled = false

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 6) {
        AppText(label, style: AppTextStyle(size: 11, weight: .w700))
          .foregroundStyle(palette.textAlpha(60))
        if autoFilled {
          MobileAutoFillBadge()
        }
      }
    }
  }
#endif
