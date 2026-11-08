#if os(macOS)
  import SwiftUI

  /// ツールバーの検索欄(Flutter 版の ToolbarSearchField)。入力を MainShellModel に流す。
  ///
  /// 地は macOS 26 以降は Liquid Glass、それより前は他の入力欄(LabeledTextField)と同じ入力欄の地 + 枠線(Surface)。
  /// フォーカス時も見た目は変えない(macOS のフォーカスリングも出さない)。
  struct ToolbarSearchField: View {
    let shell: MainShellModel

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @FocusState private var focused: Bool

    private static let textStyle = AppTextStyle.input(size: 13)

    var body: some View {
      let hint = String(localized: .search)
      let shape = RoundedRectangle(cornerRadius: px(7))
      HStack(spacing: 0) {
        // 先頭に検索アイコンを置く。
        MaterialIconView(.search, size: 17, color: colors.textTertiary)
          .padding(.leading, px(8))
        TextField(
          "", text: Binding(get: { shell.searchQuery }, set: { shell.updateSearchQuery($0) }),
          prompt: Text(verbatim: hint).foregroundStyle(colors.materialOnSurfaceVariant)
        )
        .textFieldStyle(.plain)
        .font(Self.textStyle.font(px))
        .tracking(px(Self.textStyle.letterSpacing))
        .foregroundStyle(colors.materialOnSurface)
        .focused($focused)
        .focusEffectDisabled()
        .fixedSize(horizontal: false, vertical: true)
        .padding(EdgeInsets(top: 0, leading: px(5), bottom: 0, trailing: px(10)))
      }
      .frame(width: px(200), height: height(hint: hint))
      .modifier(Surface(shape: shape))
      .onChange(of: shell.searchFocusRequest) { focused = true }
    }

    /// 欄の高さ。macOS 26 以降はツールバーのほかのガラスの部品と揃える。
    /// それより前は Flutter の入力欄と同じく、入力とヒントの行の高さの大きい方 + 上下の余白 10
    /// (ヒントが和文なら和文の行の高さになる)。
    private func height(hint: String) -> CGFloat {
      if #available(macOS 26, *) { return px(AppDimensions.toolbarControlHeight) }
      return AppTextField.height(style: Self.textStyle, texts: [hint, shell.searchQuery], verticalPadding: 10, scale: px)
    }

    /// 欄の地。macOS 26 以降はツールバーのほかの部品と同じ無色の Liquid Glass のカプセル(iOS の検索欄と同じ)。
    /// それより前は入力欄の地 + 枠線の角丸。
    private struct Surface: ViewModifier {
      let shape: RoundedRectangle

      @Environment(\.colors) private var colors
      @Environment(\.uiScale) private var px

      func body(content: Content) -> some View {
        if #available(macOS 26, *) {
          content.glassEffect(.regular.interactive(), in: .capsule)
        } else {
          content
            .background(shape.fill(colors.inputFill))
            .overlay(shape.strokeBorder(colors.inputBorder, lineWidth: px(1)))
        }
      }
    }
  }
#endif
