#if os(iOS)
  import SwiftUI

  /// iOS 版ヘッダの検索欄(Flutter 版の MobileSearchField)と、閉じる「キャンセル」。
  ///
  /// ヘッダの 🔍 で開く(MainShellModel.openSearch)。枠線は引かず、内側の影で沈めた面に置く。
  struct MobileSearchField: View {
    let shell: MainShellModel

    @Environment(\.palette) private var palette
    @Environment(\.textScale) private var textScale
    @FocusState private var focused: Bool

    /// Flutter の TextField は bodyLarge(行の高さ 1.5・字間 0.5)を継承する。
    private static var textStyle: AppTextStyle { .input(size: 15) }
    private static var iconSize: CGFloat { 20 }

    var body: some View {
      let hint = String(localized: .search)
      HStack(spacing: 10) {
        MobileWell(color: palette.wellBackground, shadows: palette.wellShadow, cornerRadius: 10) {
          HStack(spacing: 0) {
            // 先頭に検索アイコンを置く。色はヒントと揃え、入力の邪魔をしない。
            MaterialIconView(.search, size: Self.iconSize, color: palette.textAlpha(30))
              .padding(.leading, 10)
            TextField(
              "", text: Binding(get: { shell.searchQuery }, set: { shell.updateSearchQuery($0) }),
              prompt: Text(verbatim: hint).foregroundStyle(palette.textAlpha(30))
            )
            .font(Self.textStyle.font(.none, textScale: textScale))
            .tracking(Self.textStyle.letterSpacing)
            .foregroundStyle(palette.text)
            .tint(palette.accent)
            // 検索は英単語だけが対象なので英字に固定し、途中の綴りを補正させない(登録の英単語欄と同じ)。
            .keyboardType(.asciiCapable)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.search)
            .focused($focused)
            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 12))
          }
          .frame(
            minHeight: max(
              AppTextField.height(
                style: Self.textStyle, texts: [hint, shell.searchQuery], verticalPadding: 9, scale: .none,
                textScale: textScale),
              Self.iconSize + 9 * 2))
        }
        MobilePressable(style: .text, action: shell.cancelSearch) {
          AppText(.cancel, style: AppTextStyle(size: 15))
            .foregroundStyle(palette.accentOnSoft)
            .padding(.vertical, 8)
        }
      }
      // 🔍 で開いた直後(検索語が空)と、開いている間に 🔍 を押し直したときにフォーカスを当てる。
      // 検索語が残ったまま画面に戻ってきたときはキーボードを出さない。
      .onAppear { if shell.searchQuery.isEmpty { focused = true } }
      .onChange(of: shell.searchFocusRequest) { focused = true }
      .onChange(of: focused) { _, isFocused in
        if !isFocused { shell.searchFocusLost() }
      }
    }
  }
#endif
