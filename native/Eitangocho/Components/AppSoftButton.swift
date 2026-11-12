#if os(macOS)
  import SwiftUI

  /// macOS 版の淡いボタン(淡い色の地 + 同じ系統の色の文字。枠・影なし)。iOS の MobileSoftButton と同じ作り。
  ///
  /// 主ボタン(AppFilledButton)と並べる副ボタン(クイズの「忘れていた」・結果の「続ける」「条件を変える」)。
  /// 寸法はクイズで並べる AppFilledButton(上下 11・角丸 9)にそろえる。ホバーでは同じ色を薄く重ねて一段濃くする。
  struct AppSoftButton: View {
    let label: String
    let color: Color
    let background: Color
    let action: () -> Void

    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: px(9))
      AppText(label, style: AppTextStyle(size: 14, weight: .w600, height: 1.4))
        .foregroundStyle(color)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, px(14))
        .padding(.vertical, px(11))
        .background {
          shape.fill(background)
            .overlay(shape.fill(color.opacity(isHovered ? 0.08 : 0)))
        }
        .hoverTap($isHovered, in: shape, action: action)
        .pointerStyle(.link)
    }
  }
#endif
