#if os(macOS)
  import SwiftUI

  /// サイドバーの項目 1 行。件数は呼び出し側から渡す(空文字なら出さない)。
  struct SidebarItem: View {
    let label: String
    var count = ""
    let selected: Bool
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: px(6))
      HStack(spacing: 0) {
        // 選択中も太さは変えない。太字にすると字幅が広がって文字列が
        // 伸び、切り替えるたびにずれて見えるため。選択中は背景で示す
        // (macOS 標準のサイドバーと同じ)。
        AppText(label, style: AppTextStyle(size: 13))
          .foregroundStyle(colors.textPrimary)
          .frame(maxWidth: .infinity, alignment: .leading)
        if !count.isEmpty {
          AppText(count, style: AppTextStyle(size: 11))
            .foregroundStyle(colors.textAlpha(38))
        }
      }
      .padding(.horizontal, px(10))
      .padding(.vertical, px(6))
      .background(shape.fill(selected ? colors.sidebarSelected : isHovered ? colors.textAlpha(6) : .clear))
      .hoverTap($isHovered, in: shape, action: action)
      .padding(.horizontal, px(10))
      .padding(.vertical, px(1))
    }
  }
#endif
