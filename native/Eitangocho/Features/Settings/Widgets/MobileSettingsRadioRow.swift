#if os(iOS)
  import SwiftUI

  /// iOS 版の設定ラジオ行(丸いラジオ + ラベル。Flutter 版の MobileSettingsRadioRow)。行全体がタップ領域。
  struct MobileSettingsRadioRow<Trailing: View>: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    /// 行の右端に置く補助表示(列数のプレビュー等)。
    @ViewBuilder var trailing: () -> Trailing

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 0) {
        ZStack {
          Circle().fill(selected ? palette.accent : .clear)
          Circle().strokeBorder(selected ? palette.accent : palette.checkOffBorder, lineWidth: 1.5)
          if selected {
            Circle().fill(.white).frame(width: 7, height: 7)
          }
        }
        .frame(width: 20, height: 20)
        .animation(.linear(duration: 0.15), value: selected)
        Spacer().frame(width: 10)
        AppText(label, style: AppTextStyle(size: 14))
          .foregroundStyle(palette.text)
          .frame(maxWidth: .infinity, alignment: .leading)
        trailing()
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 13)
      .contentShape(Rectangle())
      .onTapGesture(perform: action)
    }
  }

  extension MobileSettingsRadioRow where Trailing == EmptyView {
    init(label: String, selected: Bool, action: @escaping () -> Void) {
      self.init(label: label, selected: selected, action: action, trailing: { EmptyView() })
    }
  }
#endif
