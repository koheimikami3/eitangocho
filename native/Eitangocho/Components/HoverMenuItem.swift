import SwiftUI

/// ポップアップメニューの項目(角丸 5、ホバーで背景色 + 白文字)。Flutter 版の HoverMenuItem。
/// 単語の右クリックメニューと並び替えメニューで共有する。
struct HoverMenuItem: View {
  let label: String
  /// 文字色。nil なら本文色(AppColors.textPrimary)。
  var color: Color?
  /// ホバー中の地。nil ならアクセント色。
  var hoverColor: Color?
  /// 選択中の印。nil ならチェック欄ごと出さない(右クリックメニュー)。
  /// true / false のときは欄を確保し、ラベルの頭を項目間で揃える。
  var checked: Bool?
  let action: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  var body: some View {
    let foreground = isHovered ? Color.white : color ?? colors.textPrimary
    let shape = RoundedRectangle(cornerRadius: px(5))
    HStack(spacing: 0) {
      if let checked {
        ZStack {
          if checked { MaterialIconView(.check, size: 14, color: foreground) }
        }
        .frame(width: px(20), alignment: .leading)
      }
      // Flutter 版の PopupMenuItem は labelLarge(w500・字間 0.1)を継承する。
      AppText(label, style: AppTextStyle(size: 13, weight: .w500, letterSpacing: 0.1))
        .foregroundStyle(foreground)
        .lineLimit(1)
    }
    .padding(.horizontal, px(12))
    .padding(.vertical, px(8))
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(shape.fill(isHovered ? hoverColor ?? colors.accent : .clear))
    .hoverTap($isHovered, in: shape, action: action)
  }
}
