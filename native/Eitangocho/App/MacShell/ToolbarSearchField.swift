#if os(macOS)
  import SwiftUI

  /// ツールバーの検索欄(Flutter 版の ToolbarSearchField)。入力を MainShellModel に流す。
  ///
  /// 他の入力欄(LabeledTextField)と同じく入力欄の地 + 枠線にする。
  /// フォーカス時も枠の色は変えない(macOS のフォーカスリングも出さない)。
  struct ToolbarSearchField: View {
    let shell: MainShellModel

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @FocusState private var focused: Bool

    /// Flutter 版の TextField は bodyLarge(行の高さ 1.5・字間 0.5)を継承する。
    private static let textStyle = AppTextStyle(size: 13, height: 1.5, letterSpacing: 0.5)

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
      // Flutter の入力欄は、入力とヒントの行の高さの大きい方 + 上下の余白 10 の高さになる
      // (ヒントが和文なら和文の行の高さになる)。
      .frame(width: px(200), height: AppTextField.height(style: Self.textStyle, texts: [hint, shell.searchQuery], verticalPadding: 10, scale: px))
      .background(shape.fill(colors.inputFill))
      .overlay(shape.strokeBorder(colors.inputBorder, lineWidth: px(1)))
      .onChange(of: shell.searchFocusRequest) { focused = true }
    }
  }
#endif
